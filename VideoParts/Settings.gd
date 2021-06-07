extends WindowDialog

onready var PathAudio = $PathAudio
onready var PathTrans = $PathTrancripts
var padding_x = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_resized():
	# When settings are resized, also resize children
	PathAudio.rect_size.x = self.rect_size.x - padding_x
	PathTrans.rect_size.x = self.rect_size.x - padding_x
