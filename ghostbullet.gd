extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED: int = 100
var moving: bool = true  

@export var is_player_bullet: bool = true

@export var is_ghost_bullet: bool = true

func _process(delta: float) -> void:
	if moving:
		position += transform.x * SPEED * delta  

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("Player"):
		return
	elif body.is_in_group("Enemy"):
		if body.is_in_group("Physical"):
			return
		else:
			if body.has_method("LoseLife"):
				body.LoseLife()
		
	moving = false 
	set_process(false)  
	animated_sprite_2d.play("splash")  
	await get_tree().create_timer(0.1).timeout  
	queue_free()
