extends Node

const main_level_scene = preload("res://Level/MainLevel.tscn")
const level_01_scene = preload("res://Level/Level_01.tscn")

onready var player = get_node("Player")
onready var level = get_node("MainLevel")

func _ready() -> void:
	set_player_to_start_pos()
	level.connect("door_entered", self, "level_transition")

func set_player_to_start_pos() -> void:
	if is_instance_valid(level) and level is Level:
		player.position = level.player_start.position
		player.rotation = level.player_start.rotation

func level_transition(_level_ind : int) -> void:
	player.cam.fade_to_black(true)
	yield(player.cam, "done_fading")
	var next_level
	match _level_ind:
		0:
			next_level = main_level_scene.instance()
		1:
			next_level = level_01_scene.instance()
		_:
			printerr("Bad _level_ind argument in GameManager.level_transition(): " + str(_level_ind))
			return
	level.queue_free()
	level = next_level
	level.connect("door_entered", self, "level_transition")
	add_child(level)
	set_player_to_start_pos()
	player.cam.fade_to_black(false)
