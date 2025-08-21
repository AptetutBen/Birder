class_name MenuText extends Control

enum Action {Tint,Enlarge,Show}

signal buttonAction
signal highlight_button(menu_text : MenuText)

@onready var texture_rect: TextureRect = $"TextureRect"

@export var highlight_action : Action
@export var key : String # used for remote activation and deactivation of button
@export var highlight_colour : Color = Color.LIGHT_CORAL
@export var enlarge_side : float = 1.2

var button_group : TextButtonGroup
var labelText : String

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func trigger_action():
	if button_group && !button_group.active:
		return
	
	buttonAction.emit()

func select_button() -> void:
	match highlight_action:
		Action.Tint:
			texture_rect.self_modulate = highlight_colour
		Action.Enlarge:
			texture_rect.scale = Vector2.ONE * enlarge_side
		Action.Show:
			texture_rect.visible = true
	

func deselect_button() -> void:
	match highlight_action:
		Action.Tint:
			texture_rect.self_modulate = Color.WHITE
		Action.Enlarge:
			texture_rect.scale = Vector2.ONE
		Action.Show:
			texture_rect.visible = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && MOUSE_BUTTON_LEFT && event.is_pressed():
		_on_button_clicked()
		
func _on_mouse_entered() -> void:
	highlight_button.emit(self)

func _on_mouse_exited() -> void:
	pass

func _on_button_clicked() -> void:
	trigger_action()
