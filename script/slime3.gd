extends CharacterBody2D

@export var speed: float = 45.0
var direction: Vector2 = Vector2.LEFT
var is_attacking: bool = false
var Health = 3

@onready var ground_ray: RayCast2D = $Area2D/GroundRayCast
@onready var wall_ray: RayCast2D = $Area2D/WallRayCast
@onready var wall_ray_2: RayCast2D = $Area2D/WallRayCast2

@onready var sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var area2d: Area2D = $Area2D  
const PLUS_LIFE = preload("res://node/plus_life.tscn")
@onready var heart_location: Marker2D = $Marker2D

func _ready() -> void:
	ground_ray.enabled = true
	wall_ray.enabled = true
	sprite.play("walk")
	print("slime z index")
	print(z_index)
	$CollisionShape2D2.disabled = false
	
func _physics_process(delta: float) -> void:
	if not is_attacking:
		# Move the slime normally
		position += direction * speed * delta

		# Check for wall collisions using raycasts
		var wall_hit = wall_ray.is_colliding()
		var wall_collider = wall_ray.get_collider()
		var wall_collider2 = wall_ray_2.get_collider()

		# Only attack if hitting a Player via the wall ray
		if wall_hit and (
			(wall_collider != null and wall_collider.is_in_group("Player")) or
			(wall_collider2 != null and wall_collider2.is_in_group("Player"))
		):
			var player = wall_collider if wall_collider != null and wall_collider.is_in_group("Player") else wall_collider2
			if player and not player.is_ghost:
				print("Wall Raycast collided with Player!")  # Debug message
				Attack(player)
		
		# Flip direction if no ground detected or wall ahead (but not a player)
		elif not ground_ray.is_colliding() or (
			wall_hit and 
			!(wall_collider != null and wall_collider.is_in_group("Player")) and
			!(wall_collider2 != null and wall_collider2.is_in_group("Player"))
		):
			_flip_direction()

# Flipping the slime's direction
func _flip_direction() -> void:
	direction = -direction
	scale.x = -scale.x
	ground_ray.target_position.x = -ground_ray.target_position.x
	wall_ray.target_position.x = -wall_ray.target_position.x
	wall_ray_2.target_position.x = -wall_ray_2.target_position.x


# Attack logic
func Attack(body: Node2D) -> void:
	is_attacking = true
	sprite.play("attack")

	if body.has_method("apply_knockback") and body.has_method("MinusHealth"):
		body.apply_knockback(global_position)  # Apply knockback with source position
		body.MinusHealth()  # Deal damage

	await get_tree().create_timer(0.5).timeout  
	sprite.play("walk")
	is_attacking = false

# Handle when slime loses health
func LoseLife() -> void:
	Health -= 1
	if Health <= 0:
		velocity = Vector2.ZERO
		sprite.play("death")
		await get_tree().create_timer(0.5).timeout
		queue_free()
		var heart = PLUS_LIFE.instantiate()
		get_tree().root.add_child(heart)
		heart.global_position = heart_location.global_position
	
	sprite.play("hurt")
	await get_tree().create_timer(.3).timeout
	sprite.play("walk")

# Triggered when an object enters the Area2D's collision shape
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_attacking:
		var player = body as CharacterBody2D
		if player and not player.is_ghost:  # Check if the player is not a ghost
			is_attacking = true
			sprite.play("attack")

			if body.has_method("apply_knockback") and body.has_method("MinusHealth"):
				body.apply_knockback(global_position)  # Apply knockback with source position
				body.MinusHealth()  # Deal damage

				await get_tree().create_timer(0.5).timeout  
				sprite.play("walk")
				is_attacking = false
