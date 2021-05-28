extends LineEdit

var LEGAL_CHARS = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
signal speed_changed(speed)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("focus_exited", self, "saved_change")
	self.connect("text_entered", self, "saved_change")
	
# Check only legal chars entered.
func _on_text_changed(new_text):
	# Only allow numbers and dots, but no dots if already have a dot
	if new_text.length() != 0 and (not new_text[new_text.length() - 1] in LEGAL_CHARS or \
		(new_text[new_text.length() - 1] == "." and "." in self.text.substr(0, self.text.length() - 1))):
		delete_char_at_cursor()

# Save change if exit edit or press enter
func saved_change(_new_text = self.text):
	var new_speed = float(self.text)
	if new_speed != 0:
		emit_signal("speed_changed", new_speed)
	else:
		print("illegal speed")
