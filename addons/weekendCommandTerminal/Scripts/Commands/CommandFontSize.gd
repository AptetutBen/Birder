class_name CommandFontSize extends ConsoleCommand

func get_command() -> String:
	return "font-size"
	
func get_help() -> String:
	return "Sets the terminal font size \n 'fontsize' - returns the current font size \n 'fontsize [10]' - sets the font size to value (5-30) \n 'fontsize reset' - sets the font size default (12)"

func run_command(strings : PackedStringArray, panel) -> String:
	if strings.size() == 1:
		return "Current font size: %s"%str(panel.get_current_font_size())
	elif strings.size() != 2:
		return default_error()
	else:
		if strings[1] == "reset":
			panel.reset_font_size()
		else:
			if !(strings[1]).is_valid_int():
				return "%s is not a valid int"%strings[1]
			panel.set_font_size(int(strings[1]))

		return ""

func default_error()-> String:
	return "'fontsize' expects 1 argument. \n " + get_help()
