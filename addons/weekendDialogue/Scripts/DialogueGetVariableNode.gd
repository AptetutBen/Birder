@tool
class_name DialogueGetVariableNode extends DialogueNode 

@onready var option_button: OptionButton = %OptionButton
@onready var value_edit: LineEdit = %"Value Edit"
@onready var key_edit: LineEdit = %"Key Edit"

var number_only : bool 
var regex_full = RegEx.new()
var regex_partial = RegEx.new()

var type : DialogueGetVariableNodeData.GetVariableType
var key : String
var value : String

func _ready() -> void:
	option_button.item_selected.connect(_on_item_selected)
	key_edit.text_changed.connect(_on_key_text_changed)
	value_edit.text_changed.connect(_on_value_text_changed)
	regex_full.compile("-?\\d+(\\.\\d+)?")
	regex_partial.compile("^-?$|^-?\\d+(\\.\\d*)?$|^-?\\.\\d*$")

func _on_item_selected(index : int):
	type = index
	if index >= 2:
		value_edit.visible = true
		if index >= 3:
			number_only = true
			_on_value_text_changed()
		else:
			number_only = false
	else:
		value_edit.visible = false
		value_edit.text= ""

func _on_key_text_changed():
	key = key_edit.text
		
func _on_value_text_changed():
	if number_only:
		# If the entire input is valid (including incomplete forms)
		if regex_partial.search(value_edit.text):
			return
			
		# Otherwise, extract the first complete number (ignoring invalid characters)
		var result = regex_full.search(value_edit.text)
		if result == null:
			value_edit.text = ""
		else:
			value_edit.text = result.get_string()

		value_edit.set_caret_column(value_edit.text.length())
	value = value_edit.text
		
func initiliase(data : DialogueNodeData):
	await self.ready
	dialogue_data = data
	id = data.id
	position_offset = dialogue_data.position
	name= "Get Variable Node_%s"%[dialogue_data.id]
	title = name
	key = data.key
	key_edit.text = key
	value = data.value
	value_edit.text = value
	type = data.type
	value_edit.visible = data.type >= 3

func initilise_new(pos : Vector2, node_number : int):
	await self.ready
	value_edit.visible = false
	dialogue_data = DialogueGetVariableNodeData.new()
	dialogue_data.position = pos
	id = node_number
	position_offset = pos
	name = "Get Variable Node_%s"%[node_number]
	title = name

func save_node(connections : Array) -> void:
	dialogue_data.position = position_offset
	dialogue_data.id = id
	dialogue_data.connected_node_id_true = -1
	dialogue_data.connected_node_id_false = -1
	dialogue_data.type = type
	dialogue_data.key = key
	dialogue_data.value = value
	dialogue_data.size = size
	
	for i in connections.size():
		if connections[i][0] == 0:
			dialogue_data.connected_node_id_true = connections[i][1]
		elif connections[i][0] == 1:
			dialogue_data.connected_node_id_false = connections[i][1]
