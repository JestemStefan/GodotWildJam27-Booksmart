extends MeshInstance

export (NodePath) var camera_path
onready var camera = get_node(camera_path)
onready var editor = get_parent()



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



func vec2_translation() -> Vector2:
	return Vector2(translation.x, translation.z)



func update_position() -> void:
	var result = mouse_raycast()
	if result:
		translation = mouse_raycast().position
		translation.x = round(translation.x)
		translation.z = round(translation.z)
		translation.y = 0
		
		if editor.get_data_tile_at_pos(vec2_translation()):
			translation.y = 1 * editor.data[editor.get_data_tile_at_pos(vec2_translation())[0]].height
