extends Area
class_name BookShelf

var state : int
enum States {FREE, TAKEN, ORDERED}

onready var marker: MeshInstance = $Marker
onready var effect_player: AnimationPlayer = $EffectPlayer

func _ready():
	state = States.FREE

func enter_state(new_state):
	state = new_state

func blink(on_off: bool):
	
	match on_off:
		true:
			marker.set_visible(true)
			effect_player.play("Blink")
		false:
			marker.set_visible(false)
			effect_player.stop()

	
