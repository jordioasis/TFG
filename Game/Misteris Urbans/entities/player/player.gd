extends KinematicBody2D

const MOVE_SPEED = 100

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree =$AnimationTree
onready var animationState = animationTree.get("parameters/playback")


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/idle/blend_position", input_vector)
		animationTree.set("parameters/caminar/blend_position", input_vector)
		animationState.travel("caminar")
		velocity = input_vector * MOVE_SPEED
	else:
		animationState.travel("idle")
		velocity = Vector2.ZERO
		
	move_and_collide(velocity * delta)
	

