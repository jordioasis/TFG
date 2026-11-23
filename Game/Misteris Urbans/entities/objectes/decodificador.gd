extends Area2D

onready var so = $so
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		get_parent().visible = false
		var nodo = get_tree().current_scene.find_node("IconeDecoder", true, false)
		if nodo != null:
			nodo.visible = true
		so.play()
		CaseManager.collected_objects.append("OBJ-03")
		yield(get_tree().create_timer(0.5), "timeout")
		get_parent().queue_free()
