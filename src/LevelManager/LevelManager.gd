extends Spatial

enum TileTypes { DEFAULT }

var tile_dimensions := Vector3(1, 1, 1)

signal level_loaded



func load_map(data : Array) -> void:
	
	for data_tile in data:
		var tile_class = Tile.new(data_tile.position, data_tile.tile)
		
		add_child(tile_class)
	
	emit_signal("level_loaded")

func _ready() -> void:
	var a = FileManager.load_from_json("res://levels/level0.json")
	a = [{"tile": "floor", "position": Vector3(0, 0, 0)}]
	if get_tree().get_current_scene().name == "World":
		load_map(a)
