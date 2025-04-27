extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED: int = 300
var moving: bool = true  

@export var is_player_bullet: bool = true

@export var is_ghost_bullet: bool = true

func _process(delta: float) -> void:
	if moving:
		position += transform.x * SPEED * delta  

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("Physical") and body.is_in_group("Enemy") and is_ghost_bullet and is_player_bullet:
		return
	if body.is_in_group("Player") and is_player_bullet and is_ghost_bullet:
		return
	
	# Handle bullet impact visuals
	moving = false 
	set_process(false)  
	animated_sprite_2d.play("splash")  
	await get_tree().create_timer(0.1).timeout  
	queue_free()
