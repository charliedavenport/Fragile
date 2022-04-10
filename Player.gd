extends KinematicBody2D
class_name Player

const ACCEL = 5.0
const BRAKING = 3.0
const TURN_SPEED = 3.0
const FRICTION = 1.5

var vel : Vector2

func _draw():
	draw_line(Vector2.ZERO, vel.rotated(-self.rotation), Color.green)

func _ready() -> void:
	vel = Vector2.ZERO

func _process(delta) -> void:
	pass
	#update()

func _physics_process(delta) -> void:
	if Input.is_action_pressed("forward"):
		vel += -1.0 * transform.y * ACCEL
	elif Input.is_action_pressed("backward"):
		vel *= 0.9
	else:
		vel *= 0.98
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
