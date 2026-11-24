extends Node2D

var hud_scene = preload ("res://entities/HUD/Textbox.tscn")
var hud_instance = hud_scene.instance()

var lupa_scene = preload("res://entities/objectes/lupa.tscn")
var lupa_instance = lupa_scene.instance()

var ulleres_scene = preload("res://entities/objectes/ulleres.tscn")
var ulleres_instance = ulleres_scene.instance()

var decodificador_scene = preload("res://entities/objectes/decodificador.tscn")
var decodificador_instance = decodificador_scene.instance()

onready var llibretaPistes = preload ("res://levels/level/LlistaPistes.tscn")
onready var sospitosos = preload ("res://levels/level/PantallaSospitosos.tscn")

onready var mi_label = $CanvasSuperior/BarraSuperior/Marge/ContenedorHoritzontal/LabelTemps

onready var esperant_inici = true

func _ready():
	add_child(hud_instance)
	assignar_testimonis_edificis()
	assignar_objectes_posicions()
	hud_instance.add_title(CaseManager.current_case_data.get("missio", {}).get("titol", "Missió sense titol"))
	hud_instance.add_text(CaseManager.current_case_data.get("missio", {}).get("descripcio", "Missió sense descripcio"))
	hud_instance.show_textbox()


func iniciar_partida():
	hud_instance.hide_textbox()
	CaseManager.iniciar_temps(300)

func _process(_delta: float) -> void:
	if esperant_inici and Input.is_action_just_pressed("ui_accept"):
		esperant_inici = false
		iniciar_partida()
	mi_label.text = CaseManager.obtir_temps()
	if !esperant_inici and Input.is_action_just_pressed("obrir_llibreta"):
		obrir_llibreta()
	if !esperant_inici and Input.is_action_just_pressed("sospitosos"):
		obrir_sospitosos()

func obrir_llibreta():
	CaseManager.pausar_temps()
	var llibreta = llibretaPistes.instance()

	var capa_ui = CanvasLayer.new()
	capa_ui.name = "CapaLlibreta"
	capa_ui.layer = 10 # Assegurem que quedi a sobre de tot
	get_tree().current_scene.add_child(capa_ui)
	capa_ui.add_child(llibreta)
	
	get_tree().paused = true

func obrir_sospitosos():
	CaseManager.pausar_temps()
	var sospitosos_ui = sospitosos.instance()

	var capa_ui = CanvasLayer.new()
	capa_ui.name = "CapaSospitosos"
	capa_ui.layer = 10 # Assegurem que quedi a sobre de tot
	get_tree().current_scene.add_child(capa_ui)
	capa_ui.add_child(sospitosos_ui)
	
	get_tree().paused = true


func assignar_testimonis_edificis():
	var edificis: Array = get_tree().get_nodes_in_group("testimoni")
	var testimonis_json: Array = CaseManager.current_case_data.get("testimonis", []).duplicate()
	randomize()
	testimonis_json.shuffle()
	
	var limit: int = int(min(edificis.size(), testimonis_json.size()))
	for i in range(limit):
		var edifici = edificis[i]
		var dades_testimoni: Dictionary = testimonis_json[i]
		edifici.nomTestimoni = dades_testimoni.get("nom")
		edifici.pista = dades_testimoni.get("pista").get("text")
		edifici.missatge_sense_objecte = dades_testimoni.get("missatge_sense_objecte")
		edifici.objecte = str(dades_testimoni.get("objecte_requerit_id"))

func assignar_objectes_posicions():
	var posicions: Array = get_tree().get_nodes_in_group("objecte_spawn")
	randomize()
	posicions.shuffle()
	lupa_instance.position = posicions[1].position
	ulleres_instance.position = posicions[2].position
	decodificador_instance.position = posicions[3].position
	
	add_child(lupa_instance)	
	add_child(ulleres_instance)
	add_child(decodificador_instance)
		
func setWitnessName(witnessName):
	hud_instance.add_title(witnessName)
	
func setClue(clue):
	hud_instance.add_text(clue)

func muestraTexto():
	hud_instance.show_textbox()

func ocultaTexto():
	hud_instance.hide_textbox()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



