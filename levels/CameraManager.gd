extends Spatial

var state
enum States{SPAWN, DESK, LEFT_BOTTOM, RIGHT_BOTTOM, CENTER_TOP, 
			CENTER_LEFT, CENTER_RIGHT, LADDER_BOTTOM, LADDER_TOP}

onready var tween: Tween = $Tween

onready var camera = $Camera_Transform/Camera
onready var camera_transform = $Camera_Transform

onready var desk_camera = $Desk_Camera
onready var bottom_left = $Bottom_Left_Camera
onready var bottom_right = $Bottom_Right_Camera 
onready var top_center = $Top_Center_Camera 
onready var top_left = $Top_Left_Camera
onready var top_right = $Top_Right_Camera



func _ready():
	move_camera(desk_camera )
	

func move_camera(target):
	
	tween.stop_all()
	
	tween.set_active(true)
	tween.interpolate_property(camera_transform, 				# who
										"transform", 			# what
										camera_transform.transform, 	# initial value
										target.transform, 	# end value
										1,						# rate
										Tween.TRANS_LINEAR, 	# transition type
										Tween.EASE_IN_OUT)		# easing
	tween.start()
	
func _on_Desk_Area_body_entered(body:KinematicBody):
	if body.get_groups()[0] == "Player":
		move_camera(desk_camera)


func _on_Left_Bottom_Area_body_entered(body):
	if body.get_groups()[0] == "Player":
		move_camera(bottom_left)


func _on_Right_Bottom_Area_body_entered(body):
	if body.get_groups()[0] == "Player":
		move_camera(bottom_right)


func _on_Center_Top_Area_body_entered(body):
	if body.get_groups()[0] == "Player":
		move_camera(top_center)


func _on_Center_Left_Area_body_entered(body):
	if body.get_groups()[0] == "Player":
		move_camera(top_left)


func _on_Center_Right_Area_body_entered(body):
	if body.get_groups()[0] == "Player":
		move_camera(top_right)
