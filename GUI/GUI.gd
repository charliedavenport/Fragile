extends Control

const COUNTDOWN_INTERVAL = 0.5

var is_doing_countdown : bool
onready var countdown_label = get_node("Countdown/Label")
onready var countdown_timer = get_node("Countdown/CountdownTimer")
onready var timer_label = get_node("PlayerTimer/Label")
onready var splash_rect = get_node("CanvasLayer/TextureRect")
onready var splash_fade = get_node("FadeTween")

signal countdown_complete

func _ready() -> void:
	is_doing_countdown = false
	countdown_label.visible = false
	countdown_timer.wait_time = COUNTDOWN_INTERVAL
	countdown_timer.one_shot = true
	show_playertimer(false)

func show_splash() -> void:
	pass

func show_countdown() -> void:
	if is_doing_countdown:
		return
	is_doing_countdown = true
	countdown_label.visible = true
	for cnt_txt in ["3...", "2...", "1..."]:
		countdown_label.text = cnt_txt
		countdown_timer.start()
		yield(countdown_timer, "timeout")
	# wait extra long on the "1..."
	countdown_timer.start()
	yield(countdown_timer, "timeout")
	countdown_label.text = "GO!!"
	emit_signal("countdown_complete")
	countdown_timer.start()
	yield(countdown_timer, "timeout")
	countdown_label.visible = false
	is_doing_countdown = false

func show_playertimer(_on) -> void:
	timer_label.visible = _on

func set_playertimer(_time : float) -> void:
	timer_label.text = "%6.4f" % _time
