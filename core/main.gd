extends Node

func _ready():
	randomize()
	globals.player = load("res://entities/player.tscn").instance()
	add_child(globals.player)
	start_level()
	     

func start_level():
	if globals.depth > 1: 
		remove_child($Map)
		globals.map.queue_free()
		
	globals.map = load("res://core/map.tscn").instance()
	if globals.depth > 1:
		var r = randi() % 8
		if r == 0: globals.map.self_modulate = Color(1.0, 1.8, 1.0)
		if r == 1: globals.map.self_modulate = Color(1.6, 1.0, 1.0)
		if r == 2: globals.map.self_modulate = Color(1.0, 1.0, 1.9)
		if r == 3: globals.map.self_modulate = Color(1.8, 1.5, 1.0)
		if r == 4: globals.map.self_modulate = Color(1.0, 1.8, 1.6)
		if r == 5: globals.map.self_modulate = Color(1.5, 1.0, 1.5)
		
	#globals.map.self_modulate = Color(1.0, 1.0, 1.0)
	add_child(globals.map)
	$HUD/DepthLabel.text = str(globals.depth * 100) + " ft"
	
	for monster in get_tree().get_nodes_in_group("monsters"):
		remove_child(monster)
	
	# Move player to start room
	var start_room = globals.map.all_rooms[randi() % len(globals.map.all_rooms)]
	var player_cell = globals.map.get_random_floor_cell(start_room["left"], start_room["top"], start_room["width"], start_room["height"])
	globals.player.position.x = player_cell.x * globals.GRID_SIZE
	globals.player.position.y = player_cell.y * globals.GRID_SIZE

	var exit = load("res://entities/exit.tscn").instance()
	var exit_room = globals.map.all_rooms[randi() % len(globals.map.all_rooms)]
	var exit_cell: = {"x": -1, "y": -1}
	while true:
		exit_cell = globals.map.get_random_floor_cell(exit_room["left"], exit_room["top"], exit_room["width"], exit_room["height"])
		if exit_cell.x != player_cell.x or exit_cell.y != player_cell.y: break
	exit.position.x = exit_cell.x * globals.GRID_SIZE
	exit.position.y = exit_cell.y * globals.GRID_SIZE
	add_child(exit)
	
	# Add monsters
	for room in globals.map.all_rooms:
		# Spawn ammount is factored on room size
		for mi in range(room.width * room.height):
			# Monster spawns factored on depth
			if (randf() * 100) <= 0.5 + (globals.depth * 1.0):
				var monster: KinematicBody2D
				var r: = randi() % 3
				if r == 0:
					monster = preload("res://entities/monster.tscn").instance()
					monster.set_script(preload("res://entities/monster-skel.gd"))
				if r == 1:
					monster = preload("res://entities/monster.tscn").instance()
					monster.set_script(preload("res://entities/monster-slime.gd"))
				if r == 2:
					monster = preload("res://entities/monster.tscn").instance()
					monster.set_script(preload("res://entities/monster-goblin.gd"))
				var m_cell = $Map.get_random_floor_cell(room["left"], room["top"], room["width"], room["height"])
				monster.position.x = m_cell.x * globals.GRID_SIZE
				monster.position.y = m_cell.y * globals.GRID_SIZE
				
				# SUPER MONSTERS!
				if randf() * 100 <= 3:
					monster.get_node("AnimatedSprite").self_modulate = Color(0.8, 0.0, 0.0)
					monster.factor = 2
				
				monster.add_to_group("monsters")
				add_child(monster)
				
func next_level():
	globals.depth += 1
	start_level()