@tool
class_name DialogueNode extends GraphNode

signal delete_node(node : DialogueNode)
signal right_click(node : DialogueNode)

var dialogue_data : DialogueNodeData

var id : int

# port number, node id
var output_ports_connected = {}

#var ports_connected = {
	#"input": {},
	#"output": {}
#}

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_click.emit(self)

func initiliase(data : DialogueNodeData):
	pass

func initilise_new(pos : Vector2, node_number : int):
	pass

func save_node(connections : Array) -> void:
	pass

func _on_delete_request() -> void:
	delete_node.emit(self)

func _on_dragged(from: Vector2, to: Vector2) -> void:
	dialogue_data.position = position_offset

func get_port_connected_id(self_port: int) -> int:
	if output_ports_connected.has(self_port):
		return output_ports_connected[self_port]
	return -1

func on_connect(self_port_type: String, self_port: int, other_node: DialogueNode, other_port: int) -> void:
	#print("I am connected to ", other_node, " on ", self_port_type, " port ", other_port)
	if self_port_type == "input" :
		return
	output_ports_connected[self_port] = other_node.id
	WeekendDialogueEditor.Instance.show_unsaved()
	#ports_connected[self_port_type][self_port] = true

func on_disconnect(self_port_type: String, self_port: int, other_node: DialogueNode, other_port: int) -> void:
	#print("I am disconnected to ", other_node, " on ", self_port_type, " port ", other_port)
	if self_port_type == "input" :
		return
	output_ports_connected[self_port] = other_node.id
	WeekendDialogueEditor.Instance.show_unsaved()
	#ports_connected[self_port_type][self_port] = false
