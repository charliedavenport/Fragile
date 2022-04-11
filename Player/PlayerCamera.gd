extends Camera2D

const FOLLOW_SPEED = 0.2
const MIN_ZOOM = 1.25
const MAX_ZOOM = 2.0

onready var target = get_parent()
var zoom_val : float

func _ready() -> void:
	set_as_toplevel(true)

func _process(delta) -> void:
	position = position.linear_interpolate(target.position, FOLLOW_SPEED)

func set_zoom(player_speed) -> void:
	var new_zoom_val = ((MAX_ZOOM - MIN_ZOOM) / 1000) * player_speed + MIN_ZOOM
	new_zoom_val = min(new_zoom_val, MAX_ZOOM)
	zoom_val = lerp(zoom_val, new_zoom_val, 0.2)
	zoom = Vector2(zoom_val, zoom_val)
