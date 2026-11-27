extends Node

signal case_loaded(case_data)
signal time_updated(seconds_remaining)
signal time_expired

const SUSPECTS_MATRIX_PATH: String = "res://data/sospitosos_matrix.json"

var current_case_data: Dictionary = {}
var suspects_matrix: Array = []
var collected_clues: Array = []
var collected_objects: Array = []
var time_remaining: int = 0
var is_game_active: bool = false
var timer_node: Timer = null
var posicio_player = null

var resolucio_actual: Dictionary = {}
var partida_guanyada: bool = false
	
func _ready() -> void:			
	load_suspects_matrix(SUSPECTS_MATRIX_PATH)
	timer_node = Timer.new()
	timer_node.wait_time = 1.0 # S'executa cada 1 segon
	timer_node.one_shot = false
	timer_node.connect("timeout", self, "_on_Timer_timeout")
	add_child(timer_node) 


func _on_Timer_timeout() -> void:
	if not is_game_active:
		return
		
	if time_remaining > 0:
		time_remaining -= 1
		if time_remaining <= 0:
			time_remaining = 0
			is_game_active = false
			timer_node.stop()
			emit_signal("time_expired")
			
			
func iniciar_temps(segons: float) -> void:
	time_remaining = int(segons)
	is_game_active = true
	timer_node.start()

func comprovar_acusacio(sospitos_id_triat: String, lloc_triat: String) -> bool:
	var culpable_real = resolucio_actual.get("culpable_id", "")
	var lloc_real = resolucio_actual.get("lloc_ocultacio", "")
	
	partida_guanyada = (sospitos_id_triat == culpable_real) and (lloc_triat == lloc_real)
	return partida_guanyada


func pausar_temps() -> void:
	is_game_active = false

func reanudar_temps() -> void:
	if time_remaining > 0.0:
		is_game_active = true

func obtir_temps() -> String:
	var total_segons: int = int(ceil(time_remaining))
	var minuts: int = total_segons / 60
	var segons: int = total_segons % 60
	return "%02d:%02d" % [minuts, segons]
	
func comprobar_objecte_disponible(objecte: String) -> bool:
	for i in range(collected_objects.size()):
		if objecte == collected_objects[i]:
			return true
	return false
	
func load_suspects_matrix(file_path: String) -> bool:
	var file: File = File.new()
	if not file.file_exists(file_path):
		printerr("CaseManager: La matriu de sospitosos no es trova a: ", file_path)
		return false
	
	if file.open(file_path, File.READ) != OK:
		printerr("CaseManager: Error en obrir la matriu de sospitosos.")
		return false
	
	var json_text: String = file.get_as_text()
	file.close()
	
	var parse_res: JSONParseResult = JSON.parse(json_text)
	if parse_res.error == OK and parse_res.result is Dictionary:
		suspects_matrix = parse_res.result.get("sospitosos", [])
		print("CaseManager: Matriu de ", suspects_matrix.size(), " sospitosos carregada.")
		return true
	
	printerr("CaseManager: Error parsejant la matriu de sospitosos.")
	return false


func load_case_from_json_string(json_string: String) -> bool:
	var parse_result: JSONParseResult = JSON.parse(json_string)
	
	if parse_result.error != OK:
		printerr("CaseManager: Error parsejant JSON a la línia ", parse_result.error_line, ": ", parse_result.error_string)
		return false
	
	if not (parse_result.result is Dictionary):
		printerr("CaseManager: El JSON rebut no és un Diccionari vàlid.")
		return false

	current_case_data = parse_result.result
	resolucio_actual = current_case_data.get("resolucio", {})
	collected_clues.clear()
	
	# Extraer metadatos y tiempo límite (por defecto 300s = 5 min)
	var metadatos: Dictionary = current_case_data.get("metadatos", {})
	time_remaining = metadatos.get("temps_limit_segons", 300)
	
	is_game_active = true
	
	emit_signal("case_loaded", current_case_data)
	emit_signal("time_updated", time_remaining)
	
	var titulo_mision = current_case_data.get("missio", {}).get("titol", "Missió sense titol")
	print("CaseManager: Cas '", titulo_mision, "' carregat amb exit.")
	return true

func tornar_al_menu():
	get_tree().paused = false
	CaseManager.is_game_active = false
	get_tree().change_scene("res://levels/menu/menu.tscn")


func get_nom_sospitos_per_id(id_buscat: String) -> String:
	for sospitos in suspects_matrix:
		if sospitos.get("id", "") == id_buscat:
			return sospitos.get("nom", "Desconegut")
	return "Desconegut"
	
# Carga una misión desde un archivo .json local (p. ej., res://data/misiones/mision_01.json)
func load_case_from_file(file_path: String) -> bool:
	var file: File = File.new()
	if not file.file_exists(file_path):
		printerr("CaseManager: EL'arxiu de missió no existeix: ", file_path)
		return false
	
	if file.open(file_path, File.READ) != OK:
		printerr("CaseManager: No s'ha pogut obrir el fitxer de missió: ", file_path)
		return false
	
	var json_text: String = file.get_as_text()
	file.close()
	
	return load_case_from_json_string(json_text)


# Devuelve la lista completa de sospechosos cargados
func get_all_suspects() -> Array:
	return suspects_matrix
