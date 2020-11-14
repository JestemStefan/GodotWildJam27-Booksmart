extends Spatial

onready var level = $Level
onready var gimbal = $Gimbal
onready var camera = $Gimbal/Camera
onready var cursor = $LevelEditorCursor
onready var zoom_tween = $Tweens/Zoom

var save_file_location := "res://levels/level0.json"
var data := []

var camera_direction := Vector2.ZERO
const CAM_MOVE_SPEED := 6



func _input(event) -> void:
	
	# Camera Rotation
	if event is InputEventMouseMotion && Input.is_action_pressed("m_click"):
		gimbal.rotate_y(deg2rad(-event.relative.x))
	
	# Placing tiles
	if event.is_action_pressed("l_click"):
		
		# Stacking tiles
		if get_data_tile_at_pos(cursor.vec2_translation()):
			var index = get_data_tile_at_pos(cursor.vec2_translation())[0]
			
			if data[index].height < 5:
				data[index].height += 1
				
				var tile = Tile.new()
				tile.texture = "res://assets/2D/wood_texture.png"
				tile.tile_position = cursor.vec2_translation()
				tile.height = data[index].height
				level.add_child(tile)
		
		# Tiles on ground
		else:
			var tile = Tile.new()
			tile.texture = "res://assets/2D/wood_texture.png"
			tile.tile_position = cursor.vec2_translation()
			tile.height = 1
			level.add_child(tile)
			
			data.append({"tile": "floor", "position": cursor.vec2_translation(), "height": 1})
	
	cursor.update_position()
	
	# Removing tiles
	if event.is_action_pressed("r_click") && get_data_tile_at_pos(cursor.vec2_translation()):
		var index = get_data_tile_at_pos(cursor.vec2_translation())[0]
		if data[index].height > 1:
			get_tile_at_pos(Vector3(cursor.translation.x, data[index].height - 1, cursor.translation.z)).queue_free()
			data[index].height -= 1
		
		else:
			get_tile_at_pos(Vector3(cursor.translation.x, data[index].height - 1, cursor.translation.z)).queue_free()
			for i in get_data_tile_at_pos(cursor.vec2_translation()):
				if data[i].position == cursor.vec2_translation(): data.remove(i)
	
	# Saving
	if event.is_action_pressed("editor_save"):
		FileManager.save_to_json(save_file_location, data)



func _process(delta : float) -> void:
	camera_movement(delta)



func camera_movement(delta : float) -> void:
	camera_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	camera_direction.y = int(Input.is_action_pressed("move_backward")) - int(Input.is_action_pressed("move_forward"))
	camera_direction = camera_direction.normalized()
	gimbal.translate(Vector3(camera_direction.x, 0, camera_direction.y) * CAM_MOVE_SPEED * delta)



func get_data_tile_at_pos(position_to_check : Vector2) -> Array:
	var indices := []
	for i in len(data):
		var tile_data = data[i]
		if tile_data.position == position_to_check:
			indices.append(i)
	return indices



func get_tile_at_pos(position_to_check : Vector3) -> Tile:
	for child in level.get_children():
		if child.translation == position_to_check:
			return child
	
	print("No tile found, returning new tile.")
	return Tile.new()
