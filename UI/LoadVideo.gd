extends Button

onready var path_transcripts = get_node("Settings/PathTrancripts/VBox")
onready var path_audio = get_node("Settings/PathAudio/Path")
onready var popup_settings = $Settings

# Dictionary of transcript paths, audio paths, original plaback speed, etc.
var settings = {"transcripts" : [],
				"audio" : "",
				"original_speed" : 1,
				"audio_start_offset" : 0}

signal load_new_video(settings)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func hide_settings():
	popup_settings.visible = false
	
func open_settings():
	popup_settings.popup()
	
func clear_settings():
	for transcript in path_transcripts.get_children():
		transcript.delete()
	path_audio.clear() # Do not delete audio path.
	
func _on_Save_pressed():
	# Get transcript paths
	for transcript in path_transcripts.get_children():
		settings["transcripts"].append(transcript.get_path_name())
	# Get audio path
	if path_audio.is_clear():
		print("No audio file selected. Keeping previous audio...")
		settings["audio"] = null # Make sure to check in Player
	else:
		settings["audio"] = path_audio.get_path_name()
	# Get other settings
	
	# Send data to video player.
	emit_signal("load_new_video", settings)
	hide_settings()

func _on_Cancel_pressed():
	clear_settings()
	hide_settings()

func _on_LoadVideo_pressed():
	open_settings()

func _on_UploadAudio_pressed():
	pass # Replace with function body.

func _on_UploadTranscript_pressed():
	pass # Replace with function body.
