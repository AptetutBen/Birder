class_name GameCamera extends Node3D

signal film_changed(Film)
signal shot_count_changed(int)
signal shot_total_changed(int)
signal take_photo
signal lens_changed(Lens)
signal flash_changed(Flash)
signal focus_changed(float)
signal zoom_changed(float)
signal flash_toggle_changed()
signal viewfinder_changed(Viewfinder)
signal battery_changed(Battery)
signal battery_level_changed(float)

@onready var flash_attach_point: Marker3D = %"Flash Attach Point"
@onready var lens_attach_point: Marker3D = %"Lens Attach Point"
@onready var viewfinder_attach_point: Marker3D = %"Viewfinder Attach Point"
@onready var film_attach_point: Marker3D = %"Film AttachPoint"

@onready var camera_3d: Camera3D = %Camera3D

@export var camera_settings : CameraSettings

var current_lens := "standard"
@export var transition_speed: float = 6.0

@onready var attrs := CameraAttributesPractical.new()
@onready var auto_focus_ray: RayCast3D = %AutoFocusRay
@onready var viewport: SubViewport = %Viewport
#@onready var obj_debug: ObjFinder = %ObjFinder

@export var focus_speed: float = 10.0    # how fast to adjust focus target (m/s)
@export var focus_lerp_speed: float = 6.0 # how fast actual focus catches up
@export var camera_ui: CameraUI

var filmRoll : FilmRoll

var focus_distance: float
var focus_target: float

var zoom_amount : float
var zoom_target : float

var active : bool = false

@export var zoom_lerp_speed: float = 6.0

@export var auto_focus_on : bool
@export var flash_on : bool

@export_category("Attachments")

@export var film : Film : 
	set = _on_change_film
	
@export var lens : Lens : 
	set = _on_change_lens

@export var flash : Flash : 
	set = _on_change_flash
	
@export var view_finder : ViewFinder : 
	set = _on_change_viewfinder

@export var battery : Battery :
	set = _onchange_battery

@export_category("Debug")
@export var draw_debug : bool = false

func _on_change_film(new_film : Film) -> void:
	film = new_film
	film.install(self)
	film_changed.emit(film)

func _on_change_viewfinder(new_viewfinder : ViewFinder) -> void:
	await ready
	view_finder = new_viewfinder
	view_finder.install(self)
	viewfinder_changed.emit(view_finder)

func _on_change_lens(new_lens : Lens) -> void:
	lens = new_lens
	lens.install(self)
	lens_changed.emit(lens)
	
func _on_change_flash(new_flash: Flash) -> void:
	flash = new_flash
	flash.install(self)
	flash_changed.emit(flash)

func _onchange_battery(new_battery : Battery) -> void:
	battery = new_battery
	battery.install(self)
	battery_changed.emit(battery)

func get_viewfinder_offset() -> Vector3:
	if ViewFinder == null:
		printerr("no viewfinder attached")
		return Vector3()
	
	return view_finder.eye_position.position - view_finder.position

func _ready() -> void:
	active = false
	
	if camera_settings == null:
		printerr("No camera settings set")
		return
		
	camera_3d.attributes = attrs
	set_up_camera()
	if filmRoll == null:
		filmRoll = FilmRoll.new()

func set_up_camera() -> void:
	# focus
	if camera_settings.has_infinate_focus:
		attrs.dof_blur_far_enabled = false
		attrs.dof_blur_near_distance = camera_settings.focal_point_max - (camera_settings.focal_depth)/2
		focus_distance = camera_settings.focal_point_min
	else:
		attrs.dof_blur_far_enabled = true
		focus_distance = camera_settings.focal_point_min - (camera_settings.focal_point_max - camera_settings.focal_point_min)/2
		attrs.dof_blur_near_distance = focus_distance - camera_settings.focal_depth/2
		attrs.dof_blur_far_distance = focus_distance + camera_settings.focal_depth/2
	focus_target = focus_distance 
	
	# fov
	camera_3d.fov = (camera_settings.fov_min + camera_settings.fov_max)/2 if camera_settings.can_zoom else camera_settings.fov_min
	zoom_amount = camera_3d.fov 
	zoom_target = zoom_amount

func get_main_viewport_texture() -> ViewportTexture:
	return viewport.get_texture()

func _process(delta: float) -> void:
	if !active:
		return
		
	if draw_debug:
		for obj in get_tree().get_nodes_in_group("Important"):
			draw_obj_debugs(obj as Node3D)

		
