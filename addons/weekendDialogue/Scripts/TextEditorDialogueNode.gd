@tool
class_name DialogueTextEditor extends GraphNode

signal on_edit(text : String)

var textLines : Array[String]
var current_node : DialogueConversationNode
@onready var text_edit: TextEdit = %TextEdit

func _ready() -> void:
	visible = false
	text_edit.text_changed.connect(_on_text_changed)

func enable(node: DialogueConversationNode):
	visible = true
	text_edit.grab_focus()
	if current_node != null:
		current_node.position_offset_changed.disconnect(_on_current_node_move)
		current_node.node_deselected.disconnect(_on_current_node_deselect)
	current_node = node
	_on_current_node_move()
	current_node.position_offset_changed.connect(_on_current_node_move)
	current_node.node_deselected.connect(_on_current_node_deselect)
	get_parent().move_child(self,-1)
	text_edit.text = current_node.text
	text_edit.set_caret_column(1000)

func _on_text_changed():
	if current_node == null:
		return
	current_node.on_text_changed(text_edit.text)
	
func _on_current_node_move():
	position_offset = current_node.position_offset + Vector2.RIGHT * (current_node.size.x + 10) + Vector2.DOWN * 20

func _on_current_node_deselect():
	visible = false


func _on_close_button_press():
	visible = false;
	if current_node:
		current_node.position_offset_changed.disconnect(_on_current_node_move)
	
func _on_bold_button_press():
	_add_markup("[b]","[/b]")

func _on_italic_button_press():
	_add_markup("[i]","[/i]")

func _on_underline_button_press():
	_add_markup("[u]","[/u]")

func _on_wave_button_press():
	_add_markup("[wave amp=50.0 freq=5.0 connected=1]","[/wave]")

func _on_tornado_button_press():
	_add_markup("[tornado radius=5 freq=2]","[/tornado]")

func _on_shake_button_press():
	_add_markup("[shake rate=5 level=10]","[/shake]")

func _on_fade_button_press():
	_add_markup("[fade start=4 length=14]","[/fade]")

func _on_rainbow_button_press():
	_add_markup("[rainbow freq=0.2 sat=10 val=20]","[/rainbow]")

func _on_colour_button_press():
	_add_markup("[b]","[/b]")




	#var selectedText : String = text_edit.get_selected_text()
	#
	#if selectedText.contains("[/b]"):
		#selectedText.replace("[/b]","")
	#
	#if selectedText.contains("[b]"):
		#selectedText.replace("[b]","")
	#
	#var string_array = PackedStringArray(textLines)
	#var fullOldString = "".join(string_array)
	#var newString : String = fullOldString.substr(0,startSelectionPos) + selectedText + fullOldString.substr(endSelectionPos,-1) 
#
	#text_edit.text = newString
	
	
func _add_markup(start : String, end : String):
	var selectionLinefrom : int = text_edit.get_selection_from_line()
	var selectionColumnfrom : int = text_edit.get_selection_from_column()
	
	var selectionLineTo : int = text_edit.get_selection_to_line()
	var selectionColumnTo : int = text_edit.get_selection_to_column()

	text_edit.insert_text(end,selectionLineTo,selectionColumnTo)
	text_edit.insert_text(start,selectionLinefrom,selectionColumnfrom)
	text_edit.get_selected_text()
	
	textLines.clear()

	for i in text_edit.get_line_count():
		textLines.append(text_edit.get_line(i))
	
	var startSelectionPos : int = _get_string_position(selectionLinefrom,selectionColumnfrom)
	var endSelectionPos : int = _get_string_position(selectionLineTo,selectionColumnTo)
	print("Start Selection: " + str(startSelectionPos))
	print("End Selection: " + str(endSelectionPos))

func _get_string_position(line:int, column:int):
	var counter : int =0
	
	for i in line:
		counter += textLines[i].length()
	
	return counter + column
