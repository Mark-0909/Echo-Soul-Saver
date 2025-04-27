extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED: int = 300
var moving: bool = true  



func _process(delta: float) -> void:
	if moving:
		position += transform.x * SPEED * delta  

func _on_body_entered(body: Node2D) -> void:
	# Bullet should pass through ghost enemies
	if body.is_in_group("Player") and body.get("is_ghost") == false:
		return
	elif body.is_in_group("Player") and body.get("is_ghost") == true:
		if body.has_method("MinusHealth"):
			body.MinusHealth()
		
	moving = false
	set_process(false)
	animated_sprite_2d.play("splash")
	await get_tree().create_timer(0.1).timeout
	queue_free()
