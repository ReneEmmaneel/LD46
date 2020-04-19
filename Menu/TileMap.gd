extends TileMap

var height = 20
var width = 1000
var h1 = 4
var w1 = 5
var wb = 6

var fire = false

func fill_random():
	randomize()
	var tree = []
	var done = []
	var list = []
	var next = []

	var dir = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]

	var cw = w1
	var ch = h1
	while cw < width:
		for x in range(2):
			for y in range(2):
				next.append(Vector2(cw + x, ch + y))
				tree.append(Vector2(cw + x, ch + y))
		set_cellv(Vector2(cw, ch), global.Blocks.TREE)
		cw += wb

	var inf = 100
	while next.size() > 0:
		for n in next:
			list.append(n)
		next = []

		while list.size() > 0:
			var li = randi() % list.size()
			var l = list[li]
			for d in dir:
				var lookat = l + d
				if lookat.y > -1 && lookat.y < 25 && lookat.x > -1 && lookat.x < 150:
					if get_cellv(lookat) == -1 and (not lookat in tree):
						if l in tree:
							set_cellv(lookat, randi() % 3)
							next.append(lookat)
						else:
							var rand = randi() % 100
							if rand < 40:
								set_cellv(lookat, get_cellv(l))
								next.append(lookat)
			done.append(l)
			list.remove(li)
		list = []
		inf -= 1
		if inf <= 0:
			break

var speed = 100
func _process(delta):
	position.x -= speed * delta

func _ready():
	fill_random()