# Move focus target like turning a lens ring
	if camera_settings.can_change_focus_point:
		if camera_settings.has_auto_focus && auto_focus_on:
			var target_collider : Node3D = auto_focus_ray.get_collider()
			if target_collider != null:
				autofocus_to(target_collider)
		else:
			if Input.is_action_just_released("FocusIn"):
				focus_distance = max(0.1, focus_distance + focus_speed * delta)
				focus_changed.emit(focus_distance)
			if Input.is_action_just_released("FocusOut"):
				focus_distance = max(0.1, focus_distance - focus_speed * delta)
				focus_changed.emit(focus_distance)
	
	if camera_settings.can_zoom:
		if Input.is_action_pressed("ZoomIn"):
			zoom_target = min(camera_settings.fov_max,zoom_target + camera_settings.zoom_speed * delta)
			zoom_changed.emit(zoom_target)
		if Input.is_action_pressed("ZoomOut"):
			zoom_target = max(camera_settings.fov_min,zoom_target - camera_settings.zoom_speed * delta)
			zoom_changed.emit(zoom_target)
			
	zoom_amount = lerp(zoom_amount, zoom_target, delta * zoom_lerp_speed)
	camera_3d.fov = zoom_amount
	
	if Input.is_action_just_pressed("TakePhoto"):
		capture_camera()

	# Smoothly ease focus_distance toward focus_target
	focus_distance = lerp(focus_distance, focus_target, delta * focus_lerp_speed)
	
	## Smooth FOV change per lens
	#camera_3d.fov = lerp(camera_3d.fov, camera_settings.fov, delta * transition_speed)
#
	## Compute focus window around focus_distance
	#var near_d = max(0.1, focus_distance - camera_settings.depth_range)
	#var far_d = focus_distance + camera_settings.depth_range
#
	## Smoothly apply DOF distances, transitions, and global blur strength
	#attrs.dof_blur_near_distance = lerp(attrs.dof_blur_near_distance, near_d, delta * transition_speed)
	#attrs.dof_blur_far_distance = lerp(attrs.dof_blur_far_distance, far_d, delta * transition_speed)
	#attrs.dof_blur_near_transition = lerp(attrs.dof_blur_near_transition, camera_settings.transition, delta * transition_speed)
	#attrs.dof_blur_far_transition = lerp(attrs.dof_blur_far_transition, camera_settings.transition, delta * transition_speed)
	#attrs.dof_blur_amount = lerp(attrs.dof_blur_amount, camera_settings.blur_amount, delta * transition_speed)

# Simple one-shot autofocus helper (optional)
func autofocus_to(target: Node3D) -> void:
	if target:
		focus_distance = global_position.distance_to(target.global_position)

func capture_camera() -> Image:

	take_photo.emit()
	
	if flash_on && flash != null:
		flash.flash()
		await get_tree().process_frame
	
	
	# Get the texture from the viewport
	var tex: Texture2D = viewport.get_texture()
	
	# Get an image copy
	var img: Image = tex.get_image()
	
	film.add_photo(img)
	# Optionally, save to disk
	# img.save_png("user://capture.png")
	
	return img

func draw_obj_debugs(obj : Node3D) -> void:
	pass
	#var obj_pos = obj.global_transform.origin 
	#if !camera_3d.is_position_in_frustum(obj_pos):
		#obj_debug.objects = []
		#return
	#var screen_pos : Vector2 = camera_3d.unproject_position(obj_pos)
	#
	#obj_debug.objects = [screen_pos]
	#var obj_rect = get_object_screen_rect(obj)
	#obj_debug.draw_debug(obj_rect,screen_pos)
	

func get_object_screen_rect(important_obj) -> Rect2:
	
	var aabb: AABB = important_obj.get_aabb()
	var obj_basis: Basis = important_obj.global_transform.basis
	var origin: Vector3 = important_obj.global_transform.origin

	# Collect projected screen points
	var screen_points: Array[Vector2] = []

	for i in range(8): # AABB has 8 corners
		var corner: Vector3 = aabb.get_endpoint(i)
		var world_corner: Vector3 = origin + (obj_basis * corner)

		if camera_3d.is_position_behind(world_corner):
			return Rect2()
		#if !camera_3d.is_position_in_frustum(world_corner):
			#continue

		# Project to screen-space in pixels (no normalization)
		var screen_pos: Vector2 = camera_3d.unproject_position(world_corner)
		screen_points.append(screen_pos)

	if screen_points.is_empty():
		return Rect2() # Not visible at all

	# Find bounding rect in screen pixels
	var min_pos: Vector2 = screen_points[0]
	var max_pos: Vector2 = screen_points[0]
	for p in screen_points:
		min_pos = min_pos.min(p)
		max_pos = max_pos.max(p)

	var rect : Rect2 = Rect2(min_pos, max_pos - min_pos)
	rect = rect.grow(rect.size.x * -0.2)
	return rect
