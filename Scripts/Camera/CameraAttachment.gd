class_name CameraAttachment extends Node3D

var camera : GameCamera
	
func install(body_camera : GameCamera, _data : CameraAttachmentData) -> void:
	camera = body_camera
