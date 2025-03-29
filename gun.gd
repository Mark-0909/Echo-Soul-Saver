extends Node2D

var initial_position: float  
const BULLET = preload("res://bullet.tscn")
@onready var muzzle: Marker2D = $Marker2D

func _ready() -> void:
	initial_position = position.x
	$AnimatedSprite2D.play("steady")
	$AnimatedSprite2D.flip_v = false

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())  
	
	rotation_degrees = wrap(rotation_degrees, 0, 360);
	
	
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -.5
		$AnimatedSprite2D.position.x = initial_position
	else:
		scale.y = .5  
		$AnimatedSprite2D.position.x = -initial_position

	if Input.is_action_just_pressed("attack"):
		$AnimatedSprite2D.play("fire")
		shoot_bullet()
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("steady")
		
		
		
func shoot_bullet() -> void:
	var bullet_instance = BULLET.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation  
