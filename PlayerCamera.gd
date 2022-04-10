extends Camera2D

const FOLLOW_SPEED = 0.5

onready var target = get_parent()

func _ready() -> void:
	set_as_toplevel(true)

func _process(delta) -> void:
	position = position.linear_interpolate(target.position, FOLLOW_SPEED)
