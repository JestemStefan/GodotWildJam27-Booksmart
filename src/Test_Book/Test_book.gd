extends RigidBody
class_name Book



func pick_up() -> void:
	# Disable collision
	set_collision_mask_bit(0, false)
	set_collision_layer_bit(0, false)



func throw() -> void:
	# Enable collision
	set_collision_mask_bit(0, true)
	set_collision_layer_bit(0, true)



func place() -> void:
	# Enable collision
	set_collision_mask_bit(0, true)
	set_collision_layer_bit(0, true)
