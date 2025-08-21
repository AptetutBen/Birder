class_name CommandQuit extends ConsoleCommand

func get_command() -> String:
	return "quit"
	
func get_help() -> String:
	return "Quits the game \n 'quit'"

func run_command(strings : PackedStringArray, panel) -> String:
	if strings.size() != 1:
		return default_error()
	else:
		panel.get_tree().quit()
		return("quitting")

func default_error()-> String:
	return "'quit' expects 0 argument. \n 'quit'"
