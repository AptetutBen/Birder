class_name CameraSettings extends Resource

@export var name : String

# zoom
@export var can_zoom : bool = false
@export var fov_min : float	 = 100
@export var fov_max : float = 60
@export var zoom_speed : float = 40

# in
@export var has_infinate_focus : bool = false
@export var focal_depth: float
@export var focal_point_min: float
@export var focal_point_max: float

@export var can_change_focus_point : bool
@export var has_auto_focus : bool

@export var blur_amount: float
@export var transition: float
