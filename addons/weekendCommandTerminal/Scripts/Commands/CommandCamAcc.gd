class_name CommandExample extends ConsoleCommand

# The command the user will need to type to access this command
func get_command() -> String:
	return "example"

# A string describing what this command does and how to use it
func get_help() -> String:
	return "An example script \n 'example' \n 'example hello' \n 'example [5]'"

# When this command gets run, this funciton gets passed what the player typed as a packed string
func run_command(strings : PackedStringArray, _panel) -> String:
	
	# If the user only typed the command
	if strings.size() == 1:
		return "This is the example return text"
	elif strings.size() == 2:
		if strings[1].to_lower() == "hello":
			return "Hello!"
		if strings[1].is_valid_int():
			return "%s is a number!"%int(strings[1])
		else:
			return "%s is not a vald argument \n %s" % [strings[1],default_error()]
	else:
		return default_error()

# the defualt error to show if the user uses the command wrong
func default_error()-> String:
	return "'example' expects 0 or 1 argument. \n " + get_help()
