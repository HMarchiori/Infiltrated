extends Node2D

@onready var room: Node2D = $Room
@onready var player: CharacterBody2D = $Player
@onready var hud_label: Label = $HUD/ScoreLabel

func _ready() -> void:
	var spawn := room.get_node("SpawnPoint") as Marker2D
	player.global_position = spawn.global_position

	EventBus.jogador_morreu.connect(_on_jogador_morreu)
	EventBus.inimigo_morreu.connect(_on_inimigo_morreu)
	EventBus.sala_limpa.connect(_on_sala_limpa)

func _on_jogador_morreu() -> void:
	hud_label.text = "GAME OVER\nScore: %d\nClique para reiniciar" % GameState.score
	await get_tree().create_timer(2.0).timeout
	GameState.resetar()
	get_tree().reload_current_scene()

func _on_inimigo_morreu() -> void:
	_atualizar_hud()

func _on_sala_limpa() -> void:
	hud_label.text = "Sala limpa! Entre no portal.\nScore: %d" % GameState.score

func _atualizar_hud() -> void:
	hud_label.text = "Score: %d" % GameState.score
