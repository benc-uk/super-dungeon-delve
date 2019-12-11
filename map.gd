extends TileMap

const MAP_SIZE = 48
const MAX_DEPTH = 4
const SPLIT_PERC = 30
const TILE_IDX_UNSET = -1
const TILE_IDX_WALL = 0
const TILE_IDX_FLOOR = 1

var rng: = RandomNumberGenerator.new()
var all_rooms: = []

func _ready():
	rng.randomize()
	
	# Generate the level
	var top_zone = LevelGenZone.new(0, 0, MAP_SIZE, MAP_SIZE, 0) 
	# We need to add the zone to the tree so it can access the map node
	add_child(top_zone)
	# Corridors after room generation but before pillars
	top_zone.make_corridor()
	# Add pillars to each room, maybe
	for room in all_rooms:
		_add_pillars(room)
	_add_walls()


func fill_cells(left, top, width, height, tile_idx, tile_coords):
	for y in range(top, top + height):
		for x in range(left, left + width):
			set_cell(x, y, tile_idx, false, false, false, tile_coords)


func fill_cells_floor(left, top, width, height):
	for y in range(top, top + height):
		for x in range(left, left + width):
			set_cell(x, y, TILE_IDX_FLOOR, false, false, false, Vector2(rng.randi_range(0, 3), rng.randi_range(0, 2)))
		
			
func _add_pillars(room):
	if room.width * room.height > 15 and room.width > 4 and room.height > 4:
		var deco_count: = rng.randi_range(3, 8)
		for p in range(deco_count):
			var pillarLeft: = rng.randi_range(1, room.width - 3)
			var pillarTop: = rng.randi_range(1, room.height - 3)
			fill_cells(room.left + pillarLeft, room.top + pillarTop, 2, 2, -1, Vector2.ZERO)	


func _add_walls():
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
					if rng.randf() <= 0.2:
						_add_torch(x, y)
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
			
func _add_torch(x, y):
	var torch_node: Node2D = preload("res://actors/Torch.tscn").instance()
	torch_node.position.x = x * $"/root/Main".GRID_SIZE
	torch_node.position.y = y * $"/root/Main".GRID_SIZE
	add_child(torch_node)

func get_random_floor_cell(left, top, width, height):
	var cells = []
	for y in range(top, top + height):
		for x in range(left, left + width):
			if get_cell(x, y) == TILE_IDX_FLOOR: cells.push_back({"x": x, "y": y})
	return cells[rng.randi_range(0, cells.size()-1)]
	