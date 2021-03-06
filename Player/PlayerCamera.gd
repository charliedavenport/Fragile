extends Camera2D

const BACKGROUND_COLOR = Color("5e3643")

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

const BKG_FLASH_INTERVAL = 0.5
onready var bkg_color_rect = get_node("CanvasLayer/BackgroundColorRect")
onready var bkg_flash_tween = get_node("BkgFlashTween")
var is_flashing : bool

const FADE_DURATION = 0.25
onready var fade_black_rect = get_node("CanvasLayer2/FadeToBlackColorRect")
onready var fade_tween = get_node("FadeTween")

signal done_fading

func _ready() -> void:
	set_as_toplevel(true)
	shake_amt = 0.0
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	noise_y = 0.0
	bkg_color_rect.color = BACKGROUND_COLOR

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

func fade_to_black(_on : bool) -> void:
	var curr_color = fade_black_rect.color
	var alpha = 1.0 if _on else 0.0
	var target_color = Color(curr_color.r, curr_color.g, curr_color.b, alpha)
	fade_tween.interpolate_property(fade_black_rect, "color", curr_color, target_color, FADE_DURATION, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	fade_tween.start()
	yield(fade_tween, "tween_completed")
	emit_signal("done_fading")

func flash_background(_on : bool) -> void:
	if _on and not is_flashing:
		is_flashing = true
		start_flashing_bkg()
	elif not _on:
		is_flashing = false
		bkg_color_rect.modulate = Color.white

func start_flashing_bkg() -> void:
	while is_flashing:
		bkg_flash_tween.interpolate_property(bkg_color_rect, "modulate", Color.white, Color.red, 
			BKG_FLASH_INTERVAL, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		bkg_flash_tween.start()
		yield(bkg_flash_tween, "tween_completed")
		if not is_flashing:
			flash_background(false)
			return
		bkg_flash_tween.interpolate_property(bkg_color_rect, "modulate", Color.red, Color.white, 
			BKG_FLASH_INTERVAL, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		bkg_flash_tween.start()
		yield(bkg_flash_tween, "tween_completed")
