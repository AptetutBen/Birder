extends Node

const saveExtention : String = ".save"
const gameSaveFileName : String = "game_data"
const gameSettingFileName : String = "game_setting"

var resizeTimer : Timer

var current_save_slot : int = 0

# Current stored values
var variable_dictionary = {}
var ethereal_dictionary = {}

var play_start : float

# Init
func _init():
	_load_settings_data()
	
func _ready() -> void:
	get_tree().get_root().size_changed.connect(_set_window_size)

func reset_save_data() -> void:
	variable_dictionary.clear()
	save_data()
	
func clear_etheral_data() -> void:
	ethereal_dictionary.clear()

func load_data(save_slot : int = 0) -> void:
	current_save_slot = save_slot
	play_start = Time.get_unix_time_from_system()
	_load_data()

func clear_save_slot(slot_number : int) -> void:
	var dir_access = DirAccess.open("user://")
	
	if dir_access.file_exists("%s_%s%s"%[gameSaveFileName,slot_number,saveExtention]):
		dir_access.remove("%s_%s%s"%[gameSaveFileName,slot_number,saveExtention])
	
	# if we are clearning the current save slot, then also clear the variable dictionary
	if slot_number == current_save_slot:
		variable_dictionary = {}

# Save Data

func get_value(key : String, default : String = "default") -> String:
	return variable_dictionary.get(key,default)

func set_value(key : String, value : String, dosave : bool = true) -> void:
	variable_dictionary.set(key,str(value))
	if dosave:
		save_data()

func get_value_int(key : String, default : int) -> int:
	return variable_dictionary.get(key,default)

func set_value_int(key : String, value : int, dosave : bool = true) -> void:
	variable_dictionary.set(key,value)
	if dosave:
		save_data()
	
func set_value_bool(key : String, value : bool, dosave : bool = true) -> void:
	variable_dictionary.set(key,value)
	if dosave:
		save_data()

func get_value_float(key : String, default : float) -> float:
	return variable_dictionary.get(key,default)

func set_value_float(key : String, value : float, dosave : bool = true) -> void:
	variable_dictionary.set(key,value)
	if dosave:
		save_data()
	
func get_value_bool(key : String, default : bool) -> bool:
	return variable_dictionary.get(key,default)
	
func has_variable(key : String) -> bool:
	return variable_dictionary.has(key)
	
func is_true(key : String) -> bool:
	return variable_dictionary.get(key, false)

func is_value(key : String, value) -> bool:
	return variable_dictionary.get(key,"") == value

# Etherial Data

func get_etheral_value(key : String, default : String = "default") -> String:
	return ethereal_dictionary.get(key,default)

func set_etheral_value(key : String, value : String) -> void:
	ethereal_dictionary.set(key,value)

func get_etheral_value_int(key : String, default : int) -> int:
	return ethereal_dictionary.get(key,default)

func set_etheral_value_int(key : String, value : int) -> void:
	ethereal_dictionary.set(key,value)

func get_etheral_value_float(key : String, default : float) -> float:
	return ethereal_dictionary.get(key,default)

func set_etheral_value_float(key : String, value : float) -> void:
	ethereal_dictionary.set(key,value)
	
func get_etheral_value_bool(key : String, default : bool) -> bool:
	return ethereal_dictionary.get(key,default)
	
func has_etheral_variable(key : String) -> bool:
	return ethereal_dictionary.has(key)
	
func is_etheral_true(key : String) -> bool:
	return ethereal_dictionary.get(key, false)

func is_etheral_value(key : String, value) -> bool:
	return ethereal_dictionary.get(key,"") == value

# Game Settings

var game_settings_save_data = {
	"vsync" : "true",
	"fullscreen" : "false",
	"window_size" : "Vector2i(1920,1080)",
	"master_volume": 1,
	"sfx_volume" : 1,
	"music_volume" : 1,
}

# Audio

func get_master_volume() -> float:
	return game_settings_save_data["master_volume"]

func set_master_volume(value : float, do_save: bool = true) -> void:
	game_settings_save_data["master_volume"] = value
	if do_save:
		_save_settings_data()
		
func get_music_volume() -> float:
	return game_settings_save_data["music_volume"]

func set_music_volume(value : float, do_save: bool = true) -> void:
	game_settings_save_data["music_volume"] = value
	if do_save:
		_save_settings_data()

