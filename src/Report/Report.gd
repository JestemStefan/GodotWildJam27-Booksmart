extends Control

onready var fade := $Fade
onready var tween := $Tween
onready var header := $Header
onready var report := $Report
onready var score_label := $Score
onready var confetti_l := $ConfettiL
onready var confetti_r := $ConfettiR
onready var continue_button := $ContinueButton
onready var animation_player := $Fade/AnimationPlayer

var score_display := 0



func _ready() -> void:
	confetti_l.emitting = false
	confetti_r.emitting = false
	report.visible = false
	report.text = ""
	fade.visible = true
	continue_button.visible = false



func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	match anim_name:
		"fade_out":
			fade.visible = false
			start_score_count()
		"fade_in":
			get_tree().change_scene("res://levels/Main_Menu.tscn")
			AudioManager.play_sound("menu")



func start_score_count() -> void:
	tween.interpolate_property(self, "score_display", 0, GameState.score, 2)
	tween.start()
	
	yield(tween, "tween_completed")
	
	confetti_l.emitting = true
	confetti_r.emitting = true
	continue_button.visible = true
	report.visible = true
	
	AudioManager.play_sound("party")
	AudioManager.play_sound("applause")
	
	if StaticData.score in range(0, 25):
		report.text += "Congratz! You failed!"
	elif StaticData.score in range(25, 50):
		report.text += "You tried!"
	elif StaticData.score in range(50, 150):
		report.text += "Quite good!"
	elif StaticData.score in range(150, 190):
		report.text += "Superb!"
	elif StaticData.score in range(190, 230):
		report.text += "Spectacular!"
	else:
		report.text += "Masterful!"
	
	yield(continue_button, "pressed")
	
	animation_player.play("fade_in")
	fade.visible = true
	
	AudioManager.stop_sound("party")
	AudioManager.stop_sound("applause")



func _process(_delta) -> void:
	score_label.text = str(score_display)
