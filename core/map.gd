extends TileMap

# Game main map, instanced as a singleton 

const MAP_SIZE = 48        # Size of the map, which is always square
const MAX_DEPTH = 4        # Recursion depth when generating

# TileSet indexes for walls and floors
const TILE_IDX_UNSET = -1
const TILE_IDX_WALL = 0
const TILE_IDX_FLOOR = 1

const SCENE_TORCH = preload("res://entities/torch.tscn")
const SCENE_CHEST = preload("res://entities/chest.tscn")
const SCENE_POTION = preload("res://entities/potion.tscn")

var rng: = RandomNumberGenerator.new()

# Will hold each "room" once generation is complete
var all_rooms: = []

func _ready():
	rng.randomize()
	all_rooms.clear()
	
	# IMPORTANT! Generate the whole level by instancing a top level LevelGenZone
	var top_zone = LevelGenZone.new(0, 0, MAP_SIZE, MAP_SIZE, 0) 
	# We need to add the zone to the tree so it can access the map node
	add_child(top_zone)
	
	# Corridors after room generation but BEFORE pillars
	top_zone.make_corridor()
	
	# Add details to each room, pillars and treasure
	for room in all_rooms:
		_add_pillars(room)
		
		# Normal treasure chance
		var treasure_chance = 0.6
		
		# Small chance of mega treasure room, wow!
		if randf() * 100 < (0.0 + globals.depth):
			treasure_chance = 25.0
			
		# Spawn loop factored on room size
		for mi in range(room.width * room.height):
			# treasure = potions & chests
			if randf() * 100 <= treasure_chance:
				var treasure
				# 50/50 chance of potion or chest
				if randf() * 100 < 50:
					treasure = SCENE_CHEST.instance()
				else:
					treasure = SCENE_POTION.instance()
					
				# Mega treasure room, only has chests!
				if treasure_chance >= 25.0:
					treasure = SCENE_CHEST.instance()
					
				var t_cell = get_random_floor_cell(room["left"], room["top"], room["width"], room["height"])
				treasure.position.x = t_cell.x * globals.GRID_SIZE
				treasure.position.y = t_cell.y * globals.GRID_SIZE
				add_child(treasure)
				continue
				
			# Random floor decorations, and stuff to make the map more interesting
			# These have no game effect
			if randf() * 100 <= 5.0:
				var deco = Sprite.new()
				var r: = randi() % 4
				if r == 0: deco.texture = preload("res://assets/misc/deco/blood.png")
				if r == 1: deco.texture = preload("res://assets/misc/deco/crack.png")
				if r == 2: deco.texture = preload("res://assets/misc/deco/skull.png")
				if r == 3: deco.texture = preload("res://assets/misc/deco/bones.png")
				if randf() > 0.5: deco.flip_h = true
				var m_cell = get_random_floor_cell(room["left"], room["top"], room["width"], room["height"])
				deco.position.x = m_cell.x * globals.GRID_SIZE + 8
				deco.position.y = m_cell.y * globals.GRID_SIZE + 8
				deco.add_to_group("decos")
				deco.self_modulate = self_modulate
				add_child(deco)		
	
	# Lastly "paint" the edges with the wall tiles
	_add_walls()
	
#
# Helper to paint a rect with a given tile 
#
func fill_cells(left, top, width, height, tile_idx, tile_coords):
	for y in range(top, top + height):
		for x in range(left, left + width):
			set_cell(x, y, tile_idx, false, false, false, tile_coords)

#
# Paint a rect of floor tiles wich are picked randomly
#
func fill_cells_floor(left, top, width, height):
	for y in range(top, top + height):
		for x in range(left, left + width):
			set_cell(x, y, TILE_IDX_FLOOR, false, false, false, Vector2(rng.randi_range(0, 3), rng.randi_range(0, 2)))
		
#
# Rooms are big empty rectangles, this randomly puts 2x2 "holes" in the rooms
#
func _add_pillars(room):
	if room.width * room.height > 15 and room.width > 4 and room.height > 4:
		var deco_count: = rng.randi_range(3, 8)
		for p in range(deco_count):
			var pillarLeft: = rng.randi_range(1, room.width - 3)
			var pillarTop: = rng.randi_range(1, room.height - 3)
			fill_cells(room.left + pillarLeft, room.top + pillarTop, 2, 2, TILE_IDX_UNSET, Vector2.ZERO)	

#
# OK, wow... 
# This sets the tiles around the edges of rooms to the correct tiles, see dungeon-tiles.tres
# There's a LOT of hard coded logic here based on how the tiles are drawn and their postions in the set
#
func _add_walls():
	for y in range(-2, MAP_SIZE + 2):
		for x in range(-2, MAP_SIZE + 2): 
			if get_cell(x, y) == TILE_IDX_UNSET:
				# Specal 1 thickness walls - doesn't look that good
				if get_cell(x-1, y) == TILE_IDX_FLOOR and get_cell(x+1, y) == TILE_IDX_FLOOR:
					#set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(1, 1))
					fill_cells_floor(x, y, 1, 1)
					continue				
				if get_cell(x, y-1) == TILE_IDX_FLOOR and get_cell(x, y+1) == TILE_IDX_FLOOR:
					#set_cell(x, y, TILE_IDX_WALL, false, false, false, Vector2(2, 1))
					fill_cells_floor(x, y, 1, 1)
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

#
# Place a torch on a south facing wall
#
func _add_torch(x, y):
	var torch_node: = SCENE_TORCH.instance()
	torch_node.position.x = x * globals.GRID_SIZE
	torch_node.position.y = y * globals.GRID_SIZE
	add_child(torch_node)

#
# Helper to pick an random open floor tile in given rect
# Returns a tuple/dict {x, y}
#
func get_random_floor_cell(left, top, width, height):
	# Build an array of all floor tiles inside given rect
	var cells = []
	for y in range(top, top + height):
		for x in range(left, left + width):
			if get_cell(x, y) == TILE_IDX_FLOOR: cells.push_back({"x": x, "y": y})
			
	# Pick one at random
	return cells[rng.randi_range(0, cells.size()-1)]
	
