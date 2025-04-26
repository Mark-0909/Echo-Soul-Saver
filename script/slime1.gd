extends CharacterBody2D

@export var speed: float = 35.0
var direction: Vector2 = Vector2.LEFT
var is_attacking: bool = false
var Health = 3

@onready var ground_ray: RayCast2D = $Area2D/GroundRayCast
@onready var wall_ray: RayCast2D = $Area2D/WallRayCast
@onready var sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var area2d: Area2D = $Area2D  

func _ready() -> void:
	ground_ray.enabled = true
	wall_ray.enabled = true
	sprite.play("walk")
	print("slime z index")
	print(z_index)

func _physics_process(delta: float) -> void:
	if not is_attacking:
		# Move the slime normally
		position += direction * speed * delta

		# Check for wall collisions using raycasts
		var wall_hit = wall_ray.is_colliding()
		var wall_collider = wall_ray.get_collider()

		# Only attack if hitting a Player via the wall ray
		if wall_hit and wall_collider.is_in_group("Player"):
			var player = wall_collider as CharacterBody2D
			if player and not player.is_ghost:
				print("Wall Raycast collided with Player!")  # Debug message
				Attack(player)

		# Otherwise, flip if no ground or wall ahead (normal walk behavior)
		elif not ground_ray.is_colliding() or (wall_hit and not wall_collider.is_in_group("Player")):
			_flip_direction()

# Flipping the slime's direction
func _flip_direction() -> void:
	direction = -direction
	scale.x = -scale.x
	ground_ray.target_position.x = -ground_ray.target_position.x
	wall_ray.target_position.x = -wall_ray.target_position.x

# Attack logic
func Attack(body: Node2D) -> void:
	is_attacking = true
	sprite.play("attack")

	if body.has_method("apply_knockback") and body.has_method("MinusHealth"):
		body.apply_knockback(global_position)
		body.MinusHealth()

	await get_tree().create_timer(0.5).timeout  # Attack animation duration
	sprite.play("walk")
	is_attacking = false

# Handle when slime loses health
func LoseLife() -> void:
	Health -= 1
	if Health <= 0:
		sprite.play("death")
		await get_tree().create_timer(0.5).timeout
		queue_free()

# Triggered when an object enters the Area2D's collision shape
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_attacking:
		var player = body as CharacterBody2D
		if player and not player.is_ghost:
			print("Slime collided with Player (body entered)!")  # Debug message
			Attack(player)
