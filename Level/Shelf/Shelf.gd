extends StaticBody2D
class_name Shelf

export var is_occluding := false

onready var anim = get_node("AnimationPlayer")
onready var is_broken := false
onready var occluder = get_node("LightOccluder2D")

signal china_broken

#func _ready() -> void:
#	occluder.

func break_china() -> void:
	if not is_broken:
		anim.play("break")
		is_broken = true
		yield(anim, "animation_finished")
		anim.play("idle")
	else:
		bump()

func emit_china_broken() -> void:
	emit_signal("china_broken")

func bump() -> void:
	if anim.current_animation == "bump" or anim.current_animation == "break":
		return
	anim.play("bump")
	yield(anim, "animation_finished")
	anim.play("idle")
