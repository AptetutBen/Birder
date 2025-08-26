class_name FilmRoll extends Resource

signal photo_taken(Photo)
signal photo_deleted(Photo)

@export var lut : Texture3D
@export var can_overwrite_photos : bool = true
@export var size : int = 5
@export var photos : Array[Photo]

func get_photos_used_count() -> int:
	return photos.size()

func add_photo(image : Image) -> void:
	if photos.size() >= size:
		if can_overwrite_photos:
			photo_deleted.emit(photos[0])
			photos.remove_at(0)
		else:
			return 
	var new_photo : Photo = Photo.new()
	new_photo.image = image
	photos.append(new_photo)
	photo_taken.emit(new_photo)
