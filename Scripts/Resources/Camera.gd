class_name GameCamera extends Node3D

signal storage_changed(Storeage)
signal lens_changed(Lens)
signal flash_changed(Flash)
signal viewfinder_changed(ViewFinder)
signal battery_changed(Battery)
signal shot_count_changed(int)
signal take_photo
signal finish_taking_photo
signal focus_changed(float)
signal zoom_changed(float)
signal flash_toggle_changed(bool)
signal battery_level_changed(float)

static var Instance : GameCamera

@onready var flash_attach_point: Marker3D = %"Flash Attach Point"
@onready var lens_attach_point: Marker3D = %"Lens Attach Point"
@onready var viewfinder_attach_point: Marker3D = %"Viewfinder Attach Point"
@onready var storage_attach_point: Marker3D = %"Storage Attach Point"
@onready var battery_attach_point: Marker3D = %"Battery Attach Point"
@onready var obj_finder: ObjFinder = %ObjFinder

@onready var camera_3d: Camera3D = %Camera3D

var current_lens := "standard"
@export var transition_speed: float = 6.0

@onready var attrs := CameraAttributesPractical.new()
@onready var auto_focus_ray: RayCast3D = %AutoFocusRay
@onready var viewport: SubViewport = %Viewport

@export var focus_speed: float = 10.0    # how fast to adjust focus target (m/s)
@export var focus_lerp_speed: float = 6.0 # how fast actual focus catches up
@export var camera_ui: CameraUI

var filmRoll : FilmRoll

var active : bool
var focus_distance: float
var focus_target: float

var zoom_amount : float
var zoom_target : float

@export var zoom_lerp_speed: float = 6.0
var auto_focus_on : bool

var storage : Storage
var lens : Lens
var flash : Flash
var viewfinder : ViewFinder
var battery : Battery

@export_category("Debug")
@export var debug_on : bool = false
@export var draw_debug : bool = false

func _ready() -> void:
	Instance = self
	
	lens_changed.connect(on_change_lens)

	for attachment : CameraAttachmentData in FlowController.get_default_camera_attachments():
		_add_attachment(attachment)
					
	camera_3d.attributes = attrs
	change_film_roll(FilmRoll.new())
	disable_viewport()


func disable_viewport() -> void:
	viewport.set_update_mode(SubViewport.UPDATE_DISABLED)
	camera_3d.visible = false

func enable_viewport() -> void:
	viewport.set_update_mode(SubViewport.UPDATE_ALWAYS)
	camera_3d.visible = true

func change_film_roll(roll: FilmRoll) -> void:
	filmRoll = roll
	PhotoPanel.Instance.set_filmroll(roll)

func get_viewfinder_offset() -> Vector3:
	if ViewFinder == null:
		printerr("no viewfinder attached")
		return Vector3()
	
	return viewfinder.eye_position.position - viewfinder.position

func add_attachment_id(id: String) -> String:
	var attachment : CameraAttachmentData = FlowController.get_attachment(id)
	if attachment == null:
		return "%s is not a valid attachment:"
	_add_attachment(attachment)
	return "Attachment attached" 

func on_change_lens(new_lens : Lens) -> void:
	# focus
	if !new_lens.data.has_infinite_focus:
		attrs.dof_blur_far_enabled = false
		attrs.dof_blur_near_distance = new_lens.data.focal_point_max - (new_lens.data.focal_depth)/2
		focus_distance = new_lens.data.focal_point_min
	else:
		attrs.dof_blur_far_enabled = true
		focus_distance = new_lens.data.focal_point_min - (new_lens.data.focal_point_max - new_lens.data.focal_point_min)/2
		attrs.dof_blur_near_distance = focus_distance - new_lens.data.focal_depth/2
		attrs.dof_blur_far_distance = focus_distance + new_lens.data.focal_depth/2
	focus_target = focus_distance 
	
	# fov
	camera_3d.fov = (new_lens.data.fov_min + new_lens.data.fov_max)/2 if new_lens.data.can_zoom else new_lens.data.fov_min
	zoom_amount = camera_3d.fov 
	zoom_target = zoom_amount

func _add_attachment(attachment : CameraAttachmentData) -> void:
	if !ready:
		await ready
	match attachment.get_type():
		CameraAttachmentData.AttachmentType.Lens:
			if lens !=null:
				lens.queue_free()
			var new_lens = attachment.prefab.instantiate()
			lens_attach_point.add_child(new_lens)
			lens = new_lens
			lens.install(self,attachment)
			lens_changed.emit(lens)
			
		CameraAttachmentData.AttachmentType.Battery:
			if battery !=null:
				battery.queue_free()
			var new_battery = attachment.prefab.instantiate()
			battery_attach_point.add_child(new_battery)
			battery = new_battery
			battery.install(self,attachment)
			battery_changed.emit(battery)
			
		CameraAttachmentData.AttachmentType.Viewfinder:
			if viewfinder !=null:
				viewfinder.queue_free()
			var new_viewfinder = attachment.prefab.instantiate()
			viewfinder_attach_point.add_child(new_viewfinder)
			viewfinder = new_viewfinder
			viewfinder.install(self,attachment)
			viewfinder_changed.emit(viewfinder)
			
		CameraAttachmentData.AttachmentType.Flash:
			if flash !=null:
				flash.queue_free()
			var new_flash = attachment.prefab.instantiate()
			flash_attach_point.add_child(new_flash)
			flash = new_flash
			flash.install(self,attachment)
			flash_changed.emit(flash)
			
		CameraAttachmentData.AttachmentType.Storage:
			if storage !=null:
				storage.queue_free()
			var new_storage = attachment.prefab.instantiate()
			storage_attach_point.add_child(new_storage)
			storage = new_storage
			storage.install(self,attachment)
			storage_changed.emit(storage)
			

