class_name PhotoUI extends Control

@onready var textureRect: TextureRect = $Texture

var resize_tween : Tween

func _ready() -> void:
	mouse_entered.connect(_on_mouse_enetered)
	mouse_exited.connect(_on_mouse_exit)

func _on_mouse_enetered()-> void:
	if resize_tween != null:
		resize_tween.kill()
	resize_tween = create_tween()
	resize_tween.tween_property(self,"custom_minimum_size",Vector2(400,264),0.4)
	
func _on_mouse_exit() -> void:
	if resize_tween != null:
		resize_tween.kill()
	resize_tween = create_tween()
	resize_tween.tween_property(self,"custom_minimum_size",Vector2(100,66),0.4)

func add_image(photo : Photo):
	var texture = ImageTexture.create_from_image(photo.image)
	textureRect.texture = texture
