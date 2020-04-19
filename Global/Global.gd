extends Node

enum Blocks {BANK, NUTRITION, WATER, TREE, SHADOW, STOP, SHADOW2, NUTRITION_GREY, WATER_GREY, EMPTY, BANK_GREY, FIRE}
var redraw_cost = 250
var rotate = 0
var music_playing = true
var first_time = true
var paused = false

var time = 0

func rotate():
	rotate = (rotate + 1) % 4
	var game = get_tree().get_root().get_node("Game")
	var selected_tile = game.selected_tile
	game.find_node("Preview").load_tile(selected_tile)
	game.find_node("Shadow").clear()
	game.find_node("Shadow").hovered()
	game.find_node("PickTile").rotate_tile_pickers()

func get_rotated(org, center):
	var rotation1 = [[Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)],
					 [Vector2(0,1), Vector2(0,0), Vector2(0,-1)],
					 [Vector2(1,1), Vector2(1,0), Vector2(1,-1)]]
	var new = org
	var curr_rotate = rotate * 3 #clockwise, counterclockwise = 1, this is super stupid

	while center == Vector2(0,0) and curr_rotate > 0:
		new = rotation1[new.y+1][new.x+1]
		curr_rotate -= 1

	return new

func _ready():
	print("read")

func toggle_music():
	if music_playing:
		music_playing = false
		$Music.stream_paused = true
		return false
	else:
		global.music_playing = true
		$Music.stream_paused = false
		return true
