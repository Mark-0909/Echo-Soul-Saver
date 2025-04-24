extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var player_life: int = 6
@export var is_ghost: bool = false
var is_transforming: bool = false

@onready var player_health: Node2D = $PlayerLife
@onready var game_manager: Node = %gameManager
@onready var timer: Timer = $"../gameManager/Timer"
@onready var Health_drain: Timer = $Timer
@onready var terrain: TileMapLayer = $"../terrain"

const TERRAIN = preload("res://shader/terrain.gdshader")

var ghost_origin: Vector2 = Vector2(0, 0)  # Starting at player's position
var target_ghost_origin: Vector2 = Vector2(0, 0)  # Target position for ghost effect
const spread_radius = 200.0

func _ready() -> void:
	if is_ghost:
		Health_drain.start()
	target_ghost_origin = global_position  # Initialize target_ghost_origin with the player's position

	# Ensure shader parameters are updated
	terrain.material.set_shader_parameter("is_ghost", is_ghost)
	terrain.material.set_shader_parameter("ghost_origin", ghost_origin)
	terrain.material.set_shader_parameter("spread_radius", spread_radius)

func _physics_process(delta: float) -> void:
	if is_transforming:
		return

	if not is_ghost and not is_on_floor():
		velocity += get_gravity() * delta
	elif is_ghost:
		velocity.y = 0

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
		velocity.x = direction_x * SPEED if direction_x != 0 else move_toward(velocity.x, 0, SPEED)

	# Check for transform button press and trigger transformation
	if Input.is_action_just_pressed("transform") and not is_transforming:
		print("Transform button pressed!")  # Debug print
		await start_transform()

	# Update ghost_origin smoothly (use a larger interpolation factor)
	if is_ghost:
		ghost_origin = ghost_origin.lerp(target_ghost_origin, 0.1)  # Adjust this for a more noticeable effect

		# Update the shader parameter for ghost_origin
		terrain.material.set_shader_parameter("ghost_origin", ghost_origin)

	move_and_slide()

func PlusHealth() -> void:
	if player_life >= 6:
		return
	player_life += 1 if player_life == 5 else 2
	PlayerState()

func MinusHealth() -> void:
	player_life -= 1
	PlayerState()

func PlayerState() -> void:
	print(player_life)
	if player_life > 0:
		match player_life:
			6: $PlayerLife/AnimatedSprite2D.play("default")
			5: $PlayerLife/AnimatedSprite2D.play("5life")
			4: $PlayerLife/AnimatedSprite2D.play("4life")
			3: $PlayerLife/AnimatedSprite2D.play("3life")
			2: $PlayerLife/AnimatedSprite2D.play("2life")
			1: $PlayerLife/AnimatedSprite2D.play("1life")
	else:
		timer.wait_time = 0.01
		timer.start()
		if game_manager.has_method("on_player_death"):
			game_manager.on_player_death()

func start_transform() -> void:
	is_transforming = true
	velocity = Vector2.ZERO

	if not is_ghost:
		$AnimatedSprite2D.play("transform")
		await get_tree().create_timer(0.7).timeout
		$AnimatedSprite2D.play("ghostidle")
		is_ghost = true
		Health_drain.start()
	else:
		$AnimatedSprite2D.play("untransform")
		await get_tree().create_timer(0.7).timeout
		$AnimatedSprite2D.play("idle")
		is_ghost = false
		Health_drain.stop()

	# Ensure shader parameters are updated
	terrain.material.set_shader_parameter("is_ghost", is_ghost)
	terrain.material.set_shader_parameter("spread_radius", spread_radius)

	print("is_ghost: ", is_ghost)
	print("ghost_origin: ", global_position)

	is_transforming = false

func _on_timer_timeout() -> void:
	if is_ghost:
		MinusHealth()
		Health_drain.start()
