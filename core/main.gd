extends Node

# Main game script, handles initialisation and changing levels

const SCENE_MONSTER = preload("res://entities/monster.tscn")
const SCENE_EXIT = preload("res://entities/exit.tscn")
const SCENE_PLAYER = preload("res://entities/player.tscn")
const SCENE_MAP = preload("res://core/map.tscn")

func _ready():
	randomize()

	# Start game, add a player and reset globals
	globals.player = SCENE_PLAYER.instance()
	globals.depth = 1
	globals.gold = 0
	globals.kills = 0
	add_child(globals.player)
	$HUD/HealthBar.value = globals.player.health
	
	# Start at depth 1 !
	start_level()

# 
# Start a level, at current depth, level will be randomly generated
#
func start_level():
	# Nuke old map if any
	if globals.depth > 1: 
		if get_node_or_null("Map") != null: remove_child($Map)
		#if globals.map != null: globals.map.queue_free()
		
	# This creates a new map, which in turn will call the random generator
	# Hold map in globals for conveniance
	globals.map = SCENE_MAP.instance()
	
	# Random colors for deeper dungeons, adds variety 
	if globals.depth > 1:
		var r = randi() % 8
		if r == 0: globals.map.self_modulate = Color(1.0, 1.8, 1.0)
		if r == 1: globals.map.self_modulate = Color(1.6, 1.0, 1.0)
		if r == 2: globals.map.self_modulate = Color(1.0, 1.0, 1.9)
		if r == 3: globals.map.self_modulate = Color(1.8, 1.5, 1.0)
		if r == 4: globals.map.self_modulate = Color(1.0, 1.8, 1.6)
		if r == 5: globals.map.self_modulate = Color(1.5, 1.0, 1.5)
		
	# Add map to Main node
	add_child(globals.map)
	$HUD/DepthLabel.text = str(globals.depth * 100) + " ft"
	
	# Remove existing monsters (if any)
	for monster in get_tree().get_nodes_in_group("monsters"):
		remove_child(monster)
	
	# Move player to a randomly selected start room
	var start_room = globals.map.all_rooms[randi() % len(globals.map.all_rooms)]
	var player_cell = globals.map.get_random_floor_cell(start_room["left"], start_room["top"], start_room["width"], start_room["height"])
	globals.player.position.x = player_cell.x * globals.GRID_SIZE
	globals.player.position.y = player_cell.y * globals.GRID_SIZE

	# Place exit in randomly selected start room
	var exit = SCENE_EXIT.instance()
	var exit_room 
	# Place exit in any random room which is not the player start room
	while true:
		exit_room = globals.map.all_rooms[randi() % len(globals.map.all_rooms)]
		if exit_room != start_room: break

	# Place exit randomly in selected exit room
	var exit_cell = globals.map.get_random_floor_cell(exit_room["left"], exit_room["top"], exit_room["width"], exit_room["height"])
	exit.position.x = exit_cell.x * globals.GRID_SIZE
	exit.position.y = exit_cell.y * globals.GRID_SIZE
	add_child(exit)
	
	# Add monsters to each room (should this be move to map.gd I don't know)
	for room in globals.map.all_rooms:
		# Spawn loop is factored on room size
		for mi in range(room.width * room.height):
			# Monster spawn rate factored on depth
			if (randf() * 100) <= 0.5 + (globals.depth * 0.7):
				var monster: KinematicBody2D
				
				# Randomly pick a monster, note we instance the same scene for all monsters
				# But attach different scripts for the different behaviors 
				var r: = randi() % 3
				if r == 0:
					monster = SCENE_MONSTER.instance()
					monster.set_script(preload("res://entities/monster-skel.gd"))
				if r == 1: 
					monster = SCENE_MONSTER.instance()
					monster.set_script(preload("res://entities/monster-slime.gd"))
				if r == 2:
					monster = SCENE_MONSTER.instance()
					monster.set_script(preload("res://entities/monster-goblin.gd"))
				
				# Place monster randomly in room
				var m_cell = globals.map.get_random_floor_cell(room["left"], room["top"], room["width"], room["height"])
				monster.position.x = m_cell.x * globals.GRID_SIZE
				monster.position.y = m_cell.y * globals.GRID_SIZE
				
				# Small chance monster will be a super monster!
				# Colored red and with more health, speed etc
				if randf() * 100 <= (3 + globals.depth):
					monster.get_node("AnimatedSprite").self_modulate = Color(1.0, 0.1, 0.1)
					monster.factor = 2
					if globals.depth > 4:
						monster.factor = 2.5
					if globals.depth > 8:
						monster.factor = 3				
				
				# Place monster in game (inside Main node)
				add_child(monster)
				
#
# Helper to move to next level
#
func next_level():
	$SfxExit.play(0.0)
	globals.depth += 1
	# IMPORTANT! Use call_deferred to prevent "flushing queries" errors/warnings
	call_deferred("start_level")
	
