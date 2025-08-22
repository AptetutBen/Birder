class_name CameraAttachmentData extends Resource
enum AttachmentType {Lens, Battery,Viewfinder,Flash,Film}

@export var attachment_name : String
@export var id : String
@export var prefab : PackedScene
@export var type : AttachmentType
