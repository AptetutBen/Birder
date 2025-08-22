class_name CameraUI extends Node

@onready var depth_slider: HSlider = %DepthSlider
@onready var zoom_slider: VSlider = %"Zoom Slider"

func adjust_depth(value : float) -> void:
	if depth_slider:
		depth_slider.value = value

func adjust_zoom(value : float) -> void:
	if zoom_slider:
		zoom_slider.value = value
