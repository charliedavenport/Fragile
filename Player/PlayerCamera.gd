extends Camera2D

const FOLLOW_SPEED = 0.2
const MIN_ZOOM = 1.25
const MAX_ZOOM = 2.0

const SHAKE_POWER = 2
const SHAKE_DECAY = 0.8
const MAX_OFFSET = Vector2(100, 75)
const MAX_ROLL = 0.1
var shake_amt : float

onready var shake_timer = get_node("ShakeTimer")

onready var rng = RandomNumberGenerator.new().randomize()
onready var noise = OpenSimplexNoise.new()
var noise_y : float

onready var target = get_parent()
var zoom_val : float

func _ready() -> void:
	set_as_toplevel(true)
	shake_amt = 0.0
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	noise_y = 0.0

func _process(delta) -> void:
	position = position.linear_interpolate(target.position, FOLLOW_SPEED)
	if shake_amt > 0:
		shake_amt = max(shake_amt - SHAKE_DECAY * delta, 0.0)
		shake()

func set_zoom(_player_speed) -> void:
	var new_zoom_val = ((MAX_ZOOM - MIN_ZOOM) / 1000) * _player_speed + MIN_ZOOM
	new_zoom_val = min(new_zoom_val, MAX_ZOOM)
	zoom_val = lerp(zoom_val, new_zoom_val, 0.2)
	zoom = Vector2(zoom_val, zoom_val)

func add_shake(_value) -> void:
	print(shake_timer.is_stopped())
	if not shake_timer.is_stopped():
		return
	shake_amt = min(shake_amt + _value, 1.0)
	shake_timer.start()

func shake() -> void:
	noise_y += 1
	var strength = pow(shake_amt, SHAKE_POWER)
	rotation = MAX_ROLL * strength * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = MAX_OFFSET.x * strength * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = MAX_OFFSET.y * strength * noise.get_noise_2d(noise.seed*3, noise_y)
