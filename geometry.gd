class_name Utility extends Node


static func closest_point(shape: Shape2D, point: Vector2, offset: Vector2) -> Vector2:
	var closest_point := Vector2()
	var min_value: float = (1 << 31) - 1
	
	if shape is RectangleShape2D:
		var points := [
			offset - shape.size / 2,
			offset + Vector2(shape.size.x / 2, -shape.size.y / 2),
			offset + shape.size / 2,
			offset + Vector2(-shape.size.x / 2, shape.size.y / 2)
		]
		for i in range(3):
			var p := Geometry2D.get_closest_point_to_segment(point, points[i], points[i+1])
			if p.distance_squared_to(point) < min_value:
				min_value = p.distance_squared_to(point)
				closest_point = p
	elif shape is ConcavePolygonShape2D:
		for i in range(shape.segments.size() - 1):
			var p := Geometry2D.get_closest_point_to_segment(point, shape.segments[i], shape.segments[i+1])
			if p.distance_squared_to(point) < min_value:
				min_value = p.distance_squared_to(point)
				closest_point = p
	elif shape is CircleShape2D:
		closest_point = (point - offset).normalized() * shape.radius + offset
	return closest_point
