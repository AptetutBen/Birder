extends Control

@onready var button_group: TextButtonGroup = $"Button Group"
@onready var debug_group: TextButtonGroup = $"Debug Group"

@onready var debug_menu: MenuText = %"Debug Menu"

func _ready() -> void:
	visible = false
	await get_tree().process_frame
	debug_group.visible = false
	
	if GameController.Instance:
		debug_menu.visible = GameController.Instance._use_debug
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if get_tree().paused:
			_unpause()
		else:
			_pause()
			button_group.enable()
			debug_group.disable()
			#debug_group.visible = false
			#button_group.select_button(0, false)

func _pause():
	FlowController.pause_game(self)
	visible = true
	button_group.enable()

func _unpause():
	FlowController.unpause_game()
	visible = false

func _on_quit_button_button_action() -> void:
	AudioManager.play_sfx("click1")
	FlowController.load_main_menu()

func _on_resume_button_button_action() -> void:
	AudioManager.play_sfx("click1")
	_unpause()

func _on_debug_menu_button_action() -> void:
	debug_group.enable()
	button_group.disable(false)
	debug_group.visible = true

# Debug Actions

func _on_close_debug_menu() -> void:
	debug_group.disable(true)
	button_group.enable()

func _on_reset_data_button_action() -> void:
	SaveController.reset_save_data()
	_unpause()
