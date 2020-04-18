extends Node2D

var all_tiles = []
var selected_tile

func get_all_tiles():
	return all_tiles

func set_selected_tile(tile):
	selected_tile = tile

func load_tiles():
	var Tile = load("res://Game/TileObj.gd")
	var text = load_text_file("res://Game/tiles.txt")
	var tiles = text.split("\n\n")
	for tile in tiles:
		var new_tile = Tile.new(tile)
		all_tiles.append(new_tile)

func _ready():
	randomize() #sets the seed

	load_tiles()
	
	$PickTile.choose_random_tiles()
	
	start_game()

	pass # Replace with function body.

func load_text_file(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = f.get_as_text()
	f.close()
	return text

###GAME LOGIC####

var data

class Data:
	var water = 500
	var water_max = 1000
	var water_per_block = 1
	var water_ps
	
	func update_water(delta, water_blocks):
		water_ps = water_per_block * water_blocks
		water += water_ps * delta
		if water > water_max:
			water = water_max

	var nutrition = 500
	var nutrition_max = 1000
	var nutrition_per_block = 1
	var nutrition_ps
	
	func update_nutrition(delta, nutrition_blocks):
		nutrition_ps = nutrition_per_block * nutrition_blocks
		nutrition += nutrition_ps * delta
		if nutrition > nutrition_max:
			nutrition = nutrition_max
	
	func _init():
		pass

func update_progress_bars():
	var npb = find_node("NutritionProgressBar")
	var wpb = find_node("WaterProgressBar")
	wpb.value = data.water
	wpb.max_value = data.water_max
	wpb.set_label(data.water, data.water_max, data.water_ps)
	npb.value = data.nutrition
	npb.max_value = data.nutrition_max
	npb.set_label(data.nutrition, data.nutrition_max, data.nutrition_ps)

func _process(delta):
	if data:
		var water_blocks = $Grid/Blocks.count_block(global.Blocks.WATER)
		data.update_water(delta, water_blocks)
		var nutrition_blocks = $Grid/Blocks.count_block(global.Blocks.NUTRITION)
		data.update_nutrition(delta, nutrition_blocks)

	update_progress_bars()
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		find_node("PickTile").cancelled()
		selected_tile = null
		find_node("Shadow").clear()


func _input(event):
	if event.is_action_pressed("1"):
		find_node("PickTile").shortkey(1)
	elif event.is_action_pressed("2"):
		find_node("PickTile").shortkey(2)
	elif event.is_action_pressed("3"):
		find_node("PickTile").shortkey(3)
	elif event.is_action_pressed("r"):
		find_node("PickTile").choose_random_tiles()

#start game
func start_game():
	data = Data.new()
