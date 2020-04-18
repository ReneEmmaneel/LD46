extends TileMap

var tree_tiles = [Vector2(5,5), Vector2(6,5), Vector2(5,6), Vector2(6,6)]

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
		print("click")

func click():
	var mouse_pos = get_global_mouse_position()
	var mx = mouse_pos.x
	var my = mouse_pos.y
	var coor = world_to_map(Vector2(mx, my) - get_parent().get_position())
