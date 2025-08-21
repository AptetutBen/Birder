class_name TerminalPanel extends Control

const default_font_size : int = 15
const min_font_size : int = 7
const max_font_size : int= 30

var commands : Array[ConsoleCommand]

var possible_commands : Array[ConsoleCommand]

var input_split : PackedStringArray

var command_history_list : Array[String]
var suggested_command_index : int = 0
var previous_command_index : int = 0

@onready var settings : TerminalSettings = preload("res://addons/weekendCommandTerminal/Data/settings.tres")

@onready var command_edit: LineEdit = %CommandEdit
@onready var suggested_text: LineEdit = %SuggestedText
@onready var beginning_label: Label = %Beginning_label

@onready var output_label: Label = %"Output Label"
@onready var scroll_container: ScrollContainer = %ScrollContainer

@onready var main_panel: Panel = %"Main Panel"

@export var builtin_command_path : String = "res://addons/weekendCommandTerminal/Scripts/Commands"
@export var additional_command_path : String

func _ready() -> void:
	hide()
	change_font_size(settings.font_size)
	output_label.text = " - weekend Terminal - \n "
	command_edit.text_submitted.connect(_on_text_submitted)
	command_edit.text_changed.connect(_on_text_changed)
	get_commands(builtin_command_path)
	commands.sort_custom(custom_sort)
	if additional_command_path != "":
		get_commands(additional_command_path)

func custom_sort(a : ConsoleCommand, b: ConsoleCommand):
	return a.command < b.command

func get_commands(path : String) -> void:
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != '':
		if dir.current_is_dir():
			get_commands(path + "/" + filename)
		if filename.get_extension() == "gd":
			var class_object = load(dir.get_current_dir() + "/" + filename)
			if class_object and class_object.new() is ConsoleCommand:
				commands.append(class_object.new())
		if filename.get_extension() == "remap":
			var class_object = load(dir.get_current_dir() + "/" + filename.substr(0,filename.length() - len(".remap")))
			if class_object and class_object.new() is ConsoleCommand:
				commands.append(class_object.new())
		filename = dir.get_next()

func add_output(string : String):
	if string == "":
		return
	output_label.text += "\n" + string
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _on_text_submitted(text : String):
	if text.length() == 0:
		return
	command_history_list.append(text)
	add_output(":"+text)
	command_edit.text = ""
	suggested_text.text = ""
	_run_command(text.split(" "))
	
func _on_text_changed(text : String):
	if text.length() == 0:
		suggested_text.text = ""
		possible_commands.clear()
		return
	
	input_split = text.split(" ")
	
	if input_split.size() == 1:
		_get_possible_commands(input_split[0])
		
		if possible_commands.size() == 0:
			suggested_text.text = ""
			return
		else:
			suggested_command_index = 0
			_update_suggested_command()
			
func _update_suggested_command():
	if possible_commands.size() == 0:
		return
	suggested_text.text = possible_commands[suggested_command_index].command

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Command_Show"):
		if visible:
			if show_hide_tween == null:
				hide_with_tween()
				accept_event()
		else:
			show_with_tween()
			command_edit.text=""
			suggested_text.text = ""
			command_edit.grab_focus()
			get_viewport().set_input_as_handled()

var show_hide_tween : Tween

func show_with_tween() -> void:
	if show_hide_tween != null:
		show_hide_tween.stop()
	
	show()
	main_panel.position.y = -main_panel.size.y
	show_hide_tween = get_tree().create_tween()
	show_hide_tween.tween_property(main_panel,"position:y",0,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	show_hide_tween.tween_callback(func(): show_hide_tween = null)
	
func hide_with_tween() -> void:
	if show_hide_tween != null:
		show_hide_tween.stop()
	
	show_hide_tween = get_tree().create_tween()
	show_hide_tween.tween_property(main_panel,"position:y",-main_panel.size.y,0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	show_hide_tween.tween_callback(func(): hide())
	show_hide_tween.tween_callback(func(): show_hide_tween = null)
	

func _edit_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		accept_event()
		if possible_commands.size() == 0:
			return
		
		command_edit.text = possible_commands[suggested_command_index].command

		command_edit.caret_column = 100000

	if event.is_action_pressed("ui_up"):
		accept_event()
		if possible_commands.size() <= 1:
			return
		
		suggested_command_index-=1
		if suggested_command_index < 0:
			suggested_command_index = possible_commands.size()-1
		await get_tree().process_frame
		command_edit.caret_column = -1
	
	if event.is_action_pressed("ui_down"):
		accept_event()
		if possible_commands.size() <= 1:
			return
		
		suggested_command_index = (suggested_command_index+1)%possible_commands.size()
		_update_suggested_command()
		
		await get_tree().process_frame
		command_edit.caret_column = -1
			
func _get_possible_commands(part : String) -> void:
	possible_commands.clear()
	
	for command : ConsoleCommand in commands:
		if command.command.to_lower().begins_with(part):
			possible_commands.append(command)
	
	possible_commands.sort()

func get_command(command_name : String) -> ConsoleCommand:
	for command in commands:
		if command.command == command_name.to_lower():
			return command
	
	return null

func get_command_list() -> String:
	var command_array : Array[String]
	
	for command in commands:
		command_array.append(command.command)
		
	return "- " +"\n- ".join(command_array)

func _run_command(command_array : PackedStringArray):
	for command in commands:
		if command.command == command_array[0].to_lower():
			add_output(command.run_command(command_array,self))
			possible_commands.clear()
			return
	
	add_output(" Command not found : %s"%command_array[0])
	command_edit.caret_column = -1
	possible_commands.clear()

func clear_console() -> void:
	output_label.text = ""

func get_current_font_size() -> int:
	return suggested_text.get_theme_font_size("font_size")
	
func reset_font_size() -> void:
	set_font_size(default_font_size)
	
func set_font_size(font_size : int):
	if font_size < min_font_size || font_size > max_font_size:
		add_output("Font size '%s' must be between %s and %s"%[font_size,min_font_size,max_font_size])
		return
		
	change_font_size(font_size)

	add_output("Font size changed to %s"%font_size)
	settings.font_size = font_size
	ResourceSaver.save(settings)

func change_font_size(font_size : int) -> void:
	suggested_text.add_theme_font_size_override("font_size", font_size)
	command_edit.add_theme_font_size_override("font_size", font_size)
	output_label.add_theme_font_size_override("font_size", font_size)
	beginning_label.add_theme_font_size_override("font_size", font_size)

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == 1:
			var delta : Vector2 = event.relative
			main_panel.size.y += delta.y
			main_panel.size.y = clamp(main_panel.size.y,125,400)
