extends TileMap

var tree_tiles = [Vector2(5,5), Vector2(6,5), Vector2(5,6), Vector2(6,6)]
var grid_size = 12
var Game

#count amount blocks of given type are connected to tree_tile
func count_block(type):
	var list = []
	var new = tree_tiles
	var next = []
	var count = 0
	var direction = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]

	var target
	while new.size() > 0:
		for tile in new:
			for dir in direction:
				target = tile + dir
				if !(target in list) and !(target in new) and !(target in next):
					if get_cellv(target) == type:
						count += 1
						next.append(target)
					elif get_cellv(target) == global.Blocks.TREE:
						next.append(target)
		for n in new:
			list.append(n)
		new = []
		for n in next:
			new.append(n)
		next = []
	return count

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("click"):
		click()

func get_mouse_coor():
	var mouse_pos = get_global_mouse_position()
	var mx = mouse_pos.x
	var my = mouse_pos.y
	var coor = world_to_map(Vector2(mx, my) - get_parent().get_position())
	return coor

func click():
	var succes = add_block(get_mouse_coor(), true)
	if succes:
		get_parent().get_parent().set_selected_tile(null)
		var picktile = get_parent().get_parent().find_node("PickTile")
		picktile.done()
		picktile.uncancel()
		picktile.random_tiles_if_empty()

func check_empty(position):
	if position.x >= 0 and position.x < grid_size and position.y >= 0 and position.y < grid_size:
		var type = get_cellv(position)
		return (type == global.Blocks.SHADOW) or (type == -1 and !(position in tree_tiles))
	else:
		return false

#second argument is wheter to add it or only a shadow version
func add_block(position, add):
	var tile = get_parent().get_parent().selected_tile
	if tile:
		for pos in tile.get_positions():
			if pos[1] != -1:
				var target = position + pos[0]
				if !check_empty(target):
					return
		for pos in tile.get_positions():
			if pos[1] != -1:
				var target = position + pos[0]
				if add:
					set_cellv(target, pos[1])
				else:
					set_cellv(target, global.Blocks.SHADOW)
		return add
	return false

