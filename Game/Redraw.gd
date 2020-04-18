extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("click"):
		mouse_click()

func mouse_click():
	var m = get_local_mouse_position()
	var size = 16
	if m.x >= -size and m.x < size and m.y >= -size and m.y < size:
		find_parent("Game").redraw()
