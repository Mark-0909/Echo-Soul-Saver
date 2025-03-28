extends Node2D

var initial_position: float  

func _ready() -> void:
	initial_position = position.x
	$AnimatedSprite2D.play("steady")
	$AnimatedSprite2D.flip_v = false

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())  
	
	var direction = get_global_mouse_position().x - global_position.x
	
	if direction > 0:
		$AnimatedSprite2D.flip_h = true  
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.position.x = initial_position
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.flip_v = true  
		$AnimatedSprite2D.position.x = -initial_position

	if Input.is_action_just_pressed("attack"):
		attack()

# 🔹
func attack() -> void:
	print("Attacking!")  
	$AnimatedSprite2D.play("fire")  
	await $AnimatedSprite2D.animation_finished 
	$AnimatedSprite2D.play("steady")
