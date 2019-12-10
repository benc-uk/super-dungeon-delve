extends Node
class_name LevelGenZone

var left: float
var top: float
var width: float
var height: float	
var center: Vector2
var depth: int
var rng: = RandomNumberGenerator.new()
var map: TileMap
	
func _init(l: float, t: float, w: float, h: float, d: int):
	rng.randomize()
	left = l
	top = t
	width = w
	height = h
	depth = d    
	center = Vector2(floor(width / 2) + left, floor(height / 2) + top)


func _ready():
	map = $"/root/Map"
	#print("New zone %s: left:%s, top:%s, width:%s, height:%s" % [depth, left, top, width, height])
	if depth < map.MAX_DEPTH and width > 0 and height > 0:
		var halfW = ceil(width / 2)
		var halfH = ceil(height / 2)
		
		var splitHori: = true;
		if width / height >= 1.25:
			splitHori = false
		elif height / width >= 1.25:
			splitHori = true
		else:
			splitHori = rand_range(0, 100) > 50
 	
		#print(" splitHori ===== ", splitHori)
		if splitHori:
			var offset = (height / 100.0) * map.SPLIT_PERC
			var splitH = rng.randi_range(halfH - offset, halfH + offset)
			add_child(get_script().new(left, top, width, splitH, depth + 1))
			add_child(get_script().new(left, top + splitH, width, height - splitH, depth + 1))
		else:
			var offset = (width / 100.0) * map.SPLIT_PERC
			var splitW = rng.randi_range(halfW - offset, halfW + offset)
			add_child(get_script().new(left, top, splitW, height, depth + 1))
			add_child(get_script().new(left + splitW, top, width - splitW, height, depth + 1))
	else:
		_make_room()


func _make_room():
	var roomWidth = rng.randi_range(floor(width / 2), max(2, width - 2))
	var roomHeight = rng.randi_range(floor(height / 2), max(2, height - 2))
	var roomLeft = left + rng.randi_range(1, max(1, width - roomWidth - 1))
	var roomTop = top + rng.randi_range(1, max(1, height - roomHeight - 1))
	#print(" New room %s: left:%s, top:%s, width:%s, height:%s" % [depth, roomX, roomY, roomWidth, roomHeight])
	if roomWidth < 1 or roomWidth < 1:
		return
	map.fill_cells_floor(roomLeft, roomTop, roomWidth, roomHeight)
	map.all_rooms.push_front({"left":roomLeft, "top":roomTop, "width":roomWidth, "height":roomHeight})


func make_corridor():
	# Only draw corridor between zones with children (not leaf nodes)
	if get_child_count() > 0:
		var a = get_child(0)
		var b = get_child(1)
		
		# Work out direction
		if a.center.x != b.center.x:
			map.fill_cells_floor(a.center.x, a.center.y, b.center.x - a.center.x, 1)
		if a.center.y != b.center.y:
			map.fill_cells_floor(a.center.x, a.center.y, 1, b.center.y - a.center.y)

		# Recurse down child zones
		a.make_corridor()
		b.make_corridor()