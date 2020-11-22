extends Inventory
class_name Desk

export var desk_capacity: int
signal book_placed



# Variables
onready var books = $Books
onready var particles: Particles = $Particles
onready var stars: Particles = $Stars

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

func enable_particles(particle, on_off: bool):
	match particle:
		"stars":
			stars.set_emitting(on_off)
		
		"particles":
			particles.set_emitting(on_off)
