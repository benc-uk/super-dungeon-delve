extends Node2D



func _on_Area2D_body_entered(body):
	if body.name == "Player":
		queue_free()
		#call_deferred("next_;evel", 
		$"/root/Main".next_level()
