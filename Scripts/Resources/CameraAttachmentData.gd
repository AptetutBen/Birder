class_name CameraAttachmentData extends Resource
enum AttachmentType {Lens, Battery,Viewfinder,Flash,Storage}

@export var attachment_name : String
@export var id : String
@export var prefab : PackedScene

func get_type() -> AttachmentType:
	return AttachmentType.Lens
