extends Node2D

onready var Caption = $Caption # current caption on screen
onready var One_Sec_Timer = $Timer # one second timer, use signal to check if change caption
onready var Timeline = $Timeline # timeline of audio
onready var curr_audio = $AudioPlayer

# TO DO: Optimize a few things [less function calls]

# Godot doesn't support pdf https://www.reddit.com/r/godot/comments/lbdk1l/can_godot_open_and_display_pdf_files/
# Try using python to convert a pdf page to image on command given pdf and page number
# check https://github.com/francogarcia/GD-PDF 
# http://theautomatic.net/2020/01/21/how-to-read-pdf-files-with-python/ 

var curr_timed_captions = {} # dictionary of time to caption that appears at that time.
var cap_times = [] #store times (keys) of curr_timed_captions
var curr_video_time = 0 # current watch time of video in seconds # Note this matches time in audio.
var original_speed = 1 # original playback speed of audio. (ie. if audio was recorded at 1.25x speed, then original_speed = 1.25)
var start_time_offset = 0 # start time offset if in case audio itself doesn't start at time 0 as in captions (ie. audio recorded some time after original video)
var video_paused = false # tracks if video paused

# Time stamp deliminator in transcript.
var DELIM_TIME_STAMP = {"begin" : " [", "end" : "] "}
var REWIND_TIME = 10 # amount of seconds to skip video in increments by if click forward / backward button
# Called when the node enters the scene tree for the first time.
func _ready():
	# Transparent for caption player - note settings must be enabled too.
	# this affects performance, so do this only if necessary
	# get_tree().get_root().set_transparent_background(true)
	
	One_Sec_Timer.connect("timeout", self, "on_timer_timeout")
	# new_video(1, "res://W3L1-BinaryRelationsPart1.mp3", "res://Week 3 L1_ Binary Relations-transcript", 5) # Your audio example has variable speed, causing offset later
	new_video(1.25, "res://W3L1-BinaryRelationsPart1.mp3", "res://Week 3 L1_ Binary Relations-transcript.txt", 11, 104) # Use this for later audio
		#YOUR AUDIO has bad variable speed so off, but math should be right

# NOTICE: There is nothing wrong with the math. If your audio becomes off, it may be variable speed.
# WE assume audio is one speed.
	
# TODO: Audio player + settings of deliminators transcript - custom captions, etc.

# start_time_offset - time in real video audio starts at (you must indicate when audio starts in real video)
# start_time - time to start video itself in real time (start at 0 to play from beginning)
func new_video(original_play_speed, audio_file_path, transcript_file_path = null, start_time_offset = 0, start_time = 0):
	One_Sec_Timer.stop()
	original_speed = original_play_speed
	change_playback_speed(original_play_speed)
	get_node("Timeline/Speed").text = str(original_play_speed)
	
	self.start_time_offset = start_time_offset
	curr_video_time = start_time_offset + start_time
	Timeline.value = start_time
	
	if File.new().file_exists(audio_file_path):
		var audio = load(audio_file_path) 
		curr_audio.stream = audio
		# Set max time on timeline to be video-audio length
		Timeline.max_value = int(audio.get_length())
	else:
		print("Audio file " + audio_file_path + " does not exist.")
		
	if transcript_file_path != null:
		set_new_transcript(transcript_file_path)
		set_current_caption(get_closest_cap_time())
	else:
		# option to not set any transcript at all
		curr_timed_captions = {}
		cap_times = [] #TODO: make new function set_curr_timed_cap instead, use in set_new_trans too. (to auto-make cap_times]
	
	# Autoplay video that just loaded - the alternative has audio "popping" noise issue when first load
	curr_audio.play(start_time)
	One_Sec_Timer.start()
	
func _on_Pause_toggled(button_pressed):
	if button_pressed:
		# want to pause video if toggle Pause button
		pause_video()
	else:
		resume_video()
	
