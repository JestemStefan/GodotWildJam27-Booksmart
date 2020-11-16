extends Spatial

onready var level = $Level
onready var gimbal = $Gimbal
onready var camera = $Gimbal/Camera
onready var cursor = $LevelEditorCursor
onready var zoom_tween = $Tweens/Zoom

var save_file_location := "res://levels/level0.json"
var data := []
var tiles := ["floor", "bookshelf_short"]
var tiles_class := [Tile, ShortBookshelf]
var selection := 0

var camera_direction := Vector2.ZERO
const CAM_MOVE_SPEED := 24

enum Pieces { TILE, BOOKSHELF }
var curr_piece : int = Pieces.TILE



func _ready() -> void:
	change_tile_selection(0)



func _input(event) -> void:
	
	# Camera Rotation
	if event is InputEventMouseMotion && Input.is_action_pressed("m_click"):
		gimbal.rotate_y(deg2rad(-event.relative.x))
	
	# Placing tiles
	if event.is_action_pressed("l_click"):
		place_tile()
	
	if event.is_action_pressed("r_click"):
		remove_tile()
	
	# Saving
	if event.is_action_pressed("editor_save"):
		FileManager.save_to_json(save_file_location, data)
	
	# Switching tiles
	if event.is_action_pressed("next_tile"):
		change_tile_selection(1)
	
	if event.is_action_pressed("prev_tile"):
		change_tile_selection(-1)



func _process(delta : float) -> void:
	camera_movement(delta)



func camera_movement(delta : float) -> void:
	camera_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	camera_direction.y = int(Input.is_action_pressed("move_backward")) - int(Input.is_action_pressed("move_forward"))
	camera_direction = camera_direction.normalized()
	gimbal.translate(Vector3(camera_direction.x, 0, camera_direction.y) * CAM_MOVE_SPEED * delta)



func get_data_tile_at_pos(position_to_check : Vector3) -> PoolIntArray:
	var indices : PoolIntArray = []
	for i in len(data):
		var tile_data = data[i]
		if tile_data.position == position_to_check:
			indices.append(i)
	return indices



func get_tile_at_pos(position_to_check : Vector3) -> Tile:
	for child in level.get_children():
		if child.translation == position_to_check:
			return child
	
	return null



func place_tile() -> void:
	var place_pos : Vector3 = cursor.get_translation_safe()
	if !get_tile_at_pos(place_pos) is tiles_class[selection]:
		var tile = TileManager.create_tile(place_pos, tiles[selection])
		level.add_child(tile)
		
		data.append({"tile": tiles[selection], "position": place_pos, "exports": tile.additionals})
	
	cursor.update_position()



func remove_tile() -> void:
	var remove_pos : Vector3 = cursor.get_translation_safe()
	if get_tile_at_pos(remove_pos) is tiles_class[selection]:
		var tile = cursor.get_collider()
		if tile:
			tile.queue_free()
			var index : int = get_data_tile_at_pos(remove_pos)[0]
			data.remove(index)
	
	cursor.update_position()



func change_tile_selection(amount : int) -> void:
	selection = wrapi(selection + amount, 0, tiles.size())
	cursor.size = Tile.TILES.get(tiles[selection]).dimensions
	cursor.update_position()

