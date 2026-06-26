extends Node

var score: int = 0

func add_points(amount: int) -> void:
	score += amount

func reset() -> void:
	score = 0
