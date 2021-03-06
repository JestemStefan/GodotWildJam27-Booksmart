extends Spatial

enum Focuses { MAIN, OPTIONS, CREDITS }

var focus : int = Focuses.MAIN

onready var camera = $Camera/Camera
onready var camera_tween = $Camera/Camera/Tween
onready var camera_points = $CameraPoints
onready var paige = $Paige
onready var paige_anim = $Paige/AnimationPlayer
onready var paige_skele = $Paige/Librarian/Skeleton
onready var paige_books = $Paige/Books
onready var fade_anim = $Overlay/AnimationPlayer
onready var overlay = $Overlay
onready var main = $Main
onready var settings = $Settings
onready var credits = $Credits



func _ready() -> void:
	camera.translation = camera_points.get_node("0").translation
	camera.rotation_degrees = camera_points.get_node("0").rotation_degrees
	
	main.visible = true
	credits.visible = false
	settings.visible = false
	overlay.visible = false
	paige_anim.play("Idle_Books")



func _process(_delta) -> void:
	paige_books.transform = paige_skele.get_bone_global_pose(paige_skele.find_bone("head"))
	paige_books.translation.y -= 2.05
	paige_books.rotation_degrees.x -= 20
	paige_books.rotation_degrees.z += 5


func change_menu(menu : int) -> void:
	main.visible = false
	match focus:
		0:
			match menu:
				0:
					fade_anim.play("fade_white")
				1: 
					change_camera_view(1)
					focus = Focuses.OPTIONS
					settings.visible = true
				2: 
					change_camera_view(2)
					focus = Focuses.CREDITS
					credits.visible = true
				3:
					fade_anim.play("fade_black")
					focus = Focuses.QUIT
		
		1:
			match menu:
				0:
					change_camera_view(0)
					focus = Focuses.MAIN
					settings.visible = false
					main.visible = true
		
		2:
			match menu:
				0:
					change_camera_view(0)
					focus = Focuses.MAIN
					credits.visible = false
					main.visible = true



func change_camera_view(point : int) -> void:
	camera_tween.stop_all()
	camera_tween.interpolate_property(camera, "translation", camera.translation, camera_points.get_child(point).translation, 0.7)
	camera_tween.interpolate_property(camera, "rotation_degrees", camera.rotation_degrees, camera_points.get_child(point).rotation_degrees, 0.7)
	camera_tween.start()



func _on_AnimationPlayer_animation_finished(anim_name):
	AudioManager.stop_sound("menu")
	
	match anim_name:
		"fade_white":
			if GameState.skip_intro:
				get_tree().change_scene("res://levels/Test_Level.tscn")
			else:
				get_tree().change_scene("res://levels/Story.tscn")
		"fade_black": get_tree().quit()
