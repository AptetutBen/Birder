class_name Storage extends CameraAttachment

var data : StorageData
@export var film_roll : FilmRoll

func install(body_camera : GameCamera, att_data : CameraAttachmentData) -> void:
	super(body_camera,att_data)
	data = att_data
	camera.film_change.emit(self)
	update_connected_attachments()
	
func update_connected_attachments() -> void:
	camera.shot_count_change.emit(0 if film_roll == null else film_roll.get_photos_used_count())
	
func insert_new_film(new_film_roll : FilmRoll) -> void:
	film_roll = new_film_roll
	update_connected_attachments()
	
func remove_film() -> FilmRoll:
	var removed_roll : FilmRoll = film_roll
	film_roll = null
	update_connected_attachments()
	return removed_roll

func swap_film(new_film : FilmRoll) -> FilmRoll:
	var removed_roll : FilmRoll = film_roll
	film_roll = new_film
	update_connected_attachments()
	return removed_roll
