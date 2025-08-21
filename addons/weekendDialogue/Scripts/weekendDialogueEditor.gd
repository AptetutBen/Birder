@tool
class_name WeekendDialogueEditor extends Control
static var Instance : WeekendDialogueEditor

@export var dialogueConversationNodePrefab : PackedScene
@export var dialogueStartNodePrefab : PackedScene
@export var dialogueSetVariableNodePrefab : PackedScene
@export var dialogueGetVariableNodePrefab : PackedScene
@export var dialogueCompareVariableNodePrefab : PackedScene

@export var settings : dialogueSettings
@onready var save_button: Button = %"Save Button"

@onready var dialogue_editor: GraphEdit = %"Dialogue Editor"
@onready var text_editor: DialogueTextEditor = %"Text Editor"

@onready var popup_menu: DeleteMenu = %PopupMenu

@onready var file_dialog: FileDialog = %FileDialog
@onready var add_menu: PopupMenu = %"Add Menu"


@onready var file_name_label: Label = %"File Name Label"

@export var dialogue_data : DialogueData

var dialogue_nodes : Array[GraphNode]
var next_id : int = 1

var is_unsaved : bool

var temp_to_from_node : String
var temp_to_from_port : int

func _ready() -> void:
	Instance = self
	file_dialog.file_selected.connect(on_select_file)
	if settings == null:
		printerr("Settings file not found")
		return
	
	if ResourceLoader.exists(settings.current_dialogue_data_path):
		_load_data(settings.current_dialogue_data_path)

func _load_data(path : String):
	dialogue_data = load(path)
	file_name_label.text = path.get_file()
	_build_graph()

func _build_graph():
	for node : DialogueNode in dialogue_nodes:
		remove_node(node,false)
	next_id = 1
	dialogue_nodes.clear()
	dialogue_editor.clear_connections()
		
	await get_tree().process_frame
	
	for data : DialogueNodeData in dialogue_data.data:
		if data is DialogueConversationNodeData:
			var newNode : DialogueConversationNode = dialogueConversationNodePrefab.instantiate()
			newNode.set_characters(dialogue_data.characters)
			newNode.edit_node.connect(_on_node_edit_selected)
			_set_node_exsisting(newNode,data)
		elif data is DialogueSetVariableNodeData:
			var newNode : DialogueSetVariableNode = dialogueSetVariableNodePrefab.instantiate()
			_set_node_exsisting(newNode,data)
		elif data is DialogueGetVariableNodeData:
			var newNode : DialogueGetVariableNode = dialogueGetVariableNodePrefab.instantiate()
			_set_node_exsisting(newNode,data)
		elif data is DialogueStartNodeData:
			var newNode : DialogueStartNode = dialogueStartNodePrefab.instantiate()
			_set_node_exsisting(newNode,data)
		elif data is DialogueCompareVariableNodeData:
			var newNode : DialogueCompareVariableNode = dialogueCompareVariableNodePrefab.instantiate()
			_set_node_exsisting(newNode,data)
	
	for connection_string in dialogue_data.connnections:
		var connection_parts : PackedStringArray = connection_string.split(",")

		if connection_parts.size() != 4:
			printerr("Connected string not correct %s"%connection_string)
			continue

		_on_dialogue_editor_connection_request(
			connection_parts[0],
			int(connection_parts[1]),
			connection_parts[2],
			int(connection_parts[3])
		)
	WeekendDialogueEditor.Instance._show_saved()

func deselect_nodes():
	for node in dialogue_nodes:
		node.selected = false
		
func _on_right_click(node : DialogueNode) -> void:
	popup_menu.show_popup(node)
	popup_menu.position = get_global_mouse_position()

func _on_node_edit_selected(node : DialogueConversationNode):
	if node == null:
		text_editor.visible = false
		return
	
	text_editor.enable(node)

func _on_open_file():
	file_dialog.visible = true
	file_dialog.position = get_global_mouse_position()

func on_select_file(path:String):
	var new_data = load(path)
	if !(new_data is DialogueData):
		printerr("This is not a DialogueData resource")
		return
	settings.current_dialogue_data_path = path
	ResourceSaver.save(settings)
	_load_data(path)

func remove_node(node : DialogueNode, remove_from_array = true):
	var connections : Array
	
	for con in dialogue_editor.get_connection_list():
		if con.to_node == node.name || con.from_node == node.name :
			connections.append(con)
	
	for con in connections:
		_on_dialogue_editor_disconnection_request(con.from_node,con.from_port,con.to_node,con.to_port)

	if remove_from_array:
		dialogue_nodes.erase(node)
	node.queue_free()

