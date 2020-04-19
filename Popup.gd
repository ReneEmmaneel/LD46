extends Popup

export(bool) var right
export(bool) var arrow = true
export(String) var text
export(bool) var big = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if !right:
		get_node("ColorRect/Arrow").anchor_left = 0.1
	text = text.replace("\\","\n")
	get_node("ColorRect/ColorRect/Label").set_text(text)
	if !arrow:
		find_node("Sprite").visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Popup_popup_hide():
	var Game = get_tree().get_root().get_node("Game")
	if Game:
		Game.popup_gone()
