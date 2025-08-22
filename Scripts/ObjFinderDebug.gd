class_name ObjFinder extends Control

var rects: Array[Rect2]
var objects: Array[Vector2]

func _process(_delta):

	queue_redraw()


func _draw():
	for obj in objects:
		draw_circle(obj,5,Color.RED)
	
	for obj in rects:
		if obj.size != Vector2.ZERO:
			var rect_px = Rect2(obj.position ,obj.size)
			draw_rect(rect_px, Color.RED, false, 2.0) # false = outline only
	
	rects.clear()
	objects.clear()


func draw_debug(rect: Rect2, pos : Vector2) -> void:
	rects.append(rect)
	objects.append(pos)