func _on_save_pressed():
	dialogue_data.data.clear()
	dialogue_data.connnections.clear()
	
	for node in dialogue_nodes:
		
		var connections : Array
		for con in dialogue_editor.get_connection_list():
			if con.from_node == node.name:
				var to_node : DialogueNode = get_dialogue_node(con.to_node)
				connections.append([con.from_port,to_node.id])
		
		node.save_node(connections)
		
		if node is DialogueConversationNode:
			dialogue_data.data.append(node.dialogue_data)
		elif node is DialogueStartNode:
			dialogue_data.data.append(node.dialogue_data)
		elif node is DialogueSetVariableNode:
			dialogue_data.data.append(node.dialogue_data)
		elif node is DialogueGetVariableNode:
			dialogue_data.data.append(node.dialogue_data)
		elif node is DialogueCompareVariableNode:
			dialogue_data.data.append(node.dialogue_data)
			
	for con in dialogue_editor.get_connection_list():
		var from_node : String = con.from_node
		var from_port : int = con.from_port
		var to_node : String = con.to_node
		var to_port : int = con.to_port
		var connection : String = "%s,%s,%s,%s"%[from_node,str(from_port),to_node,str(to_port)]
		dialogue_data.connnections.append(connection)
	
	ResourceSaver.save(dialogue_data)
	print("Data Saved")
	_show_saved()

func show_unsaved():
	if is_unsaved:
		return
	
	is_unsaved = true
	save_button.text = "* Save"
	save_button.add_theme_color_override("font_color",Color.RED)

func _show_saved():
	is_unsaved = false
	save_button.text = "Save"
	save_button.add_theme_color_override("font_color",Color.WHITE)
	
func _find_node(node_name : StringName) -> GraphNode:
	for node : GraphNode in dialogue_nodes:
		if node.name == node_name:
			return node
	return null

func connect_out_node(node_id : String):
	dialogue_data

func _on_dialogue_editor_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	for con in dialogue_editor.get_connection_list():
		if con.from_node == from_node and con.from_port == from_port:
			_on_dialogue_editor_disconnection_request(con.from_node,con.from_port,con.to_node,con.to_port)
	dialogue_editor.connect_node(from_node, from_port, to_node, to_port)

	var from_node_inst = get_dialogue_node(from_node)
	var to_node_inst = get_dialogue_node(to_node)
	
	if from_node_inst == null:
		printerr("From Node not found: %s"%from_node)
		return
	
	if to_node_inst == null:
		printerr("To Node not found: %s"%to_node)
		return
	
	from_node_inst.on_connect("output", from_port, to_node_inst, to_port)
	to_node_inst.on_connect("input", to_port, from_node_inst, from_port)
	show_unsaved()

func _on_dialogue_editor_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	dialogue_editor.disconnect_node(from_node, from_port, to_node, to_port)

	var from_node_inst = get_dialogue_node(from_node)
	var to_node_inst = get_dialogue_node(to_node)

	from_node_inst.on_disconnect("output", from_port, to_node_inst, to_port)
	to_node_inst.on_disconnect("input", to_port, from_node_inst, from_port)
	show_unsaved()

func get_dialogue_node(node_name : String) -> DialogueNode:
	return dialogue_editor.find_child(node_name,false,false)

# Adding nodes
func _on_add_node_pressed() -> void:
	add_menu. visible = true
	add_menu.position = get_global_mouse_position()

func _on_add_start_node_pressed() -> DialogueNode:
	return _set_node_basics(dialogueStartNodePrefab.instantiate())

func _on_add_compare_variable_node_pressed() -> DialogueNode:
	return _set_node_basics(dialogueCompareVariableNodePrefab.instantiate())

func _on_add_conversation_node_pressed() -> DialogueNode:
	var newNode : DialogueConversationNode = dialogueConversationNodePrefab.instantiate() as DialogueConversationNode
	newNode.edit_node.connect(_on_node_edit_selected)
	newNode.set_characters(dialogue_data.characters)
	return _set_node_basics(newNode)

func _on_add_set_variabe_node_pressed() -> DialogueNode:
	return _set_node_basics( dialogueSetVariableNodePrefab.instantiate())

func _on_add_get_variabe_node_pressed() -> DialogueNode:
	return _set_node_basics(dialogueGetVariableNodePrefab.instantiate())

func _set_node_basics(newNode : DialogueNode) -> DialogueNode:
	newNode.initilise_new(Vector2(100,100),next_id)
	next_id += 1
	add_node_common(newNode)
	add_menu.visible = false
	show_unsaved()
	return newNode

func _set_node_exsisting(newNode : DialogueNode,data : DialogueNodeData):
	newNode.initiliase(data)
	next_id = max(next_id,data.id + 1)
	add_node_common(newNode)

func add_node_common(newNode : DialogueNode) -> void:
	dialogue_editor.add_child(newNode)
	dialogue_nodes.append(newNode)
	newNode.delete_node.connect(remove_node)
	newNode.right_click.connect(_on_right_click)

func _on_add_menu_id_pressed(id: int) -> void:
	var new_node : DialogueNode
	match id:
		0:
			new_node = _on_add_start_node_pressed()
		1:
			new_node = _on_add_conversation_node_pressed()
		2:
			new_node = _on_add_get_variabe_node_pressed()
		3:
			new_node = _on_add_compare_variable_node_pressed()
		4:
			new_node = _on_add_set_variabe_node_pressed()

func _on_dialogue_editor_connection_from_empty(to_node: StringName, to_port: int, release_position: Vector2) -> void:
	temp_to_from_node = to_node
	temp_to_from_port = to_port
	add_menu.visible = true
	add_menu.position = get_global_mouse_position()

func _on_dialogue_editor_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	temp_to_from_node = from_node
	temp_to_from_port = from_port
	add_menu.visible = true
	add_menu.position = get_global_mouse_position()
