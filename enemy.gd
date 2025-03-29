extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.flip_h = true
	$Sprite2D.flip_v = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
