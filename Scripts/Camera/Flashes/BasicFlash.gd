extends Flash

func flash() -> void:
	visible = true
	await get_tree().create_timer(0.1).timeout
	visible = false
