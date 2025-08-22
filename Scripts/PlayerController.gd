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


func _ready():
	# Capture the mouse
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.position = camera_down_marker.position

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
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("Move Up"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("Move Down"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("Move Left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("Move Right"):
		input_dir += transform.basis.x

	# Normalize so diagonal isn’t faster
	input_dir = input_dir.normalized()

	# Gravity
	if not is_on_floor():
		velocity_y -= gravity * delta
	else:
		velocity_y = 0
		#if Input.is_action_just_pressed("Jump"):
			#velocity_y = jump_strength

	# Final velocity
	velocity = input_dir * speed
	velocity.y = velocity_y
	
	move_and_slide()
