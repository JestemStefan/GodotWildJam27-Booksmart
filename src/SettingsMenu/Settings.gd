extends Control

var temp_settings := {
	"antisotropic": 16
}

onready var antisotrpoic_options := $VBoxContainer/VBoxContainer/Antisotropic/AntisotrpoicOptions
onready var antisotropic_label := $VBoxContainer/VBoxContainer/Antisotropic/Label

onready var environment_options := $VBoxContainer/VBoxContainer/Environment/EnvironmentOptions
onready var environment_label := $VBoxContainer/VBoxContainer/Environment/Label

onready var apply_button := $VBoxContainer/VBoxContainer/ApplyButton



func _ready() -> void:
	antisotrpoic_options.add_item("1")
	antisotrpoic_options.add_item("2")
	antisotrpoic_options.add_item("4")
	antisotrpoic_options.add_item("8")
	antisotrpoic_options.add_item("16")
	antisotrpoic_options.selected = 4
	
	environment_options.add_item("LIGHT")
	environment_options.add_item("HEAVY")
	environment_options.selected = 1



func _on_ReturnButton_pressed() -> void:
	$"..".change_menu(0)



func update() -> void:
	pass



func _on_ApplyButton_pressed():
	StaticData.settings = temp_settings.duplicate(true)
	update()



func _on_AntisotrpoicOptions_item_selected(index) -> void:
	var val : String = antisotrpoic_options.get_item_text(index)
	temp_settings.antisotropic = int(val)
	antisotropic_label.text = "ANTISOTROPIC FILTERING : " + val + "X"
	update()



func _on_EnvironmentOptions_item_selected(index):
	var val : String = environment_options.get_item_text(index)
	temp_settings.environment = val
	environment_label.text = "ENVIRONMENT : " + val
	update()
