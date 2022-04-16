extends StaticBody2D
class_name Vase

onready var anim = get_node("AnimationPlayer")
onready var is_broken := false
onready var occluder = get_node("LightOccluder2D")
onready var collision = get_node("CollisionShape2D")

signal china_broken

#func _ready() -> void:
#	occluder.

func break_china() -> void:
	if not is_broken:
		anim.play("break")
		is_broken = true
		collision.disabled = true
		yield(anim, "animation_finished")
		anim.play("idle")

func emit_china_broken() -> void:
	emit_signal("china_broken")

func bump() -> void:
	if is_broken or anim.current_animation == "bump" or anim.current_animation == "break":
		return
	anim.play("bump")
	yield(anim, "animation_finished")
	anim.play("idle")
