class_name CommandAudio extends ConsoleCommand

func get_command() -> String:
	return "audio"
	
func get_help() -> String:
	return "Sets the game Audio \n'audio mute' - Mutes the master audio\n'audio music [0 - 100]' - Sets the music audio\n'audio sfx [0 - 100]' - Sets the sfx audio\n'audio master [0 - 100]' - Sets the sfx audio"

func run_command(strings : PackedStringArray, panel) -> String:
	
	if strings.size() == 3:
		
		if !(strings[2]).is_valid_float():
			return "%s is not a valid number"%strings[2]
			
		var value = float(strings[2])/100
		
		match strings[1]:
			"master":
				AudioManager.set_master_volume(value)
				return  "set master volume to: %s%"%strings[2]
			"music":
				AudioManager.set_music_volume(value)
				return  "set music volume to: %s%"%strings[2]
			"sfx":
				AudioManager.set_sfx_volume(value)
				return  "set sfx volume to: %s%"%strings[2]
	
	if strings.size() == 2:
		if strings[1] == "mute":
			AudioManager.set_master_volume(0)
			return "Master audio set to 0%"

	return default_error()

func default_error()-> String:
	return "'audio' expects 1 or 2 arguments. \n " + get_help()
