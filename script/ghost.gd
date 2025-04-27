extends CharacterBody2D

var life: int = 3
@onready var soul_location: Marker2D = $Marker2D
const PLUS_LIFE = preload("res://node/soul.tscn")
func _ready() -> void:
	$Sprite2D.flip_h = false
	$Sprite2D.flip_v = false

func LoseLife() -> void:
	life -= 1
	print("Enemy hit! Remaining life:", life)
	$Sprite2D.play("hurt")
	await get_tree().create_timer(0.5).timeout
	$Sprite2D.play("default")
	if life <= 0:
		var heart = PLUS_LIFE.instantiate()
		$Sprite2D.play("dead")
		await get_tree().create_timer(0.5).timeout  
		queue_free()
		get_tree().root.add_child(heart)
		heart.global_position = soul_location.global_position

	
