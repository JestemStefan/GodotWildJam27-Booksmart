extends StaticBody
class_name Tile

# General Data #
var tile_position := Vector2.ZERO
var height := 0
var ticks_since_born := 0
var timer : Timer
var collision : CollisionShape
var mesh : MeshInstance
var tps := 4.0 # ticks per second
var texture := "res://assets/2D/icon.png"

# Virtuals #
func _level_start() -> void: pass
func _tick() -> void: pass



func _ready() -> void:
	set_process(false)
	generate_mesh()
	generate_collision()
	initiate_timer()
	LevelManager.connect("level_loaded", self, "_on_level_load")
	translation.x = tile_position.x * LevelManager.tile_dimensions.x
	translation.z = tile_position.y * LevelManager.tile_dimensions.z
	translation.y = height - 1 * LevelManager.tile_dimensions.y



func _process(_delta) -> void:
	if timer.time_left == 0:
		_tick()
		timer.start()



func initiate_timer() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0 / tps
	timer.one_shot = true
	
	add_child(timer)
	timer.start()



func generate_collision() -> void:
	var shape = BoxShape.new()
	collision = CollisionShape.new()
	collision.shape = shape
	shape.extents = LevelManager.tile_dimensions / 2.0
	
	add_child(collision)



func generate_mesh() -> void:
	var material = SpatialMaterial.new()
	mesh = MeshInstance.new()
	mesh.mesh = CubeMesh.new()
	mesh.mesh.material = material
	mesh.mesh.size = LevelManager.tile_dimensions
	material.albedo_texture = load(texture)
	
	add_child(mesh)



func _on_level_load() -> void:
	set_process(true)
	_level_start()
