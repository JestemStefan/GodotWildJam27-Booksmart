extends Control

onready var display = $Display


func _process(_delta) -> void:
	display.text = "Score: " + str(GameState.score)
