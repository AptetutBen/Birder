class_name DialogueCompareVariableNodeData extends DialogueNodeData

@export var key : String
@export var default_connected_node : int = -1
@export var connections = {}

func get_next_node() -> int:
	if connections.size() == 0:
		return default_connected_node
	
	var saved_value : String = SaveController.get_value(key,"")
	
	if connections.has(saved_value):
		return connections[saved_value]
	
	return default_connected_node
