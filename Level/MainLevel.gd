extends Level

# control doors and signal player entering an open door
# player should be "invincible" in main level

#onready var door_01_area = get_node("Door_01")
var doors : Array

var current_level : int

func _ready() -> void:
	#door_01_area.connect("body_entered", self, "on_door_entered", [1])
	var doors_node = get_node("Doors")
	doors = []
	for child in doors_node.get_children():
		if child is Door:
			doors.append(child)
			child.connect("body_entered", self, "on_door_entered", [child.index])
	for d in doors:
		if d.index <= (current_level + 1):
			d.open()

func on_door_entered(_body, _ind) -> void:
	if not _body is Player:
		return
	emit_signal("door_entered", _ind)

func set_open_doors(_levels_completed) -> void:
	for d in doors:
		if d.index <= (_levels_completed + 1):
			d.open()
			if d.index <= _levels_completed:
				d.light.enabled = false

func get_door_by_index(_ind : int):
	for d in doors:
		if d.index == _ind:
			return d
	return null

func set_best_times(_best_times : Array) -> void:
	for ind in range(_best_times.size()):
		var door = get_door_by_index(ind+1)
		if door:
			door.set_best_time(_best_times[ind])
