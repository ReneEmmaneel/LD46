extends "res://Menu/TitleScreen.gd"

var start = false
var curr = 0
var finished = 3

func show_score(delta):
	if start:
		curr += delta
		if curr > finished:
			curr = finished
			start = false
			$AnimationPlayer.play("thanks")
			find_node("StartGame").disabled = false
		var n = find_node("Score")
		if n:
			n.set_text("%01.0d:%02.0d" % [int(global.time * curr / finished / 60), int(global.time * curr / finished) % 60])

func _ready():
	$AnimationPlayer.play("view_label")
	find_node("StartGame").disabled = true

func _process(delta):
	show_score(delta)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "view_label":
		$AnimationPlayer.play("view_time")
	elif anim_name == "view_time":
		start = true
