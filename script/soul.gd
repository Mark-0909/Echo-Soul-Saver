extends Area2D

var orbit_angle := 0.0
var orbit_speed := 2.0
var orbit_radius_x := 15.0  # Horizontal sway
var orbit_radius_y := 5.0   # Vertical sway
var orbit_offset := Vector2(0, -10)  # Float above head
var player: Node2D = null

@onready var change_pattern_timer: Timer = $Timer

# Target values for smooth transitions
var target_speed := orbit_speed
var target_radius_x := orbit_radius_x
var target_radius_y := orbit_radius_y
var target_offset := orbit_offset

func _ready():
	$AnimatedSprite2D.play("create")
	await get_tree().create_timer(0.5).timeout
	$AnimatedSprite2D.play("default")

	randomize()
	orbit_angle = randf() * TAU

	target_speed = orbit_speed
	target_radius_x = orbit_radius_x
	target_radius_y = orbit_radius_y
	target_offset = orbit_offset

	change_pattern_timer.wait_time = randf_range(2.0, 4.0)
	change_pattern_timer.start()

func _process(delta):
	if player and is_instance_valid(player) and player.is_inside_tree():
		# Smoothly interpolate current to target
		orbit_speed = lerp(orbit_speed, target_speed, delta * 1.5)
		orbit_radius_x = move_toward(orbit_radius_x, target_radius_x, delta * 10)
		orbit_radius_y = move_toward(orbit_radius_y, target_radius_y, delta * 10)
		orbit_offset = orbit_offset.lerp(target_offset, delta * 2)

		# Calculate orbit motion
		orbit_angle += orbit_speed * delta
		var offset = Vector2(
			orbit_radius_x * cos(orbit_angle),
			orbit_radius_y * sin(orbit_angle)
		)
		global_position = player.global_position + orbit_offset + offset
	else:
		player = null

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and player == null:
		player = body

func _on_timer_timeout() -> void:
	# New random orbit behavior
	target_speed = 1.5 + randf() * 2.5
	target_radius_x = 10.0 + randi_range(-5, 5)
	target_radius_y = 4.0 + randi_range(-2, 2)
	target_offset = Vector2(randi_range(-5, 5), -30 + randi_range(-5, 5))

	change_pattern_timer.wait_time = randf_range(2.0, 4.0)
	change_pattern_timer.start()
