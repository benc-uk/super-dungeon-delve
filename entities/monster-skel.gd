extends Monster

var move_time: = 0.0

func _ready():
	$AnimatedSprite.animation = "skel"
	health = 10
	gold = 5
	damage = 10
	death_sfx = "2"
	$Particles2D.modulate = Color("fdf7ed")
	$SfxDeath.stream = load("res://assets/sfx/bones.wav")

func _physics_process(delta):
	move_time -= delta
	if move_time <= 0:
		speed = 0.0
		var perc = (randf() * 100.0)
		if perc < 1.5: 
			speed = 80
			#_velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
			_direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized()
			move_time = 0.4
