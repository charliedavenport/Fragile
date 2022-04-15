extends Level

export var level_number : int

onready var door = get_node("Door")

func _ready() -> void:
	door.connect("body_entered", self, "on_door_entered", [0])
	door.open()

func on_door_entered(_body, _ind) -> void:
	if not _body is Player:
		return
	emit_signal("door_entered", _ind)
