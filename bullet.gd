extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer  # Make sure Timer exists in your scene

const SPEED: int = 300
var moving: bool = true  # Allow movement initially

func _process(delta: float) -> void:
	if moving:
		position += transform.x * SPEED * delta  # Bullet moves forward

func _on_body_entered(body: Node2D) -> void:
	print("Bullet hit:", body.name)  # Debugging output

	# Stop movement and play splash animation
	moving = false
	set_physics_process(false)  
	animated_sprite_2d.play("splash")  
	
	await get_tree().create_timer(0.1).timeout
	
	queue_free()
	
