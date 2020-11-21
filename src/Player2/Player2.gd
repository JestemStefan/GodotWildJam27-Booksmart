extends KinematicBody

# Meta #
enum State { DEFAULT, LADDER }
var state : int 

# Movement #
var velocity := Vector3.ZERO
const MAX_SPEED := 8
const ACCELERATION := 6
const DEACCELERATION_WEIGHT := 0.4
const GRAVITY := -40
const JUMP_SPEED := 10
var direction := Vector2.ZERO

# Ladder movement #
var ladder

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
	change_animation("Idle")



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
					match picked_object.get_groups()[0]:

						"Books":
							print("Book")
							var picked_book = picked_object.get_parent()

							var stored_books = book_storage.get_children()
							if stored_books.size() < book_capacity:
								
								pick_up_book(picked_book)

							else:
								drop_book(stored_books[0])
								pick_up_book(picked_book)
							
							update_book_stack()

						"Bookshelfs":
							
							print("Bookshelf")
							
							var selected_bookshelf = picked_object

							var stored_books = book_storage.get_children()
							
							
							
							if selected_bookshelf.state == 0:  #Free
								if stored_books.size() > 0: # if there are books on head
									
									# get book from the bottom
									var bottom_book = stored_books[0]
									
									#place book on the shelf
									book_to_shelf(bottom_book, selected_bookshelf)
							
								else:
									pass
									
							elif selected_bookshelf.state == 1:  # Taken
								
								var book_on_shelf = selected_bookshelf.get_node("BookPosition").get_child(0)
								
								if stored_books.size() < book_capacity:
									shelf_to_player(selected_bookshelf, book_on_shelf)
								
								else:
									if stored_books.size() > 0:
										# get book from the bottom
										var bottom_book = stored_books[0]
										
										switch_books(selected_bookshelf, bottom_book, book_on_shelf)
								
						
							update_book_stack()
						
						"Desk":
							print("Desk")
							
							
							# save picked object as desk
							var selected_desk = picked_object
							
							# player books
							var stored_books = book_storage.get_children()
							
							# access books position
							var deskBooks = selected_desk.get_node("Books")
							
							# get books on desk
							var books_on_desk = deskBooks.get_children()
							
							##################################################################
							
							# if player have some books
							if stored_books.size() > 0:
								
								# get book from the bottom
								var bottom_book = stored_books[0]
								
								######################################################################
								# if desk is not full
								if books_on_desk.size() < selected_desk.desk_capacity:

									#put book on the desk
									book_to_desk(deskBooks, bottom_book)
								
								######################################################################
								
								# or if desk is full
								else:
									
									# if player have space for more books
									if stored_books.size() < book_capacity:
										#take book from the desk
										desk_to_player(deskBooks, books_on_desk[0])
										
									# if both player and desk is full
									else:
										
										# get bottom book from the desk
										var bottom_book_on_desk = books_on_desk[0]
										
										# switch books
										switch_books(deskBooks, bottom_book, bottom_book_on_desk)
							
							######################################################################################
							
							# if player don't have books
							else:
								
								# if there are books on the desk
								if books_on_desk.size() > 0:
									
									# get bottom book from the desk
									var bottom_book_on_desk = books_on_desk[0]
								
									# pick book from the desk
									desk_to_player(deskBooks, bottom_book_on_desk)

							update_book_stack()

							############################################################################################

						"Ladder":
							pass
				
				else:
					var stored_books = book_storage.get_children()
					if stored_books.size() > 0:
						drop_book(stored_books[0]) 


			if Input.is_action_just_pressed("use"): #mapped as Space
				
				
				if interact_ray.is_colliding():
					var picked_object = interact_ray.get_collider()
					
					if picked_object.get_groups()[0] == "Ladder":
						
						ladder = picked_object
						
						translation.x = ladder.translation.x
						rotation.y = 0
						
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
				
				#Shoot a ray to check what is in front
				if interact_ray.is_colliding():
					
					#save collider and check what it is
					var picked_object = interact_ray.get_collider()
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
							
							print("Bookshelf")
							
							var selected_bookshelf = picked_object

							var stored_books = book_storage.get_children()
							
							
							
							if selected_bookshelf.state == 0:  #Free
								if stored_books.size() > 0: # if there are books on head
									
									# get book from the bottom
									var bottom_book = stored_books[0]
									
									#place book on the shelf
									book_to_shelf(bottom_book, selected_bookshelf)
							
								else:
									pass
									
							elif selected_bookshelf.state == 1:  # Taken
								
								var book_on_shelf = selected_bookshelf.get_node("BookPosition").get_child(0)
								
								if stored_books.size() < book_capacity:
									shelf_to_player(selected_bookshelf, book_on_shelf)
								
								else:
									if stored_books.size() > 0:
										# get book from the bottom
										var bottom_book = stored_books[0]
										
										switch_books(selected_bookshelf, bottom_book, book_on_shelf)
								
						
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
					change_animation("Run")
				
				else:
					change_animation("Idle")

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

			var vel = Vector3.ZERO
			
			vel.y = -direction.y * 0.1
			vel.x = direction.x * 0.1
			
				
			if direction.y < 0:
				change_animation("Ladder_up")
			elif direction.y > 0:
				change_animation("Ladder_down")
				vel.y = vel.y * 1.5
				
			else:
				change_animation("STOP")
				
			#left right
			ladder.translate(Vector3(vel.x, 0, 0))
			ladder.translation.x = clamp(ladder.translation.x, -9, 9)
			translation.x = ladder.translation.x
			
			#up down
			translate(Vector3(0, vel.y, 0))
			translation.y = clamp(translation.y, 0.1, 7)




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
	bookshelf.get_node("BookPosition").add_child(book)
	bookshelf.enter_state(1) # 1 means taken
	
	# reset translation and rotation
	book.translation = Vector3.ZERO
	book.rotation = Vector3.ZERO
	
	# pause physics
	book.set_mode(1)
	
	book.place()


