extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	find_node("StartGame").grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Game/Game.tscn")


func _on_MusicButton_pressed():
	if global.toggle_music():
		find_node("MusicButton").texture_normal = load("res://tileset/misc/music.png")
	else:
		find_node("MusicButton").texture_normal = load("res://tileset/misc/music2.png")
