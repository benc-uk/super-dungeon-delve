extends Node

var player: KinematicBody2D
const GRID_SIZE = 16

func _ready():
	var all_rooms = $Map.all_rooms
	player = load("res://actors/Player.tscn").instance()
	
	# Add player
	var start_room = $Map.all_rooms[randi() % len($Map.all_rooms)]
	var player_cell = $Map.get_random_floor_cell(start_room["left"], start_room["top"], start_room["width"], start_room["height"])
	player.position.x = player_cell.x * GRID_SIZE
	player.position.y = player_cell.y * GRID_SIZE
	add_child(player)
	
	# Add monsters
	for room in $Map.all_rooms:
		# Monster spawn ammount is factored on room size
		for mi in range(room.width * room.height):
			# 50% chance
			if randf() <= 0.04:
				var m = preload("res://actors/Monster.tscn").instance()
				var m_cell = $Map.get_random_floor_cell(room["left"], room["top"], room["width"], room["height"])
				m.position.x = m_cell.x * 16
				m.position.y = m_cell.y * 16
				$"/root/Main".add_child(m)