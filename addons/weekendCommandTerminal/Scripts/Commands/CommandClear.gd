class_name CommandClear extends ConsoleCommand

func get_command() -> String:
	return "clr"
	
func get_help() -> String:
	return "Clears the console \n 'clr'"

func run_command(strings : PackedStringArray, panel) -> String:
	if strings.size() != 1:
		return default_error()
	else:
		panel.clear_console()
		return("")

func default_error()-> String:
	return "'clr' expects 0 argument. \n 'clr'"