func get_sfx_volume() -> float:
	return game_settings_save_data["sfx_volume"]

func set_sfx_volume(value : float, do_save: bool = true) -> void:
	game_settings_save_data["sfx_volume"] = value
	if do_save:
		_save_settings_data()

func get_is_vsync() -> bool:
	return str_to_var(game_settings_save_data["vsync"])

func set_vsync(value : bool) -> void:
	game_settings_save_data["vsync"] = var_to_str(value)
	_save_settings_data()

func get_is_fullscreen() -> bool:
	return str_to_var(game_settings_save_data["fullscreen"])

func set_fullscreen(value : bool) -> void:
	game_settings_save_data["fullscreen"] = var_to_str(value)
	_save_settings_data()

func get_resolution() -> Vector2i:
	return str_to_var(game_settings_save_data["window_size"])

func _set_window_size() -> void:
	if resizeTimer == null:
		resizeTimer = Timer.new()
		add_child(resizeTimer)
		resizeTimer.one_shot = true
		resizeTimer.timeout.connect(_on_view_port_resize_timer_timeout)
		resizeTimer.start(2)
	else:
		resizeTimer.start(2)

func _on_view_port_resize_timer_timeout():
	game_settings_save_data["window_size"] = var_to_str(DisplayServer.window_get_size())
	_save_settings_data()
	print("Updating window size")
	resizeTimer = null

# Save data from save file
func save_data():
	variable_dictionary["play_length"] = get_value_float("play_length",0) + (Time.get_unix_time_from_system() - play_start)
	play_start = Time.get_unix_time_from_system()
	var json_string = JSON.stringify(variable_dictionary)
	var save_file = FileAccess.open("user://%s_%s%s"%[gameSaveFileName,current_save_slot,saveExtention], FileAccess.WRITE)
	save_file.store_line(json_string)
	save_file.close()

func create_new_save_data(slot_number : int = 0, save_name : String = "", do_save : bool = false):
	current_save_slot = slot_number
	
	variable_dictionary = {}
	variable_dictionary["save_name"] = save_name
	variable_dictionary["game_version"] = ProjectSettings.get_setting("application/config/version")
	variable_dictionary["date_time_created"]= Time.get_unix_time_from_system()
	variable_dictionary["play_length"] = 0
	
	if do_save:
		save_data()

# Load data from save file
func _load_data():
	var save_file : FileAccess = FileAccess.open("user://%s_%s%s"%[gameSaveFileName,current_save_slot,saveExtention], FileAccess.READ)
	
	if save_file == null:
		create_new_save_data(current_save_slot)
		return
		
	variable_dictionary = JSON.parse_string(save_file.get_as_text())
	
		# Check if save version is for the current date of the game
	if variable_dictionary["game_version"] !=ProjectSettings.get_setting("application/config/version"):
		print("Save file is for a previous version of the game, will upgrade")
		_save_file_upgrader(game_settings_save_data["game_version"])

func has_save_file(save_slot : int):
	var save_file : FileAccess = FileAccess.open("user://%s_%s%s"%[gameSaveFileName,save_slot,saveExtention], FileAccess.READ)
	return save_file != null

# Load data from save file
func _load_settings_data():
	var save_file : FileAccess = FileAccess.open("user://%s%s"%[gameSettingFileName,saveExtention], FileAccess.READ)
	
	if save_file == null:
		_save_settings_data();
		return

	game_settings_save_data = JSON.parse_string(save_file.get_as_text())


func _save_settings_data():
	var json_string = JSON.stringify(game_settings_save_data)
	var save_file = FileAccess.open("user://%s%s"%[gameSettingFileName,saveExtention], FileAccess.WRITE)
	save_file.store_line(json_string)
	save_file.close()

func _save_file_upgrader(version : String):
	match version:
		"0.1":
			#change all the settings needed from 0.1 to the next version of the save file
			print("Upgrading from v0.1 to v0.2")
			_save_file_upgrader("0.2")
			return
		"0.2":
			#change all the settings needed from 0.2 to the next version of the save file
			print("Upgrading from v0.1 to v0.2")
			_save_file_upgrader("0.3")
			return
	
	print("Saving data againt to new updated version")
	save_data()
	
	
	
