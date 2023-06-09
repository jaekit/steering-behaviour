class_name Player extends CharacterBody2D


var speed := 500


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if (get_global_mouse_position() - position).length_squared() < speed * delta:
		velocity = Vector2()
	else:
		velocity = (get_global_mouse_position() - position).normalized() * speed
	move_and_slide()
