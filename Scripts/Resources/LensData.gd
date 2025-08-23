class_name LensData extends CameraAttachmentData

@export var can_zoom : bool = false
@export var fov_min : float = 60
@export var fov_max : float = 100
@export var zoom_speed : float = 10

@export var can_focus : bool = true
@export var has_infinite_focus : bool = false
@export var focal_depth : float = 10
@export var focal_point_min : float = 5
@export var focal_point_max : float = 20
@export var focus_speed : float = 10
@export var has_auto_focus : bool = false
@export var blur_amount : float = 0.4
@export var lens_transition : float = 0

func get_type() -> AttachmentType:
	return AttachmentType.Lens
