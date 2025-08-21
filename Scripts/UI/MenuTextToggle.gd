class_name MenuTextToggle extends MenuText

signal button_toggle_action(is_on : bool)

@export var on_text : String = "On"
@export var off_text : String = "Off"
@export var toggled : bool
@onready var toggle_text: RichTextLabel = $"Toggle Text"

func trigger_action():
	button_toggle_action.emit(!toggled)

func toggle(on : bool):
	if on:
		toggle_on()
	else:
		toggle_off()
		
func toggle_on():
	toggled = true
	toggle_text.text = on_text

func toggle_off():
	toggled = false
	toggle_text.text = off_text
