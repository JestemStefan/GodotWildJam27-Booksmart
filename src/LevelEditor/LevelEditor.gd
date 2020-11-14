extends Spatial

var occupied_position := []
var data := []

func _process(delta) -> void:
	if Input.is_action_pressed("r_click"):
		$MeshInstance.visible = false
	else:
		$MeshInstance.visible = true
	
	var set_translation = get_3d_mouse_translation()
	if set_translation:
		$MeshInstance.translation = set_translation.position
		$MeshInstance.translation.x = round($MeshInstance.translation.x)
		$MeshInstance.translation.z = round($MeshInstance.translation.z)
		$MeshInstance.translation.y = 0



func _input(event) -> void:
	if event is InputEventMouseMotion && Input.is_action_pressed("r_click"):
		$Spatial.rotate_y(deg2rad(-event.relative.x))
	if event.is_action_pressed("l_click"):
		if not $MeshInstance.translation in occupied_position:
			var tile = Tile.new()
			tile.texture = "res://assets/2D/wood_texture.png"
			add_child(tile)
			tile.translation = $MeshInstance.translation
			occupied_position.append(tile.translation)
			var vec2_pos = Vector2.ZERO
			vec2_pos.x = $MeshInstance.translation.x
			vec2_pos.y = $MeshInstance.translation.z
			var values := {
				"tile": "floor",
				"position": vec2_pos,
				"height": 1
			}
			data.append(values)
	if event.is_action_pressed("ui_accept"):
		write_to_file(data)



func write_to_file(stuff) -> void:
	var file = File.new()
	file.open("res://levels/level0.json", File.WRITE)
	file.store_string(to_json(stuff))
	file.close()



func get_3d_mouse_translation() -> Dictionary:
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = $Spatial/Camera
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var space_state = get_world().get_direct_space_state()
	# use global coordinates, not local to node
	var result = space_state.intersect_ray( from, to, [$MeshInstance] )
	return result
