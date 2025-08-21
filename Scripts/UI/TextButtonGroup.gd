class_name TextButtonGroup extends Control

signal close_action

var buttons : Array[MenuText]
var current_selected_button : MenuText
var can_navigate : bool = true

@export var vertical : bool = true
@export var active : bool = false
@export var close_on_left : bool = false
@export var open_on_right : bool = false

func _ready() -> void:
	var found_first_button : bool 
	
	for child in get_children():
		if child is MenuText:
			buttons.append(child)
			child.button_group = self
			child.highlight_button.connect(select_button)
			if !found_first_button && child.visible:
				child.select_button()
				found_first_button = true
				current_selected_button = child
			else:
				child.deselect_button()
	
	visibility_changed.connect(_on_visibility_changed)
	
func enable():
	active = true
	show()

func disable(hide_node : bool = true):
	active = false
	if hide_node:
		hide()

func _get_first_visable_button() -> MenuText:
	for i in buttons.size():
		if buttons[i].is_visible_in_tree():
			return buttons[i]
	return null

func _on_visibility_changed():
	if !is_visible_in_tree():
		return
		
	var first_button = _get_first_visable_button()
	if first_button == null:
		return
		
	select_button(first_button,false)

func _on_close():
	close_action.emit()

func select_button(selected_button : MenuText, play_sound : bool = true):
	if !active:
		return
		
	if play_sound:
		AudioManager.play_sfx("click1")
		
	if current_selected_button != null:
		current_selected_button.deselect_button()
	
	current_selected_button = selected_button
		
	for button in buttons:
		if button == selected_button:
			button.select_button()
		else:
			button.deselect_button()

func _find_next_active_button() -> MenuText:
	var current_button_index : int = buttons.find(current_selected_button)
	for i in (buttons.size() -1):
		var button_to_check : int = (1 + current_button_index + i)%buttons.size()
		if buttons[button_to_check].is_visible_in_tree():
			return buttons[button_to_check]
	return null

func _find_previous_active_button() -> MenuText:
	var current_button_index : int = buttons.find(current_selected_button)
	for i in (buttons.size() -1):
		var button_to_check : int = fposmod((current_button_index - 1 - i),buttons.size())
		if buttons[button_to_check].is_visible_in_tree():
			return buttons[button_to_check]
	return null

func _on_select() -> void:
	current_selected_button.trigger_action()

func _input(event: InputEvent) -> void:
	if !is_visible_in_tree() || !active || current_selected_button == null:
		return

	if event.is_action_pressed("UI Cancel"):
		_on_close()
	
	if close_on_left && vertical && event.is_action_pressed("UI Left"):
		_on_close()
	
	if close_on_left && !vertical && event.is_action_pressed("UI Up"):
		_on_close()
	
	# Pause to stop previous menu also being triggered
	await get_tree().process_frame
	
	if event.is_action_pressed("UI Accept"):
		_on_select()
		
	if open_on_right && vertical && event.is_action_pressed("UI Right"):
		_on_select()
	
	if open_on_right && !vertical && event.is_action_pressed("UI Downs"):
		_on_select()
	
	if event.is_action_pressed("UI Up" if vertical else "UI Left"):
		if !can_navigate:
			return
		AudioManager.play_sfx("click1")
		var next_button =  _find_previous_active_button()
		
		if next_button == null:
			return
			
		select_button(next_button)
		
		can_navigate = false
		await get_tree().create_timer(0.05).timeout
		can_navigate = true
	
	if event.is_action_pressed("UI Down" if vertical else "UI Right"):
		if !can_navigate:
			return
		AudioManager.play_sfx("click1")
		var next_button =  _find_next_active_button()
		
		if next_button == null:
			return

		select_button(next_button)
		
		can_navigate = false
		await get_tree().create_timer(0.05).timeout
		can_navigate = true
