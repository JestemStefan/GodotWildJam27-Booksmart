extends StaticBody
class_name Tile

# General Data #
var dimensions := Vector3.ONE
var ticks_since_born := 0
var timer := Timer.new()
var mesh := MeshInstance.new()
var collision := CollisionShape.new()
var tps := 4.0 # ticks per second
var mesh_texture := "res://models/floortiles/wood_texture.png"
var mesh_resource := "res://models/floortiles/floortile_wood.obj"
var additionals : Dictionary

# Virtuals #
func _level_start() -> void: pass
func _tick() -> void: pass

## Isaac - TILES constant will store data that is constant with each tile.
## Stuff like their mesh and class script.

const TILES := {
	"floor":
		{
			"script": "",
			"mesh": "res://models/floortiles/floortile_wood.obj",
			"texture": "res://models/floortiles/wood_texture.png",
			"dimensions": Vector3(8, 0.1, 8)
		},
	"bookshelf_short":
		{
			"script": "",
			"mesh": "res://models/bookshelf/prop_bookshelf.obj",
			"texture": "res://models/bookshelf/bookshelf_d.png",
			"dimensions": Vector3(16, 20, 4)
		}
}



func _init(set_translation : Vector3, tile : String) -> void:
	var set_dimensions : Vector3 = TILES.get(tile).dimensions
	var set_mesh_resource : String = TILES.get(tile).mesh
	var set_mesh_texture : String = TILES.get(tile).texture
	
	translation = set_translation
	dimensions = set_dimensions
	mesh_texture = set_mesh_texture
	mesh_resource = set_mesh_resource



func _ready() -> void:
	set_process(false)
	generate_mesh()
	generate_collision()
	initiate_timer()
	LevelManager.connect("level_loaded", self, "_on_level_load")



func _process(_delta) -> void:
	if timer.time_left == 0:
		_tick()
		timer.start()



func initiate_timer() -> void:
	timer.wait_time = 1.0 / tps
	timer.one_shot = true
	
	add_child(timer)
	timer.start()



func generate_collision() -> void:
	var shape = BoxShape.new()
	collision.shape = shape
	shape.extents = dimensions / 2.0
	collision.translation.y += dimensions.y / 2.0
	
	add_child(collision)



func generate_mesh() -> void:
	var material = SpatialMaterial.new()
	mesh.mesh = load(mesh_resource)
	mesh.mesh.surface_set_material(0, material)
	material.albedo_texture = load(mesh_texture)
	material.params_cull_mode = SpatialMaterial.CULL_FRONT
	
	add_child(mesh)



func _on_level_load() -> void:
	set_process(true)
	_level_start()
