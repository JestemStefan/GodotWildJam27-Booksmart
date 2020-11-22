extends Control

export var round_time := 180

onready var display = $Display


func _process(_delta) -> void:
	display.text = "Score: " + str(GameState.score)
