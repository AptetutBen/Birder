class_name PlayerController extends CharacterBody3D

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.2
@export var jump_strength: float = 4.5
@export var gravity: float = 9.8

var velocity_y: float = 0.0
var camera_move_tween : Tween
var is_camera_up : bool = false

@onready var player_camera: Camera3D = %PlayerCamera
@onready var camera_down_marker: Marker3D = %"Camera Down Marker"
@onready var camera: GameCamera = %Camera

@onready var nav_region: NavigationRegion3D = $"../NavigationRegion3D"
var nav_ready := false
@onready var useNav = false

func _ready():
	# Capture the mouse
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.position = camera_down_marker.position
	
	var nav_map = nav_region.get_navigation_map()
	NavigationServer3D.map_changed.connect(
		func(changed_map):
		if changed_map == nav_map:)
	# Also check if it's already synced
	if NavigationServer3D.map_get_iteration_id(nav_map) > 0:
		nav_ready = true

func _process(_delta: float) -> void:
	if Input.is_action_just_released("ToggleCamera"):
		if camera_move_tween != null:
				camera_move_tween.kill()
		if is_camera_up:
			camera_move_tween = create_tween()
			camera_move_tween.tween_property(camera,"position",camera_down_marker.position,0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			camera.active = false
			is_camera_up = false
		else:
			camera_move_tween = create_tween()
			camera_move_tween.tween_property(camera,"position", -camera.get_viewfinder_offset(),0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
			camera.active = true
			is_camera_up = true

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate player (Y-axis)
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		# Rotate camera (X-axis, clamped so it doesn’t flip)s
		player_camera.rotation_degrees.x 	= clamp(
			player_camera.rotation_degrees.x - event.relative.y * mouse_sensitivity,
			-79, 79
		)



func _physics_process(delta):

	if !nav_ready && useNav:
		return

	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("Move Up"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("Move Down"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("Move Left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("Move Right"):
		input_dir += transform.basis.x
	
	input_dir = input_dir.normalized()

	# Gravity
	if not is_on_floor():
		velocity_y -= gravity * delta
	else:
		velocity_y = 0
	
	if useNav:
		# --- Project movement onto navmesh ---
		var nav_map = nav_region.get_navigation_map()
		var current_pos = global_transform.origin
		var desired_pos = current_pos + input_dir * speed * delta

		# Snap both to navmesh
		var nearest_current = NavigationServer3D.map_get_closest_point(nav_map, current_pos)
		var nearest_desired = NavigationServer3D.map_get_closest_point(nav_map, desired_pos)

		# Direction constrained to navmesh
		var allowed_move = (nearest_desired - nearest_current).normalized()

		# Apply corrected movement
		velocity.x = allowed_move.x * speed
		velocity.z = allowed_move.z * speed
	else:
		velocity.x = input_dir.x * speed
		velocity.z = input_dir.z * speed
	velocity.y = velocity_y

	move_and_slide()
