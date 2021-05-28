extends RichTextLabel

# allow for drag and drop capabilities (ex. user can move text)
var draggable = false
var can_grab = false
var grabbed_offset = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if draggable:
			can_grab = true
		else:
			can_grab = false
		grabbed_offset = self.rect_position - get_global_mouse_position()

func _process(_delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_grab:
		self.rect_position = get_global_mouse_position() + grabbed_offset

func _on_mouse_entered():
	draggable = true

func _on_mouse_exited():
	draggable = false
