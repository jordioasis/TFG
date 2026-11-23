extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for item in CaseManager.collected_clues:
		var nova_label_pista := Label.new()
		nova_label_pista.text = str(item)
		nova_label_pista.autowrap = true # Opcional: hace salto de línea automático si el texto es largo
		add_child(nova_label_pista)		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
