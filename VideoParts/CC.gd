extends CheckBox

onready var Caption = $Caption

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_CC_toggled(button_pressed):
	Caption.visible = !button_pressed
