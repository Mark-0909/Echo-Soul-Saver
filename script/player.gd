extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var player_life: int = 6
@export var is_ghost: bool = false
var is_transforming: bool = false
@export var souls: int = 0
@onready var player_health: Node2D = $PlayerLife
@onready var game_manager: Node = %gameManager
@onready var timer: Timer = $"../gameManager/Timer"
@onready var Health_drain: Timer = $Timer
@onready var terrain: TileMapLayer = $"../terrain"
@onready var player: CharacterBody2D = $"."

var is_offering_souls := false

var enemy_alert_played := false

var deployed := false

var is_dead := false

@export var detection_radius: float = 150.0

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
	
	if is_dead:
		if is_ghost:
			await start_transform()
		$AnimatedSprite2D.play("dead")
		await get_tree().create_timer(0.7).timeout
		get_tree().reload_current_scene()
		return
		
		
	if not deployed:
		$AnimatedSprite2D.play("appear")
		await get_tree().create_timer(0.7).timeout
		deployed = true
		return
		
		
		
	if is_transforming:
		return

	# Gravity
	if not is_ghost and not is_on_floor():
		velocity += get_gravity() * delta
	elif is_ghost:
		velocity.y = 0

	# If offering souls, freeze movement and force animation
	if is_offering_souls:
		velocity.x = 0
		# Ensure we don't override the animation
		if not $AnimatedSprite2D.is_playing() or $AnimatedSprite2D.animation != "offer":
			$AnimatedSprite2D.play("offer")
		move_and_slide()
		return  # Stop all other processing

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_ghost:
		velocity.y = JUMP_VELOCITY

	# Movement Input
	var direction_x := Input.get_axis("left", "right")
	var direction_y: float = Input.get_axis("jump", "down") if is_ghost else 0.0

	# Animation
	if direction_x == 0 and direction_y == 0:
		$AnimatedSprite2D.play("ghostidle" if is_ghost else "idle")
	else:
		if is_ghost:
			$AnimatedSprite2D.play("ghostwalk")  # Replace with your walk anim
		elif is_on_floor():
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("jump")

	# Flip sprite
	var mouse_x = get_global_mouse_position().x
	var player_x = global_position.x
	if abs(direction_x) > 0:
		$AnimatedSprite2D.flip_h = direction_x > 0
	else:
		$AnimatedSprite2D.flip_h = mouse_x > player_x

	# Velocity application
	if is_ghost:
		velocity.x = direction_x * SPEED
		velocity.y = direction_y * SPEED
	else:
		if direction_x != 0:
			velocity.x = direction_x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta * 5)

	# Transform input
	if Input.is_action_just_pressed("transform") and not is_transforming:
		await start_transform()

	# Shader update
	if is_ghost:
		ghost_origin = ghost_origin.lerp(target_ghost_origin, 0.1)
		terrain.material.set_shader_parameter("ghost_origin", ghost_origin)

	# Final move
	move_and_slide()
	detect_nearby_enemies()

func detect_nearby_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var enemy_near = false
	
	for enemy in enemies:
		if not enemy or not enemy is Node2D:
			continue
		
		if global_position.distance_to(enemy.global_position) <= detection_radius:
			enemy_near = true
			break
	
	if enemy_near and not enemy_alert_played:
		$bgmusic.stop()
		$enemynear.play()
		enemy_alert_played = true
	elif not enemy_near and enemy_alert_played:
		$enemynear.stop()
		$bgmusic.play()
		enemy_alert_played = false



func PlusHealth() -> void:
	if player_life >= 6:
		return
	player_life += 1 if player_life == 5 else 2
	PlayerState()

func MinusHealth() -> void:
	player_life -= 1
	PlayerState()
	await blink_damage()

func blink_damage() -> void:
	for i in range(4):  # 4 blinks (2 times visible/invisible)
		visible = false
		await get_tree().create_timer(0.05).timeout
		visible = true
		await get_tree().create_timer(0.05).timeout

	
	
func AddSoul() -> void:
	souls += 1

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
		is_dead = true

func start_transform() -> void:
	is_transforming = true
	velocity = Vector2.ZERO

	if not is_ghost:
		$AnimatedSprite2D.play("transform")
		await get_tree().create_timer(0.7).timeout
		$AnimatedSprite2D.play("ghostidle")
		is_ghost = true
		Health_drain.start()
		$Gun.is_ghost_bullet = true
		if $Gun.has_node("AnimatedSprite2D"):
				$Gun.get_node("AnimatedSprite2D").play("create_circle")
				await get_tree().create_timer(0.7).timeout
				$Gun.get_node("AnimatedSprite2D").play("circle")
	else:
		$AnimatedSprite2D.play("untransform")
		await get_tree().create_timer(0.7).timeout
		$AnimatedSprite2D.play("idle")
		is_ghost = false
		Health_drain.stop()
		$Gun.is_ghost_bullet = false
		if $Gun.has_node("AnimatedSprite2D"):
				$Gun.get_node("AnimatedSprite2D").play("steady")
				await get_tree().create_timer(0.7).timeout
				$Gun.get_node("AnimatedSprite2D").play("steady")

	# Update shader parameters
	terrain.material.set_shader_parameter("is_ghost", is_ghost)
	terrain.material.set_shader_parameter("spread_radius", spread_radius)

	print("is_ghost: ", is_ghost)
	print("ghost_origin: ", global_position)

	is_transforming = false

func _on_timer_timeout() -> void:
	if is_ghost:
		MinusHealth()
		Health_drain.start()

func OfferSouls(is_offering: bool) -> void:
	if is_ghost:
		await start_transform()
	
	is_offering_souls = is_offering
	if is_offering:
		$bgmusic.stop()
		$ritualsfx.play()
		$AnimatedSprite2D.play("offer")
	else:
		$ritualsfx.stop()
		$bgmusic.play()
		$AnimatedSprite2D.play("idle")

func apply_knockback(source_position: Vector2) -> void:
	# Calculate direction from the source position to the player's position
	var knockback_direction = (global_position - source_position).normalized()
	
	# Apply knockback force: Increase the magnitude for stronger knockback
	velocity += knockback_direction * 500  # Increase the multiplier for stronger knockback

	# Prevent downward velocity (keep player from being pushed down after knockback)
	if not is_ghost:
		velocity.y = max(velocity.y, 0)  # Ensure no downward movement after knockback

	# Call move_and_slide to process the new velocity
	move_and_slide()  # Apply the velocity to the movement system
