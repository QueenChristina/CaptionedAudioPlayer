extends Label

# An "id" number of the caption, this "time" serves to identify one caption from another
export var time = 0 setget set_time, get_time
onready var FocusStyle = preload("res://VideoParts/CapFocus.tres")
onready var UnfocusStyle = preload("res://VideoParts/CapUnfocus.tres")
onready var HoverStyle = preload("res://VideoParts/CapHover.tres")

var selectable = false

signal caption_clicked()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_time(new_time):
	time = new_time
	
func get_time():
	return time

func _on_Cap_mouse_entered():
	selectable = true
	# Change to hover style
	self.add_stylebox_override("normal", HoverStyle)

func _on_Cap_mouse_exited():
	selectable = false
	# Change style to before hover
	if self.has_focus():
		self.add_stylebox_override("normal", FocusStyle)
	else:
		self.add_stylebox_override("normal", UnfocusStyle)

func _on_Cap_gui_input(_event):
	if selectable and Input.is_action_pressed("click"):
		# print("clicked on " + self.text)
		emit_signal("caption_clicked")
