extends Node2D

@export var game_over_delay: float = 2.0

@onready var room: Node2D = $Room
@onready var player: CharacterBody2D = $Player
@onready var hud_label: Label = $HUD/ScoreLabel
@onready var hud_lives: Label = $HUD/LivesLabel
@onready var room_clear_banner: Label = $HUD/RoomClearBanner

func _ready() -> void:
	var spawn := room.get_node("SpawnPoint") as Marker2D
	player.global_position = spawn.global_position

	EventBus.jogador_morreu.connect(_on_jogador_morreu)
	EventBus.inimigo_morreu.connect(_on_inimigo_morreu)
	EventBus.sala_limpa.connect(_on_sala_limpa)
	EventBus.jogador_hp_alterado.connect(_on_jogador_hp_alterado)
	_on_jogador_hp_alterado(player.hp)

func _on_jogador_morreu() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://youLost.tscn")

func _on_inimigo_morreu() -> void:
	_atualizar_hud()

func _on_sala_limpa() -> void:
	_atualizar_hud()
	var tween := create_tween()
	tween.tween_property(room_clear_banner, "modulate:a", 1.0, 0.6)

func _on_jogador_hp_alterado(hp_atual: int) -> void:
	hud_lives.text = "❤ ".repeat(max(0, hp_atual)).strip_edges()

func _atualizar_hud() -> void:
	hud_label.text = "Score: %d" % GameState.score
