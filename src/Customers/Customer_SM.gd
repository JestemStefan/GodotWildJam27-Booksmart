extends Spatial

# Tween #
onready var tween: Tween = $Tween
onready var desk: Desk = get_tree().get_nodes_in_group("Desk")[0]

# Book #
onready var library:Library = get_tree().get_nodes_in_group("Library")[0]
onready var book = preload("res://src/Test_Book/Test_book.tscn")

var book_ordered: Book

onready var spawn_pos: Spatial = $SpawnPosition
onready var desk_pos: Spatial = $DeskPosition
onready var exit_pos: Spatial = $ExitPosition

onready var customer: Spatial = $Customer

onready var Wizard = preload("res://src/Customers/Wizard.tscn")
onready var Archer = preload("res://src/Customers/Archer.tscn")
onready var Ninja = preload("res://src/Customers/Ninja.tscn")
onready var Warrior = preload("res://src/Customers/Warrior.tscn")

var customer_type
onready var customer_hand = $Customer/Books
onready var customer_animPlayer: AnimationPlayer

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
			
			customer_type = null
			
			randomize()
			var random = randi()%4
			var random_customer = [Wizard, Archer, Ninja, Warrior][random]
			
			match random:
				0:
					customer_type = "Wizard"
				1:
					customer_type = "Archer"
				2:
					customer_type = "Ninja"
				3:
					customer_type = "Warrior"
			
			var spawn_customer = random_customer.instance()
			
			customer.add_child(spawn_customer)
			
			customer.translation = spawn_pos.translation
			customer_animPlayer = spawn_customer.get_anim_player()
			
			# get customer hand
			var customer_hand = $Customer/Books
			
			for i in range(randi()%2 + 1):
				generate_book(customer_hand)
			
			enter_state(State.WALK_TO_DESK)
		
		
		State.WALK_TO_DESK:
			
			tween.interpolate_property(customer, 				# who
										"translation", 			# what
										customer.translation, 	# initial value
										desk_pos.translation, 	# end value
										2,						# rate
										Tween.TRANS_LINEAR, 	# transition type
										Tween.EASE_IN_OUT)		# easing
			tween.start()
			
			customer.look_at(desk_pos.get_global_transform().origin, Vector3.UP)
			change_animation("Walk")

		State.GIVE_BOOKS:
			var customer_books = customer_hand.get_children()
			
			for customer_book in customer_books:
				give_books(customer_book)
				

			
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
			customer.look_at(desk.get_global_transform().origin, Vector3.UP)
			change_animation("Idle")
			
			
		State.CORRECT_BOOK:
			change_animation("Book_Good")
			
			match customer_type:
				"Wizard":
					AudioManager.play_sound("wizard_good", false, customer, "Voice")
				
				"Warrior":
					AudioManager.play_sound("warrior_good", false, customer, "Voice")
				
				"Ninja":
					AudioManager.play_sound("ninja_good", false, customer, "Voice")
				
				"Archer":
					AudioManager.play_sound("archer_good", false, customer, "Voice")
			
			customer_patience.start(1)
			
			
		State.WRONG_BOOK:
			change_animation("Book_Bad")
			
			match customer_type:
				"Wizard":
					AudioManager.play_sound("wizard_fail", false, customer, "Voice")
				
				"Warrior":
					AudioManager.play_sound("warrior_fail", false, customer, "Voice")
					
				"Ninja":
					AudioManager.play_sound("ninja_fail", false, customer, "Voice")
				
				"Archer":
					AudioManager.play_sound("archer_fail", false, customer, "Voice")
			
			
			customer_patience.start(1)
			
		State.WALK_TO_EXIT:
			
			tween.interpolate_property(customer, 				# who
										"translation", 			# what
										customer.translation, 	# initial value
										exit_pos.translation, 	# end value
										2,						# rate
										Tween.TRANS_LINEAR, 	# transition type
										Tween.EASE_IN_OUT)		# easing
			tween.start()
			
			customer.look_at(exit_pos.get_global_transform().origin, Vector3.UP)
			change_animation("Walk")
	
func _physics_process(delta):
		pass
	
func change_animation(anim_name):
	match anim_name:
		"Walk":
			customer_animPlayer.play(anim_name)
			customer_animPlayer.set_speed_scale(3)

		
		"Idle":
			customer_animPlayer.play(anim_name)
			customer_animPlayer.set_speed_scale(1)
			
		"Book_Good":
			customer_animPlayer.play(anim_name)
			customer_animPlayer.set_speed_scale(1.5)
			
		"Book_Bad":
			customer_animPlayer.play(anim_name)
			customer_animPlayer.set_speed_scale(1)

			


func _on_Tween_tween_completed(object, key):
	
	match state:
		State.WALK_TO_DESK:
			enter_state(State.GIVE_BOOKS)
			
			
		State.WALK_TO_EXIT:
			customer.get_child(1).call_deferred("free")
			enter_state(State.SPAWN)

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
		
		
		var correct_book_found: bool = false
		
		for book in books_on_table:
			if book == book_ordered:
				
				correct_book_found = true
				GameState.add_points(25)
				
				desk.enable_particles("stars", true)
				AudioManager.play_sound("book_sparkle", false, desk, "Effects")
				desk.enable_particles("particles", false)
				
				book_ordered = null
				book.call_deferred("free")
				
				enter_state(State.CORRECT_BOOK)
		
		
		if not correct_book_found:
			enter_state(State.WRONG_BOOK)
	
func generate_book(customer_hand):
	# make a book
	var generated_book = book.instance()
	# add book to it
	customer_hand.add_child(generated_book)
	generated_book.enter_state(2)
	
	# get free place for this book
	generated_book.set_desired_bookshelf()
	
	# turn off physics on the book
	generated_book.set_mode(1)
	generated_book.place()
	
func give_books(customer_book):
	
	customer_hand.remove_child(customer_book)

	# spawn in world
	desk.get_node("Books").add_child(customer_book)
	desk._render()
	
	# pause physics
	customer_book.set_mode(1)
	
	customer_book.place()
