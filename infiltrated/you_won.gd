extends Node2D

func _ready() -> void:
	$CanvasLayer/Root/ScoreLabel.text = "Score: %d" % GameState.score
	GameState.resetar()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game.tscn")
	
