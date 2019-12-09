extends TileMap

const MAP_SIZE = 48
const MAX_DEPTH = 4
const SPLIT_PERC = 30
const TILE_IDX_WALL = 0
const TILE_IDX_FLOOR = 1
var rng: = RandomNumberGenerator.new()
var allRooms: = []

func _ready():
	rng.randomize()
	
	# Generate the level
	var top_zone = LevelGenZone.new(0, 0, MAP_SIZE, MAP_SIZE, 0) 
	add_child(top_zone)
	top_zone.make_corridor()
	
	# Set player start room & location
	allRooms.shuffle()
	$Player.position.x = (allRooms[0]["left"] + floor(allRooms[0]["width"] / 2)) * 16
	$Player.position.y = (allRooms[0]["top"] + floor(allRooms[0]["height"] / 2)) * 16

	# Draw walls on edges of rooms
	for y in range(0, MAP_SIZE):
		for x in range(0, MAP_SIZE): 
			if get_cell(x, y) == -1:
				# Specal 1 thickness walls
				if get_cell(x-1, y) == TILE_IDX_FLOOR and get_cell(x+1, y) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(1, 1))
					continue				
				if get_cell(x, y-1) == TILE_IDX_FLOOR and get_cell(x, y+1) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(2, 1))
					continue		
									
				# Cardinal directions
				if get_cell(x, y+1) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(1, 0))
					continue
				if get_cell(x, y-1) == TILE_IDX_FLOOR:
					# "north" walls are a special case due to fake perspective
					if get_cell(x-1, y) == TILE_IDX_FLOOR:
						set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(0, 5))
					elif get_cell(x+1, y) == TILE_IDX_FLOOR:
						set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(5, 5))						
					else:
						set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(1, 4))
					continue
				if get_cell(x+1, y) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(0, 0))
					continue
				if get_cell(x-1, y) == TILE_IDX_FLOOR:
					set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(5, 0))
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