extends CharacterBody2D

var life: int = 3
@onready var soul_location: Marker2D = $Marker2D
const SOUL = preload("res://node/soul.tscn")

@onready var sprite: AnimatedSprite2D = $Sprite2D

var player: Node2D = null  # Will find a node in group "Player"
var adjusted: bool = false  # New global variable to check if we already adjusted position

func _ready() -> void:
	sprite.flip_h = false
	sprite.flip_v = false

func _physics_process(delta: float) -> void:
	if player == null:
		# Find player only once
		for node in get_tree().get_current_scene().get_children():
			if node.is_in_group("Player"):
				player = node
				break

	if player != null:
		var distance = global_position.distance_to(player.global_position)
		if distance <= 200:
			if player.global_position.x > global_position.x:
				if sprite.flip_h:  # Was flipped, now unflip
					sprite.flip_h = false
					if not adjusted:
						global_position.x += 5  # adjust a bit to the right
						adjusted = true
			else:
				if not sprite.flip_h:  # Was normal, now flip
					sprite.flip_h = true
					if not adjusted:
						global_position.x -= 5  # adjust a bit to the left
						adjusted = true
		else:
			adjusted = false  # Reset adjustment when player is far

func LoseLife() -> void:
	life -= 1
	print("Enemy hit! Remaining life:", life)

	if life <= 0:
		var soul = SOUL.instantiate()
		sprite.play("dead")
		await get_tree().create_timer(0.2).timeout  
		queue_free()
		get_tree().root.add_child(soul)
		soul.global_position = soul_location.global_position
