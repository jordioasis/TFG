# ==============================================================================
# CaseManager.gd (Godot Engine 3.6 LTS)
# Script Singleton / Autoload para la gestión global del estado del caso,
# la matriz de 12 sospechosos, las pistas y la resolución (Quién + Dónde).
# ==============================================================================
extends Node

# Señales globales para la interfaz de usuario (HUD, Diálogos, Libreta, Acusación)
signal case_loaded(case_data)
signal clue_added(clue_data)
signal time_updated(seconds_remaining)
signal case_resolved(is_success, explanation)
signal game_over(reason)

# Ruta por defecto de la matriz global de 12 sospechosos
const SUSPECTS_MATRIX_PATH: String = "res://data/sospechosos_matrix.json"

# Estado global de la partida
var current_case_data: Dictionary = {}
var suspects_matrix: Array = []
var collected_clues: Array = []
var time_remaining: int = 0
var is_game_active: bool = false
var timer_node: Timer = null


func _ready() -> void:
	# 1. Configurar e inicializar el temporizador regresivo
	timer_node = Timer.new()
	timer_node.wait_time = 1.0
	timer_node.one_shot = false
	timer_node.connect("timeout", self, "_on_timer_timeout")
	add_child(timer_node)
	
	# 2. Cargar la matriz global de sospechosos al iniciar el juego
	load_suspects_matrix(SUSPECTS_MATRIX_PATH)


# ------------------------------------------------------------------------------
# 1. CARGA DE LA MATRIZ DE SOSPECHOSOS Y CASOS (JSON)
# ------------------------------------------------------------------------------

# Carga el archivo global con los 12 sospechosos y sus 4 características
func load_suspects_matrix(file_path: String) -> bool:
	var file: File = File.new()
	if not file.file_exists(file_path):
		printerr("CaseManager: Matriz de sospechosos no encontrada en ", file_path)
		return false
	
	if file.open(file_path, File.READ) != OK:
		printerr("CaseManager: Error al abrir la matriz de sospechosos.")
		return false
	
	var json_text: String = file.get_as_text()
	file.close()
	
	var parse_res: JSONParseResult = JSON.parse(json_text)
	if parse_res.error == OK and parse_res.result is Dictionary:
		suspects_matrix = parse_res.result.get("sospechosos", [])
		print("CaseManager: Matriz de ", suspects_matrix.size(), " sospechosos cargada.")
		return true
	
	printerr("CaseManager: Error parseando la matriz de sospechosos.")
	return false


# Carga y parsea el JSON de la misión (desde la API REST en Python o cadena local)
func load_case_from_json_string(json_string: String) -> bool:
	var parse_result: JSONParseResult = JSON.parse(json_string)
	
	if parse_result.error != OK:
		printerr("CaseManager: Error parseando JSON en la línea ", parse_result.error_line, ": ", parse_result.error_string)
		return false
	
	if not (parse_result.result is Dictionary):
		printerr("CaseManager: El JSON recibido no es un Diccionario válido.")
		return false

	current_case_data = parse_result.result
	collected_clues.clear()
	
	# Reiniciar inventario de objetos en la partida si existe InventoryManager
	if Engine.has_singleton("InventoryManager") or get_node_or_null("/root/InventoryManager"):
		get_node("/root/InventoryManager").clear_inventory()
	
	# Extraer metadatos y tiempo límite (por defecto 300s = 5 min)
	var metadatos: Dictionary = current_case_data.get("metadatos", {})
	time_remaining = metadatos.get("tiempo_limite_segundos", 300)
	
	is_game_active = true
	timer_node.start()
	
	emit_signal("case_loaded", current_case_data)
	emit_signal("time_updated", time_remaining)
	
	var titulo_mision = current_case_data.get("mision", {}).get("titulo", "Misión sin título")
	print("CaseManager: Caso '", titulo_mision, "' cargado con éxito.")
	return true


# Carga una misión desde un archivo .json local (p. ej., res://data/misiones/mision_01.json)
func load_case_from_file(file_path: String) -> bool:
	var file: File = File.new()
	if not file.file_exists(file_path):
		printerr("CaseManager: El archivo de misión no existe: ", file_path)
		return false
	
	if file.open(file_path, File.READ) != OK:
		printerr("CaseManager: No se pudo abrir el archivo de misión: ", file_path)
		return false
	
	var json_text: String = file.get_as_text()
	file.close()
	
	return load_case_from_json_string(json_text)


# ------------------------------------------------------------------------------
# 2. GESTIÓN DE PISTAS Y LIBRETA DE DEDUCCIÓN
# ------------------------------------------------------------------------------

# Registra una pista en la libreta si no ha sido descubierta previamente
func add_clue(clue_data: Dictionary) -> void:
	var clue_id = clue_data.get("id_pista", clue_data.get("texto", ""))
	
	for existing_clue in collected_clues:
		var existing_id = existing_clue.get("id_pista", existing_clue.get("texto", ""))
		if existing_id == clue_id:
			print("CaseManager: La pista ya está en la libreta.")
			return
	
	collected_clues.append(clue_data)
	emit_signal("clue_added", clue_data)
	print("CaseManager: Nueva pista añadida a la libreta.")


# Devuelve la lista completa de sospechosos cargados
func get_all_suspects() -> Array:
	return suspects_matrix


# Devuelve las pistas obtenidas hasta el momento
func get_collected_clues() -> Array:
	return collected_clues


# ------------------------------------------------------------------------------
# 3. LÓGICA DE RESOLUCIÓN (DOBLE ACUSACIÓN: QUIÉN + DÓNDE) Y TEMPORIZADOR
# ------------------------------------------------------------------------------

# Valida el formulario de acusación formal comparando Sospechoso + Sector
func submit_accusation(selected_suspect_id: String, selected_location: String) -> bool:
	if not is_game_active:
		return false
	
	var resolucion: Dictionary = current_case_data.get("resolucion", {})
	var correct_suspect: String = resolucion.get("culpable_id", "")
	var correct_location: String = resolucion.get("lugar_ocultacion", "")
	var explicacion: String = resolucion.get("explicacion", "")
	
	# La acusación debe acertar tanto el ID del sospechoso como la ubicación (Norte, Sur, Este, Oeste)
	var is_success: bool = (selected_suspect_id == correct_suspect) and (selected_location == correct_location)
	
	is_game_active = false
	timer_node.stop()
	
	emit_signal("case_resolved", is_success, explicacion)
	return is_success


# Bucle de actualización del temporizador cada segundo
func _on_timer_timeout() -> void:
	if not is_game_active:
		return
	
	time_remaining -= 1
	emit_signal("time_updated", time_remaining)
	
	if time_remaining <= 0:
		is_game_active = false
		timer_node.stop()
		emit_signal("game_over", "¡Tiempo agotado! El culpable ha escapado de la ciudad.")
