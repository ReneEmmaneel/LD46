extends TileMap

var w1 = 2
var w2 = 7
var w3 = 13
var h = 2
var hbetw = 3

func rand():
	return randi() % 5 - 2

func generate(start):
	for i in range(500):
		set_cellv(Vector2(w1 + rand(), start + h + hbetw * i + rand()), global.Blocks.TREE, randi() %2, randi() %2)
		set_cellv(Vector2(w2 + rand(), start + h + hbetw * i + rand()), global.Blocks.TREE, randi() %2, randi() %2)
		set_cellv(Vector2(w3 + rand(), start + h + hbetw * i + rand()), global.Blocks.TREE, randi() %2, randi() %2)

var speed = 100
func _process(delta):
	position.y -= delta * speed
	if position.y < -32 * 100:
		position.y = 0

func _ready():
	generate(0)

