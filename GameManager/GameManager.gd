extends Node

const main_level_scene = preload("res://Level/MainLevel.tscn")
const level_01_scene = preload("res://Level/Level_01.tscn")
const level_02_scene = preload("res://Level/Level_02.tscn")
const level_03_scene = preload("res://Level/Level_03.tscn")
const level_04_scene = preload("res://Level/Level_04.tscn")

onready var player = get_node("Player")
onready var level = get_node("MainLevel")
onready var gui = get_node("CanvasLayer/GUI")

var curr_level_ind : int
var main_level_doors : Array
var levels_completed : int

var best_times : Array
var curr_level_time : float # seconds
var start_os_time : int # measured in milisecond "ticks", so int instead of float
var is_timing_player : bool

func _ready() -> void:
	set_player_to_start_pos()
	level.connect("door_entered", self, "on_door_entered")
	player.connect("player_reset", self, "on_player_reset")
	curr_level_ind = 0
	levels_completed = 0
	is_timing_player = false
	best_times = []

func set_player_to_start_pos() -> void:
	player.reset_anger()
	if is_instance_valid(level) and level is Level:
		player.position = level.player_start.position
		player.rotation = level.player_start.rotation

func level_transition(_level_ind : int) -> void:
	is_timing_player = false
	curr_level_time = 0.0
	player.has_control = false
	player.vel = Vector2.ZERO
	player.set_state(Player.State.IDLE)
	player.cam.fade_to_black(true)
	yield(player.cam, "done_fading")
	var next_level
	match _level_ind:
		0:
			next_level = main_level_scene.instance()
		1:
			next_level = level_01_scene.instance()
		2: 
			next_level = level_02_scene.instance()
		3:
			next_level = level_03_scene.instance()
		4: 
			next_level = level_04_scene.instance()
		_:
			printerr("Bad _level_ind argument in GameManager.level_transition(): " + str(_level_ind))
			next_level = main_level_scene.instance()
			_level_ind = 0
	curr_level_ind = _level_ind
	level.queue_free()
	level = next_level
	level.connect("door_entered", self, "on_door_entered")
	add_child(level)
	set_player_to_start_pos()
	player.cam.fade_to_black(false)
	if _level_ind > 0:
		var china = level.get_china()
		for c in china:
			c.connect("china_broken", self, "on_china_broken")
		gui.show_countdown()
		yield(gui, "countdown_complete")
		start_timing_player()
	else:
		level.set_open_doors(levels_completed)
		level.set_best_times(best_times)
		level.current_level = levels_completed + 1
	player.has_control = true

func start_timing_player() -> void:
#	if is_timing_player:
#		printerr("Can't start timing player when is_timing_player is already true. ")
#		return
	is_timing_player = true
	curr_level_time = 0.0
	start_os_time = OS.get_ticks_msec()
	gui.show_playertimer(true)
	while is_timing_player:
		curr_level_time = float(OS.get_ticks_msec() - start_os_time) / 1000.0
		gui.set_playertimer(curr_level_time)
		yield(get_tree(), "idle_frame")
	gui.show_playertimer(false)

func check_best_time() -> void:
	if curr_level_ind == best_times.size() + 1:
		best_times.append(curr_level_time)
	elif curr_level_ind <= best_times.size():
		var best_t_ind = curr_level_ind - 1
		if curr_level_time < best_times[best_t_ind]:
			best_times[best_t_ind] = curr_level_time
			print(best_times)
	

func on_door_entered(_ind) -> void:
	if curr_level_ind > 0:
		is_timing_player = false
		check_best_time()
	if curr_level_ind == levels_completed + 1:
		levels_completed += 1
#		print("levels_completed = " + str(levels_completed))
	level_transition(_ind)

func on_china_broken() -> void:
	player.increase_anger()

func on_player_reset() -> void:
	level_transition(curr_level_ind)
