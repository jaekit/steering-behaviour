class_name InterestArea extends Area2D

# TODO: Currently unused.
signal activated(value: bool)


## How close to the target to get before moving away.
@export_range(0.0, 2.0) var proximity := 1.0
@export_enum("CW:1", "CCW:-1") var rotate := 1


const _SQ2 := 1.0/sqrt(2.0)
const _DIRECTIONS := [
	Vector2(1, 0), Vector2(_SQ2, _SQ2), Vector2(0, 1), Vector2(-_SQ2, _SQ2),
	Vector2(-1, 0), Vector2(-_SQ2, -_SQ2), Vector2(0, -1), Vector2(_SQ2, -_SQ2)
]


# Array of weights for eight directions. Which directions are preferable and which are dangerous.
@onready var interest := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
@onready var danger := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
# Bodies within my area.
var _dangerous_bodies: Dictionary
var _target: CollisionObject2D


# Best direction to go to.
var best_direction: Vector2


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	_update_best_direction()


func _draw() -> void:
	for i in range(_DIRECTIONS.size()):
		draw_line(Vector2(), _DIRECTIONS[i] * interest[i] * 100, Color.GREEN, 2.0)
		draw_line(Vector2(), _DIRECTIONS[i] * danger[i] * 100, Color.RED, 2.0)
	draw_line(Vector2(), best_direction * 100, Color.BLUE, 2.0)


func _update_best_direction() -> void:
	best_direction = Vector2(0, 0)
	
	for i in range(_DIRECTIONS.size()):
		interest[i] = 0.0
		danger[i] = 0.0
	for body in _dangerous_bodies:
		_adjust_weights(body)
	if _target != null:
		_adjust_weights(_target)
	#var best_index := 0
	for i in range(_DIRECTIONS.size()):
		interest[i] -= danger[i]
#		if interest[i] > interest[best_index]:
#			best_index = i
		best_direction += _DIRECTIONS[i] * interest[i]
	#best_direction = interest[best_index] * _DIRECTIONS[best_index]
	queue_redraw()


func _adjust_weights(body: CollisionObject2D) -> void:
	var posn := Utility.closest_point(body.shape_owner_get_shape(0, 0), global_position, body.position)
	var direction: Vector2 = (posn - global_position).normalized()
	var distance := (posn - global_position).length_squared()
	var radius := pow(shape_owner_get_shape(0, 0).radius, 2) * proximity
	
	for i in range(_DIRECTIONS.size()):
		if body == _target:
			var dot := direction.dot(_DIRECTIONS[i].rotated(rotate * (distance - radius) / radius * PI))
			interest[i] = max(interest[i], dot)
		else:
			# Move away from the danger.
			# cosine to scale danger from 0 to 1 based on how close we are.
			# pow(x, factor) so that high danger only when really close.
			danger[i] = max(danger[i], direction.dot(_DIRECTIONS[i]) *
				(pow(cos((posn - global_position).length_squared() / radius * PI / 2), 10)))
			
			# Try to kite orthogonally.
			interest[i] = max(interest[i], direction.dot(_DIRECTIONS[i].rotated(rotate * PI / 2)))


func acute(a: Vector2, b: Vector2) -> int:
	var angle := a.angle_to(b)
	if angle < PI / 2 and angle > - PI / 2:
		return 1
	return -1


func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body == get_parent():
		return
	if _dangerous_bodies.size() == 0:
		activated.emit(true)
	_dangerous_bodies[body] = true


func _on_body_exited(body: Node2D) -> void:
	_dangerous_bodies.erase(body)
	if _dangerous_bodies.size() == 0:
		activated.emit(false)
