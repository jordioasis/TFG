extends Node2D

var hud_scene = preload ("res://entities/HUD/Textbox.tscn")

func _ready():
	var hud_instance = hud_scene.instance()
	hud_instance.title = "hola titulo"
	hud_instance.text = "hola texto"



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
