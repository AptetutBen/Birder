class_name PhotoPanel extends Node

static var Instance :PhotoPanel

@onready var photo_parent: VBoxContainer = %PhotoParent
@export var photo_prefab : PackedScene

var photo_lookup : Dictionary[Photo,PhotoUI]
var camera_storage : Storage
var film_roll : FilmRoll

func _ready() -> void:
	Instance = self
	_clear_panel()

func set_filmroll(film : FilmRoll):
	if film == null:
		film_roll = null;
		return
	if film_roll != null:
		film_roll.photo_taken.disconnect(_on_photo_add)
		film_roll.photo_deleted.disconnect(_on_photo_remove)
	film_roll = film
	film_roll.photo_taken.connect(_on_photo_add)
	film_roll.photo_deleted.connect(_on_photo_remove)
	_clear_panel()
	
	
	for photo : Photo in film_roll.photos:
		_on_photo_add(photo)

func _clear_panel() -> void:
	for photo : Control in photo_parent.get_children():
		photo.queue_free()
	
func _on_photo_add(photo : Photo) -> void:
	var new_photo : PhotoUI = photo_prefab.instantiate()
	photo_parent.add_child(new_photo)
	photo_lookup[photo] = new_photo
	new_photo.add_image(photo)

func _on_photo_remove(photo : Photo) -> void:
	if !photo_lookup.has(photo):
		printerr("Photo not found in lookup")
		return
	
	var photo_ui = photo_lookup[photo]
	photo_lookup.erase(photo)
	photo_ui.queue_free()
