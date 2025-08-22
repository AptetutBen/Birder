@tool
extends EditorPlugin

var next_play_button: Button
var selected_scene_path : String

func _enter_tree() -> void:
	# Create a new button
	next_play_button = Button.new()
	next_play_button.icon = preload("res://addons/weekendFocusPlayButton/focused_play_button.png")
	next_play_button.tooltip_text = "Focus Play"
	next_play_button.focus_mode = Control.FOCUS_NONE
	next_play_button.pressed.connect(_on_next_play_pressed)

	# Connect gui_input to detect right click
	next_play_button.gui_input.connect(_on_next_play_gui_input)

	# Add it to the play control panel (top-right)
	add_control_to_container(CONTAINER_TOOLBAR, next_play_button)
	
	var parent : HBoxContainer = next_play_button.get_parent()
	var index_of_buttons : int = parent.get_node("@HBoxContainer@4632").get_index()
	parent.move_child(next_play_button,index_of_buttons-1)
	
	next_play_button.add_theme_color_override("icon_hover_color", Color(0, 1, 0))  

func _exit_tree() -> void:
	# Remove button when plugin is disabled
	remove_control_from_container(CONTAINER_TOOLBAR, next_play_button)
	next_play_button.queue_free()

func _on_next_play_pressed() -> void:
	if selected_scene_path == "":
		EditorInterface.play_main_scene()
	else:
		EditorInterface.play_custom_scene(selected_scene_path)

func _on_next_play_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var scene: Node = get_editor_interface().get_edited_scene_root()
		if scene:
			selected_scene_path = scene.scene_file_path
			next_play_button.add_theme_color_override("icon_normal_color", Color(0.295, 0.619, 0.308, 1.0)) 
			print("Focused scene set to: " + selected_scene_path)
