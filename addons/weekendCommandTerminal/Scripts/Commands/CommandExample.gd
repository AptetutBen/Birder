class_name CommandCamatt extends ConsoleCommand

# The command the user will need to type to access this command
func get_command() -> String:
	return "camatt"

# A string describing what this command does and how to use it
func get_help() -> String:
	return "Used to change camera attachments \n camatt \n camatt list \n camatt [attatchment id] \n camatt remove [attachment id]"

# When this command gets run, this funciton gets passed what the player typed as a packed string
func run_command(strings : PackedStringArray, _panel) -> String:
	# If the user only typed the command
	if strings.size() == 1:
		if GameCamera.Instance == null:
			return "No Camera Currently Loaded"
		return "Camear has: \n	>" + ("\n	> ".join(GameCamera.Instance.get_all_attachment_ids()))
	elif strings.size() == 2:
		if strings[1].to_lower() == "list":
			return "list of loaded attachments: \n	> " + ("\n	>".join(FlowController.get_attchment_list_ids()))
		else:
			if FlowController.get_attchment_list_ids().has(strings[1]):
				GameCamera.Instance.add_attachment_id(strings[1])
				return "Added Attachments"
			else:
				return "%s is a not valid!"%strings[1]
	else:
		return default_error()

# the defualt error to show if the user uses the command wrong
func default_error()-> String:
	return "'example' expects 1 or 2 argument. \n " + get_help()
