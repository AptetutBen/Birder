class_name Lens extends CameraAttachment

var data : LensData

func install(body_camera : GameCamera, att_data : CameraAttachmentData) -> void:
	super(body_camera,att_data)
	data = att_data
