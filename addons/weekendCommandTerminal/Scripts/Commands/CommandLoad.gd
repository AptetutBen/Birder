class_name CommandLoad extends ConsoleCommand

func get_command() -> String:
	return "load"
	
func get_help() -> String:
	return "Loads a scene \n 'load [scene name]' - Loads the given scene\n'load available' - Get a list of available scenes \n 'load reload' - Reloads the current scene"

func run_command(strings : PackedStringArray, panel) -> String:
	if strings.size()>2:
		var string_start = strings[0]
		strings.remove_at(0)
		var string_scene_name = " ".join(strings)
		strings.clear()
		strings.append(string_start)
		strings.append(string_scene_name)
	
	if strings.size() == 2:
		if strings[1] == "reload":
			FlowController.reload_current_scene()
			return ""
		elif strings[1] == "available":
			return "Avaliable scenes that can be loaded:\n-"+"\n-".join(FlowController.sceneDirectory.keys())
		else:
			if !FlowController.sceneDirectory.has(strings[1]):
				return "Scene %s is not found"%strings[1]
			else:
				FlowController.load_scene(strings[1])
				return "Loading Scene %s"%strings[1]

	return default_error()

func default_error()-> String:
	return "'load' expects 1 argument. \n " + get_help()
