extends Node2D

const BULLET = preload("res://node/bulletplayer.tscn")
const GHOSTBULLET = preload("res://node/ghostbullet.tscn")
@onready var muzzle: Marker2D = $Marker2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var is_ghost_bullet: bool = false

var initial_position: float

func _ready() -> void:
	initial_position = animated_sprite.position.x
	animated_sprite.play("steady")
	animated_sprite.flip_v = false

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())  # Gun will always point to mouse position

	rotation_degrees = wrap(rotation_degrees, 0, 360)

	# Flip sprite horizontally based on the direction of rotation
	if rotation_degrees > 90 and rotation_degrees < 270:
		animated_sprite.flip_h = true  # Flip horizontally for left side
		animated_sprite.flip_v = true
		animated_sprite.position.x = -initial_position  
	else:
		animated_sprite.flip_h = true
		animated_sprite.flip_v = false
		animated_sprite.position.x = initial_position  # Reset position
	
	if Input.is_action_just_pressed("attack"):
		if is_ghost_bullet:
			animated_sprite.play("cicle")
		else:
			animated_sprite.play("fire")
		shoot_bullet()
		await animated_sprite.animation_finished
		animated_sprite.play("steady")

func shoot_bullet() -> void:
	if is_ghost_bullet:
		var ghostbullet_instance = GHOSTBULLET.instantiate()
		get_tree().root.add_child(ghostbullet_instance)
		
		if muzzle:
			ghostbullet_instance.global_position = muzzle.global_position
			ghostbullet_instance.rotation = rotation
	else:
		var bullet_instance = BULLET.instantiate()
		get_tree().root.add_child(bullet_instance)
		
		if muzzle:
			bullet_instance.global_position = muzzle.global_position
			bullet_instance.rotation = rotation
