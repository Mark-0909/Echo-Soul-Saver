extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var player_life: int = 6
var is_ghost: bool = false
var is_transforming: bool = false

@onready var player_health: Node2D = $PlayerLife
@onready var game_manager: Node = %gameManager
@onready var timer: Timer = $"../gameManager/Timer"
@onready var Health_drain: Timer = $Timer

func _ready() -> void:
	if is_ghost:
		Health_drain.start()

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
		velocity.x = direction_x * SPEED if direction_x != 0 else move_toward(velocity.x, 0, SPEED)

	# Handle transform input
	if Input.is_action_just_pressed("transform") and not is_transforming:
		await start_transform()

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
		Health_drain.start()  # Start draining when entering ghost
	else:
		$AnimatedSprite2D.play("untransform")
		await get_tree().create_timer(0.7).timeout
		$AnimatedSprite2D.play("idle")
		is_ghost = false
		Health_drain.stop()   # Stop draining when leaving ghost

	is_transforming = false


func _on_timer_timeout() -> void:
	if is_ghost:
		MinusHealth()
		Health_drain.start()