# Changed video time - Timeline value in seconds
var prev_timeline_value = 0
func _on_Timeline_value_changed(value):
	# print("Changed time to " + str(value))
	if value != prev_timeline_value + 1 and value != prev_timeline_value:
		set_video_time(value)
	prev_timeline_value = value
	
# pause video - must change timings - or just pause everything, including OS.get_ticks [change to timer instead if hard]
# when scrubbing video - set counter in one sec increments, and restart Timer
# pause - pause Timer [so counter stays same]
func set_video_time(time):
	# Only sets in one second increments. Refresh timer.
	One_Sec_Timer.stop()
	# Change audio time
	if curr_audio.stream != null and time <= curr_audio.stream.get_length():
		curr_audio.seek(time) # audio time at 0 is video start time 
	
	# Change caption # Note - curr_video_time should always have start_time_offset in it
	curr_video_time = time + start_time_offset
	set_current_caption(get_closest_cap_time())
	
	if !video_paused:
		One_Sec_Timer.start()
	
func get_closest_cap_time():
	if cap_times.size() != 0:
		var closest_index = cap_times.bsearch(curr_video_time) # + start_time_offset since audio starts with built in offset
		if closest_index >= cap_times.size():
			closest_index = cap_times.size() - 1
		return cap_times[closest_index]

# speed multiplier here is absolute.; ie. if original playback speed is 1.25, then multip of 1.25 has no effect
func change_playback_speed(speed_multiplier):
	# time and pitch scale are flipped calc since bigger time = slower, but bigger pitch = faster.
	One_Sec_Timer.wait_time = 1 / speed_multiplier # For captions - assume captions timestamps are for playback speed 1
	# print(One_Sec_Timer.wait_time)
	# float(original_speed)
	if curr_audio != null:
		curr_audio.pitch_scale = float(speed_multiplier) / original_speed # The absolute playback speed, as relative to orignal
		# https://godotengine.org/qa/88935/how-can-i-change-speed-of-an-audio-without-changing-its-pitch
		# var shift = AudioServer.get_bus_effect(BUS_INDEX, EFF_INDEX)
		# shift.pitch_scale = 1.0 / pitch
		# Changing speed audio without pitch
		# https://www.reddit.com/r/godot/comments/kzsmd1/gamedev_tip_how_to_change_music_speed_without/
		# https://godotengine.org/qa/45137/speed-of-an-audio

func pause_video():
	One_Sec_Timer.paused = true
	curr_audio.stream_paused = true
	video_paused = true
	
func resume_video():
	One_Sec_Timer.paused = false
	curr_audio.stream_paused = false
	video_paused = false
	
	if One_Sec_Timer.is_stopped():
		One_Sec_Timer.start()
		print("Was stopped")
#	if !curr_audio.playing:
#		curr_audio.play() # Need start time.
#		print("Set to play")
#	else:
#		print("Already playing")

# one second timer - check set caption only every second
func on_timer_timeout():
	# Counts seconds since video started.
	# set_current_caption(curr_timed_captions, get_time_elapsed_sec(curr_start_time))
	curr_video_time += 1
	Timeline.value += 1 # how to not trigger signal?
	set_current_caption(curr_video_time)
	
	if curr_video_time - start_time_offset > Timeline.max_value:
		print("Video ended. " + str(curr_video_time))
		pause_video()
		get_node("Timeline/Pause").pressed = true
#		One_Sec_Timer.stop()
#		curr_audio.stop()
	
	# Real time of audio is curr_audio.get_playback_position() / original_speed + start_time_offset
	# Actually fairly accurate.
#	print("The time is " + str(curr_video_time))
#	print("The time should be " + str(curr_audio.get_playback_position() / original_speed + start_time_offset))
#	var real_time = curr_audio.get_playback_position() / original_speed + start_time_offset
#	if curr_video_time != int(real_time):
#		curr_video_time = real_time
	
