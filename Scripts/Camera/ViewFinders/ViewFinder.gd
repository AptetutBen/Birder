class_name ViewFinder extends CameraAttachment

@export var eye_position : Marker3D
	
func install(game_camera : GameCamera) -> void:
	camera = game_camera
