extends Control

func _ready():
	$AnimationPlayer.play("selected")
	
func _on_StartButton_pressed():
	get_tree().change_scene("res://core/main.tscn")

func _input(event):
	pass #print(event)