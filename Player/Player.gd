extends KinematicBody2D
class_name Player

const ACCEL = 5.0
const BRAKING_FRICTION = 0.1
const TURN_SPEED = 3.0
const FRICTION = 0.01

var vel : Vector2

onready var cam = get_node("PlayerCamera")

#func _draw():
#	draw_line(Vector2.ZERO, vel.rotated(-self.rotation), Color.green)

func _ready() -> void:
	vel = Vector2.ZERO

func _process(delta) -> void:
	pass
	#update()

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
			if prev_vel.length() > 300:
				col.break_shelf()
			elif prev_vel.length() > 10:
				col.bump()
