extends Node

const SIMPLE_AUDIO_PLAYER = preload("res://src/AudioPlayer/SimpleAudioPlayer.tscn")
const AUDIO_PLAYER_3D = preload("res://src/AudioPlayer/3D_Audio_Player.tscn")

var audio_clips = {"ambient": preload("res://assets/Audio/GWJ27_loopable_idea_1.ogg"),
					"game_music": preload("res://assets/Audio/GWJ27_Music_V4.ogg"),
					"wizard_fail": preload("res://assets/Audio/SFX/Santas_Death.ogg"),
					"wizard_good": preload("res://assets/Audio/SFX/Santas-3.ogg"),
					"warrior_fail": preload("res://assets/Audio/SFX/Confusion-Voice-3.ogg"),
					"warrior_good": preload("res://assets/Audio/SFX/Affirmative_Voice_4.ogg"),
					"ninja_fail": preload("res://assets/Audio/SFX/Confusion-Voice-2.ogg"),
					"ninja_good": preload("res://assets/Audio/SFX/Affirmative_Voice_3.ogg"),
					"archer_fail": preload("res://assets/Audio/SFX/Confusion-Voice-4.ogg"),
					"archer_good": preload("res://assets/Audio/SFX/Affirmative-Voice-6.ogg"),
					"book_sparkle": preload("res://assets/Audio/SFX/GWJ27_book_sparkle_5.ogg"),
					"menu": preload("res://assets/Audio/assets_Audio_GWJ27_Menu.ogg"),
					"party": preload("res://assets/Audio/Party-blower.ogg"),
					"applause": preload("res://assets/Audio/mixkit-auditorium-moderate-appla.ogg"),
					"main": preload("res://assets/Audio/GWJ27_Music_V4.ogg"),
					"whistle": preload("res://assets/Audio/SFX/referee-blowing-whistle-sound-effect.ogg"),
					"doorbell": preload("res://assets/Audio/SFX/Shop_entry_2.ogg")}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_sound(sound, shouldLoop = false, position = null, bus="Music"):
	
	#check if there is an audio clips
	if audio_clips.has(sound):
		
		#set audioclip
		var audio_file = audio_clips[sound]
		var audio_player
		
		# If sound have position then use 3D audioplayer
		if position is Vector3:
			audio_player = AUDIO_PLAYER_3D.instance()
			audio_player.play_audio(audio_file)
			audio_player.name = sound
			add_child(audio_player, true)
			audio_player.set_bus(bus)
			audio_player.loop(shouldLoop)
			audio_player.set_translation(position)
			
		# if position is an 3D object then add it as child to this object
		elif position is Spatial:
			audio_player = AUDIO_PLAYER_3D.instance()
			audio_player.play_audio(audio_file)
			audio_player.name = sound
			position.add_child(audio_player, true)
			audio_player.set_bus(bus)
			audio_player.loop(shouldLoop)
			
		else:
			audio_player = SIMPLE_AUDIO_PLAYER.instance()
			audio_player.play_audio(audio_file)
			audio_player.name = sound
			add_child(audio_player, true)
			audio_player.set_bus(bus)
			audio_player.loop(shouldLoop)
			

		print("now playing " + sound)
		
	else:
		print("No sound called" + sound + "in library")



func stop_sound(sound):
	
	if audio_clips.has(sound):
		for audio_player in get_children():
			if audio_player is AudioStreamPlayer || audio_player is AudioStreamPlayer3D:
				if audio_player.name == sound:
					audio_player.stop()
					audio_player.queue_free()
	
	else:
		print("No sound called" + sound + "in library")
