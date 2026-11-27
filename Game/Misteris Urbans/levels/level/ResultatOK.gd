extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var vbox = $ContainerPistes
	var resolucio: Dictionary = CaseManager.resolucio_actual
	
	var culpable_id: String = resolucio.get("culpable_id", "")
	var nom_culpable: String = CaseManager.get_nom_sospitos_per_id(culpable_id)
	var lloc: String = resolucio.get("lloc_ocultacio", "")
	

	var explicacio: String = resolucio.get("explicacio", "Sense explicació disponible.")
	
	# LABEL 1: Culpable i lloc
	var label_culpable := Label.new()
	label_culpable.text = "Culpable: " + nom_culpable + "\nLloc: " + lloc
	label_culpable.autowrap = true
	label_culpable.rect_min_size.x = 330
	label_culpable.add_color_override("font_color", Color.black)
	vbox.add_child(label_culpable)
	
	var espaiador := Control.new()
	espaiador.rect_min_size.y = 20
	vbox.add_child(espaiador)
	#  LABEL 2: Explicació
	var label_explicacio := Label.new()
	label_explicacio.text = explicacio
	label_explicacio.autowrap = true
	label_explicacio.rect_min_size.x = 330
	label_explicacio.add_color_override("font_color", Color.black)
	vbox.add_child(label_explicacio)
	
	vbox.add_child(espaiador.duplicate())
	#  LABEL 3: -Missatge user
	var label_next := Label.new()
	label_next.text = "Pulsa Enter per a següent missió.\nPulsa Esc per tornar al menú principal."
	label_next.autowrap = true
	label_next.rect_min_size.x = 330
	label_next.add_color_override("font_color", Color.black)
	vbox.add_child(label_next)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		tornar_al_menu()
	elif event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		carregar_missio_2()
	
func carregar_missio_2():
	get_tree().paused = false 
	waiting = true
	CaseManager.load_case_from_file("res://data/missions/missio_02.json")
	get_tree().change_scene("res://levels/level/level.tscn")

func tornar_al_menu():
	get_tree().paused = false
	CaseManager.is_game_active = false
	waiting = true
	get_tree().change_scene("res://levels/menu/menu.tscn")
