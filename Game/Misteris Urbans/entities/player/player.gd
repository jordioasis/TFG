extends KinematicBody2D

const MOVE_SPEED = 150.0
const SCREEN_WIDTH = 640
const SCREEN_HEIGHT = 360



func _process(delta):
	var input_dir = Vector2()
	if Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1.0
		$AnimationPlayer.play("caminar_up")
	elif Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1.0
		$AnimationPlayer.play("caminar_down")
	elif Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1.0
		$AnimationPlayer.play("caminar_left")
	elif Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1.0
		$AnimationPlayer.play("caminar_right")
	else:
		$AnimationPlayer.play("idle_front")
		
	if position.x < 0.0:
	 position.x = 0.0
	elif position.x > SCREEN_WIDTH:
	 position.x = SCREEN_WIDTH
	if position.y < 0.0:
	 position.y = 0.0
	elif position.y > SCREEN_HEIGHT:
	 position.y = SCREEN_HEIGHT
	
	position += (delta * MOVE_SPEED) * input_dir
	
	

