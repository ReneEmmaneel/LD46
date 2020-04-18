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
		if 'R' in tile:
			for i in range(3):
				var curr = tile.replace('R', i)
				var new_tile = Tile.new(curr)
				all_tiles.append(new_tile)
		else:
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
	## WATER
	var water = 500
	var water_max = 1000
	var water_per_block = 1
	var water_used = -5
	var water_use_increase_curr = 0
	var water_use_increase_time = 10
	var water_ps
	
	func update_water(delta, water_blocks):
		water_ps = water_per_block * water_blocks + water_used
		if drought:
			water_ps -= drought_effect
		water += water_ps * delta
		if water > water_max:
			water = water_max

		water_use_increase_curr += delta
		if water_use_increase_curr > water_use_increase_time:
			water_use_increase_curr -= water_use_increase_time
			water_used -= 1

	## NUTRITION
	var nutrition = 500
	var nutrition_max = 1000
	var nutrition_per_block = 1
	var nutrition_used = -5
	var nutrition_use_increase_curr = 0
	var nutrition_use_increase_time = 10
	var nutrition_ps
	
	func update_nutrition(delta, nutrition_blocks):
		nutrition_ps = nutrition_per_block * nutrition_blocks + nutrition_used
		if famine:
			nutrition_ps -= famine_effect
		nutrition += nutrition_ps * delta
		if nutrition > nutrition_max:
			nutrition = nutrition_max

		nutrition_use_increase_curr += delta
		if nutrition_use_increase_curr > nutrition_use_increase_time:
			nutrition_use_increase_curr -= nutrition_use_increase_time
			nutrition_used -= 1

	## GOLD
	var gold = 0
	var gold_per_block = 1
	var gold_ps
	
	func update_gold(delta, gold_blocks):
		gold_ps = gold_per_block * gold_blocks
		gold += gold_ps * delta

	var disaster_time = 60
	var disaster_time_max = 10
	var disaster_progress = 0
	var disaster_mul = 0.9
	var famine = false
	var famine_effect = 10
	var famine_curr = 0
	var famine_end = 30
	var drought = false
	var drought_effect = 10
	var drought_curr = 0
	var drought_end = 30

	enum DISASTER {DROUGHT, FAMINE, STORM, FIRE}

	var next_disaster
	
	func choose_random_disaster():
		next_disaster = randi() % 4

	func trigger_fire():
		pass

	func trigger_disaster():
		var return_value = next_disaster
		if next_disaster == DISASTER.DROUGHT:
			drought = true
			drought_curr = 0
		if next_disaster == DISASTER.FAMINE:
			famine = true
			famine_curr = 0

		choose_random_disaster()

		return return_value

	func progress_disaster(delta):
		disaster_progress += delta

		if famine:
			famine_curr += delta
			if famine_curr > famine_end:
				famine_curr = 0
				famine = false
		if drought:
			drought_curr += delta
			if drought_curr > drought_end:
				drought_curr = 0
				drought = false

		if disaster_progress > disaster_time:
			disaster_progress = 0
			disaster_time *= disaster_mul
			if disaster_time < disaster_time_max:
				disaster_time = disaster_time_max

			return trigger_disaster()
		return null

	func _init():
		choose_random_disaster()

func update_progress_bars():
	var npb = find_node("NutritionProgressBar")
	var wpb = find_node("WaterProgressBar")
	wpb.value = data.water
	wpb.max_value = data.water_max
	wpb.set_label(data.water, data.water_max, data.water_ps)
	npb.value = data.nutrition
	npb.max_value = data.nutrition_max
	npb.set_label(data.nutrition, data.nutrition_max, data.nutrition_ps)
	
	var glabel = find_node("GoldLabel")
	var format_string = "%.0f gold (%.0f/sec)"
	glabel.set_text(format_string % [data.gold, data.gold_ps])

func redraw():
	if data.gold > global.redraw_cost:
		data.gold -= global.redraw_cost
		find_node("PickTile").choose_random_tiles()

func _process(delta):
	if data:
		var water_blocks = $Grid/Blocks.count_block(global.Blocks.WATER)
		data.update_water(delta, water_blocks)
		var nutrition_blocks = $Grid/Blocks.count_block(global.Blocks.NUTRITION)
		data.update_nutrition(delta, nutrition_blocks)
		var gold_blocks = $Grid/Blocks.count_block(global.Blocks.GOLD)
		data.update_gold(delta, gold_blocks)

	update_progress_bars()

	if Input.is_action_just_pressed("ui_cancel"):
		find_node("PickTile").cancelled()
		selected_tile = null
		find_node("Shadow").clear()

	var disaster = data.progress_disaster(delta)
	if disaster != null:
		if disaster == data.DISASTER.STORM:
			find_node("Blocks").trigger_storm()
		if disaster == data.DISASTER.FIRE:
			pass
		
		update_disaster_name()
	$DisasterBar.value = data.disaster_progress
	$DisasterBar.max_value = data.disaster_time

	var nutrition_label = $Info/col1/Nutrition/NutritionLabel
	var water_label = $Info/col1/Water/WaterLabel

	var famine = data.nutrition_used
	if data.famine:
		famine -= data.famine_effect
	nutrition_label.text = "Nutrition used: " + str(famine) + "/sec"
	
	var water = data.water_used
	if data.drought:
		water -= data.drought_effect
	water_label.text = "Water used: " + str(water) + "/sec"


func _input(event):
	if event.is_action_pressed("1"):
		find_node("PickTile").shortkey(1)
	elif event.is_action_pressed("2"):
		find_node("PickTile").shortkey(2)
	elif event.is_action_pressed("3"):
		find_node("PickTile").shortkey(3)
	elif event.is_action_pressed("r"):
		global.rotate()
	elif event.is_action_pressed("q"):
		redraw()

func update_disaster_name():
	var name
	if data.next_disaster == data.DISASTER.FAMINE:
		name = "Famine"
	if data.next_disaster == data.DISASTER.DROUGHT:
		name = "Drought"
	if data.next_disaster == data.DISASTER.STORM:
		name = "Storm"
	if data.next_disaster == data.DISASTER.FIRE:
		name = "Fire"
	find_node("DisasterName").set_text("Upcoming: " + name)

#start game
func start_game():
	data = Data.new()
	update_disaster_name()
