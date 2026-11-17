extends CanvasLayer

onready var textbox_container = $TextboxContainer
onready var title = $TextboxContainer/MarginContainer/HBoxContainer/Title
onready var text = $TextboxContainer/MarginContainer/HBoxContainer/Text


func _ready():
	pass

func hide_textbox():
	title.text = ""
	text.text = ""
	textbox_container.hide()
	
func show_textbox():
	textbox_container.visible = true
	
func add_text(next_text):
	text.text = next_text

func add_title(next_title):
	title.text = next_title
