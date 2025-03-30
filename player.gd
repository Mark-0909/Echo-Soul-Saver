extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
var player_life: int = 6
@onready var player_health: Node2D = $PlayerLife
@onready var game_manager: Node = %gameManager
@onready var timer: Timer = $"../gameManager/Timer"

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


func MinusHealth() -> void:
	player_life -= 1

	if player_life > 0:
		match player_life:
			6: $PlayerLife/AnimatedSprite2D.play("6life")
			5: $PlayerLife/AnimatedSprite2D.play("5life")
			4: $PlayerLife/AnimatedSprite2D.play("4life")
			3: $PlayerLife/AnimatedSprite2D.play("3life")
			2: $PlayerLife/AnimatedSprite2D.play("2life")
			1: $PlayerLife/AnimatedSprite2D.play("1life")
	else:
		timer.wait_time = 0.01  # Set the timer to 0.2 seconds
		timer.start()  # Start the timer with the new duration
		if game_manager.has_method("on_player_death"):
			game_manager.on_player_death()
 

	
