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

	if is_player_bullet:
		# Player bullet behavior
		if body.is_in_group("Player"):
			return  # Ignore hitting self
		
		if body.is_in_group("Enemy"):
			if body.is_in_group("Ghost"):
				print("Enemy is a ghost — bullet passed through")
				return  # Ignore hitting ghost enemies
			
			if body.has_method("LoseLife"):
				body.LoseLife()
	else:
		# Enemy bullet behavior
		if body.is_in_group("Enemy"):
			return  # Enemy bullets ignore other enemies

		if body.is_in_group("Player"):
			if "is_ghost" in body and body.is_ghost:
				print("Player in ghost mode — bullet passed through")
				return  # Ignore player ghosts

			if body.has_method("MinusHealth"):
				body.MinusHealth()

	# Common impact logic (bullet disappears)
	moving = false
	set_process(false)
	animated_sprite_2d.play("splash")
	await get_tree().create_timer(0.1).timeout
	queue_free()
