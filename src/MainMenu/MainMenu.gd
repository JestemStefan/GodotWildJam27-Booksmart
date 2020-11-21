extends Spatial

enum Focuses { MAIN, OPTIONS, CREDITS, QUIT }

var focus : int = Focuses.MAIN

onready var camera = $Camera
onready var camera_tween = $Camera/Tween
onready var camera_points = $CameraPoints
onready var paige = $Paige
onready var paige_anim = $Paige/AnimationPlayer
onready var paige_skele = $Paige/Librarian/Skeleton
onready var paige_books = $Paige/Books
onready var fade_anim = $Overlay/AnimationPlayer
onready var overlay = $Overlay



func _ready() -> void:
	overlay.visible = false
	AudioManager.play_sound("menu", true)
	paige_anim.play("Idle_Books")



func _process(_delta) -> void:
	paige_books.transform = paige_skele.get_bone_global_pose(paige_skele.find_bone("head"))
	paige_books.translation.y -= 2.05
	paige_books.rotation_degrees.x -= 20
	paige_books.rotation_degrees.z += 5


func change_menu(menu : int) -> void:
	match focus:
		0:
			match menu:
				0:
					fade_anim.play("fade_white")
				1: pass
				2: pass
				3:
					fade_anim.play("fade_black")
					focus = Focuses.QUIT



func change_camera_view(point : int) -> void:
	camera_tween.stop_all()
	camera_tween.interpolate_property(camera, "translation", camera.translation, camera_points.get_child(point).translation, 0.7)
	camera_tween.interpolate_property(camera, "rotation_degrees", camera.rotation_degrees, camera_points.get_child(point).rotation_degrees, 0.7)
	camera_tween.start()



func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade_white": get_tree().change_scene("res://levels/Test_Level.tscn")
		"fade_black": get_tree().quit()
	
