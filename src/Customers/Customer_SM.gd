extends Spatial

# Tween #
onready var tween: Tween = $Tween
onready var desk = get_tree().get_nodes_in_group("Desk")[0]

onready var desk_pos: Spatial = $DeskPosition
onready var exit_pos: Spatial = $ExitPosition

onready var customer: Spatial = $Customer_Wizard
onready var customer_animPlayer: AnimationPlayer = $Customer_Wizard/Wizard/AnimationPlayer

onready var customer_patience: Timer = $Customer_Patience_Timer

export var WAIT_TIME: int

# Meta #
enum State {WALK_TO_DESK, GIVE_BOOKS, WAIT, WRONG_BOOK, CORRECT_BOOK, WALK_TO_EXIT}
var state : int 

func _ready():
	state = State.WALK_TO_DESK
	enter_state(state)

func enter_state(new_state):
	
	state = new_state
	match state:
		
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


		State.WAIT:
			print("Waiting at desk")
			customer.look_at(desk.get_global_transform().origin, Vector3.UP)
			change_animation("Idle")
			customer_patience.start(WAIT_TIME)
		
		
		State.CORRECT_BOOK:
			print("Correct book")
			change_animation("Book_Good")
			
			customer_patience.start(1)
			
			
		State.WRONG_BOOK:
			pass
			
			
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
			enter_state(State.WAIT)
			
		State.WALK_TO_EXIT:
			call_deferred("free")

func _on_Customer_Patience_Timer_timeout():
	match state:
		State.WAIT:
			enter_state(State.CORRECT_BOOK)
			
		State.CORRECT_BOOK:
			enter_state(State.WALK_TO_EXIT)
