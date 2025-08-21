class_name ConsoleCommand

var command : String:
	get:
		return get_command()
		
var help : String:
	get:
		return get_help()

func get_command() -> String:
	return ""
	
func get_help() -> String:
	return ""

func run_command(_strings : PackedStringArray, _panel) -> String:
	return ""
