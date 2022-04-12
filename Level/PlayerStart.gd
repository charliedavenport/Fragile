tool
extends Node2D

func _draw():
	if not Engine.editor_hint:
		return
	draw_line(Vector2.ZERO, Vector2.UP * 50, Color.green, 2.0)

func _init():
	update()

func _process(delta):
	update()
