extends Area

var state : int
enum States {FREE, TAKEN}

func _ready():
	state = States.FREE

func enter_state(new_state):
	state = new_state
