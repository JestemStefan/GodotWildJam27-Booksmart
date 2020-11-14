extends KinematicBody

# Meta #
enum State { DEFAULT }
var state : int = State.DEFAULT

# Movement #
var velocity := Vector3.ZERO
const MAX_SPEED := 12
const ACCELERATION := 6
const DEACCELERATION_WEIGHT := 0.8
var direction := Vector2.ZERO



func _ready() -> void:
	pass



func _physics_process(delta : float) -> void:
	process_input(delta)
	process_movement(delta)



func process_input(delta : float) -> void:
	
	match state:
		
		State.DEFAULT:
			
			direction = Vector2.ZERO
			
			direction.y += int(Input.is_action_pressed("move_backward")) - int(Input.is_action_pressed("move_forward"))
			direction.x += int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			
			direction = direction.normalized()



func process_movement(delta : float) -> void:
	
	match state:
		
		State.DEFAULT:
			
			velocity.x += ACCELERATION * direction.x
			velocity.z += ACCELERATION * direction.y
			
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
			velocity.z = clamp(velocity.z, -MAX_SPEED, MAX_SPEED)
			
			velocity = move_and_slide(velocity, Vector3.UP)
			
			velocity.x = lerp(velocity.x, 0, DEACCELERATION_WEIGHT)
			velocity.z = lerp(velocity.z, 0, DEACCELERATION_WEIGHT)
