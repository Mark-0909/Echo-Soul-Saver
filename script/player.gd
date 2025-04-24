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

	# Apply gravity only when not ghost
	if not is_ghost and not is_on_floor():
		velocity += get_gravity() * delta
	elif is_ghost:
		velocity.y = 0  # reset vertical velocity for full control

	# Handle jump (only if not ghost)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_ghost:
		velocity.y = JUMP_VELOCITY

	var direction_x := Input.get_axis("left", "right")
	var direction_y: float = Input.get_axis("jump", "down") if is_ghost else 0.0



	# Animations
	if direction_x == 0 and direction_y == 0:
		$AnimatedSprite2D.play("ghostidle" if is_ghost else "idle")
	else:
		if is_ghost:
			$AnimatedSprite2D.play("ghostwalk")
		elif is_on_floor():
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("jump")

	# Flip sprite horizontally
	var mouse_x = get_global_mouse_position().x
	var player_x = global_position.x
	if abs(direction_x) > 0:
		$AnimatedSprite2D.flip_h = direction_x > 0
	else:
		$AnimatedSprite2D.flip_h = mouse_x > player_x

	# Apply movement
	if is_ghost:
		velocity.x = direction_x * SPEED
		velocity.y = direction_y * SPEED
	else:
		# regular player mode
		velocity.x = direction_x * SPEED if direction_x else move_toward(velocity.x, 0, SPEED)

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
		await get_tree().create_timer(.7).timeout
		$AnimatedSprite2D.play("ghostidle")
		is_ghost = true
	else:
		# Transform back to normal
		$AnimatedSprite2D.play("untransform")  # <- Create this anim if needed
		await get_tree().create_timer(.7).timeout
		$AnimatedSprite2D.play("idle")
		is_ghost = false

	is_transforming = false