# use when start new video
func set_new_transcript(file_path):
	# "restart" new video time
	# curr_start_time = OS.get_ticks_msec() / 1000
	var text = read_file(file_path)
	curr_timed_captions = parse_transcript(text)
	
	cap_times = []
	for time in curr_timed_captions:
		cap_times.append(time)
	cap_times.sort()
	
# Using absolute video time instead with counters with timer
# get time in seconds elpased since time_start_sec (the time in seconds since game started)
#func get_time_elapsed_sec(time_start_sec):
#	var time_curr_sec = OS.get_ticks_msec() / 1000
#	return time_curr_sec - time_start_sec
	
# curr_player_time - current time of video player in seconds
func set_current_caption(curr_player_time):
	# times are sorted separately to make picking right timed caption easier
	var cap = ""
	if curr_player_time in cap_times:
		cap = curr_timed_captions[int(curr_player_time)]
#		print(curr_video_time)
#		print(cap)
		Caption.bbcode_text= "[center]" + cap + "[/center]"
#	else:
#		print("did not set " + str(curr_player_time))
	return cap
	
	
# Given transcript, separate times and caption
# timestamp is in format [mm:ss]
# Return - dictionary of time (in seconds) to caption
func parse_transcript(text):
	var timed_captions = {}
	
	var curr_index = text.find(DELIM_TIME_STAMP["begin"])
	var len_delim_begin = DELIM_TIME_STAMP["begin"].length()
	var len_delim_end = DELIM_TIME_STAMP["end"].length()
	while curr_index != -1:
		var end_index = text.find(DELIM_TIME_STAMP["end"], curr_index)
		var timestamp = text.substr(curr_index + len_delim_begin, 
							end_index - curr_index - len_delim_begin)
		
		# set beginning next timestamp, and ending current caption
		curr_index = text.find(DELIM_TIME_STAMP["begin"], end_index)
		var caption = text.substr(end_index + len_delim_end, 
						curr_index - end_index - len_delim_end)
		
		# set time
		if timestamp_to_sec(timestamp) != null:
			var sec = timestamp_to_sec(timestamp)
			timed_captions[sec] = caption
		else:
			print("Invalid timestamp " + timestamp + " with caption " + caption)
		
	return timed_captions

# timestamp - string of format hh:mm:ss
# Returns - integer of time in seconds
func timestamp_to_sec(timestamp):
	var split_times = timestamp.split(":")
	
	var tot_sec = null
	# last - seconds. mid - minutes. first - hour (if present)
	if split_times.size() == 3:
		# account for hours, min, and seconds
		tot_sec = 60*60*int(split_times[0]) + 60*int(split_times[1]) + int(split_times[2])
	elif split_times.size() == 2:
		# minutes and seconds only
		tot_sec = 60*int(split_times[0]) + int(split_times[1])
	else:
		# only seconds
		if split_times[0] != "0" and int(split_times[0]) == 0:
			print("Invalid transcript timestamp format of " + timestamp)
		else:
			tot_sec = int(split_times[0])
	return tot_sec

# Returns - string text content of file of given type.
func read_file(file_path):
	var f = File.new()
	var err = f.open(file_path, File.READ)
	var content
	if err != OK:
		print("Error opening file " + file_path)
	else:
		content = f.get_as_text()
		f.close()
	return content

func _on_speed_changed(speed):
	change_playback_speed(speed)

# Move backward 10 seconds
func _on_Backward_pressed():
	var new_time = max(curr_video_time - REWIND_TIME, start_time_offset)
	set_video_time(new_time - start_time_offset)
	Timeline.value = new_time - start_time_offset

# Move forward 10 seconds
func _on_Forward_pressed():
	var new_time = min(curr_video_time + REWIND_TIME, Timeline.max_value + start_time_offset)
	set_video_time(new_time - start_time_offset)
	Timeline.value = new_time - start_time_offset

## finished video
#func _on_AudioPlayer_finished():
#	print("Video ended. " + str(curr_video_time))
#	pause_video()
#	$Pause.pressed = true

func _on_Volume_changed(volume):
	curr_audio.set_volume_db(volume)
