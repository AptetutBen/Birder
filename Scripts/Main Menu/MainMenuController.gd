extends Control

@onready var credits: Credits = %Credits
@onready var version_label: Label = $"Version Label"

@onready var main_buttons: TextButtonGroup = %"Main Buttons"
@onready var options_buttons: TextButtonGroup = %"Options Buttons"

@onready var fullscreen_button: MenuTextToggle = %"Fullscreen Button"
@onready var vsync_toggle: MenuTextToggle = %"Vsync Toggle"

@onready var music_volume: MenuTextRange = %"Music Volume"
@onready var game_volume: MenuTextRange = %"Game Volume"
@onready var sfx_volume: MenuTextRange = %"SFX Volume"


func _ready():
	AudioManager.play_music("Menu Music")
	credits.hide()
	options_buttons.hide()
	main_buttons.show()
	version_label.text = "v " + ProjectSettings.get_setting("application/config/version")
	fullscreen_button.visibility_changed.connect(_fullscreen_visibility_changed)
	vsync_toggle.visibility_changed.connect(_vsync_visibility_changed)
	music_volume.update_value(AudioManager.get_music_volume())
	game_volume.update_value(AudioManager.get_master_volume())

func _on_start_button_pressed():
	FlowController.start_game()
	AudioManager.play_sfx("click1")

func _on_exit_button_pressed():
	AudioManager.play_sfx("click1")
	get_tree().quit()

func _on_credits_button_pressed():
	AudioManager.play_sfx("click1")
	credits.show_panel()
	main_buttons.disable(false)

func _on_close_credits_button_pressed():
	AudioManager.play_sfx("click1")
	credits.hide_panel()
	main_buttons.enable()

func _on_options_button_pressed():
	AudioManager.play_sfx("click1")
	options_buttons.enable()
	main_buttons.disable(false)

func _on_master_volume_click() -> void:
	var current_volume :float = AudioManager.get_master_volume()
	current_volume = current_volume + 0.1
	
	if current_volume > 1:
		current_volume = 0
	
	AudioManager.set_master_volume(current_volume)
	game_volume.update_value(current_volume)

func _on_sfx_volume_click() -> void:
	var current_volume :float = AudioManager.get_sfx_volume()
	current_volume = current_volume + 0.1
	
	if current_volume > 1:
		current_volume = 0
	
	AudioManager.set_sfx_volume(current_volume)
	sfx_volume.update_value(current_volume)
	AudioManager.play_sfx("switch2")

func _on_music_volume_click() -> void:
	var current_volume :float = AudioManager.get_music_volume()
	current_volume = current_volume + 0.1
	
	if current_volume > 1:
		current_volume = 0
	
	AudioManager.set_music_volume(current_volume)
	music_volume.update_value(current_volume)

func _on_back_button_button_action() -> void:
	AudioManager.play_sfx("click1")
	options_buttons.disable(true)
	main_buttons.enable()
	
func _fullscreen_visibility_changed() -> void:
	if !fullscreen_button.visible:
		return
	fullscreen_button.toggle(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	
func _fullscreen_toggled(value : bool) -> void:
	SaveController.set_fullscreen(value)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen_button.toggle(value)

func _vsync_visibility_changed() -> void:
	if !vsync_toggle.visible:
		return
	vsync_toggle.toggle(DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED)
	
func _vsync_toggled(value : bool) -> void:
	SaveController.set_vsync(value)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)
	vsync_toggle.toggle(value)
