extends CanvasLayer

var level = preload ("res://levels/level/level.tscn")
onready var http_request = $HTTPRequest
onready var boto_aleatoria =$VBoxContainer/btnAleatoria

const URL_SERVIDOR = "http://localhost:8000/api/missio" 


func _ready() -> void:	
	pass


func _on_btnJugar_pressed():
	CaseManager.load_case_from_file("res://data/missions/missio_01.json")
	get_tree().change_scene("res://levels/level/level.tscn")


func _on_btnAleatoria_pressed():
	# Desactivamos el botón mientras carga para evitar dobles clics
	boto_aleatoria.disabled = true
	boto_aleatoria.text = "Carregant cas..."
	
	# Hacemos la petición GET

	var error = http_request.request(URL_SERVIDOR)

	if error != OK:
		printerr("Error al iniciar la petició HTTP: ", error)
		boto_aleatoria.disabled = false
		boto_aleatoria.text = "Tornar a intentar"


func _on_btnSortir_pressed():
	get_tree().quit()


func _on_HTTPRequest_request_completed(result: int, response_code: int, _headers: PoolStringArray, body: PoolByteArray):
	boto_aleatoria.disabled = false
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		printerr("Error del servidor. Result: ", result, " | Codi HTTP: ", response_code)
		boto_aleatoria.text = "Error de connexió"
		return
	

	var json_string: String = body.get_string_from_utf8()
	print("TEXT REBUT DEL SERVIDOR: '", json_string.left(200), "'") 

	var carrega_correcta: bool = CaseManager.load_case_from_json_string(json_string)
	
	if carrega_correcta:
		get_tree().change_scene("res://levels/level/Level.tscn")
	else:
		boto_aleatoria.text = "Error en les dades del cas"
