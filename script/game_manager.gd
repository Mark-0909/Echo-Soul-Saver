extends Node

var score = 0;

@onready var player: CharacterBody2D = $"../Player"

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var checkpoint := 0

func add_score():
	score += 1


"stream"
@onready var timer: Timer = $Timer

func timerstarter() -> void:
	timer.start()
	
func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
