extends TileMap

var tile_map_size = 3

func empty_tile_map():
	for x in range(tile_map_size):
		for y in range(tile_map_size):
			set_cellv(Vector2(x,y), -1)

func load_tile(tile):
	if tile == null:
		return
	empty_tile_map()
	for pos in tile.get_positions():
		set_cellv(global.get_rotated(pos[0], Vector2(0,0)) + Vector2(1,1), pos[1])

func _ready():
	pass # Replace with function body.
