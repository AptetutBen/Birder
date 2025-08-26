class_name Flash extends CameraAttachment

@export var light : Light3D
@export var flash_duration : float = 0.2

var _flash_tween : Tween
var _start_brightness : float
var data : FlashData
var power_use : float
var flash_on : bool

func _ready() -> void:
	light.visible = false
	_start_brightness = light.light_energy

func flash() -> void:
	if !flash_on:
		return
	if camera.battery == null:
		return
	if !camera.battery.has_enough_power(power_use):
		return
	camera.battery.use_power(power_use)
	light.visible = true
	
	light.light_energy = _start_brightness
	
	if _flash_tween != null:
		_flash_tween.kill()
	
	_flash_tween = create_tween()
	_flash_tween.tween_property(light,"light_energy",0,flash_duration)
	_flash_tween.tween_callback(func(): light.visible = false)

func toggle() -> void:
	flash_on = !flash_on
	camera.flash_toggle_changed.emit(flash_on)
	

func install(body_camera : GameCamera, att_data : CameraAttachmentData) -> void:
	super(body_camera,att_data)
	data = att_data
	
