class_name DialogueCharacters extends Resource

@export var characters : Array[DialogueCharacter]

func get_character(id : int) -> DialogueCharacter:
	for char : DialogueCharacter in characters:
		if char.id == id:
			return char
	printerr("Cant find character with id : %s"%id)
	return null
