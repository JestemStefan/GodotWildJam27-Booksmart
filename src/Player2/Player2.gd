extends KinematicBody

# Meta #
enum State { DEFAULT }
var state : int = State.DEFAULT

# Movement #
var velocity := Vector3.ZERO
const MAX_SPEED := 12
const ACCELERATION := 6
const DEACCELERATION_WEIGHT := 0.8
const GRAVITY := -40
const JUMP_SPEED := 10
var direction := Vector2.ZERO



func _ready() -> void:
	pass



func _physics_process(delta : float) -> void:
	process_input(delta)
	process_movement(delta)



func process_input(delta : float) -> void:
	
	match state:
		
		State.DEFAULT:
			# ------------------------------------------------------------------
			# Walking
			direction = Vector2.ZERO
			
			direction.y += int(Input.is_action_pressed("move_backward")) - int(Input.is_action_pressed("move_forward"))
			direction.x += int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			
			direction = direction.normalized()
			
			# ------------------------------------------------------------------
			# Jumping
			if is_on_floor():
				if Input.is_action_pressed("move_jump"):
					velocity.y = JUMP_SPEED



func process_movement(delta : float) -> void:
	
	match state:
		
		State.DEFAULT:
			
			velocity.y += GRAVITY * delta
			
			velocity.x += ACCELERATION * direction.x
			velocity.z += ACCELERATION * direction.y
			
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
			velocity.z = clamp(velocity.z, -MAX_SPEED, MAX_SPEED)
			
			velocity = move_and_slide(velocity, Vector3.UP, true)
			
			velocity.x = lerp(velocity.x, 0, DEACCELERATION_WEIGHT)
			velocity.z = lerp(velocity.z, 0, DEACCELERATION_WEIGHT)
