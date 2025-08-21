@tool
class_name DialogueCompareVariableNode extends DialogueNode 

@export var option_prefab : PackedScene

@onready var key_edit: LineEdit = %"Key Edit"

@export var options : Array[DialogueOptionUI]

var key : String

func _ready() -> void:
	key_edit.text_changed.connect(_on_key_text_changed)

func _on_key_text_changed():
	key = key_edit.text

func _delete_option(option : DialogueOptionUI) -> void:
	options.erase(option)
	option.queue_free()

func initiliase(data : DialogueNodeData):
	await self.ready
	dialogue_data = data as DialogueCompareVariableNodeData
	id = data.id
	position_offset = dialogue_data.position
	name= "Compare Variable Node_%s"%[dialogue_data.id]
	title = name
	key = data.key
	key_edit.text = key
	
	for value in dialogue_data.connections.keys():
		_add_option(value)

func initilise_new(pos : Vector2, node_number : int):
	await self.ready
	dialogue_data = DialogueCompareVariableNodeData.new()
	dialogue_data.position = pos
	id = node_number
	position_offset = pos
	name = "Compare Variable Node_%s"%[node_number]
	title = name

func save_node(connections : Array) -> void:
	dialogue_data.position = position_offset
	dialogue_data.id = id
	dialogue_data.key = key
	dialogue_data.size = size
	
	dialogue_data.connections.clear()
	dialogue_data.default_connected_node = get_port_connected_id(0)

	for i in range(options.size()):
		dialogue_data.connections[options[i].option_text.text] = get_port_connected_id(i+1)

func _add_option(value : String) -> void:
	var new_option : DialogueOptionUI = _on_add_button_pressed()
	new_option.option_text.text = value

func _on_add_button_pressed() -> DialogueOptionUI:
	var new_option : DialogueOptionUI = option_prefab.instantiate() as DialogueOptionUI
	add_child(new_option)
	options.append(new_option)
	new_option.delete_request.connect(_delete_option)
	set_slot_enabled_right(options.size() + 1,true)
	return new_option
