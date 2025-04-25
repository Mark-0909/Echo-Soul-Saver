extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED: int = 300
var moving: bool = true  

@export var is_player_bullet: bool = true

@export var is_ghost_bullet: bool = false

func _ready() -> void:
	if is_ghost_bullet:
		animated_sprite_2d.play("ghostbullet")
	else:
		animated_sprite_2d.play("flying") 
	
	print(is_ghost_bullet)

func _process(delta: float) -> void:
	if moving:
		position += transform.x * SPEED * delta  

func _on_body_entered(body: Node2D) -> void:
	print("Bullet hit:", body.name)  

	# Ignore friendly fire
	if is_player_bullet and body.is_in_group("Player"):
		return
	if not is_player_bullet and body.is_in_group("Enemy"):
		return
	
	# If bullet is enemy's and hits player, subtract health
	if not is_player_bullet and body.is_in_group("Player"):
		if "is_ghost" in body and body.is_ghost:
			print("Ghost mode active — bullet passed through")
			return
		if body.has_method("MinusHealth"):
			body.MinusHealth()

	# If bullet hits a damageable object
	if body.has_method("LoseLife"):
		body.LoseLife()
	
	# Handle bullet impact visuals
	moving = false 
	set_process(false)  
	animated_sprite_2d.play("splash")  
	await get_tree().create_timer(0.1).timeout  
	queue_free()
