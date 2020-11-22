extends Inventory
class_name Desk

export var desk_capacity: int

# Variables
onready var books = $Books



func _render() -> void:
	for i in len(books.get_children()):
		var book : Book = books.get_children()[i]
		
		book.rotation_degrees = Vector3(
			90,
			i * 60,
			0
		)
		
		book.translation = Vector3(
			0,
			i * 0.4,
			0
		)
