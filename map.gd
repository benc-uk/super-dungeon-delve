extends TileMap

const MAP_SIZE = 48
const MAX_DEPTH = 4
const SPLIT_PERC = 30
const TILE_IDX_UNSET = -1
const TILE_IDX_WALL = 0
const TILE_IDX_FLOOR = 1
const TORCH_SCENE = preload("res://actors/Torch.tscn")
var rng: = RandomNumberGenerator.new()
var all_rooms: = []

func _ready():
	rng.randomize()
	
	# Generate the level
	var top_zone = LevelGenZone.new(0, 0, MAP_SIZE, MAP_SIZE, 0) 
	add_child(top_zone)
	top_zone.make_corridor()
	for room in all_rooms:
		deco_room(room)

	# Set player start room & location
	all_rooms.shuffle()
	var start_room = all_rooms[0]
	var px = (start_room["left"] + floor(start_room["width"] / 2))
	var py = (start_room["top"] + floor(start_room["height"] / 2))	
	while true:
		if get_cell(px, py) == TILE_IDX_FLOOR: break
		px += 1
	
	$Player.position.x = px * 16
	$Player.position.y = py * 16
	
	# Draw walls on edges of rooms
	for y in range(-1, MAP_SIZE+1):
		for x in range(-1, MAP_SIZE+1): 
			if get_cell(x, y) == TILE_IDX_UNSET:
				# Specal 1 thickness walls
				if get_cell(x-1, y) == TILE_IDX_FLOOR and get_cell(x+1, y) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(1, 1))
					continue				
				if get_cell(x, y-1) == TILE_IDX_FLOOR and get_cell(x, y+1) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(2, 1))
					continue		
									
				# Cardinal directions
				if get_cell(x, y+1) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(rng.randi_range(1, 4), 0))
					if rng.randf() > 0.8:
						add_torch(x, y)
					continue
				if get_cell(x, y-1) == TILE_IDX_FLOOR:
					# "north" walls are a special case due to fake perspective
					if get_cell(x-1, y) == TILE_IDX_FLOOR:
						set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(0, 5))
					elif get_cell(x+1, y) == TILE_IDX_FLOOR:
						set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(5, 5))						
					else:
						set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(rng.randi_range(1, 4), 4))
					continue
				if get_cell(x+1, y) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(0, rng.randi_range(0, 3)))
					continue
				if get_cell(x-1, y) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(5, rng.randi_range(0, 3)))
					continue		
									
				# Diagonals		
				if get_cell(x+1, y-1) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(0, 4))
					continue
				if get_cell(x-1, y-1) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(5, 4))
					continue
				if get_cell(x+1, y+1) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(0, 0))
					continue
				if get_cell(x-1, y+1) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(5, 0))
					continue
					
																			
func fill_cells(left, top, width, height, tile_idx, tile_coords):
	for y in range(top, top + height):
		for x in range(left, left + width):
			set_cell(x, y, tile_idx, false, false, false, tile_coords)

func fill_cells_floor(left, top, width, height):
	for y in range(top, top + height):
		for x in range(left, left + width):
			set_cell(x, y, TILE_IDX_FLOOR, false, false, false, get_floor_tile())
			
func get_floor_tile() -> Vector2:
	return Vector2(rng.randi_range(0, 3), rng.randi_range(0, 2))
	
func deco_room(room):
	var deco_count = rng.randi_range(3, 8)
	if room.width * room.height > 15 and room.width > 4 and room.height > 4:
		for p in range(deco_count):
			var pillarLeft: = rng.randi_range(1, room.width - 3)
			var pillarTop: = rng.randi_range(1, room.height - 3)
			fill_cells(room.left + pillarLeft, room.top + pillarTop, 2, 2, -1, Vector2.ZERO)	
			
func add_torch(x, y):
	var torch_node: Node2D = TORCH_SCENE.instance()
	torch_node.position.x = x * 16
	torch_node.position.y = y * 16
	add_child(torch_node)
