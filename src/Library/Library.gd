extends Spatial
class_name Library

# Bookshelfs #
var all_bookshelfs = []
var all_free_bookshelfs = []
var all_taken_bookshelfs = []
var all_ordered_bookshelfs = []

export var book_in_library: int

# BOOK #
onready var book = preload("res://src/Test_Book/Test_book.tscn")

func _ready():
	update_library()
	
	for i in range(book_in_library):
		spawn_book()
		update_library()
	
# debug
func _process(delta):
	
	if Input.is_action_just_released("editor_save"):
		spawn_book()
		update_library()
	
	if Input.is_action_just_released("X_Button"):
		
		var book_and_shelf = get_book_from_library()
		
		var book_to_remove = book_and_shelf[0]
		var bookshelf_to_clean: BookShelf = book_and_shelf[1]
		
		mark_spot(bookshelf_to_clean)
		
		book_to_remove.call_deferred("free")
		bookshelf_to_clean.enter_state(2)
		
		update_library()


func update_library():
	all_bookshelfs = []
	
	for node in get_children():
		if node is Area:
			all_bookshelfs.append(node)
			
	all_free_bookshelfs = []
	all_taken_bookshelfs = []
	all_ordered_bookshelfs = []
	
	for bookshelf in all_bookshelfs:
		match bookshelf.state:
			0: # Free
				all_free_bookshelfs.append(bookshelf)
				
			1: # Taken
				all_taken_bookshelfs.append(bookshelf)
				
			2: # Ordered
				all_ordered_bookshelfs.append(bookshelf)
			
			3:
				all_ordered_bookshelfs.append(bookshelf)
				
#	print("Free space: " + str(all_free_bookshelfs.size()))
#	print(all_free_bookshelfs)
#	print("Taken space: " + str(all_taken_bookshelfs.size()))
#	print(all_taken_bookshelfs)
#	print("Ordered space: " + str(all_ordered_bookshelfs.size()))
#	print(all_ordered_bookshelfs)
			
			
func get_free_bookshelf():
	
	# if there are any free books
	if all_free_bookshelfs.size() > 0:
		
		#select random free bookshelf from library
		var random_index = randi()%all_free_bookshelfs.size()
		var random_free_bookshelf = all_free_bookshelfs[random_index]
		
		
		return random_free_bookshelf
		
	else:
		return null
	
func get_book_from_library():
	
	if all_taken_bookshelfs.size() > 0:
		var random_index = randi()%all_taken_bookshelfs.size()
		var random_taken_bookshelf = all_taken_bookshelfs[random_index]
		
		var book = random_taken_bookshelf.get_node("BookPosition").get_child(0)
		
		return [book, random_taken_bookshelf]
		
	else:
		return null


func spawn_book():
	
	# make a book
	var generated_book = book.instance()
	
	# find empty spot in library
	var empty_bookshelf:BookShelf = get_free_bookshelf()
	
	# if empty bookshelf is found
	if empty_bookshelf != null:
		
		# mark as taken
		empty_bookshelf.enter_state(1)
		
		# add book to it
		empty_bookshelf.get_node("BookPosition").add_child(generated_book)
		
		### ROMOVE THIS LATER##########
		generated_book.set_desired_bookshelf()
		
		# turn off physics on the book
		generated_book.set_mode(1)
		generated_book.place()
		
	else:
		print("No free bookshelfs")
		


func mark_spot(bookshelf:BookShelf):
	
	if bookshelf != null:
	
		for each_bookshelf in all_bookshelfs:
			each_bookshelf.blink(false)
		
		bookshelf.blink(true)
	
func disable_markers():
	for each_bookshelf in all_bookshelfs:
		each_bookshelf.blink(false)
