extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var player_life: int = 6
var is_ghost = false
var is_transforming = false

@onready var player_health: Node2D = $PlayerLife
@onready var game_manager: Node = %gameManager
@onready var timer: Timer = $"../gameManager/Timer"

func _physics_process(delta: float) -> void:
	if is_transforming:
		return  # skip movement during transformation

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

	# Handle transform input
	if Input.is_action_just_pressed("transform") and not is_transforming:
		await start_transform()

	move_and_slide()

# -- TRANSFORMATION LOGIC --
func start_transform() -> void:
	is_transforming = true
	velocity = Vector2.ZERO

	if not is_ghost:
		# Transform into ghost
		$AnimatedSprite2D.play("transform")
		await get_tree().create_timer(.8).timeout
		$AnimatedSprite2D.play("ghostidle")
		is_ghost = true
	else:
		# Transform back to normal
		$AnimatedSprite2D.play("untransform")  # <- Create this anim if needed
		await get_tree().create_timer(.8).timeout
		$AnimatedSprite2D.play("idle")
		is_ghost = false

	is_transforming = false
