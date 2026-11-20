extends Node2D

var hud_scene = preload ("res://entities/HUD/Textbox.tscn")
var hud_instance = hud_scene.instance()
onready var mi_label = $CanvasLayer/Label

func _ready():
	add_child(hud_instance)
#	var hud_instance = hud_scene.instance()
#	add_child(hud_instance)
#	hud_instance.title = "hola titulo"
#	hud_instance.text = "hola texto"
	pass	

func muestraTexto():
	hud_instance.title = "hola titulo"
	hud_instance.text = "hola texto"
	hud_instance.show_textbox()

func ocultaTexto():
	hud_instance.hide_textbox()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



