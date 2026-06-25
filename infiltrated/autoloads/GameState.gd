extends Node

var score: int = 0
var current_room: int = 1

func add_points(amount: int) -> void:
	score += amount

func reset() -> void:
	score = 0
	current_room = 1
