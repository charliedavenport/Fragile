extends Control

const COUNTDOWN_INTERVAL = 0.5

var is_doing_countdown : bool
onready var countdown_label = get_node("Countdown/Label")
onready var countdown_timer = get_node("Countdown/CountdownTimer")

signal countdown_complete

func _ready() -> void:
	is_doing_countdown = false
	countdown_label.visible = false
	countdown_timer.wait_time = COUNTDOWN_INTERVAL
	countdown_timer.one_shot = true

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
	
