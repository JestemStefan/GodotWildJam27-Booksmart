extends Spatial

# Tween #
onready var tween: Tween = $Tween
onready var desk: Desk = get_tree().get_nodes_in_group("Desk")[0]

# Book #
onready var library:Library = get_tree().get_nodes_in_group("Library")[0]
onready var book = preload("res://src/Test_Book/Test_book.tscn")

var book_ordered: Book

onready var desk_pos: Spatial = $DeskPosition
onready var exit_pos: Spatial = $ExitPosition

onready var customer: Spatial = $Customer_Wizard
onready var customer_hand = $Customer_Wizard/Books
onready var customer_animPlayer: AnimationPlayer = $Customer_Wizard/Wizard/AnimationPlayer

onready var customer_patience: Timer = $Customer_Patience_Timer
onready var timer: Timer = $Timer

export var WAIT_TIME: int

# Meta #
enum State {SPAWN, WALK_TO_DESK, GIVE_BOOKS, ORDER_BOOK, WAIT, WRONG_BOOK, CORRECT_BOOK, WALK_TO_EXIT, DESPAWN}
var state : int 

func _ready():
	timer.start(1)

func enter_state(new_state):
	
	state = new_state
	match state:
		
		State.SPAWN:
			print("Customer spawned")
			# make a book
			var generated_book = book.instance()
			
			# get customer hand
			var customer_hand = $Customer_Wizard/Books
			
		
			# add book to it
			customer_hand.add_child(generated_book)
			generated_book.enter_state(2)
			
			# get free place for this book
			generated_book.set_desired_bookshelf()
			
			# turn off physics on the book
			generated_book.set_mode(1)
			generated_book.place()
			
			enter_state(State.WALK_TO_DESK)
		
		
		State.WALK_TO_DESK:
			print("Walking to desk")
			
			tween.interpolate_property(customer, 				# who
										"translation", 			# what
										customer.translation, 	# initial value
										desk_pos.translation, 	# end value
										5,						# rate
										Tween.TRANS_LINEAR, 	# transition type
										Tween.EASE_IN_OUT)		# easing
			tween.start()
			
			customer.look_at(desk_pos.get_global_transform().origin, Vector3.UP)
			customer_animPlayer.play("Run")

		State.GIVE_BOOKS:
			
			var customer_book = customer_hand.get_child(0)
			customer_hand.remove_child(customer_book)
	
			# spawn in world
			desk.get_node("Books").add_child(customer_book)
			desk._render()
			
			# pause physics
			customer_book.set_mode(1)
			
			customer_book.place()
			
			print("customer book to desk")
			
			enter_state(State.ORDER_BOOK)
			
		State.ORDER_BOOK:
			
			book_ordered = null
			
			# get free book from library
			var book_and_shelf = library.get_book_from_library()
			book_ordered = book_and_shelf[0]
			
			# 0=Free 1=Ordered 2=Rented 3=Orphan
			book_ordered.enter_state(1)
			
#			# do something with book
			book_ordered.enable_particles(true)
#			desk.enable_particles(true)
			
			enter_state(State.WAIT)
			
		State.WAIT:
			print("Waiting at desk")
			customer.look_at(desk.get_global_transform().origin, Vector3.UP)
			change_animation("Idle")
			
			
		State.CORRECT_BOOK:
			print("Correct book")
			change_animation("Book_Good")
			
			customer_patience.start(1)
			
			
		State.WRONG_BOOK:
			print("Wrong book")
			change_animation("Book_Bad")
			
			customer_patience.start(1)
			
		State.WALK_TO_EXIT:
			print("Walking to exit")
			
			tween.interpolate_property(customer, 				# who
										"translation", 			# what
										customer.translation, 	# initial value
										exit_pos.translation, 	# end value
										5,						# rate
										Tween.TRANS_LINEAR, 	# transition type
										Tween.EASE_IN_OUT)		# easing
			tween.start()
			
			customer.look_at(exit_pos.get_global_transform().origin, Vector3.UP)
			change_animation("Run")
	
func _physics_process(delta):
		pass

func generate_books():
	pass
	
func change_animation(anim_name):
	match anim_name:
		"Run":
			customer_animPlayer.play(anim_name)
			customer_animPlayer.set_speed_scale(2)

		
		"Idle":
			customer_animPlayer.play(anim_name)
			customer_animPlayer.set_speed_scale(1)
			
		"Book_Good":
			customer_animPlayer.play(anim_name)
			customer_animPlayer.set_speed_scale(1.5)

			


func _on_Tween_tween_completed(object, key):
	
	match state:
		State.WALK_TO_DESK:
			enter_state(State.GIVE_BOOKS)
			
			
		State.WALK_TO_EXIT:
			call_deferred("free")

func _on_Customer_Patience_Timer_timeout():
	match state:
		State.WAIT:
			enter_state(State.WRONG_BOOK)
			
		State.WRONG_BOOK:
			enter_state(State.WAIT)
			
		State.CORRECT_BOOK:
			enter_state(State.WALK_TO_EXIT)


func _on_Timer_timeout():
	enter_state(State.SPAWN)


func _on_Desk_book_placed():
	
	if state == State.WAIT:
		var books_on_table = desk.get_node("Books").get_children()
		
		print([books_on_table, book_ordered])
		
		var correct_book_found: bool = false
		
		for book in books_on_table:
			if book == book_ordered:
				
				correct_book_found = true
				GameState.add_points(25)
				
				desk.enable_particles("stars", true)
				desk.enable_particles("particles", false)
				
				book_ordered = null
				book.call_deferred("free")
				
				enter_state(State.CORRECT_BOOK)
				
		if not correct_book_found:
			enter_state(State.WRONG_BOOK)
	
	
