extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var esta_desactivado = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("sospitosos"):
		CaseManager.reanudar_temps()
		get_tree().paused = false
		get_parent().queue_free() # Elimina el CanvasLayer (CapaLibreta) 




func _on_TextureRect_gui_input(event):
# Detecta clic izquierdo del ratón (o toque en pantalla)
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		alternar_estado()

func alternar_estado():
	esta_desactivado = !esta_desactivado
	
	if esta_desactivado:
		# Aplica un tinte gris oscuro y baja la opacidad al 50%
		$Containersospitosos/SospitososFila1/Fitxa/TextureRect.modulate = Color(0.5, 0.5, 0.5, 0.5)
	else:
		# Restaura los colores originales de la textura
		$Containersospitosos/SospitososFila1/Fitxa/TextureRect.modulate = Color(1, 1, 1, 1)
