class_name MenuTextRange extends MenuText

@onready var toggle_text: RichTextLabel = $"Range Text"

func update_value(value : float):
	toggle_text.text = str(value * 100) + "%"
