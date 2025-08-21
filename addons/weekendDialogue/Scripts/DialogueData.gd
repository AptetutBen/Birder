class_name DialogueData extends Resource

@export var data : Array[DialogueNodeData]
@export var connnections : Array[String]
@export var characters : DialogueCharacters

func get_node_from_start(key : String) -> DialogueConversationNodeData:
	for node : DialogueNodeData in data:
		if node is DialogueStartNodeData:
			if node.start_key == key:
				return get_dialogue_node(node.first_node_id)
	printerr("Can't find start node id: %s" % [key])
	return null

func get_dialogue_node(id : int) -> DialogueConversationNodeData:
	if id < 0:
		return null
	
	for node : DialogueNodeData in data:
		if node.id == id:
			if node is DialogueStartNodeData:
				return get_dialogue_node(node.first_node_id)
			if node is DialogueConversationNodeData:
				node.dialoge_data = self
				return node
			else:
				return get_dialogue_node(node.get_next_node())
	printerr("Can't find node id: %s" % [id])
	return null

func get_next_node(current_node : DialogueConversationNodeData, selected_option = 0) -> DialogueConversationNodeData:
	match current_node.options.size():
		0:
			return null
		1:
			return get_dialogue_node(current_node.options[0].linking_node_id)
		_:
			return get_dialogue_node(current_node.options[selected_option].linking_node_id)
	
	
	
