extends Node2D

func _ready():
	$Sprite.self_modulate = Color(0.0, 0.6, 0.0, 0.2)
	var scale = rand_range(0.7, 1.1)
	$Sprite.scale.x = scale
	$Sprite.scale.y = scale
	rotate(randf())
	$Timer.wait_time = rand_range(1.0, 1.5)

func _on_Timer_timeout():
	queue_free()
