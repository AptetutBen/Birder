class_name CameraAttachment extends Node3D

@export var data : CameraAttachmentData
var camera : GameCamera

func install(body_camera : GameCamera) -> void:
	camera = body_camera
