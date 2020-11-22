extends Control

export var round_time := 180

onready var timer = $Timer
onready var display = $Display

signal timer_up



func to_minutes(time : float) -> int:
	return int(floor(time / 60.0))



func just_seconds(time : float) -> int:
	return int(fmod(time, 60.0))



func as_string_time(time : float) -> String:
	var result := ""
	
	result += str(int(floor(time / 10.0)))
	result += ("X" + str(int(time)))[-1]
	
	return result



func _ready() -> void:
	timer.wait_time = round_time
	timer.start()



func _process(_delta) -> void:
	display.text = str(to_minutes(timer.time_left)) + ":" + str(as_string_time(just_seconds(timer.time_left)))
	if !timer.time_left:
		set_process(false)
		emit_signal("timer_up")
