extends ProgressBar


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_label(curr, maximum, ps):
	var format_string = "%.0f/%.0f (%.0f/sec)"
	$Label.set_text(format_string % [curr, maximum, ps])
