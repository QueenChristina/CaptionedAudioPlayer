extends HSlider

onready var label_time = $Time

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_value_changed(seconds):
	label_time.bbcode_text = "[right]" + sec_to_time(seconds) + "[/right]"

func sec_to_time(seconds):
	var minutes = int(seconds / 60)
	var hours = int(seconds / (60*60))
	seconds = seconds - minutes*60 - hours*60*60
	var str_sec
	if seconds < 10:
		str_sec = ":0" + str(seconds)
	else:
		str_sec = ":"  + str(seconds)
		
	var time = ""
	if hours != 0:
		time = str(hours) + ":" + str(minutes) + str_sec
	elif minutes != 0:
		time = str(minutes) + str_sec
	else:
		time = str(0) + str_sec 
	return time
