extends Level

# control doors and signal player entering an open door
# player should be "invincible" in main level

onready var door_01_area = get_node("Door_01")

func _ready() -> void:
	door_01_area.connect("body_entered", self, "on_door_entered", [1])

func on_door_entered(_body, _ind) -> void:
	if not _body is Player:
		return
	print("on_door_entered")
	emit_signal("door_entered", _ind)
