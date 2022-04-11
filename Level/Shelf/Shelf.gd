extends StaticBody2D
class_name Shelf

onready var anim = get_node("AnimationPlayer")
onready var is_broken := false

func break_shelf() -> void:
	if not is_broken:
		anim.play("break")
		is_broken = true
		yield(anim, "animation_finished")
		anim.play("idle")
	else:
		bump()

func bump() -> void:
	if anim.current_animation == "bump" or anim.current_animation == "break":
		return
	anim.play("bump")
	yield(anim, "animation_finished")
	anim.play("idle")