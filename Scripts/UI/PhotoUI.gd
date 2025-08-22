class_name PhotoUI extends Node

@onready var textureRect: TextureRect = $Texture

func PhotoUI(image : Image):
	var texture = ImageTexture.create_from_image(image)
	textureRect.texture = texture
