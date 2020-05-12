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
	var kongregate = true
	var text = ""
	if !kongregate:
		var f = File.new()
		var err = f.open(path, File.READ)
		text = f.get_as_text()
		f.close()
		print(path)
		print(text)
	else:
		if path == "res://Game/tiles.txt":
			text = "xxx\nxRR\nxRR\n\nxxx\n111\n222\n\nxxx\nRRx\nxRR\n\nRxx\nxRx\nxxR\n\nxxx\nx21\nx11\n\nxxx\nx12\nx22\n\nxx1\n111"
			text += "\n\nxxx\nxRx\nxxx\n\nxxx\nRxR\nxxx\n\nxxx\nxRR\nxRx\n\nxxx\nxRx\nRxR\n"
		elif path == "res://Game/empty.txt":
			text = "999\n999\n999\n"
		elif path == "res://Game/food.txt":
			text = "xxx\nx1x\nxxx\n"
		elif path == "res://Game/water.txt":
			text = "xxx\nx2x\nxxx\n"
		else:
			print(path)

	return text

###GAME LOGIC####

var data

class Data:
	var time = 0


	## WATER
	var water = 500
	var water_max = 1000
	var water_per_block = 1
	var water_used = -10
	var water_use_increase_curr = 00
	var water_use_increase_time = 15
	var water_ps
	
	func update_water(delta, water_blocks):
		water_ps = water_per_block * water_blocks
		if drought:
			water_ps += water_used * drought_effect
		else:
			water_ps += water_used
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
	var nutrition_used = -10
	var nutrition_use_increase_curr = 0
	var nutrition_use_increase_time = 15
	var nutrition_ps
	
	func update_nutrition(delta, nutrition_blocks):
		nutrition_ps = nutrition_per_block * nutrition_blocks
		if famine:
			nutrition_ps += nutrition_used * famine_effect
		else:
			nutrition_ps += nutrition_used

		nutrition += nutrition_ps * delta
		if nutrition > nutrition_max:
			nutrition = nutrition_max

		nutrition_use_increase_curr += delta
		if nutrition_use_increase_curr > nutrition_use_increase_time:
			nutrition_use_increase_curr -= nutrition_use_increase_time
			nutrition_used -= 1

	## GOLD
	var gold = 250
	var gold_per_block = 1
	var gold_ps
	
	func update_gold(delta, gold_blocks):
		gold_ps = gold_per_block * gold_blocks
		gold += gold_ps * delta
		if gold <= 0:
			gold = 0 #cant go below 0

	var disaster_time = 30
	var disaster_time_max = 10
	var disaster_progress = 0
	var disaster_mul = 0.9
	var famine = false
	var famine_effect = 2
	var famine_curr = 0
	var famine_end = 15
	var drought = false
	var drought_effect = 2
	var drought_curr = 0
	var drought_end = 15
	var prev_disaster = null

	enum DISASTER {DROUGHT, FAMINE, STORM, FIRE}

	var next_disaster
	
	func choose_random_disaster():
		next_disaster = randi() % 4
		if next_disaster == prev_disaster:
			choose_random_disaster()

	func trigger_disaster():
		var return_value = next_disaster
		if next_disaster == DISASTER.DROUGHT:
			drought = true
			drought_curr = 0
		if next_disaster == DISASTER.FAMINE:
			famine = true
			famine_curr = 0

		prev_disaster = next_disaster
		choose_random_disaster()

		return return_value

	func cont_famine(delta):
		if famine:
			famine_curr += delta
			if famine_curr > famine_end:
				famine_curr = 0
				famine = false
				return true
		return false

	func cont_drought(delta):
		if drought:
			drought_curr += delta
			if drought_curr > drought_end:
				drought_curr = 0
				drought = false
				return true
		return false

	func progress_disaster(delta):
		disaster_progress += delta

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
		selected_tile = null
		data.gold -= global.redraw_cost
		find_node("PickTile").choose_random_tiles()

func animate_nutrition():
	find_node("NutrAnim").play("alarm")

func stop_animate_nutrition():
	find_node("NutrAnim").stop()

func animate_water():
	find_node("WaterAnim").play("drought")

func stop_animate_water():
	find_node("WaterAnim").stop()

