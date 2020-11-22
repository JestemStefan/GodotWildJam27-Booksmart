extends RigidBody
class_name Book

var state: int
enum State{FREE, ORDERED, RENTED}

onready var library = get_tree().get_nodes_in_group("Library")[0]
var desired_bookshelf: BookShelf

const PATH = "res://models/books/"

var color : String = ["red", "yellow", "green", "blue"][randi() % 4]
var numeral : String = ["I", "II", "III", "IV"][randi() % 4]
var symbol : String = ["ninja", "knight", "wizard", "archer"][randi() % 4]

onready var mesh := $MeshInstance
onready var pickUpArea: Area = $Area


func _ready() -> void:
	randomize()
	apply_material()
	state = State.FREE
	set_desired_bookshelf()


func pick_up() -> void:
	# Disable collision
	set_collision_mask(0)
	set_collision_layer(0)
	pickUpArea.set_collision_layer(0)


func throw() -> void:
	# Enable collision
	set_collision_mask(15)
	set_collision_layer(2)
	pickUpArea.set_collision_layer(8)


func place() -> void:
	# Enable collision
	set_collision_mask(0)
	set_collision_layer(2)
	pickUpArea.set_collision_layer(0)


func apply_material() -> void:
	
	var material_color = SpatialMaterial.new()
	var material_numeral = SpatialMaterial.new()
	var material_symbol = SpatialMaterial.new()
	
	match color:
		"red": material_color.albedo_texture = load(PATH + "book_d.jpg")
		"green": material_color.albedo_texture = load(PATH + "book_d2.jpg")
		"blue": material_color.albedo_texture = load(PATH + "book_d3.jpg")
		"yellow": material_color.albedo_texture = load(PATH + "book_d3.jpg")
	
	match numeral:
		"I": material_numeral.albedo_texture = load(PATH + "numset_1.png")
		"II": material_numeral.albedo_texture = load(PATH + "numset_2.png")
		"III": material_numeral.albedo_texture = load(PATH + "numset_3.png")
		"IV": material_numeral.albedo_texture = load(PATH + "numset_4.png")
	
	match symbol:
		"ninja": material_symbol.albedo_texture = load(PATH + "numset_1.png")
		"knight": material_symbol.albedo_texture = load(PATH + "numset_2.png")
		"wizard": material_symbol.albedo_texture = load(PATH + "numset_3.png")
		"archer": material_symbol.albedo_texture = load(PATH + "numset_4.png")
	
	material_numeral.flags_transparent = true
	material_symbol.flags_transparent = true
	
	#material_color.albedo_texture = load("res://models/books/book_d.jpg")
	
	mesh.set_surface_material(0, material_color)
	mesh.set_surface_material(1, material_numeral)
	mesh.set_surface_material(2, material_symbol)


func set_desired_bookshelf():
	desired_bookshelf = library.get_free_bookshelf()
	desired_bookshelf.enter_state(2)
	library.update_library()
