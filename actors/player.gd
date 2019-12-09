extends KinematicBody2D

var time:= 0.0
var rng: = RandomNumberGenerator.new()
var light_old_pos = Vector2(8, 8)

func _ready():
	rng.randomize()
	
func _physics_process(delta: float):
	time += delta
	if time > 500000: time = 0
	if Input.is_action_pressed("down"):
		move_and_slide(Vector2(0, 100))
	if Input.is_action_pressed("up"):
		move_and_slide(Vector2(0, -100))
	if Input.is_action_pressed("left"):
		move_and_slide(Vector2(-100, 0))
		$Sprite.flip_h = true
	if Input.is_action_pressed("right"):
		move_and_slide(Vector2(100, 0))		
		$Sprite.flip_h = false

	# light flicker		
	$Light2D.texture_scale = 0.19 + (cos(time * 9) * 0.005)
	$Light2D.energy = 2.8 + (cos(time * 6) * 0.1)
	
func _on_LightTimer_timeout():
	var light_new_pos = Vector2(rand_range(4, 12), rand_range(4, 12))
	$Light2D/Tween.interpolate_property($Light2D, "position:x", light_old_pos.x, light_new_pos.x, 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Light2D/Tween.interpolate_property($Light2D, "position:y", light_old_pos.y, light_new_pos.y, 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Light2D/Tween.start()
	light_old_pos = light_new_pos
