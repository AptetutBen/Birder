class_name ViewFinder extends CameraAttachment

@export var eye_position : Marker3D
	
func install(game_camera : GameCamera) -> void:
	camera = game_camera
	
	camera.take_photo.connect(_on_take_photo)
	camera.film_changed.connect(_on_film_change)
	camera.shot_count_changed.connect(_on_shot_count_change)
	camera.shot_total_changed.connect(_on_shot_total_change)
	camera.lens_changed.connect(_on_lens_change)
	camera.focus_changed.connect(_on_focus_change)
	camera.zoom_changed.connect(_on_zoom_change)
	camera.flash_toggle_changed.connect(_on_flash_toggle_change)
	camera.viewfinder_changed.connect(_on_viewfinder_change)
	camera.battery_changed.connect(_on_battery_change)
	camera.battery_level_changed.connect(_on_battery_level_change)


func _on_take_photo() -> void:
	pass

func _on_film_change(_film : Film) -> void:
	pass

func _on_shot_count_change(_count : int) -> void:
	pass

func _on_shot_total_change(_total : int) -> void:
	pass

func _on_lens_change() -> void:
	pass

func _on_focus_change(_value : float) -> void:
	pass

func _on_zoom_change(_value : float) -> void:
	pass

func _on_flash_toggle_change() -> void:
	pass

func _on_viewfinder_change() -> void:
	pass

func _on_battery_change() -> void:
	pass

func _on_battery_level_change(_level : float) -> void:
	pass
