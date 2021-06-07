extends Button

onready var Window = $Window
onready var Scroll = $Window/Scroll
onready var List = $Window/Scroll/VBox
onready var SearchBar = $Window/LineEdit
onready var Cap = preload("res://VideoParts/Cap.tscn")
onready var CapFocusStyle = preload("res://VideoParts/CapFocus.tres")
onready var CapUnfocusStyle = preload("res://VideoParts/CapUnfocus.tres")

var PADDING = 40
var curr_captions = {} # Key - caption : time
var curr_cap = ""
var curr_cap_label = null

signal go_to_caption(time)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Search_toggled(button_pressed):
	if button_pressed:
		Window.popup()
		for cap in List.get_children():
			if cap.text == curr_cap: # Set to focus on current caption when first open
				set_focus(cap)
#				cap.grab_focus()
#				cap.add_stylebox_override("normal", CapFocusStyle)
#				Scroll.scroll_horizontal = 0 # Make sure focusing doesn't offset to middle of text
#				curr_cap_label = cap
	else:
		Window.hide()
		# Unfocus currently focused
		if curr_cap_label != null:
			curr_cap_label.add_stylebox_override("normal", CapUnfocusStyle)

func _on_new_captions(captions):
	#curr_captions = {}
	curr_captions = captions
	# Load captions
	load_new_captions(captions)
	
func load_new_captions(captions):
	clear_list()
	# add captions to list
	for time in captions:
		#curr_captions[captions[time]] = time
		# curr_captions = captions
		var new_cap = Cap.instance()
		List.add_child(new_cap)
		new_cap.text = captions[time]
		new_cap.set_time(time)
		new_cap.connect("caption_clicked", self, "on_caption_clicked", [new_cap])

func clear_list():
	for old_cap in List.get_children():
		old_cap.queue_free()

func _on_Window_resized():
	Scroll.rect_size.x = Window.rect_size.x - PADDING
	Scroll.rect_size.y = Window.rect_size.y - 2*PADDING
	SearchBar.rect_size.x = Window.rect_size.x - PADDING
	
func _on_caption_changed(new_caption):
	# If visible, then set caption focus to current caption
	curr_cap = new_caption
	if curr_cap_label != null:
		curr_cap_label.add_stylebox_override("normal", CapUnfocusStyle) # unfocus previously focused
	if Window.visible and !SearchBar.has_focus(): # only focus on current caption if search bar not focused
		for cap in List.get_children():
			if cap.text == new_caption:
				set_focus(cap)

func set_focus(cap):
	cap.grab_focus()
	cap.add_stylebox_override("normal", CapFocusStyle)
	Scroll.scroll_horizontal = 0
	curr_cap_label = cap

func on_caption_clicked(caption): # caption is the node
	# Clicking on caption allows you to go there in video time
	emit_signal("go_to_caption", caption.get_time())

func search_captions(text = SearchBar.text):
	if text != "":
		curr_cap_label = null
		clear_list()
		for time in curr_captions:
			if text in curr_captions[time]:
				var new_cap = Cap.instance()
				List.add_child(new_cap)
				new_cap.text = curr_captions[time]
				new_cap.set_time(time)
				new_cap.connect("caption_clicked", self, "on_caption_clicked", [new_cap])
	else:
		# reload captions
		load_new_captions(curr_captions)
		curr_cap_label = null
		SearchBar.release_focus() # unfocus from searchbar
		# focus on current caption
		for cap in List.get_children():
			if cap.text == curr_cap:
				set_focus(cap)
