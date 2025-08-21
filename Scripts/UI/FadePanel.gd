class_name FadePanel extends ColorRect

signal finished_fade

func disable() -> void:
	visible = false

func fade_in(delay: float = 1,duration : float = 3) -> void:
	visible = true
	modulate.a = 1
	var fade_tween : Tween = get_tree().create_tween()
	fade_tween.tween_interval(delay)
	fade_tween.tween_property(self, "modulate:a", 0, duration).set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_callback(_finish_fade)
	fade_tween.play()

func fade_out(duration : float = 3) -> void:
	var fade_tween : Tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 1, duration).set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_callback(func (): visible = false)
	fade_tween.tween_callback(_finish_fade)
	fade_tween.play()
	
func _finish_fade() -> void:
	finished_fade.emit()
