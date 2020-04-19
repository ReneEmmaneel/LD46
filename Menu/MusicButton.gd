extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_pictures()



func set_pictures():
	if global.music_playing:
		texture_normal = load("res://tileset/misc/music.png")
		texture_hover = load("res://tileset/misc/music_hover.png")
	else:
		texture_normal = load("res://tileset/misc/music_cross.png")
		texture_hover = load("res://tileset/misc/music_cross_hover.png")


func _on_MusicButton_pressed():
	set_pictures()
