extends TileMap

var grid_size = 12

func _ready():
	pass

func has_selection():
	return get_parent().get_parent().selected_tile != null

func get_mouse_coor():
	var mouse_pos = get_global_mouse_position()
	var mx = mouse_pos.x
	var my = mouse_pos.y
	var coor = world_to_map(Vector2(mx, my) - get_parent().get_position())

func _input(event):
	if event is InputEventMouseMotion:
		clear()
		hovered()
	if event is InputEventMouseButton:
		if !has_selection():
			clear()

func hovered():
	var m = get_local_mouse_position()
	add_block(world_to_map(m), false)

func clear():
	for x in range(12):
		for y in range(12):
			set_cellv(Vector2(x,y), -1)

func check_empty(position):
	if position.x >= 0 and position.x < grid_size and position.y >= 0 and position.y < grid_size:
		return true
	else:
		return false

#second argument is wheter to add it or only a shadow version
func add_block(position, add):
	if !has_selection():
		return
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
