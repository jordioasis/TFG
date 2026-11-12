# ==============================================================================
# CaseManager.gd (Godot Engine 3.6 LTS)
# Script Singleton / Autoload para la gestión global del estado del caso y parseo JSON.
# ==============================================================================
extends Node

# Señales globales para sincronizar la interfaz de usuario (HUD, Diálogos, Acusación)
signal case_loaded(case_data)
signal clue_added(clue_data)
signal time_updated(seconds_remaining)
signal case_resolved(is_success, explanation)
signal game_over(reason)

# Estado global de la partida
var current_case_data: Dictionary = {}
var collected_clues: Array = []
var time_remaining: int = 0
var is_game_active: bool = false
var timer_node: Timer = null


func _ready() -> void:
	# Inicializar el nodo Timer para el temporizador regresivo de la partida
	timer_node = Timer.new()
	timer_node.wait_time = 1.0
	timer_node.one_shot = false
	timer_node.connect("timeout", self, "_on_timer_timeout")
	add_child(timer_node)


# ------------------------------------------------------------------------------
# 1. CARGA Y PARSEO DEL CASO (JSON)
# ------------------------------------------------------------------------------

# Carga y parsea una cadena JSON (procedente de la API REST en Python o de un archivo local)
func load_case_from_json_string(json_string: String) -> bool:
	var parse_result: JSONParseResult = JSON.parse(json_string)
	
	if parse_result.error != OK:
		printerr("CaseManager: Error parseando JSON en la línea ", parse_result.error_line, ": ", parse_result.error_string)
		return false
	
	if not (parse_result.result is Dictionary):
		printerr("CaseManager: El JSON parseado no es un Diccionario válido.")
		return false

	current_case_data = parse_result.result
	collected_clues.clear()
	
	# Extraer metadatos de configuración
	var metadatos: Dictionary = current_case_data.get("metadatos", {})
	time_remaining = metadatos.get("tiempo_limite_segundos", 300)
	
	is_game_active = true
	timer_node.start()
	
	emit_signal("case_loaded", current_case_data)
	emit_signal("time_updated", time_remaining)
	print("CaseManager: Caso '", current_case_data.get("misterio", {}).get("titulo", "Sin título"), "' cargado correctamente.")
	return true


# Carga un caso desde un archivo .json local (p. ej., res://data/cases_preset.json)
func load_case_from_file(file_path: String) -> bool:
	var file: File = File.new()
	if not file.file_exists(file_path):
		printerr("CaseManager: El archivo no existe en la ruta: ", file_path)
		return false
	
	var err = file.open(file_path, File.READ)
	if err != OK:
		printerr("CaseManager: No se pudo abrir el archivo. Error código: ", err)
		return false
	
	var json_text: String = file.get_as_text()
	file.close()
	
	return load_case_from_json_string(json_text)


# ------------------------------------------------------------------------------
# 2. GESTIÓN DE PISTAS Y LIBRETA
# ------------------------------------------------------------------------------

# Añade una pista a la libreta si no ha sido recogida previamente
func add_clue(clue_data: Dictionary) -> void:
	var clue_id = clue_data.get("id_pista", "")
	for existing_clue in collected_clues:
		if existing_clue.get("id_pista", "") == clue_id:
			print("CaseManager: La pista ", clue_id, " ya está registrada en la libreta.")
			return
	
	collected_clues.append(clue_data)
	emit_signal("clue_added", clue_data)
	print("CaseManager: Pista añadida a la libreta: ", clue_data.get("texto_dialogo", ""))


# Comprueba si el jugador ya posee una pista específica por su ID
func has_clue(clue_id: String) -> bool:
	for clue in collected_clues:
		if clue.get("id_pista", "") == clue_id:
			return true
	return false


# Devuelve el listado completo de pistas recogidas
func get_collected_clues() -> Array:
	return collected_clues


# ------------------------------------------------------------------------------
# 3. LÓGICA DE RESOLUCIÓN Y TEMPORIZADOR
# ------------------------------------------------------------------------------

# Realiza la acusación formal comparando el ID del sospechoso con el culpable del JSON
func check_accusation(suspect_id: String) -> bool:
	if not is_game_active:
		return false
	
	var resolucion: Dictionary = current_case_data.get("resolucion", {})
	var culpable_id: String = resolucion.get("culpable_id", "")
	var explicacion: String = resolucion.get("explicacion_resolucion", "")
	
	var is_correct: bool = (suspect_id == culpable_id)
	is_game_active = false
	timer_node.stop()
	
	emit_signal("case_resolved", is_correct, explicacion)
	return is_correct


# Bucle del temporizador (se ejecuta cada segundo)
func _on_timer_timeout() -> void:
	if not is_game_active:
		return
	
	time_remaining -= 1
	emit_signal("time_updated", time_remaining)
	
	if time_remaining <= 0:
		is_game_active = false
		timer_node.stop()
		emit_signal("game_over", "¡Tiempo agotado! El culpable ha escapado de la ciudad.")
