extends Monster

var move_time: = 0.0

func _ready():
	$AnimatedSprite.animation = "goblin"
	health = 18
	gold = 20
	speed = 20.0 + randf() * 30.0
	$Particles2D.modulate = Color("3d734f")
	$SfxDeath.stream = load("res://assets/sfx/death.wav")

func _physics_process(delta):
	if _recoil_countdown <= 0:
		_velocity = $"/root/Main/Player".position - position
		_velocity = _velocity.normalized()
