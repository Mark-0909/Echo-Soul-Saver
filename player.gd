extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")

	if is_on_floor():
		if velocity.x == 0:
			$AnimatedSprite2D.play("idle")
		elif velocity.x != 0:
			$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("jump")

	var mouse_x = get_global_mouse_position().x
	var player_x = global_position.x
	
	if abs(direction) > 0:  
		$AnimatedSprite2D.flip_h = direction > 0  
	else:  
		$AnimatedSprite2D.flip_h = mouse_x > player_x  

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
