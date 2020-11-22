extends Control

var settings := {
	"anisotropic": 16,
	"fullscreen": false,
	"play_music": true,
	"skip_itro": false
}

var temp_settings := {
	"anisotropic": 16,
	"fullscreen": false,
	"play_music": true,
	"skip_intro": false
}

onready var anisotropic_options := $VBoxContainer/VBoxContainer/Anisotropic/AnisotropicOptions
onready var anisotropic_label := $VBoxContainer/VBoxContainer/Anisotropic/Label

onready var fullscreen_options := $VBoxContainer/VBoxContainer/FullScreen/FullScreenOptions
onready var fullscreen_label := $VBoxContainer/VBoxContainer/FullScreen/Label

onready var play_music_options := $VBoxContainer/VBoxContainer/PlayMusic/PlayMusicOptions
onready var play_music_label := $VBoxContainer/VBoxContainer/PlayMusic/Label

onready var skip_intro_options := $VBoxContainer/VBoxContainer/SkipIntro/SkipIntroOptions
onready var skip_intro_label := $VBoxContainer/VBoxContainer/SkipIntro/Label

onready var apply_button := $VBoxContainer/ApplyButton



func _ready() -> void:
	anisotropic_options.add_item("1")
	anisotropic_options.add_item("2")
	anisotropic_options.add_item("4")
	anisotropic_options.add_item("8")
	anisotropic_options.add_item("16")
	
	fullscreen_options.add_item("TRUE")
	fullscreen_options.add_item("FALSE")
	
	play_music_options.add_item("TRUE")
	play_music_options.add_item("FALSE")
	
	skip_intro_options.add_item("TRUE")
	skip_intro_options.add_item("FALSE")
	
	anisotropic_options.selected = 4
	fullscreen_options.selected = 1
	play_music_options.selected = 0
	match GameState.skip_intro:
		true: skip_intro_options.selected = 0
		false: skip_intro_options.selected = 1
	
	temp_settings = settings.duplicate(true)



func _on_ReturnButton_pressed() -> void:
	$"..".change_menu(0)



func _on_ApplyButton_pressed():
	settings = temp_settings.duplicate(true)
	
	OS.set_window_fullscreen(settings.fullscreen)
	GameState.play_music = settings.play_music
	GameState.skip_intro = settings.skip_intro



func _on_AnisotropicOptions_item_selected(index) -> void:
	var val : String = anisotropic_options.get_item_text(index)
	temp_settings.anisotropic = int(val)
	anisotropic_label.text = "ANTISOTROPIC FILTERING : " + val + "X"



func _on_FullScreenOptions_item_selected(index):
	var val : String = fullscreen_options.get_item_text(index)
	temp_settings.fullscreen = str_to_bool(val)
	fullscreen_label.text = "FULLSCREEN : " + val



func str_to_bool(string : String) -> bool:
	match string.to_lower():
		"true": return true
		"false": return false
	return false



func _on_PlayMusicOptions_item_selected(index):
	var val : String = play_music_options.get_item_text(index)
	temp_settings.play_music = str_to_bool(val)
	play_music_label.text = "PLAY MUSIC : " + val



func _on_SkipIntroOptions_item_selected(index):
	var val : String = skip_intro_options.get_item_text(index)
	temp_settings.skip_intro = str_to_bool(val)
	skip_intro_label.text = "SKIP INTRO : " + val
