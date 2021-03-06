extends Node

var score: int
var play_music := true
var skip_intro := false

func _ready():
	score = 0
	update_score()
	
func add_points(bonus_points: int):
	score += bonus_points
	update_score()
	
func penalty(minus_points: int):
	score += minus_points
	update_score()
	
func update_score():
	print("Current score: " + str(score))
	
func _timer_up():
	print("Time out")
	
	AudioManager.play_sound("whistle")
	yield(get_tree().create_timer(3), "timeout")
