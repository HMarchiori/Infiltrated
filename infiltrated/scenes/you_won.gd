extends Node2D

func _ready() -> void:
	$CanvasLayer/Root/ScoreLabel.text = "Score: %d" % GameState.score
	GameState.reset()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	
