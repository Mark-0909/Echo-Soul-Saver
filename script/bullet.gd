extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED: int = 300
var moving: bool = true  

@export var is_player_bullet: bool = true

func _process(delta: float) -> void:
	if moving:
		position += transform.x * SPEED * delta  

func _on_body_entered(body: Node2D) -> void:
	print("Bullet hit:", body.name)  

	if is_player_bullet and body.is_in_group("Player"):
		return
	if not is_player_bullet and body.is_in_group("Enemy"):
		return
	
	if not is_player_bullet and body.is_in_group("Player"):
		if body.has_method("MinusHealth"):
			body.MinusHealth()
	
	if not is_player_bullet and body.is_in_group("Player"):
		# Use optional chaining just in case
		if "is_ghost" in body and body.is_ghost:
			print("Player is ghost - bullet passed through")
			return
	
	moving = false 
	set_process(false)  
	
	
	if body.has_method("LoseLife"):
		body.LoseLife()
	
	animated_sprite_2d.play("splash")  
	await get_tree().create_timer(0.1).timeout  
	queue_free()
