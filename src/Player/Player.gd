extends KinematicBody



# Meta #
enum States { DEFAULT }
var state : int = States.DEFAULT

# Movement Variables #
const GRAVITY := -40
var velocity := Vector3.ZERO
const MAX_SPEED := 12
const JUMP_SPEED := 20
const ACCELERATION := 6
const DEACCELERATION := 11
const MAX_SLOPE_ANGLE := 40
var direction := Vector3.ZERO

# Camera Variables #
onready var gimbal_x := $GimbalX
onready var gimbal_y := $GimbalX/GimbalY
onready var camera := $GimbalX/GimbalY/Camera
var mouse_camera_sensitivity := 0.4

# Debug Interface #
onready var debug_interface := $DebugInterface
onready var debug_cam_sens_label := $DebugInterface/VBoxContainer/CamSensitivity/Label

# Picking up #
onready var detect_book_ray: RayCast = $GimbalX/PickBookRay
onready var detect_book_area : Area = $GimbalX/PickBookArea
onready var book_storage: Spatial = $GimbalX/BookStorage


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_debug_interface()



func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		gimbal_x.rotate_y(deg2rad(-event.relative.x * mouse_camera_sensitivity))
		gimbal_y.rotate_x(deg2rad(-event.relative.y * mouse_camera_sensitivity))
		
		gimbal_y.rotation_degrees.x = clamp(gimbal_y.rotation_degrees.x, -75, 40)



func _physics_process(delta : float) -> void:
	process_input(delta)
	process_movement(delta)



func process_input(_delta : float) -> void:
	
	match state:
		
		States.DEFAULT:
			
			# -----------------------------------------------------------------
			# Walking
			direction = Vector3.ZERO
			var camera_xform = camera.get_global_transform()
			
			var input_movement_vector := Vector2.ZERO
			
			## Isaac - We use a cool method here to handle movement in a cleaner
			## fashion and in less lines. First we take in boolean input, then
			## convert it to an int, making it either a 1 or 0.
			##
			## Imagine A is pressed and D is not.
			## ```input_movement_vector.x = A(1) - D(0) = -1```
			##
			## This gets our movement direction. We use an incrementation method
			## instead, but pretty much it works the same.
			input_movement_vector.y += int(Input.is_action_pressed("move_forward")) - int(Input.is_action_pressed("move_backward"))
			input_movement_vector.x += int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			
			input_movement_vector = input_movement_vector.normalized()
			
			direction += -camera_xform.basis.z * input_movement_vector.y
			direction += camera_xform.basis.x * input_movement_vector.x
			
			# ------------------------------------------------------------------
			# Jumping
			if is_on_floor():
				if Input.is_action_pressed("move_jump"):
					velocity.y = JUMP_SPEED
			
			
			#Picking up books
			if Input.is_action_just_pressed("interact"): #mapped as E key
				
				#if detect_book_ray.is_colliding():
					#var picked_book: RigidBody = detect_book_ray.get_collider()
					
				# get_bodies in layer 3
				var books = detect_book_area.get_overlapping_bodies() 
				
				# if some book can be picked up
				if books.size() > 0: 
					var picked_book = books[0]  # pick first book
					
					pick_up_book(picked_book)
					
				 # no free books detected
				else:
					
					# check if there are any books above head
					var stored_books = book_storage.get_children()
					if stored_books.size() > 0:
						var bottom_book = stored_books[0] # get book from the bottom
						
						#TODO Put book on the shelf
						#book_to_shelf(bottom_book)
						
						# Throw a book on the ground if you don't want it?
						drop_book(bottom_book)

			# ------------------------------------------------------------------
			# Capture / Free cursor
			
			## Isaac - I only use a switch statement here for cleanliness.
			if Input.is_action_just_pressed("ui_cancel"):
				match Input.get_mouse_mode():
					Input.MOUSE_MODE_VISIBLE: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					Input.MOUSE_MODE_CAPTURED: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func process_movement(delta : float) -> void:
	
	match state:
		
		States.DEFAULT:
			
			direction.y = 0
			direction = direction.normalized()
			
			velocity.y += GRAVITY * delta
			
			var h_velocity := velocity
			h_velocity.y = 0
			
			var target := direction
			target *= MAX_SPEED
			
			var acceleration
			if direction.dot(h_velocity) > 0:
				acceleration = ACCELERATION
			else:
				acceleration = DEACCELERATION
			
			h_velocity = h_velocity.linear_interpolate(target, acceleration * delta)
			velocity.x = h_velocity.x
			velocity.z = h_velocity.z
			velocity = move_and_slide(velocity, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))



# ------------------------------------------------------------------------------
# Debug interface stuff

func update_debug_interface():
	debug_cam_sens_label.text = "Camera Sensitivity : " + str(mouse_camera_sensitivity)

func _on_HSlider_value_changed(value):
	mouse_camera_sensitivity = value
	update_debug_interface()


func pick_up_book(book):
	# change parent of a book to player
	book.get_parent().remove_child(book)
	book_storage.add_child(book)
	
	# reset translation and rotation
	book.translation = Vector3.ZERO
	book.rotation = Vector3.ZERO
	
	#pause physics
	book.set_sleeping(true)


func book_to_shelf(book):
	# TODO
	pass


func drop_book(book):
	
	# save location in the global space for spawn
	var book_position = book.get_global_transform()
	book_storage.remove_child(book)
	
	# spawn in world
	owner.add_child(book)
	book.set_global_transform(book_position)
	
	# enable physics
	book.set_sleeping(false)
	
	# Throw in correct doirection
	book.set_linear_velocity(-book_storage.get_global_transform().basis.z * 10 + Vector3(0, 2 ,0) + velocity)
					
