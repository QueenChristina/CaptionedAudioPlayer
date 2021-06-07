extends HBoxContainer

onready var label = $Label

var path_name
export var file_type = ""# file_type of path; transcript or audio
var LABEL_LENGTH = 30 #chars to display as path on label
signal delete_path(path_name, file_type)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(path, type):
	set_path_name(path)
	file_type = type #transcript or audio
	
func set_path_name(name):
	path_name = name
	label.text = name

func get_path_name():
	return path_name
	
func is_clear():
	return path_name == "Please upload new file."
	
func clear():
	set_path_name("Please upload new file.")

func delete():
	emit_signal("delete_path", path_name, file_type) # currently signal not used - see "Save" function of parent
	# cannot delete audio path
	if file_type != "audio":
		self.queue_free()
	else:
		clear()
