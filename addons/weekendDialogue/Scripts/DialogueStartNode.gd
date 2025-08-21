@tool
class_name DialogueStartNode extends DialogueNode

@onready var start_key_line_edit: LineEdit = %"Start Key LineEdit"

var linking_node_id : String
	
func initiliase(data : DialogueNodeData):
	await self.ready
	dialogue_data = data
	start_key_line_edit.text = data.start_key
	position_offset = dialogue_data.position
	name= "Start Node_%s"%[dialogue_data.id]
	title = name

func initilise_new(pos : Vector2, node_number : int):
	await self.ready
	dialogue_data = DialogueStartNodeData.new()
	dialogue_data.position = pos
	id = node_number
	position_offset = pos
	name = "Start Node_%s"%[node_number]
	title = name

func save_node(connections : Array) -> void:
	dialogue_data.position = position_offset
	dialogue_data.id = id
	dialogue_data.start_key = start_key_line_edit.text
	
	if connections.size() == 0:
		dialogue_data.first_node_id  = -1
	else:
		dialogue_data.first_node_id = connections[0][1]
