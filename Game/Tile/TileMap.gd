extends TileMap

var tile_map_size = 3
var current_tile
var prev_tile
var done = false
var currently_laying = false
var preview

func empty_tile_map():
	for x in range(tile_map_size):
		for y in range(tile_map_size):
			set_cellv(Vector2(x,y), -1)

func get_random_tile():
	var Game = find_parent("Game")
	var all_tiles = Game.get_all_tiles()
	return all_tiles[randi() % all_tiles.size()]

func load_tile(tile):
	if tile == null:
		tile = get_random_tile()
	current_tile = tile
	empty_tile_map()
	for pos in tile.get_positions():
		set_cellv(global.get_rotated(pos[0], Vector2(0,0)) + Vector2(1,1), pos[1])
	currently_laying = false

func _ready():
	preview = find_parent("Game").find_node("Preview")

func _process(delta):
	if Input.is_action_just_pressed("click"):
		mouse_click()

func mouse_click():
	var m = get_local_mouse_position()
	var size = 32 * tile_map_size
	if m.x >= 0 and m.x < size and m.y >= 0 and m.y < size:
		clicked()

func clicked():
	if !done:
		if currently_laying:
			currently_laying = false
			preview.empty_tile_map()
			var game = get_tree().get_root().get_node("Game")
			game.selected_tile = null
			load_tile(prev_tile)
			game.find_node("Shadow").clear()
			game.find_node("Shadow").hovered()
		else:
			get_parent().get_parent().get_parent().cancelled()
			$"../../../..".set_selected_tile(current_tile)
			preview.load_tile(current_tile)
			empty_tile_map()
			prev_tile = current_tile
			current_tile = null
			currently_laying = true
