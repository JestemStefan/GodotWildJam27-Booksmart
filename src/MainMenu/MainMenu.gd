extends Spatial

enum Focuses { MAIN, OPTIONS, CREDITS, QUIT }

var focus : int = Focuses.MAIN

onready var camera = $Camera
onready var camera_tween = $Camera/Tween
onready var camera_points = $CameraPoints



func change_menu(menu : int) -> void:
	match focus:
		0:
			match menu:
				0: change_camera_view(0)
				1: pass
				2: pass
				3: pass



func change_camera_view(point : int) -> void:
	camera_tween.stop_all()
	camera_tween.interpolate_property(camera, "translation", camera.translation, camera_points.get_child(point).translation, 0.7)
	camera_tween.interpolate_property(camera, "rotation_degrees", camera.rotation_degrees, camera_points.get_child(point).rotation_degrees, 0.7)
	camera_tween.start()
