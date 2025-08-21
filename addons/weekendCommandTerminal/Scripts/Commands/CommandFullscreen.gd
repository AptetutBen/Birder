class_name CommandFullScreen extends ConsoleCommand

func get_command() -> String:
	return "fullscreen"
	
func get_help() -> String:
	return "Sets the game to windowed or fullscreen mode \n 'fullscreen' \n 'fullscreen true' \n 'fullscreen false'"

func run_command(strings : PackedStringArray, _panel) -> String:
	if strings.size() == 1:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			return _set_windowed()
		else:
			return _set_fullscreen()
	elif strings.size() == 2:
		if strings[1].to_lower() == "true":
			return _set_fullscreen()
		elif strings[1].to_lower() == "false":
			return _set_windowed()
		else:
			return "%s is not a vald argument \n %s" % [strings[1],default_error()]
	else:
		return default_error()

func _set_fullscreen() -> String:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	return "Setting game to Fullscreen mode"
	
func _set_windowed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	return "Setting game to Windowed mode"

func default_error()-> String:
	return "'quit' expects 0 argument. \n 'quit [command]'"
