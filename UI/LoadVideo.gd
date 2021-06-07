extends Button

onready var path_transcripts = get_node("Settings/PathTrancripts/VBox")
onready var path_audio = get_node("Settings/PathAudio/Path")
onready var popup_settings = $Settings
onready var popup_upload_audio = $FileDialogAudio
onready var popup_upload_transcripts = $FileDialogTranscript

onready var label_path = preload("res://UI/Path.tscn")

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
	settings["transcripts"] = [] # clear in case there is previous deletion
	for transcript in path_transcripts.get_children():
		settings["transcripts"].append(transcript.get_path_name())
	# Get audio path
	if path_audio.is_clear():
		settings["audio"] = null 
	else:
		settings["audio"] = path_audio.get_path_name()
	# Get other settings
	
	# Send data to video player.
	emit_signal("load_new_video", settings)
	hide_settings()

func _on_LoadVideo_pressed():
	open_settings()

func _on_UploadAudio_pressed():
	popup_upload_audio.popup()

func _on_UploadTranscript_pressed():
	popup_upload_transcripts.popup()

func _on_Transcript_files_selected(paths):
	for path in paths:
		var new_label_path = label_path.instance()
		path_transcripts.add_child(new_label_path)
		new_label_path.init(path, "transcript")
	# Change to other upload to start at same directory if haven't uploaded anything yet
	if path_audio.is_clear():
		popup_upload_audio.current_dir = popup_upload_transcripts.current_dir

func _on_Audio_file_selected(path):
	path_audio.set_path_name(path)
	# Change to other upload to start at same directory if haven't uploaded anything yet
	if path_transcripts.get_child_count() == 0:
		popup_upload_transcripts.current_dir = popup_upload_audio.current_dir

func _on_start_offset_changed(offset_start_time):
	settings["audio_start_offset"] = offset_start_time

func _on_Speed_changed(original_playback_speed):
	settings["original_speed"] = original_playback_speed
