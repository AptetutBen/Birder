extends ViewFinder

@onready var screen: MeshInstance3D = %Screen

func install(game_camera : GameCamera) -> void:
	super.install(game_camera)
	var material = screen.get_active_material(0) as StandardMaterial3D
	material.albedo_texture = camera.get_main_viewport_texture()
