class_name Battery extends CameraAttachment

@export var power : float
var data : BatteryData

func has_enough_power(required_power : float) -> bool:
	return required_power <= power

func use_power(value : float) -> void:
	power -= value
	camera.battery_level_changed.emit(power)

func charge(value :float) -> void:
	power += value
	
	if power > data.max_power:
		power = data.max_power
	
func install(body_camera : GameCamera, att_data : CameraAttachmentData) -> void:
	super(body_camera,att_data)
	data = att_data
