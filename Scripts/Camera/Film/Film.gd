class_name Film extends CameraAttachment

@export var film_roll : FilmRoll
@export var size : int = 5

func install(body_camera : GameCamera) -> void:
	super(body_camera)
	camera.film_change.emit(self)
	update_connected_attachments()

func update_connected_attachments() -> void:
	camera.shot_count_change.emit(0 if film_roll == null else film_roll.get_photos_used_count())
	camera.shot_total_change.emit(0 if film_roll == null else size)
	
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
