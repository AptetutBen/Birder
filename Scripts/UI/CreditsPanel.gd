class_name Credits extends TextureRect

signal close_action

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@export var scroll_speed : float = 10

func show_panel():
	show()
	rich_text_label.scroll_to_line(0)

func hide_panel():
	hide()
	
func _on_close_press():
	close_action.emit()
	
func _input(event: InputEvent) -> void:
	if !is_visible_in_tree():
		return
		
	if event.is_action("UI Up"):
		rich_text_label.get_v_scroll_bar().value -= scroll_speed 
	
	if event.is_action("UI Down"):
		rich_text_label.get_v_scroll_bar().value += scroll_speed 
	
	if event.is_action_pressed("UI Cancel") || event.is_action_pressed("UI Left")  || event.is_action_pressed("UI Accept"):
		await get_tree().process_frame
		_on_close_press()
		
