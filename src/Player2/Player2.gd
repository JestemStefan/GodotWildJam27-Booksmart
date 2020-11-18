extends KinematicBody

# Meta #
enum State { DEFAULT, LADDER }
var state : int 

# Movement #
var velocity := Vector3.ZERO
const MAX_SPEED := 8
const ACCELERATION := 6
const DEACCELERATION_WEIGHT := 0.8
const GRAVITY := -40
const JUMP_SPEED := 10
var direction := Vector2.ZERO

# Ladder movement #
var ladder: StaticBody

# Animations
onready var anim_player: AnimationPlayer = $char_page/AnimationPlayer
onready var foot_smoke: Particles = $FootSmoke

# Picking up #
onready var interact_ray: RayCast = $GimbalX/InteractRay
onready var interact_area : Area = $GimbalX/InteractionArea
onready var book_storage: Spatial = $GimbalX/BookStorage

export var book_capacity: int


func _ready() -> void:
	state = State.DEFAULT
	anim_player.play("Idle")



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
			
#
#			# ------------------------------------------------------------------
#			# Jumping
#			if is_on_floor():
#				if Input.is_action_pressed("move_jump"):
#					velocity.y = JUMP_SPEED
					


			#Picking up books
			if Input.is_action_just_pressed("interact"): #mapped as E key
				
				if interact_ray.is_colliding():
					var picked_object = interact_ray.get_collider()
					
					# Possible better way of doing things. If we decide it's unnecessary, just get rid of this little block of code.
					if picked_object is Inventory:
						var stored_books = book_storage.get_children()
						if len(stored_books) > 0:
							picked_object.append(stored_books[-1])
							stored_books[-1].queue_free()
					
					else:
						match picked_object.get_groups()[0]:
	
							"Books":
								print("Book")
								var picked_book = picked_object
	
								var stored_books = book_storage.get_children()
								if stored_books.size() < book_capacity:
									
									pick_up_book(picked_book)
	
								else:
									drop_book(stored_books[0])
									pick_up_book(picked_book)
								
								update_book_stack()
	
							"Bookshelfs":
								var selected_bookshelf = picked_object
	
								var stored_books = book_storage.get_children()
	
								if stored_books.size() > 0:
									
									# get book from the bottom
									var bottom_book = stored_books[0]
									book_to_shelf(bottom_book, selected_bookshelf)
							
								update_book_stack()
							
							"Counter":
								#TODO
								pass
	
							"Ladder":
								pass



			if Input.is_action_just_pressed("use"): #mapped as Space
				
				
				if interact_ray.is_colliding():
					var picked_object = interact_ray.get_collider()
					
					if picked_object.get_groups()[0] == "Ladder":
						
						ladder = picked_object

						state = State.LADDER

						# Disable collision for a ladder
						interact_ray.set_collision_mask(8)

		
		State.LADDER:
			
			# ------------------------------------------------------------------
			# Movement direction
			direction = Vector2.ZERO
			
			direction.y += int(Input.is_action_pressed("move_backward")) - int(Input.is_action_pressed("move_forward"))
			direction.x += int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			
			direction = direction.normalized()
			
			
			#Picking up books
			if Input.is_action_just_pressed("interact"): #mapped as E key
	
				if interact_ray.is_colliding():
					var picked_object = interact_ray.get_collider()

					print(picked_object)

					match picked_object.get_groups()[0]:

						"Books":
							var picked_book = picked_object

							var stored_books = book_storage.get_children()
							if stored_books.size() < book_capacity:
								
								pick_up_book(picked_book)

							else:
								drop_book(stored_books[0])
								pick_up_book(picked_book)
							

						"Bookshelfs":
							var selected_bookshelf = picked_object

							var stored_books = book_storage.get_children()

							if stored_books.size() > 0:
								
								# get book from the bottom
								var bottom_book = stored_books[0]
								book_to_shelf(bottom_book, selected_bookshelf)
				
				update_book_stack()
						
			
			
			if Input.is_action_just_pressed("use"): #mapped as Space
					state = State.DEFAULT

					# Enable collision for a ladder
					interact_ray.set_collision_mask(24)
			

func process_movement(delta : float) -> void:
	
	match state:
		
		State.DEFAULT:
			
			velocity.y += GRAVITY * delta
			
			if is_on_floor():
				
				if direction != Vector2.ZERO:
					anim_player.play("Run")
					foot_smoke.set_emitting(true)
				
				else:
					anim_player.play("Idle")
					foot_smoke.set_emitting(false)

				velocity.x += ACCELERATION * direction.x
				velocity.z += ACCELERATION * direction.y
				
				velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
				velocity.z = clamp(velocity.z, -MAX_SPEED, MAX_SPEED)
				
				var rotation_dir = Vector3(direction.x, 0, direction.y)
				
				if rotation_dir != Vector3.ZERO:
					look_at(global_transform.origin + rotation_dir, Vector3.UP)
				
			velocity = move_and_slide(velocity, Vector3.UP, true)
			
			velocity.x = lerp(velocity.x, 0, DEACCELERATION_WEIGHT)
			velocity.z = lerp(velocity.z, 0, DEACCELERATION_WEIGHT)
			
			

		State.LADDER:

			
			
			velocity.y = -direction.y * 0.1
			velocity.x = direction.x * 0.1
			
			translate(velocity)
			
			ladder.translate(Vector3(velocity.x, 0, 0))



func pick_up_book(book):
	# change parent of a book to player
	book.get_parent().remove_child(book)
	book_storage.add_child(book)
	
	# reset translation and rotation
	book.translation = Vector3.ZERO
	book.rotation = Vector3.ZERO
	
	#pause physics MODE_STATIC
	book.set_mode(1)
	
	book.pick_up()



func book_to_shelf(book, bookshelf):
	
	book_storage.remove_child(book)
	
	# spawn in world
	bookshelf.get_node("Shelf_space").add_child(book)
	
	# reset translation and rotation
	book.translation = Vector3.ZERO
	book.rotation = Vector3.ZERO
	
	# pause physics
	book.set_mode(1)
	
	book.place()
	bookshelf.place_on_shelf(book)



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
	
	book.throw()



func update_book_stack():
	for book in book_storage.get_children():
		book.set_translation(Vector3.RIGHT * book.get_index())
