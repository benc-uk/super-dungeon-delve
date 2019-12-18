extends Node

func _on_Area2D_body_entered(body):
	globals.player.heal(10 + randi() % 10)
	$Area2D.queue_free()
	$Light2D.queue_free()
	$Particles2D.queue_free()
	$Sprite.queue_free()
	$Sfx.play(0.0)

func _on_Sfx_finished():
	queue_free()
