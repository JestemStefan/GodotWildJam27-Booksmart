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

# Picking up #
onready var detect_book_ray: RayCast = $GimbalX/PickBookRay
onready var interact_area : Area = $GimbalX/InteractionArea
onready var book_storage: Spatial = $GimbalX/BookStorage

export var book_capacity: int


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


			#Picking up books
			if Input.is_action_just_pressed("interact"): #mapped as E key
				
				#if detect_book_ray.is_colliding():
					#var picked_book: RigidBody = detect_book_ray.get_collider()
					
				# get_bodies in layer 3
				var interactable_items = interact_area.get_overlapping_bodies() 
				print(interactable_items)
				
				var books = []
				var bookshelfs = []
				var lib_counter = []
				
				for item in interactable_items:
					match item.get_groups()[0]:
						"Books":
							books.append(item)
							print("Books: ")
						
						"Bookshelfs":
							bookshelfs.append(item)
							print("Bookshelfs: ")
					
				var stored_books = book_storage.get_children()
				
				# if some book can be picked up
				if books.size() > 0 and stored_books.size() < book_capacity: 
					var picked_book = books[0]  # pick first book
					
					pick_up_book(picked_book)
					
				 # no free books detected
				else:
				
					# check if there are any books above head
					
					if stored_books.size() > 0:
						var bottom_book = stored_books[0] # get book from the bottom
						
						if bookshelfs.size() > 0:
							var selected_bookshelf = bookshelfs[0]
						
							book_to_shelf(bottom_book, selected_bookshelf)
						
						else:
							# Throw a book on the ground if you don't want it?
							drop_book(bottom_book)

				update_book_stack()

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
			
			var rotation_dir = velocity
			rotation_dir.y = 0
			
			if rotation_dir != Vector3.ZERO:
				look_at(global_transform.origin + rotation_dir, Vector3.UP)



func pick_up_book(book):
	# change parent of a book to player
	book.get_parent().remove_child(book)
	book_storage.add_child(book)
	
	# reset translation and rotation
	book.translation = Vector3.ZERO
	book.rotation = Vector3.ZERO
	
	#pause physics MODE_STATIC
	book.set_mode(1)


func book_to_shelf(book, bookshelf):
	
	book_storage.remove_child(book)
	
	# spawn in world
	bookshelf.get_node("Shelf_space").add_child(book)
	
	# reset translation and rotation
	book.translation = Vector3.ZERO
	book.rotation = Vector3.ZERO
	
	# pause physics
	book.set_mode(1)


func drop_book(book):
	
	# save location in the global space for spawn
	var book_position = book.get_global_transform()
	book_storage.remove_child(book)
	
	# spawn in world
	owner.add_child(book)
	book.set_global_transform(book_position)
	
	# enable physics
	book.set_mode(0)
	
	# Throw in correct doirection
	book.set_linear_velocity(-book_storage.get_global_transform().basis.z * 10 + Vector3(0, 2 ,0) + velocity)
								

func update_book_stack():
	for book in book_storage.get_children():
		book.set_translation(Vector3.RIGHT * book.get_index())
