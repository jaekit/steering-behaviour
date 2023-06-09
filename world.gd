extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	$Enemy.target = $Player
	$Enemy2.target = $Player
	#$Enemy3.player = $Player
