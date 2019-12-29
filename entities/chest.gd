extends Node2D

func _on_Area2D_body_entered(body):
	globals.player.add_gold(100)
	$Area2D.queue_free()
	$Sprite.queue_free()
	$"Particles2D-Anim".queue_free()
	$Sfx.play(0.0)
	$Particles2D.emitting = true
	$Particles2D.one_shot = true

func _on_Sfx_finished():
	queue_free()
