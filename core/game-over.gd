extends Control

func _ready():
	$ScoresLabel.text = "Depth:  " + str(globals.depth * 100) + "ft\nGold:  " + str(globals.gold) + "\nKills:  " + str(globals.kills)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://core/start-menu.tscn")
