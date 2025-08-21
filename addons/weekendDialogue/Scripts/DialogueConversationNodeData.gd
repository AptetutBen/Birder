class_name DialogueConversationNodeData extends DialogueNodeData

@export var text : String
@export var options : Array[DialogueOption]
@export var character_id : int

var dialoge_data : DialogueData

func get_character() -> DialogueCharacter:
	return dialoge_data.characters.get_character(character_id)
