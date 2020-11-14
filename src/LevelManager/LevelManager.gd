extends Spatial

enum TileTypes { DEFAULT }

var tile_dimensions := Vector3(1, 1, 1)

signal level_loaded

## Isaac - TILES constant will store data that is constant with each tile.
## Stuff like their mesh and class script.

var TILES := {
	"floor":
		{
			"mesh": "yes.png",
			"script": "omega_lul.gd",
			"type": TileTypes.DEFAULT,
			"texture": "res://assets/2D/wood_texture.png"
		},
	"bookshelf":
		{
			"mesh": "yeah_nah.lol",
			"script": "yesn't.tscn",
			"type": TileTypes.DEFAULT,
			"texture": "res://assets/2D/stone_texture.png"
		}
}

func load_map_from_raw(data : Array) -> void:
	
	for data_tile in data:
		for height in data_tile.height:
			
			var tile_class = Tile.new()
			
			tile_class.texture = TILES.get(data_tile.tile).texture
			tile_class.tile_position = data_tile.position
			tile_class.translation.y += height
			
			match data_tile.tile:
				TileTypes.DEFAULT: pass
			
			add_child(tile_class)
	
	emit_signal("level_loaded")

func _ready() -> void:
	var map_data := []
	load_map_from_raw(map_data)
