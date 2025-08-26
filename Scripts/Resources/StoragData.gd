class_name StorageData extends CameraAttachmentData

@export var has_auto_advance: bool = true
@export var storage_size : int = 5

func get_type() -> AttachmentType:
	return AttachmentType.Storage
