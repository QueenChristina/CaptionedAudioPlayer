extends HSlider

onready var label_time = $Time

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Show text of current video time.
func _on_value_changed(seconds):
	label_time.bbcode_text = "[right]" + sec_to_time(seconds) + "[/right]"

# Convert seconds to string format hh:mm:ss
func sec_to_time(seconds):
	var minutes = int(seconds / 60) % 60
	var hours = int(seconds / (60*60))
	seconds = seconds - minutes*60 - hours*60*60
	var str_sec
	if seconds < 10:
		str_sec = ":0" + str(seconds)
	else:
		str_sec = ":"  + str(seconds)
		
	var time = ""
	if hours != 0:
		var str_min
		if minutes < 10:
			str_min = ":0" + str(minutes)
		else:
			str_min = ":" + str(minutes)
		time = str(hours) + str_min + str_sec
	elif minutes != 0:
		time = str(minutes) + str_sec
	else:
		time = str(0) + str_sec 
	return time

# On mouse hover, show time of video (set: hint_tooltip)
var hovering = false
func _on_mouse_entered():
	hovering = true

func _on_mouse_exited():
	hovering = false
	
# Gets time on timeline based on mouse position
func get_hover_time():
	var tick_px = (self.rect_size.x - 8) / self.max_value # pixels per one second tick # 5 for pixels not used for slider
	var seconds = int (get_local_mouse_position().x / tick_px)
	return sec_to_time(seconds)

func _input(event):
	if hovering and event is InputEventMouseMotion:
		# Change timeline hover time
		self.hint_tooltip = get_hover_time()

func _on_Search_go_to_caption(time):
	self.value = time
	label_time.bbcode_text = "[right]" + sec_to_time(time) + "[/right]"
