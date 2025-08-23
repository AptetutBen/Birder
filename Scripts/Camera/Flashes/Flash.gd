class_name Flash extends CameraAttachment

var data : FlashData
@export var light : Node3D
var power_use : float

var flash_on : bool

func flash() -> void:
	if camera.battery == null:
		return
	if !camera.battery.has_enough_power(power_use):
		return
	camera.battery.use_power(power_use)
	light.visible = true
	await get_tree().create_timer(0.1).timeout
	light.visible = false

func toggle() -> void:
	flash_on = !flash_on
	camera.flash_toggle_changed.emit(flash_on)
	

func install(body_camera : GameCamera, att_data : CameraAttachmentData) -> void:
	super(body_camera,att_data)
	data = att_data
	
