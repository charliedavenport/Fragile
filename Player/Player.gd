extends KinematicBody2D
class_name Player

const ACCEL = 5.0
const BRAKING_FRICTION = 0.1
const TURN_SPEED = 3.0
const FRICTION = 0.005
const MAX_ANGER = 5

enum State {IDLE, RUNNING, STOPPING}

var curr_state : int

var vel : Vector2

onready var cam = get_node("PlayerCamera")
onready var sprite = get_node("Sprite")
onready var run_anim_timer = get_node("RunAnimTimer")
var is_running : bool
var has_control : bool

var anger_level : int

signal player_reset

#func _draw():
#	#draw_line(Vector2.ZERO, vel.rotated(-self.rotation), Color.green)
#	draw_line(Vector2.ZERO, Vector2.UP * 50, Color.blue)

func _ready() -> void:
	vel = Vector2.ZERO
	set_state(State.IDLE)
	reset_anger()
	has_control = true

func _process(delta) -> void:
	#update()
	# sprite always points up
	sprite.rotation = -rotation
	# flip the sprite based on rotation
	var check_rot = fmod(rotation, TAU)
	if check_rot < 0.0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	# determine y-coordinate of spritesheet, based on rotation
	check_rot = abs(check_rot)
	var y_coord
	if check_rot < 1.0/32.0 * TAU:
		y_coord = 0
	elif check_rot < 3.0/32.0 * TAU:
		y_coord = 1
	elif check_rot < 5.0/32.0 * TAU:
		y_coord = 2
	elif check_rot < 7.0/32.0 * TAU:
		y_coord = 3
	elif check_rot < 9.0/32.0 * TAU:
		y_coord = 4
	elif check_rot < 11.0/32.0 * TAU:
		y_coord = 5
	elif check_rot < 13.0/32.0 * TAU:
		y_coord = 6
	elif check_rot < 15.0/32.0 * TAU:
		y_coord = 7
	else:
		y_coord = 8
	sprite.frame_coords.y = y_coord
	# determine the x-coordinate of spritesheet, based on speed
	var speed = vel.length()
	if speed < 10.0 and curr_state != State.IDLE:
		set_state(State.IDLE)
	elif Input.is_action_pressed("backward") and curr_state != State.IDLE:
		set_state(State.STOPPING)
	elif speed >= 10.0 and curr_state != State.RUNNING:
		set_state(State.RUNNING)

func _physics_process(delta) -> void:
	var prev_vel = vel
	if has_control:
		if Input.is_action_pressed("backward"):
			vel *= (1.0 - BRAKING_FRICTION)
		elif Input.is_action_pressed("forward"):
			vel += -1.0 * transform.y * ACCEL
		else:
			vel *= (1.0 - FRICTION)
		if Input.is_action_pressed("turn_left") or Input.is_action_pressed("turn_right"):
			var rot_amt = TURN_SPEED * delta
			if Input.is_action_pressed("turn_left"):
				rot_amt *= -1
			# exclusive or - don't do anything if both left and right are pressed 
			if Input.is_action_pressed("turn_left") and Input.is_action_pressed("turn_right"):
				rot_amt = 0
			self.rotate(rot_amt)
			vel = vel.rotated(rot_amt)
	vel = move_and_slide(vel)
	vel = vel.rotated(vel.angle_to(-transform.y))
	cam.set_zoom(vel.length())
	# check for collision with shelf
	var slides = get_slide_count()
	for i in range(slides):
		var col = get_slide_collision(i).collider
		if col is Shelf:
			if prev_vel.length() > 400:
				col.break_shelf()
				cam.add_shake(0.5)
			elif prev_vel.length() > 10:
				col.bump()
				cam.add_shake(0.3)

func set_state(_value : int) -> void:
	var prev_state = curr_state
	curr_state = _value
	match _value:
		State.IDLE:
			do_idle_animation()
		State.RUNNING:
			do_run_animation()
		State.STOPPING:
			do_stopping_animation()
		_:
			pass

func do_stopping_animation() -> void:
	sprite.frame_coords.x = 3

func do_idle_animation() -> void:
	sprite.frame_coords.x = 0

func do_run_animation() -> void:
	while curr_state == State.RUNNING:
		sprite.frame_coords.x = 1
		run_anim_timer.start()
		yield(run_anim_timer, "timeout")
		if not curr_state == State.RUNNING:
			return
		sprite.frame_coords.x = 2
		run_anim_timer.start()
		yield(run_anim_timer, "timeout")

func increase_anger() -> void:
	anger_level += 1
	if anger_level == MAX_ANGER - 1:
		cam.flash_background(true)
	var gb_val = lerp(1.0, 0.0, min((1.0/float(MAX_ANGER)) * anger_level, 1.0))
	sprite.modulate = Color(1.0, gb_val, gb_val, 1.0)
	if anger_level >= MAX_ANGER:
		rage_and_reset()

func reset_anger() -> void:
	cam.flash_background(false)
	anger_level = 0
	sprite.modulate = Color.white

func rage_and_reset() -> void:
	vel = Vector2.ZERO
	# play "rage" animation
	set_state(State.IDLE)
	emit_signal("player_reset")
