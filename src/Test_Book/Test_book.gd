extends RigidBody


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
