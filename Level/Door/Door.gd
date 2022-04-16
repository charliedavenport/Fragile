extends Area2D
class_name Door

const open_sprite = preload("res://Level/Door/door_open.png")

export var index : int

onready var sprite = get_node("Sprite")
onready var collision = get_node("CollisionShape2D")
onready var light = get_node("DoorLight")
onready var occluder = get_node("LightOccluder2D")
onready var best_time_label = get_node("BestTime/Label")

var is_open : bool

signal door_entered(_ind)

func _ready():
	is_open = false
	collision.disabled = true
	best_time_label.visible = false

func open() -> void:
	light.enabled = true
	occluder.visible = true
	sprite.texture = open_sprite
	collision.disabled = false

func set_best_time(_time : float) -> void:
	best_time_label.visible = true
	best_time_label.text = 'Best Time:\n%6.3f' % _time
