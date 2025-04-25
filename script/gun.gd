extends Node2D

const BULLET = preload("res://node/bullet.tscn")
const GHOSTBULLET = preload("res://node/ghostbullet.tscn")
@onready var muzzle: Marker2D = $Marker2D
@onready var player := $Player as CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var is_ghost_bullet: bool = false

var initial_position: float

func _ready() -> void:
	initial_position = animated_sprite.position.x
	animated_sprite.play("steady")
	animated_sprite.flip_v = false

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

	rotation_degrees = wrap(rotation_degrees, 0, 360)

	# Flip vertically based on direction
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -0.5
		animated_sprite.position.x = initial_position
	else:
		scale.y = 0.5
		animated_sprite.position.x = -initial_position

	if Input.is_action_just_pressed("attack"):
		animated_sprite.play("fire")
		shoot_bullet()
		await animated_sprite.animation_finished
		animated_sprite.play("steady")

func shoot_bullet() -> void:
	if is_ghost_bullet:
		var ghostbullet_instance = GHOSTBULLET.instantiate()
		get_tree().root.add_child(ghostbullet_instance)
		ghostbullet_instance.global_position = muzzle.global_position
		ghostbullet_instance.rotation = rotation
	else:
		var bullet_instance = BULLET.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = muzzle.global_position
		bullet_instance.rotation = rotation
