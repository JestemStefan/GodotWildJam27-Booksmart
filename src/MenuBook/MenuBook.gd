extends StaticBody

enum Types { PLAY, OPTIONS, CREDITS, QUIT }

export (Types) var type : int = Types.PLAY
export (NodePath) var animation_player_path : String

onready var main_menu : Spatial = $"../.."
onready var animation_player : AnimationPlayer = get_node(animation_player_path)

var selected := false
var slid_out := false



func _on_mouse_entered() -> void:
	if is_focused(): selected = true
	update_slide()



func _on_mouse_exited() -> void:
	if is_focused(): selected = false
	update_slide()



func _input(event) -> void:
	if event.is_action_pressed("l_click") && selected && is_focused():
		main_menu.change_menu(type)
		selected = false
		update_slide()



func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"slide_forward": slid_out = true
		"slide_backward": slid_out = false
	update_slide()



func update_slide() -> void:
	if selected != slid_out:
		if selected: animation_player.play("slide_forward")
		else: animation_player.play("slide_backward")


func is_focused() -> bool:
	if $"../..".focus == $"../..".Focuses.MAIN:
		return true
	return false
