extends Node2D

var initial_position: float  
const BULLET = preload("res://bullet.tscn")

@onready var muzzle: Marker2D = $Marker2D
@export var is_player_gun: bool = false  # Default is false for enemies

func _ready() -> void:
	initial_position = position.x
	$AnimatedSprite2D.play("steady")
	$AnimatedSprite2D.flip_v = true
	
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -.5
		$AnimatedSprite2D.position.x = initial_position
	else:
		scale.y = .5  
		$AnimatedSprite2D.position.x = -initial_position
		
	await get_tree().process_frame  # Ensure properties update before debug
	print("EnemyGun spawned. is_player_gun:", is_player_gun)
	
	if not is_player_gun:
		start_shooting_cycle()

func _process(delta: float) -> void:
	if not is_player_gun:
		var player = get_tree().get_first_node_in_group("Player")  
		if player:
			look_at(player.global_position)  # Enemy gun follows the player ✅

func start_shooting_cycle() -> void:
	while true:
		await shoot_enemy_gun()
		await get_tree().create_timer(2.0).timeout  # Enemy shoots every 2 seconds
		
func shoot_enemy_gun() -> void:
	print("Enemy fires!")  # Debug ✅
	$AnimatedSprite2D.play("fire")

	# 🔥 Fixed: Proper await with .timeout so bullets fire in sequence
	shoot_bullet()
	await get_tree().create_timer(0.3).timeout  # ✅ Wait 0.3s
	shoot_bullet()
	await get_tree().create_timer(0.3).timeout  # ✅ Wait another 0.3s
	shoot_bullet()

	await $AnimatedSprite2D.animation_finished  # Wait for animation to finish
	$AnimatedSprite2D.play("steady")

func shoot_bullet() -> void:
	var bullet_instance = BULLET.instantiate()
	bullet_instance.is_player_bullet = false
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation
	print("Bullet fired!")  # ✅ Debug log for bullet firing
