extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("sospitosos"):
		CaseManager.reanudar_temps()
		get_tree().paused = false
		get_parent().queue_free() # Elimina el CanvasLayer (CapaLibreta) 
