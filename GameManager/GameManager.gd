extends Node

const main_level_scene = preload("res://Level/MainLevel.tscn")
const level_01_scene = preload("res://Level/Level_01.tscn")

onready var player = get_node("Player")
onready var level = get_node("MainLevel")
onready var gui = get_node("CanvasLayer/GUI")

var curr_level_ind : int

func _ready() -> void:
	set_player_to_start_pos()
	level.connect("door_entered", self, "level_transition")
	player.connect("player_reset", self, "on_player_reset")
	curr_level_ind = 0

func set_player_to_start_pos() -> void:
	player.reset_anger()
	if is_instance_valid(level) and level is Level:
		player.position = level.player_start.position
		player.rotation = level.player_start.rotation

func level_transition(_level_ind : int) -> void:
	player.has_control = false
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
	curr_level_ind = _level_ind
	level.queue_free()
	level = next_level
	level.connect("door_entered", self, "level_transition")
	add_child(level)
	set_player_to_start_pos()
	player.cam.fade_to_black(false)
	if _level_ind > 0:
		var shelves = level.get_shelves()
		for shelf in shelves:
			shelf.connect("china_broken", self, "on_china_broken")
		gui.show_countdown()
		yield(gui, "countdown_complete")
	player.has_control = true

func on_china_broken() -> void:
	player.increase_anger()

func on_player_reset() -> void:
	level_transition(curr_level_ind)
	#player.cam.flash_background(false)
