extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const SPEED: int = 300
var moving: bool = true  # Ensure movement is controlled

func _process(delta: float) -> void:
	if moving:
		position += transform.x * SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	print("Bullet hit:", body.name)  

	if body.is_in_group("Player"):
		return
	# ✅ Stop movement
	moving = false
	set_physics_process(false)  

	# ✅ If the body is an enemy, call LoseLife()
	if body.is_in_group("Enemy"):
		if body.has_method("LoseLife"):
			body.LoseLife()  
	elif body.is_in_group("Player"):
		pass

	# ✅ Play splash animation, then remove bullet
	animated_sprite_2d.play("splash")  
	await get_tree().create_timer(0.1).timeout  
	queue_free()
