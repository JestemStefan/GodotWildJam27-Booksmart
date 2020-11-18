extends AudioStreamPlayer3D


var shouldLoop: bool

func loop(true_false):
	shouldLoop = true_false

func play_audio(audio_clip):
	
	if audio_clip != null:
		set_stream(audio_clip)
		play(0.0)
	else:
		print("Error: No audio file")
		call_deferred("free")


func _on_3D_Audio_Player_finished():
	if shouldLoop:
		# Start playing again, at the beginning
		play(0.0)
	else:
		stop()
		call_deferred("free")
