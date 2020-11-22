extends KinematicBody

onready var angry_material = preload("res://src/Barrel/Barrel_angry.material")
onready var calm_material = preload("res://src/Barrel/Barrel_peaceful.material")

onready var barrel_mesh = $Shedderenemy/Skeleton/Shredder

onready var player: KinematicBody = get_tree().get_nodes_in_group("Player")[0]
var victim
onready var nav: Navigation = get_tree().get_nodes_in_group("Navigation")[0]
onready var anim_player: AnimationPlayer = $AnimationPlayer

onready var path_timer: Timer = $Path_Timer
onready var victim_timer: Timer = $Victim_Timer
onready var bookKill_timer: Timer = $BookKill_Timer

var path = []
var path_node = 0

onready var idle_position = get_global_transform().origin
export var speed: int

var state
enum States{IDLE, MOVE, BACK}



func _ready():
	enter_state(States.IDLE)


func enter_state(new_state):
	
	state = new_state
	print(state)
	
	match state:
		States.IDLE:
			print("Berrel IDLE")
			victim_timer.start(2)
			play_animation("Idle")
			change_material()
			
		States.MOVE:
			print("Berrel Move")
			path_timer.start(0.5)
			play_animation("Walk")
			change_material()
			
		States.BACK:
			print("Berrel Back")
			path_timer.start(0.5)
			play_animation("Walk")
			change_material()

func change_material():
	match state:
		States.MOVE:
			barrel_mesh.set_surface_material(0, angry_material)
			
		States.IDLE:
			barrel_mesh.set_surface_material(0, calm_material)
			
		States.BACK:
			barrel_mesh.set_surface_material(0, calm_material)
	
func _physics_process(delta):
	
	match state:
		States.IDLE:
			look_at(player.global_transform.origin, Vector3.UP)
	
		States.MOVE:
			if victim != null:
				if global_transform.origin.distance_squared_to(victim.global_transform.origin) < 2:
					victim.smoke()
					victim.place()
					bookKill_timer.start(1)
				
				if path_node < path.size():
					var dir:Vector3 = (path[path_node] - global_transform.origin)
					if dir.length_squared() < 1:
						path_node += 1

					else:
						process_movement(dir)
		
		States.BACK:
			if global_transform.origin.distance_squared_to(idle_position) < 2:
				enter_state(States.IDLE)
			
			if path_node < path.size():
				var dir:Vector3 = (path[path_node] - global_transform.origin)
				if dir.length_squared() < 1:
					path_node += 1

				else:
					process_movement(dir)
			
			
func process_movement(direction):
	look_at(path[path_node], Vector3.UP)
	move_and_slide(direction.normalized() * speed, Vector3.UP)

func get_new_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
	
	path_timer.start(1)


func play_animation(anim_name):
	
	match anim_name:
		"Idle":
			anim_player.play(anim_name)
			anim_player.set_speed_scale(1)
			
		"Walk":
			anim_player.play(anim_name)
			anim_player.set_speed_scale(2)



			
			
func _on_Path_Timer_timeout():
	
	match state:
		States.IDLE:
			if victim!= null:
				enter_state(States.MOVE)
			
		States.MOVE:
			if victim != null:
				get_new_path(victim.get_global_transform().origin)
			
		States.BACK:
			get_new_path(idle_position)


func _on_Victim_Timer_timeout():
	match state:
		States.IDLE:
			var victims = get_tree().get_nodes_in_group("Orphans")
			print(victims)
			
			if victims.size() > 0:
				victim = victims[0]
				print("chasing: " + victim.get_name())
		
				path_timer.start(0.5)
		
func remove_victim(book):
	
	if victim == book:
		victim = null
		enter_state(States.BACK)


func _on_BookKill_Timer_timeout():
	print("Barrel back")
	var temp_victim = victim
	remove_victim(victim)
	temp_victim.call_deferred("free")
	
	
	enter_state(States.BACK)
