extends Area2D

@export var speed: float = 50.0
var direction: Vector2 = Vector2.LEFT

@onready var ground_ray: RayCast2D = $GroundRayCast
@onready var wall_ray: RayCast2D = $WallRayCast

func _ready() -> void:
	ground_ray.enabled = true
	wall_ray.enabled = true
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	# Move slime
	position += direction * speed * delta

	# Turn around if no ground or wall ahead
	if not ground_ray.is_colliding() or wall_ray.is_colliding():
		direction = -direction
		scale.x = -scale.x
		# Flip the raycasts' cast_to manually
		ground_ray.target_position.x = -ground_ray.target_position.x
		wall_ray.target_position.x = -wall_ray.target_position.x
