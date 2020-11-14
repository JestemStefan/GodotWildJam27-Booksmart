extends KinematicBody

var globals

# Movement variables #
const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40
var dir = Vector3()

onready var run_audio: AudioStreamPlayer = $RunningAudio

# Camera variables #
var camera
var rotation_helper
var MOUSE_SENSITIVITY = 0.1

# Shooting #
var canFire: bool = true
onready var ray_cast: RayCast = $Rotation_Helper/RayCast
onready var anim_player: AnimationPlayer = $Rotation_Helper/Gun/Rifle/AnimationPlayer
#onready var b_decal = preload("res://ammunition/BulletDecal.tscn")

# Health and ammo #
var respawn_position: Vector3
export var health: float
onready var health_particle: Particles = $Health_Particle
export var ammo: int

# UI #
onready var HUD: Control = $HUD


func _ready():
	if owner.find_node("PlayerRespawnPoint") != null:
		respawn_position = owner.find_node("PlayerRespawnPoint").global_transform.origin
	else:
		respawn_position = global_transform.origin
	globals = get_node("/root/Globals")
	
	change_animation("Idle")  #Start with idle animation
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	
	HUD.set_heath(health)
	HUD.set_ammo(ammo)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("move_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backwards"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if vel != Vector3.ZERO:
			if !run_audio.playing:
				run_audio.play()
		else:
			run_audio.stop()
		
		if Input.is_action_just_pressed("move_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	if Input.is_action_just_pressed("ui_fire") and canFire:
		if ammo > 0:
			canFire = false
			lose_ammo(1)
			process_raycast(delta)
			change_animation("Fire")
	


	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func process_raycast(_delta):
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		# Check if target can take damage
		if collider.has_method("take_damage"):
			collider.take_damage(40)
		
		if collider.get_parent().has_method("damage_part"):
			collider.get_parent().damage_part(collider.get_name())
		
		add_bullet_decal()


func take_damage(damage_amount):
	
	health -= damage_amount
	
	if health <= 0:
		respawn()
	HUD.set_heath(health)
	
	
func heal(hp_amount):
	health_particle.set_emitting(true)
	health += hp_amount
	if health > 100:
		health = 100
	
	HUD.set_heath(health)

func gain_ammo(ammo_amount):
	ammo += ammo_amount
	
	if ammo > 200:
		ammo = 20
	
	HUD.set_ammo(ammo)

func lose_ammo(amount):
	ammo -= 1
	
	HUD.set_ammo(ammo)
	
func respawn():
	translation = respawn_position
	health = 50
	ammo = 5
	
	HUD.set_heath(health)
	HUD.set_ammo(ammo)
# ANIMATION FUNCTIONS

func change_animation(anim_name:String):
	match anim_name:
		"Idle":
			anim_player.set_speed_scale(1)
			anim_player.play("Idle")
		"Fire":
			globals.play_sound("rifle_shot")

			anim_player.set_speed_scale(2)
			anim_player.play("Fire")
	


func _on_AnimationPlayer_animation_finished(anim_name):
	
	change_animation("Idle") # back to idle animation
	match anim_name:
		"Fire":
			canFire = true


func add_bullet_decal():
#	var b = b_decal.instance()
#	ray_cast.get_collider().add_child(b)
#	b.global_transform.origin = ray_cast.get_collision_point()
#	b.look_at(ray_cast.get_collision_point() + ray_cast.get_collision_normal(), Vector3(0.3,0.3,0.3))
	pass

