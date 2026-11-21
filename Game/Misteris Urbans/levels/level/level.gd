extends Node2D

var hud_scene = preload ("res://entities/HUD/Textbox.tscn")
var hud_instance = hud_scene.instance()

var lupa_scene = preload("res://entities/objectes/lupa.tscn")
var lupa_instance = lupa_scene.instance()

var ulleres_scene = preload("res://entities/objectes/ulleres.tscn")
var ulleres_instance = ulleres_scene.instance()

var decodificador_scene = preload("res://entities/objectes/decodificador.tscn")
var decodificador_instance = decodificador_scene.instance()

onready var mi_label = $CanvasLayer/Label

func _ready():
	add_child(hud_instance)
	assignar_testimonis_edificis()
	assignar_objectes_posicions()

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



