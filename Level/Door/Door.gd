extends Area2D
class_name Door

const open_sprite = preload("res://Level/Door/door_open.png")

export var index : int

onready var sprite = get_node("Sprite")
onready var collision = get_node("CollisionShape2D")

var is_open : bool

signal door_entered(_ind)

func _ready():
	is_open = false
	collision.disabled = true

func open() -> void:
	sprite.texture = open_sprite
	collision.disabled = false
