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
	z_index = 0

func _process(delta: float) -> void:
	if moving:
		position += transform.x * SPEED * delta  

func _on_body_entered(body: Node2D) -> void:
	print("Bullet hit:", body.name)

	# Player bullets should damage enemies
	if is_player_bullet:
		if body.is_in_group("Player"):
			return  # Ignore hitting self
		if body.is_in_group("Enemy"):
			if body.has_method("LoseLife"):
				body.LoseLife()
	elif not is_player_bullet:
		# Enemy bullets should damage players
		if body.is_in_group("Enemy"):
			return  # Ignore hitting self
		if body.is_in_group("Player"):
			if "is_ghost" in body and body.is_ghost:
				print("Ghost mode active — bullet passed through")
				return
			if body.has_method("MinusHealth"):
				body.MinusHealth()

	# Handle bullet impact visuals (common for any hit)
	moving = false
	set_process(false)
	animated_sprite_2d.play("splash")
	await get_tree().create_timer(0.1).timeout
	queue_free()
