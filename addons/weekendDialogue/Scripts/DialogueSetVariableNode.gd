@tool
class_name DialogueSetVariableNode extends DialogueNode 

@onready var key_edit: LineEdit = %"Key Edit"
@onready var value_edit: LineEdit = %"Value Edit"
@onready var variable_type_option: OptionButton = %"Variable Type Option"
@onready var boolean_checkbox: CheckBox = %"Boolean Checkbox"

var key : String
var value : String
var save_type : DialogueSetVariableNodeData.SaveType

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	
func initiliase(data : DialogueNodeData):
	await self.ready
	dialogue_data = data
	id = data.id
	key = data.saved_key
	key_edit.text = key
	value = data.saved_value
	value_edit.text = value
	save_type = data.save_type
	variable_type_option.select(save_type)
	position_offset = data.position
	name= "Set Variable Node_%s"%[data.id]
	title = name
	set_value_input()

func initilise_new(pos : Vector2, node_number : int):
	await self.ready
	dialogue_data = DialogueSetVariableNodeData.new()
	dialogue_data.position = pos
	id = node_number
	position_offset = pos
	name = "Set Variable Node_%s"%[node_number]
	title = name

# enum SaveType {SaveString, SaveBool, SaveInt, SaveFloat}
func set_value_input():
	if save_type == 0:
		value_edit.visible = false
		boolean_checkbox.visible = true
		value_edit.text = ""
		value = ""
	else:
		value_edit.visible = true
		boolean_checkbox.visible = false
		boolean_checkbox.set_pressed_no_signal(true)
		_on_boolean_checkbox_toggled(true)
	size.y = 0
	

func save_node(connections : Array) -> void:
	dialogue_data.position = position_offset
	dialogue_data.id = id
	dialogue_data.saved_key = key
	dialogue_data.saved_value = value
	dialogue_data.save_type = save_type
	dialogue_data.size = size
	
	if connections.size() == 0:
		dialogue_data.connected_node_id = -1
	else:
		dialogue_data.connected_node_id = connections[0][1]
	
func _on_value_edit_text_changed() -> void:
	value = value_edit.text

func _on_key_edit_text_changed() -> void:
	key = key_edit.text

func _on_variable_type_option_item_selected(index: int) -> void:
	save_type = index
	set_value_input()

func _on_boolean_checkbox_toggled(toggled_on: bool) -> void:
	if save_type != 0:
		return
	if toggled_on:
		value = "true"
	else:
		value = "flase"
