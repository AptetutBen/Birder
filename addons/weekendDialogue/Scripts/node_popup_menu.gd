@tool
class_name DeleteMenu extends PopupMenu

signal click_button(id : int)

var selected_node : DialogueNode

func _ready() -> void:
	hide()

func show_popup(node : DialogueNode) -> void:
	print(node.name)
	selected_node = node
	visible = true
	position = get_mouse_position()

func _on_delete_button_press():
	selected_node._on_delete_request()
	hide()

func show_from_menu():
	show()

func show_from_drag_to(toThen: Callable):
	show()

func show_from_drag_from(toThen: Callable):
	show()


func _on_id_pressed(id: int) -> void:
	match id:
		0:
			_on_delete_button_press()
