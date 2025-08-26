class_name Bird extends Node3D

@export var important_mesh : MeshInstance3D

func _ready() -> void:
	add_to_group("Important")
	
	if important_mesh == null:
		for child in get_children():
			if child is MeshInstance3D:
				important_mesh = child
				return

func get_aabb() -> AABB:
	if important_mesh == null:
		return AABB()
	return important_mesh.get_aabb()
	
