extends Node2D

var initial_position: float  

func _ready() -> void:
	initial_position = position.x
	$AnimatedSprite2D.play("steady")

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	
	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	elif direction < 0:
		$AnimatedSprite2D.flip_h = false