func _process(delta):
	if data.nutrition < 200 or data.water < 200:
		if !$Alarm.playing:
			$Alarm.play()
	else:
		$Alarm.stop()
	if global.paused:
		return
	data.time += delta
	find_node("Time").set_text("%01.0d:%02.0d" % [int(data.time / 60), int(data.time) % 60])

	if data.water <= 0 || data.nutrition <= 0:
		global.time = data.time
		global.first_time = false
		get_tree().change_scene("res://Menu/EndScreen.tscn")

	if data:
		var water_blocks = $Grid/Blocks.count_block(global.Blocks.WATER)
		data.update_water(delta, water_blocks)
		var nutrition_blocks = $Grid/Blocks.count_block(global.Blocks.NUTRITION)
		data.update_nutrition(delta, nutrition_blocks)
		var gold_blocks = $Grid/Blocks.count_block(global.Blocks.BANK)
		data.update_gold(delta, gold_blocks)

	update_progress_bars()

	if Input.is_action_just_pressed("ui_cancel"):
		find_node("PickTile").cancelled()
		selected_tile = null
		find_node("Shadow").clear()

	if data.cont_famine(delta):
		stop_animate_nutrition()

	if data.cont_drought(delta):
		stop_animate_water()

	var disaster = data.progress_disaster(delta)
	if disaster != null:
		if disaster == data.DISASTER.STORM:
			find_node("Blocks").trigger_storm()
			$StormSound.play()
		if disaster == data.DISASTER.FIRE:
			find_node("Blocks").trigger_fire()
			$FireSound.play()
		if disaster == data.DISASTER.FAMINE:
			animate_nutrition()
			$Famine.play()
		if disaster == data.DISASTER.DROUGHT:
			$Famine.play()
			animate_water()
		
		update_disaster_name()
	$DisasterBar.value = data.disaster_progress
	$DisasterBar.max_value = data.disaster_time

	var nutrition_label = find_node("NutritionLabel")
	var water_label = find_node("WaterLabel")

	var famine = data.nutrition_used
	if data.famine:
		famine *= 2
	nutrition_label.text = "Food consumed: " + str(famine) + "/sec"
	
	var water = data.water_used
	if data.drought:
		water *= 2
	water_label.text = "Water consumed: " + str(water) + "/sec"

	find_node("Button").disabled = data.gold < 300
	find_node("Button2").disabled = data.gold < 500
	find_node("Button3").disabled = data.gold < 500
	find_node("Button4").disabled = data.gold < 1000


func _input(event):
	if !global.paused:
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
	var tooltip
	if data.next_disaster == data.DISASTER.FAMINE:
		name = "Famine"
		tooltip = "Famine will increase food consumption by two"
	if data.next_disaster == data.DISASTER.DROUGHT:
		name = "Drought"
		tooltip = "Drought will increase water consumption by two"
	if data.next_disaster == data.DISASTER.STORM:
		name = "Storm"
		tooltip = "Storm will randomely make blocks unusable"
	if data.next_disaster == data.DISASTER.FIRE:
		name = "Fire"
		tooltip = "Fire will destroy a random 3 wide row or column"
	find_node("DisasterName").set_text("Upcoming: " + name)
	find_node("DisasterBar").hint_tooltip = tooltip

#start game
func start_game():
	data = Data.new()
	update_disaster_name()

	if global.first_time:
		tutorial()

###TUTORIAL

var tutorial_list

func tutorial():
	tutorial_list = [$Popup1, $Popup2, $Popupp, $Popup5, $Popup4, $Popup3, $Popup6]
	global.paused = true
	if global.first_time:
		popup_gone()

func popup_gone():
	if tutorial_list.size() > 0:
		tutorial_list[0].popup()
		tutorial_list.remove(0)
	else:
		global.paused = false

func add_single_tile(text_file, cost = 0):
	find_node("PickTile").cancelled()
	
	var Tile = load("res://Game/TileObj.gd")
	var text = load_text_file(text_file)
	var new_tile = Tile.new(text, cost)

	set_selected_tile(new_tile)
	find_node("Preview").load_tile(new_tile)

func _on_Button_pressed():
	if data.gold >= 300:
		data.gold -= 300
		add_single_tile("res://Game/empty.txt", 300)

func _on_Button2_pressed():
	if data.gold >= 500:
		data.gold -= 500
		add_single_tile("res://Game/food.txt", 500)

func _on_Button3_pressed():
	if data.gold >= 500:
		data.gold -= 500
		add_single_tile("res://Game/water.txt", 500)

func _on_Button4_pressed():
	if data.gold >= 1000:
		data.gold -= 1000
		data.nutrition += 500
		if data.nutrition >= data.nutrition_max:
			data.nutrition = data.nutrition_max
		data.water += 500
		if data.water >= data.water_max:
			data.water = data.water_max

func _on_TextureButton_pressed():
	global.toggle_music()

