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


#	var pistes: Array = CaseManager.get_collected_clues()
#
#	for entrada in pistes:
#		var nom_testimoni: String = entrada.get("testimoni", "Testimoni desconegut")
#		var text_pista: String = entrada.get("text", "")
#
#		var label_pista := Label.new()
#		label_pista.text = nom_testimoni.to_upper() + ": " + text_pista
#		label_pista.autowrap = true
#		label_pista.rect_min_size.x = 330
#		label_pista.add_color_override("font_color", Color.black)
#
#		# Afegeix-la al teu VBoxContainer de la llibreta
#		add_child(label_pista)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("obrir_llibreta"):
		CaseManager.reanudar_temps()
		get_tree().paused = false
		get_parent().queue_free() # Elimina el CanvasLayer (CapaLibreta) 
