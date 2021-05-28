extends CheckBox

onready var Slider = $VSlider

signal volume_changed(volume)
var prev_volume = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Volume_mouse_entered():
	# Show volume slider
	Slider.visible = true
	Slider.editable = true
	print("enter")
	
func _on_Area_mouse_entered():
	pass # Replace with function body.
	
func _on_Area_mouse_exited():
	# Hide volume slider
	# NOTE: button "Volume" causes issues with overlapping area, so set to not overlap
	Slider.visible = false
	Slider.editable = false
	print("Exit")

func _on_value_changed(value):
	print(value)
	prev_volume = value
	emit_signal("volume_changed", value)
	
	# in case they try to change value when muted
	if self.pressed:
		self.pressed = false

func _on_Volume_toggled(mute):
	if mute:
		emit_signal("volume_changed", -80)
	else:
		emit_signal("volume_changed", prev_volume)
