class_name CommandHelp extends ConsoleCommand

func get_command() -> String:
	return "help"
	
func get_help() -> String:
	return "Provides help for any command \n :help [command]"

func run_command(strings : PackedStringArray, panel) -> String:
	if strings.size() == 2:
		var command_needing_help : ConsoleCommand = panel.get_command(strings[1])
		if command_needing_help == null:
			return "Command '%s' is not found, type 'help' for a list of avaliable commands"%strings[1]
		return command_needing_help.help
	elif strings.size() == 1:
		return "Avaliable commands:\n%s"%panel.get_command_list()
	else:
		return default_error()

func default_error()-> String:
	return "'help' expects 1 argument. \n 'help [command]'"