func get_all_attachment_ids() -> Array[String]:
	var return_array : Array[String]
	
	if viewfinder != null:
		return_array.append(viewfinder.data.id)
	if lens != null:
		return_array.append(lens.data.id)
	if flash != null:
		return_array.append(flash.data.id)
	if battery != null:
		return_array.append(battery.data.id)
	if storage != null:
		return_array.append(storage.data.id)
	return return_array

func get_main_viewport_texture() -> ViewportTexture:
	return viewport.get_texture()

func _process(delta: float) -> void:
	if !active:
		return
	if draw_debug:
		for obj in get_tree().get_nodes_in_group("Important"):
			draw_obj_debugs(obj as Node3D)
		
# Move focus target like turning a lens ring
	if lens.data.can_focus:
		if lens.data.has_auto_focus && auto_focus_on:
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
	
	if lens.data.can_zoom:
		if Input.is_action_just_released("ZoomOut"):
			zoom_target = min(lens.data.fov_max,zoom_target + lens.data.zoom_speed * delta)
			zoom_changed.emit(zoom_target)
		if Input.is_action_just_released("ZoomIn"):
			zoom_target = max(lens.data.fov_min,zoom_target - lens.data.zoom_speed * delta)
			zoom_changed.emit(zoom_target)
	
	if Input.is_action_just_pressed("FlashToggle") && flash != null:
		flash.toggle()
		print(flash.flash_on)
	
	zoom_amount = lerp(zoom_amount, zoom_target, delta * zoom_lerp_speed)
	camera_3d.fov = zoom_amount
	
	if Input.is_action_just_pressed("TakePhoto"):
		capture_photo()

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

func capture_photo() -> void:
	
	if flash != null:
		flash.flash()
	
	camera_3d.set_cull_mask_value(2,false)
	camera_3d.set_cull_mask_value(3,true)
	
	# Disable Main Viewport
	var scene_tree = Engine.get_main_loop() as SceneTree
	var root_viewport : Viewport = scene_tree.root.get_viewport()
	
	RenderingServer.viewport_set_update_mode(root_viewport.get_viewport_rid(),RenderingServer.VIEWPORT_UPDATE_DISABLED)
	
	
	RenderingServer.force_draw()
	await RenderingServer.frame_post_draw
	
	
	# Get the texture from the viewport
	var tex: Texture2D = viewport.get_texture()
	
	# Get an image copy
	var img: Image = tex.get_image()
	
	filmRoll.add_photo(img)
	#img.save_png("user://capture.png")
	
	camera_3d.set_cull_mask_value(2,true)
	camera_3d.set_cull_mask_value(3,false)
	await get_tree().process_frame
	
	await get_tree().process_frame
	RenderingServer.viewport_set_update_mode(root_viewport.get_viewport_rid(),RenderingServer.VIEWPORT_UPDATE_ALWAYS)

	
	#RenderingServer.viewport_set_active(root_viewport.get_viewport_rid(), true)
	#viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_DISABLED
	take_photo.emit()
	
	
	#camera_3d.set_cull_mask_value(2,true)
	#camera_3d.set_cull_mask_value(3,false)
	await get_tree().process_frame
	
	RenderingServer.viewport_set_update_mode(viewport.get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ALWAYS)
	finish_taking_photo.emit()
	
#func _render_subviewport(subviewport: SubViewport) -> Image:
	## Disable main viewport so it doesn't redrawn
	#var scene_tree = Engine.get_main_loop() as SceneTree
	#var root_viewport = scene_tree.root.get_viewport_rid()
	#RenderingServer.viewport_set_active(root_viewport, false)
	#
 	## Render SubViewport once
	#RenderingServer.viewport_set_update_mode(subviewport.get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ONCE)
	#RenderingServer.force_draw()
	#await RenderingServer.frame_post_draw
	#
	## Enable main viewport again
	#RenderingServer.viewport_set_active(root_viewport, true)
#
	#return subviewport.get_texture().get_image()

func draw_obj_debugs(obj : Node3D) -> void:
	var obj_pos = obj.global_transform.origin 
	if !camera_3d.is_position_in_frustum(obj_pos):
		obj_finder.objects = []
		return
	var screen_pos : Vector2 = camera_3d.unproject_position(obj_pos)
	
	obj_finder.objects = [screen_pos]
	var obj_rect = get_object_screen_rect(obj)
	obj_finder.draw_debug(obj_rect,screen_pos)
	

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
