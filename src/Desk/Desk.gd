extends Inventory
class_name Desk

# Variables
onready var books = $Books



func _render() -> void:
	for i in len(books.get_children()):
		var book : Book = books.get_children()[i]
		
		book.rotation_degrees = Vector3(
			0,
			randi() % 360,
			90
		)
		
		book.translation = Vector3(
			rand_range(-0.1, 0.1),
			i * 0.4,
			rand_range(-0.1, 0.1)
		)



func _item_added(item : Object) -> void:
	books.add_child(item.duplicate())

func _item_erased(item : Object) -> void:
	books.remove_child(item)

func _item_removed(index : int) -> void:
	books.get_children()[index].queue_free()



func _update() -> void:
	for book in books.get_children():
		book.mode = RigidBody.MODE_STATIC
