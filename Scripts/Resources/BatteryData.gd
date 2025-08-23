class_name BatteryData extends CameraAttachmentData

@export var max_power : float = 100

func get_type() -> AttachmentType:
	return AttachmentType.Battery
