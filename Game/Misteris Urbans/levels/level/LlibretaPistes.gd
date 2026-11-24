extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for item in CaseManager.collected_clues:
		var nova_label_pista := Label.new()
		nova_label_pista.text = str(item)
		nova_label_pista.autowrap = true
		nova_label_pista.rect_min_size.x = 330
		nova_label_pista.add_color_override("font_color", Color.black)
		add_child(nova_label_pista)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("obrir_llibreta"):
		CaseManager.reanudar_temps()
		get_tree().paused = false
		get_parent().queue_free() # Elimina el CanvasLayer (CapaLibreta) 
