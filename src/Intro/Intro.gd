extends Control



func _ready() -> void:
	AudioManager.play_sound("menu", true)



func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://levels/Main_Menu.tscn")
