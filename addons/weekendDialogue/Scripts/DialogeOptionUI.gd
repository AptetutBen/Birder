@tool
class_name DialogueOptionUI extends Control

signal delete_request

@onready var delete_button: Button = %Delete_button
@onready var option_text: LineEdit = %"Option Text"

var dialogue_option : DialogueOption

func _ready() -> void:
	delete_button.pressed.connect(_on_delete_button_press)

func initialise(data : DialogueOption) -> void:
	dialogue_option = data
	option_text.text = data.text

func initialise_new() -> void:
	dialogue_option = DialogueOption.new()

func save() -> void:
	dialogue_option.text = option_text.text

func _on_delete_button_press()-> void:
	delete_request.emit(self)
