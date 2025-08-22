class_name ImportantObject extends Node3D

@export var mesh : MeshInstance3D

func _ready() -> void:
	add_to_group("Important")
	
	if mesh == null:
		for child in get_children():
			if child is MeshInstance3D:
				mesh = child
				return

func get_aabb() -> AABB:
	if mesh == null:
		return AABB()
	return mesh.get_aabb()
