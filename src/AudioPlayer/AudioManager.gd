extends Node

const SIMPLE_AUDIO_PLAYER = preload("res://src/AudioPlayer/SimpleAudioPlayer.tscn")
const AUDIO_PLAYER_3D = preload("res://src/AudioPlayer/3D_Audio_Player.tscn")

var audio_clips = {"ambient": preload("res://assets/Audio/GWJ27_loopable_idea_1.ogg"),
					"santa_2": preload("res://assets/Audio/SFX/Santas_2.ogg")}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_sound(sound, shouldLoop = false, position = null):
	
	#check if there is an audio clips
	if audio_clips.has(sound):
		
		#set audioclip
		var audio_file = audio_clips[sound]
		var audio_player
		
		# If sound have position then use 3D audioplayer
		if position is Vector3:
			audio_player = AUDIO_PLAYER_3D.instance()
			audio_player.play_audio(audio_file)
			add_child(audio_player)
			audio_player.loop(shouldLoop)
			audio_player.set_translation(position)
			
		# if position is an 3D object then add it as child to this object
		elif position is Spatial:
			audio_player = AUDIO_PLAYER_3D.instance()
			audio_player.play_audio(audio_file)
			position.add_child(audio_player)
			audio_player.loop(shouldLoop)
			
		else:
			audio_player = SIMPLE_AUDIO_PLAYER.instance()
			audio_player.play_audio(audio_file)
			add_child(audio_player)
			audio_player.loop(shouldLoop)
			

		print("now playing " + sound)
		
	else:
		print("No sound called" + sound + "in library")
