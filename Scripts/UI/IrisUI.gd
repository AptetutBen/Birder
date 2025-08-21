class_name Iris extends CanvasItem

var window_size : Vector2i
var corner_length : float
var current_radius: float = 1

func _ready() -> void:
	visible = false
	get_tree().get_root().size_changed.connect(_set_window_size)
	_set_window_size()

func iris_in(duration : float = 2) ->void:
	visible = true
	var current_tween : Tween = create_tween()
	current_tween.tween_method(set_radius,1.0,0.0,duration)
	await current_tween.finished

func iris_out(duration : float = 2) ->void:
	var current_tween : Tween = create_tween()
	current_tween.tween_method(set_radius,0.0,1.0,duration)
	current_tween.tween_callback(func() : visible = false)
	await current_tween.finished

func _set_window_size():
	window_size = DisplayServer.screen_get_size()
	material.set_shader_parameter("viewport_size",window_size)
	material.set_shader_parameter("pos",window_size/2)
	corner_length = get_circle_radius_to_corner(window_size)
	set_radius(current_radius)

func set_radius(value : float):
	material.set_shader_parameter("r",value*corner_length)
	current_radius = value

func get_circle_radius_to_corner(screen_resolution: Vector2i) -> float:
	var half_width = screen_resolution.x / 2
	var half_height = screen_resolution.y / 2
	return sqrt(pow(half_width, 2) + pow(half_height, 2))
