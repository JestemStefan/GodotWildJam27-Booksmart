extends RigidBody
class_name Book



func _ready() -> void:
	make_distinct()



func pick_up() -> void:
	# Disable collision
	set_collision_mask(0)
	set_collision_layer(0)



func throw() -> void:
	# Enable collision
	set_collision_mask(31)
	set_collision_layer(8)



func place() -> void:
	# Enable collision
	set_collision_mask(0)
	set_collision_layer(8)



func make_distinct() -> void: # Temporary! Delete when we get book models in!
	var material = SpatialMaterial.new()
	var mesh = CubeMesh.new()
	$MeshInstance.mesh = mesh
	mesh.material = material
	mesh.size = Vector3(0.4, 1.6, 1.2)
	material.albedo_color = Color(randf(), randf(), randf(), 1)
