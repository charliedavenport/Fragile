extends KinematicBody2D
class_name Player

const ACCEL = 5.0
const BRAKING_FRICTION = 0.1
const TURN_SPEED = 3.0
const FRICTION = 0.005
const MAX_ANGER = 3

var vel : Vector2

onready var cam = get_node("PlayerCamera")
onready var sprite = get_node("Sprite")
onready var run_anim_timer = get_node("RunAnimTimer")
var is_running : bool

var anger_level : int

signal player_reset

#func _draw():
#	#draw_line(Vector2.ZERO, vel.rotated(-self.rotation), Color.green)
#	draw_line(Vector2.ZERO, Vector2.UP * 50, Color.blue)

func _ready() -> void:
	vel = Vector2.ZERO
	is_running = false
	reset_anger()

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
	if check_rot < 1.0/16.0 * TAU:
		y_coord = 0
	elif check_rot < 3.0/16.0 * TAU:
		y_coord = 1
	elif check_rot < 5.0/16.0 * TAU:
		y_coord = 2
	elif check_rot < 7.0/16.0 * TAU:
		y_coord = 3
	else:
		y_coord = 4
	sprite.frame_coords.y = y_coord
	# determine the x-coordinate of spritesheet, based on speed
	var speed = vel.length()
	if speed < 10.0 and is_running:
		is_running = false
		sprite.frame_coords.x = 0
	elif speed >= 10.0 and not is_running:
		is_running = true
		do_run_animation()

func _physics_process(delta) -> void:
	var prev_vel = vel
	if Input.is_action_pressed("forward"):
		vel += -1.0 * transform.y * ACCEL
	elif Input.is_action_pressed("backward"):
		vel *= (1.0 - BRAKING_FRICTION)
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
	#print(prev_vel.length())
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

func do_run_animation() -> void:
	is_running = true
	while is_running:
		sprite.frame_coords.x = 1
		run_anim_timer.start()
		yield(run_anim_timer, "timeout")
		if not is_running:
			return
		sprite.frame_coords.x = 2
		run_anim_timer.start()
		yield(run_anim_timer, "timeout")

func increase_anger() -> void:
	anger_level += 1
	var gb_val = lerp(1.0, 0.0, min((1.0/float(MAX_ANGER)) * anger_level, 1.0))
	sprite.modulate = Color(1.0, gb_val, gb_val, 1.0)
	if anger_level >= MAX_ANGER:
		rage_and_reset()

func reset_anger() -> void:
	anger_level = 0
	sprite.modulate = Color.white

func rage_and_reset() -> void:
	# play "rage" animation
	emit_signal("player_reset")
