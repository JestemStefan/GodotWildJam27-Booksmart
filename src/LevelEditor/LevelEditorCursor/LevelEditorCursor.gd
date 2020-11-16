extends MeshInstance

export (NodePath) var camera_path
onready var camera = get_node(camera_path)
onready var editor = get_parent()

var size := Vector3(16, 35, 8)



func _input(event) -> void:
	if event is InputEventMouseMotion && not Input.is_action_pressed("m_click"):
		update_position()



func mouse_raycast() -> Dictionary:
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to, [self])
	return result



func get_translation_safe() -> Vector3:
	var fig_1 = translation
	var fig_2 = Vector3(0, size.y / 2.0, 0)
	return fig_1 - fig_2



func update_position() -> void:
	var result = mouse_raycast()
	if result:
		scale = size
		
		translation = mouse_raycast().position
		translation.x = stepify(translation.x, size.x)
		translation.z = stepify(translation.z, size.z)
		translation.y = 0 + size.y / 2.0