func shelf_to_player(bookshelf, book):
	
	print(book.get_name())
	
	bookshelf.get_node("BookPosition").remove_child(book)
	
	# spawn in world
	book_storage.add_child(book)
	bookshelf.enter_state(0) # 1 means Free
	
	#pause physics MODE_STATIC
	book.set_mode(1)
	
	book.pick_up()


func book_to_desk(desk, book):
	
	book_storage.remove_child(book)
	
	# spawn in world
	desk.add_child(book)
	
	# reset translation and rotation
	book.translation = Vector3.ZERO
	book.rotation = Vector3.ZERO
	
	# pause physics
	book.set_mode(1)
	
	book.place()
	
	
func desk_to_player(desk, book):
	
	desk.remove_child(book)
	
	# spawn in world
	book_storage.add_child(book)
	
	#pause physics MODE_STATIC
	book.set_mode(1)
	
	book.pick_up()
	

func switch_books(bookshelf, head_book, shelf_book):
	
	book_storage.remove_child(head_book)
	bookshelf.get_node("BookPosition").remove_child(shelf_book)
	
	# spawn in world
	book_storage.add_child(shelf_book)
	
	bookshelf.get_node("BookPosition").add_child(head_book)
	
	#pause physics MODE_STATIC
	head_book.set_mode(1)
	shelf_book.set_mode(1)
	
	head_book.pick_up()
	shelf_book.place()
	

func switch_books_desk(desk, head_book, desk_book):
	
	book_storage.remove_child(head_book)
	desk.remove_child(desk_book)
	
	# spawn in world
	book_storage.add_child(desk_book)
	
	desk.add_child(head_book)
	
	#pause physics MODE_STATIC
	head_book.set_mode(1)
	desk_book.set_mode(1)
	
	head_book.pick_up()
	desk_book.place()
	
	
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
		

func change_animation(anim_name):
	match anim_name:
		"Run":
			anim_player.play(anim_name)
			anim_player.set_speed_scale(2)
			foot_smoke.set_emitting(true)

		
		"Idle":
			anim_player.play(anim_name)
			anim_player.set_speed_scale(1)
			foot_smoke.set_emitting(false)
		
		
		"Ladder_up":
			anim_player.play(anim_name)
			anim_player.set_speed_scale(3)
			foot_smoke.set_emitting(false)
			
			
		"Ladder_down":
			anim_player.play(anim_name)
			anim_player.set_speed_scale(1)
			foot_smoke.set_emitting(false)
			
		"STOP":
			anim_player.play("Ladder_up")
			anim_player.stop()
