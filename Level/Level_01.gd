extends Level

onready var door = get_node("Door")

func _ready() -> void:
	door.connect("body_entered", self, "on_door_entered", [0])

func on_door_entered(_body, _ind) -> void:
	if not _body is Player:
		return
	print("on_door_entered")
	emit_signal("door_entered", _ind)
