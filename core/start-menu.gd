extends Control

const OPT_START = 0
const OPT_EXIT = 1

var _selected = 0
var _old_selected = 1

func _ready():
	$AnimationPlayer.play("selected")
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if _selected == OPT_START:
			# Let the player know what is happening
			$Label0.text = "Generating Dungeon ..."
			$Label0.modulate = Color.lawngreen
			$Label0.rect_position.x = $Label0.rect_position.x - 180
			$Label1.visible = false
			$pointer.visible = false
			# Without this, the label change is never visible before the scene switch
			yield(get_tree(), 'idle_frame')
			# Now start the game by switching to the main scene
			get_tree().change_scene("res://core/main.tscn")
			
		if _selected == OPT_EXIT:
			get_tree().quit()
			
	if Input.is_action_just_pressed("ui_down"):
		_old_selected = _selected
		_selected += 1
	if Input.is_action_just_pressed("ui_up"):
		_old_selected = _selected
		_selected -= 1
				
	if _selected > OPT_EXIT: 
		_selected = OPT_START
	if _selected < OPT_START: 
		_selected = OPT_EXIT
			
	# Move pointer next to selected option label
	$pointer.position.y = get_node("Label"+str(_selected)).rect_position.y + get_node("Label"+str(_selected)).rect_size.y / 2
	
	# Change the animation which makes the labels "glow"
	var ani = $AnimationPlayer.get_animation("selected")
	get_node("Label"+str(_old_selected)).modulate = Color.white
	# We can modify the property the animation path animates on the fly, how clever!
	ani.track_set_path(1, "Label"+str(_selected)+":modulate")				
