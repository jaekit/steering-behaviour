class_name Enemy extends CharacterBody2D


var player: Player = null

var mass := 5.0
var max_force := 50.0
var max_speed := 200.0
var steering_force := Vector2()


# TODO: Currently unused.
var interested: bool


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	steering_force = Vector2.ZERO
	if player != null and (player.position - position).length_squared() > 50000:
		pursuit(player)
	
	steering_force += $InterestArea.best_direction
	
	steering_force = steering_force.limit_length(max_force)
	var acceleration := steering_force / mass
	velocity = (velocity + acceleration).limit_length(max_speed)
	velocity.lerp(Vector2.ZERO, 0.5)
	move_and_slide()


func seek(target: Vector2) -> void:
	$NavigationAgent2D.target_position = target
	target = $NavigationAgent2D.get_next_path_position()
	steering_force = (target - position).normalized() * max_speed - velocity


func pursuit(target: CharacterBody2D) -> void:
	# If the target is ahead and facing us, we can seek to the target's position
	var to_target := target.position - position
	var rel_heading := velocity.normalized().dot(target.velocity.normalized())
	if to_target.dot(velocity.normalized()) > 0 and rel_heading < -0.95: # acos(0.95) = 18 deg
		return seek(target.position)
	var look_ahead_time := to_target.length() / (max_speed + target.velocity.length())
	seek(target.position + target.velocity * look_ahead_time)


func _on_interest_area_activated(value: bool) -> void:
	interested = value
