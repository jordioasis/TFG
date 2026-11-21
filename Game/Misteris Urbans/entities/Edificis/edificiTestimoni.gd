extends StaticBody2D


# Declare member variables here. Examples:
var nomTestimoni = "Name"
var pista = "Clue text"
var objecte = "res"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AreaEntrada_body_entered(object):
	if object.is_in_group("player"):
		var parent = get_parent()
		parent.get_parent().setWitnessName(nomTestimoni)
		parent.get_parent().setClue(pista)
		parent.get_parent().muestraTexto()



func _on_AreaEntrada_body_exited(body):
	if body.is_in_group("player"):
		var parent = get_parent()
		parent.get_parent().ocultaTexto()
