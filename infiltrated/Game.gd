extends Node2D

@export var game_over_delay: float = 2.0

@onready var room: Node2D = $Room
@onready var player: CharacterBody2D = $Player
@onready var hud_label: Label = $HUD/ScoreLabel
@onready var hud_lives: Label = $HUD/LivesLabel

func _ready() -> void:
	var spawn := room.get_node("SpawnPoint") as Marker2D
	player.global_position = spawn.global_position

	EventBus.jogador_morreu.connect(_on_jogador_morreu)
	EventBus.inimigo_morreu.connect(_on_inimigo_morreu)
	EventBus.sala_limpa.connect(_on_sala_limpa)
	EventBus.jogador_hp_alterado.connect(_on_jogador_hp_alterado)
	_on_jogador_hp_alterado(player.hp)

func _on_jogador_morreu() -> void:
	var score_final := GameState.score
	GameState.resetar()
	hud_label.text = "GAME OVER\nScore: %d\nClique para reiniciar" % score_final
	await get_tree().create_timer(game_over_delay).timeout
	get_tree().reload_current_scene()

func _on_inimigo_morreu() -> void:
	_atualizar_hud()

func _on_sala_limpa() -> void:
	hud_label.text = "Sala limpa! Entre no portal.\nScore: %d" % GameState.score

func _on_jogador_hp_alterado(hp_atual: int) -> void:
	hud_lives.text = "❤ x %d" % hp_atual

func _atualizar_hud() -> void:
	hud_label.text = "Score: %d" % GameState.score
