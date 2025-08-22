extends CameraAttachment

@export var eye_position : Marker3D
	
func install(game_camera : GameCamera) -> void:
	camera = game_camera
	camera.take_photo.connect(_on_take_photo)

func _on_take_photo():
	pass
