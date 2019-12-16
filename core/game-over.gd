extends Control

func _ready():
	$Button.grab_focus()
	$ScoresLabel.text = "Depth: " + str(globals.depth * 100) + "ft\nGold: " + str(globals.gold) + "\nKills: " + str(globals.kills)
	
func _on_Button_pressed():
	get_tree().change_scene("res://core/start-menu.tscn")
