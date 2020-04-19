extends TileMap

var tree_tiles = [Vector2(5,5), Vector2(6,5), Vector2(5,6), Vector2(6,6)]
var grid_size = 12
var Game

#count amount blocks of given type are connected to tree_tile
func count_block(type):
	var nutr = [global.Blocks.NUTRITION, global.Blocks.NUTRITION_GREY]
	var water = [global.Blocks.WATER, global.Blocks.WATER_GREY]
	var bank = [global.Blocks.BANK, global.Blocks.BANK_GREY]

	var curr_types

	var count = 0
	if type in nutr or type in water or type in bank:
		if type in nutr:
			curr_types = nutr
		elif type in water:
			curr_types = water
		else:
			curr_types = bank


		var list = []
		var new = tree_tiles
		var next = []
		var direction = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]
	
		var target
		while new.size() > 0:
			for tile in new:
				for dir in direction:
					target = tile + dir
					if !(target in list) and !(target in new) and !(target in next):
						if get_cellv(target) in curr_types:
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

		for tile in get_used_cells():
			type = get_cellv(tile)
			if type != global.Blocks.TREE:
				if tile in list:
					set_cellv(tile, curr_types[0])
				elif type in curr_types:
					set_cellv(tile, curr_types[1])

	return count

func _ready():
	pass


func trigger_storm():
	for i in range(5):
		var x = randi() % grid_size
		var y = randi() % grid_size
		var vec = Vector2(x,y)
		if vec in tree_tiles:
			i -= 1
		else:
			set_cellv(Vector2(x,y), global.Blocks.STOP)

func trigger_fire():
	var rand = randi() % 6
	if rand >= 3:
		rand += 4
	if randi() % 2:
		for y in range(12):
			for x in range(3):
				set_cellv(Vector2(x+rand,y), global.Blocks.FIRE)
	else:
		for y in range(3):
			for x in range(12):
				set_cellv(Vector2(x,y+rand), global.Blocks.FIRE)

	var t = Timer.new()
	t.set_wait_time(1.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")

	for x in range(12):
		for y in range(12):
			if get_cellv(Vector2(x,y)) ==  global.Blocks.FIRE:
				set_cellv(Vector2(x,y), -1)



func _process(delta):
	if !global.paused:
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
	var Game = get_parent().get_parent()
	if succes:
		Game.get_node("Place").play()
		Game.set_selected_tile(null)
		var picktile = Game.find_node("PickTile")
		picktile.done()
		picktile.uncancel()
		picktile.random_tiles_if_empty()
	else:
		if check_on_map(get_mouse_coor()):
			Game.get_node("Error").play()
	count_block(global.Blocks.NUTRITION)
	count_block(global.Blocks.WATER)
	count_block(global.Blocks.BANK)

func check_on_map(position):
	return position.x >= 0 and position.x < grid_size and position.y >= 0 and position.y < grid_size

func check_empty(position):
	if check_on_map(position):
		var type = get_cellv(position)
		return (type == global.Blocks.SHADOW) or (type == -1 and !(position in tree_tiles)) or (type == global.Blocks.FIRE)
	else:
		return false

#second argument is wheter to add it or only a shadow version
func add_block(position, add):
	var tile = get_parent().get_parent().selected_tile
	if tile:
		if tile.get_positions()[0][1] == global.Blocks.EMPTY:
			var poss = tile.get_positions()
			if position.x >= 1 && position.x <= 10 && position.y >= 1 && position.y <= 10:
				if !(position.x >= 4 and position.x <= 7 and position.y >= 4 and position.y <= 7):
					for pos in poss:
						var target = position + global.get_rotated(pos[0], Vector2(0,0))
						set_cellv(target, -1)
					return true
		else:
			for pos in tile.get_positions():
				if pos[1] != -1:
					var target = position + global.get_rotated(pos[0], Vector2(0,0))
					if !check_empty(target):
						return
			for pos in tile.get_positions():
				if pos[1] != -1:
					var target = position + global.get_rotated(pos[0], Vector2(0,0))
					if add:
						set_cellv(target, pos[1])
					else:
						set_cellv(target, global.Blocks.SHADOW)
			return add
	return false

