class_name CommandClearData extends ConsoleCommand

func get_command() -> String:
	return "clear-data"
	
func get_help() -> String:
	return "Clears saved data \n 'cleardata data' - clears saved data\n 'cleardata all' - clears all saved data \n 'cleardata ethereal' - clears all ethereal saved data "

func run_command(strings : PackedStringArray, panel) -> String:
	if strings.size() != 2:
		return default_error()
	else:
		match strings[1]:
			"data":
				SaveController.reset_save_data()
			"all":
				SaveController.reset_save_data()
				SaveController.clear_etheral_data()
			"ethereal":
				SaveController.clear_etheral_data()
			_:
				return default_error()

		return("Data cleared")

func default_error()-> String:
	return "'cleardata' expects 1 argument. \n " + get_help()
