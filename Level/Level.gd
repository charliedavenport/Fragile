extends Node2D
class_name Level

onready var player_start = get_node("PlayerStart")

signal door_entered(_ind)

func get_shelves() -> Array:
	var shelves_node = get_node("Shelves")
	var arr = []
	if shelves_node:
		for child in shelves_node.get_children():
			if child is Shelf:
				arr.append(child)
	return arr

