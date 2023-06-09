extends CharacterBody2D


var target: CharacterBody2D


@export var max_speed := 200.0
## How far do I want to be from my target.
@export var acceleration := 50.0
@export var mass := 5.0
@export var kite_radius := 100.0
## How strongly to move away from my target if I am too close.
@export var avoidance_strength := 100.0
## How strongly to circle around my target once I am close.
@export var circling_strength := 100.0


@onready var original_kite_radius := kite_radius
var _radius_increasing := 1
var steering_force := Vector2()


func _process(delta: float) -> void:
	# Increase / decrease my kite_radius
#	if kite_radius >= original_kite_radius * 2:
#		_radius_increasing = -1
#	elif kite_radius <= original_kite_radius:
#		_radius_increasing = 1
#	kite_radius += delta * _radius_increasing * 30
	
	var distance := (target.position - position).length()
	
	if target != null and distance > kite_radius:
		pursuit(target)
		velocity += steering_force / mass * delta
	else:
		var direction := (target.position - position).normalized()
		# Move towards my target until we reach kite_radius.
		velocity += (direction * max_speed) - direction * kite_radius
		# If we are too close, move away as a function of 1 / distance.
		if distance < kite_radius:
			velocity -= (avoidance_strength / distance) * direction
		# Start circling once we get close.
		velocity += circling_strength * direction.rotated(PI/2) * min(1.0, pow(0.5, distance / kite_radius))
		
	velocity = velocity.limit_length(max_speed)
	move_and_slide()


func seek(target: Vector2) -> void:
	$NavigationAgent2D.target_position = target
	target = $NavigationAgent2D.get_next_path_position()
	steering_force = 10 * (target - position).normalized() * max_speed - velocity


func pursuit(target: CharacterBody2D) -> void:
	# If the target is ahead and facing us, we can seek to the target's position
	var to_target := target.position - position
	var rel_heading := velocity.normalized().dot(target.velocity.normalized())
	if to_target.dot(velocity.normalized()) > 0 and rel_heading < -0.95: # acos(0.95) = 18 deg
		return seek(target.position)
	var look_ahead_time := to_target.length() / (max_speed + target.velocity.length())
	seek(target.position + target.velocity * look_ahead_time)
