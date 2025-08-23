extends CameraAttachment

@export var eye_position : Marker3D

func install(body_camera : GameCamera, _data : CameraAttachmentData) -> void:
	camera = body_camera
	camera.take_photo.connect(_on_take_photo)

func _on_take_photo():
	pass
