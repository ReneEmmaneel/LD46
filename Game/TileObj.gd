extends Node

var positions
var start = -1
var rotation = 0

func get_random_tile():
	var Game = find_parent("Game")
	var all_tiles = Game.get_all_tiles()
	return all_tiles[randi() % all_tiles.size()]

func text_to_positions(positions_text):
	var positions = []
	var curr_pos = Vector2(start, start)
	for t in positions_text:
		if t == '\n':
			curr_pos.x = start
			curr_pos.y += 1
		else:
			if t == 'x':
				t = -1
			else:
				t = int(t)
			positions.append([curr_pos, t])
			curr_pos.x += 1
	return positions

func get_positions():
	return positions

func _init(positions_text):
	self.positions = self.text_to_positions(positions_text)
	""""""

func _ready():
	pass # Replace with function body.
