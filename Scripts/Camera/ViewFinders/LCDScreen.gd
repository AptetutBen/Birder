extends ViewFinder

@onready var screen: MeshInstance3D = %Screen

func install(body_camera : GameCamera, att_data : CameraAttachmentData) -> void:
	super(body_camera,att_data)
	data = att_data
	var material = screen.get_active_material(0) as StandardMaterial3D
	material.albedo_texture = camera.get_main_viewport_texture()
