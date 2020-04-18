extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var nodes
var preview

# Called when the node enters the scene tree for the first time.
func _ready():
	var a = get_node("Tile1/TileMap")
	var b = get_node("Tile2/TileMap")
	var c = get_node("Tile3/TileMap")
	preview = find_parent("Game").find_node("Preview")
	nodes = [a,b,c]

func shortkey(key):
	nodes[key-1].clicked()

func cancelled():
	for tile_obj in nodes:
		if tile_obj.currently_laying:
			tile_obj.currently_laying = false
			tile_obj.load_tile(tile_obj.prev_tile)
	preview.empty_tile_map()

func done():
	for tile_obj in nodes:
		if tile_obj.currently_laying:
			tile_obj.done = true
	preview.empty_tile_map()

func uncancel():
	for tile_obj in nodes:
		tile_obj.currently_laying = false
		if tile_obj.current_tile == null:
			tile_obj.prev_tile = null

func random_tiles_if_empty():
	for tile_obj in nodes:
		if tile_obj.current_tile != null or tile_obj.currently_laying == true:
			return
	choose_random_tiles()

func get_random_tile():
	var Game = find_parent("Game")
	var all_tiles = Game.get_all_tiles()
	return all_tiles[randi() % all_tiles.size()]

func choose_random_tiles():
	for tile_obj in nodes:
		tile_obj.load_tile(get_random_tile())
		tile_obj.done = false
