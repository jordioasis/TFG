# ==============================================================================
# WitnessNPC.gd (Godot Engine 3.6 LTS)
# Script para controlar a los Testigos / NPCs interactivos en el escenario 2D.
# Hereda de Area2D para detectar la proximidad del jugador.
# ==============================================================================
extends Area2D

# Señales locales
signal player_interacted(witness_data)

# Propiedades del testigo cargadas desde el JSON
var witness_id: String = ""
var witness_name: String = ""
var is_liar: bool = false
var testimony_data: Dictionary = {}

# Estado de interacción
var is_player_nearby: bool = false
var has_talked: bool = false

# Referencias a nodos hijos (ajustar nombres según tu escena WitnessNPC.tscn)
onready var interaction_prompt: Node2D = get_node_or_null("InteractionPrompt")
onready var animated_sprite: AnimatedSprite = get_node_or_null("AnimatedSprite")


func _ready() -> void:
	# Conectar señales nativas de Area2D para la detección del jugador
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
	# Ocultar el indicador visual de interacción al inicio
	if interaction_prompt:
		interaction_prompt.visible = false


# Inicializa los datos del testigo a partir de la estructura del JSON del caso
func setup_witness(data: Dictionary) -> void:
	witness_id = data.get("id", "")
	witness_name = data.get("nombre", "")
	is_liar = data.get("mentiroso", false)
	testimony_data = data.get("testimonio", {})
	
	# Si la posición en el mapa viene indicada en el JSON, posicionar el nodo
	var pos_dict = data.get("posicion_escena", {})
	if pos_dict.has("x") and pos_dict.has("y"):
		position = Vector2(pos_dict.x, pos_dict.y)


func _unhandled_input(event: InputEvent) -> void:
	# Detectar la pulsación de la tecla de interacción ("ui_accept" o tecla "E")
	if is_player_nearby and event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		interact()


# Ejecuta la interacción principal con el jugador
func interact() -> void:
	if testimony_data.is_empty():
		print("WitnessNPC: Este testigo no tiene testimonio asignado.")
		return
	
	# Registrar la pista de forma global en el CaseManager (Autoload)
	CaseManager.add_clue(testimony_data)
	has_talked = true
	
	# Emitir señal local para que el sistema de Diálogo/UI muestre el texto
	emit_signal("player_interacted", {
		"id": witness_id,
		"nombre": witness_name,
		"testimonio": testimony_data
	})
	
	print("WitnessNPC: Interacción completada con ", witness_name)


# ------------------------------------------------------------------------------
# DETECCIÓN DE PROXIMIDAD (SEÑALES NATIVAS DE AREA2D)
# ------------------------------------------------------------------------------

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_nearby = true
		if interaction_prompt:
			interaction_prompt.visible = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_nearby = false
		if interaction_prompt:
			interaction_prompt.visible = false
