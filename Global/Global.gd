extends Node

enum Blocks {GOLD, NUTRITION, WATER, TREE, SHADOW, STOP, SHADOW2}
var redraw_cost = 250
var rotate = 0

func rotate():
	rotate = (rotate + 1) % 4

#Yeeeeeeehaw
func get_rotated(org, center):
	var rotation1 = [[Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)],
					 [Vector2(0,1), Vector2(0,0), Vector2(0,-1)],
					 [Vector2(1,1), Vector2(1,0), Vector2(1,-1)]]
	var new = org
	var curr_rotate = rotate

	print(rotate)
	while center == Vector2(0,0) and curr_rotate > 0:
		new = rotation1[new.y+1][new.x+1]
		curr_rotate -= 1

	return new

func _ready():
	pass
