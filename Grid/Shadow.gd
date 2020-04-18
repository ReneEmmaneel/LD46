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

func draw_all():
	clear()
	hovered()

func clear():
	for x in range(12):
		for y in range(12):
			set_cellv(Vector2(x,y), -1)

func check_empty(position):
	if position.x >= 0 and position.x < grid_size and position.y >= 0 and position.y < grid_size:
		return true
	else:
		return false


func check_really_empty(position):
	if position.x >= 0 and position.x < grid_size and position.y >= 0 and position.y < grid_size:
		var type = $"../Blocks".get_cellv(position)
		return (type == global.Blocks.SHADOW) or (type == -1 and !(position in $"../Blocks".tree_tiles))
	else:
		return false

#second argument is wheter to add it or only a shadow version
func add_block(position, add):
	if !has_selection():
		return
	var tile = get_parent().get_parent().selected_tile
	if tile:
		if tile.get_positions()[0][1] == global.Blocks.EMPTY:
			var poss = tile.get_positions()
			if position.x >= 1 && position.x <= 10 && position.y >= 1 && position.y <= 10:
				if !(position.x >= 4 and position.x <= 7 and position.y >= 4 and position.y <= 7):
					for pos in poss:
						var target = position + global.get_rotated(pos[0], Vector2(0,0))
						set_cellv(target, global.Blocks.SHADOW2)
					
		else:
			var really_empty = true
			for pos in tile.get_positions():
				if pos[1] != -1:
					var target = position + global.get_rotated(pos[0], Vector2(0,0))
					if !check_empty(target):
						return
					if !check_really_empty(target):
						really_empty = false
			for pos in tile.get_positions():
				if pos[1] != -1:
					var target = position + global.get_rotated(pos[0], Vector2(0,0))
					if add:
						set_cellv(target, pos[1])
					else:
						if check_really_empty(target):
							var block
							if pos[1] == global.Blocks.NUTRITION:
								block = global.Blocks.NUTRITION_GREY
							if pos[1] == global.Blocks.WATER:
								block = global.Blocks.WATER_GREY
							if pos[1] == global.Blocks.BANK:
								block = global.Blocks.BANK_GREY
							set_cellv(target, block)
						else:
							set_cellv(target, global.Blocks.SHADOW)
