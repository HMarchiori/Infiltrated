extends Node2D

@export var game_over_delay: float = 2.0

@onready var room: Node2D = $Room
@onready var player: CharacterBody2D = $Player
@onready var hud_label: Label = $HUD/ScoreLabel
@onready var hud_enemies: Label = $HUD/EnemiesLabel
@onready var hud_lives: Label = $HUD/LivesLabel
@onready var hud_timer: Label = $HUD/TimerLabel
@onready var room_clear_banner: Label = $HUD/RoomClearBanner
@onready var enemy_spawner = $Room/EnemySpawner
@onready var _psycho_material: ShaderMaterial = $PostFX/Overlay.material

var time_left: float = 180.0
var _game_over: bool = false

func _ready() -> void:
	var spawn := room.get_node("SpawnPoint") as Marker2D
	player.global_position = spawn.global_position

	EventBus.jogador_morreu.connect(_on_jogador_morreu)
	EventBus.inimigo_morreu.connect(_on_inimigo_morreu)
	EventBus.sala_limpa.connect(_on_sala_limpa)
	EventBus.jogador_hp_alterado.connect(_on_jogador_hp_alterado)
	EventBus.jogador_dano.connect(_on_jogador_dano)
	_on_jogador_hp_alterado(player.hp)
	_atualizar_hud()

	# Smoky, ghostly environment rendered behind the world tiles.
	var smoke_layer := CanvasLayer.new()
	smoke_layer.layer = -10
	add_child(smoke_layer)
	var smoke_rect := ColorRect.new()
	smoke_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	smoke_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var smoke_material := ShaderMaterial.new()
	smoke_material.shader = load("res://hud_smoke.gdshader")
	smoke_rect.material = smoke_material
	smoke_layer.add_child(smoke_rect)

func _process(delta: float) -> void:
	if _game_over:
		return
	time_left = max(0.0, time_left - delta)
	var mins := int(time_left) / 60
	var secs := int(time_left) % 60
	hud_timer.text = "Tempo: %d:%02d" % [mins, secs]
	if time_left <= 30.0:
		hud_timer.add_theme_color_override("font_color", Color(1.0, 0.2, 0.1, 1.0))
	if time_left == 0.0:
		_on_jogador_morreu()

func _on_jogador_morreu() -> void:
	if _game_over:
		return
	_game_over = true
	get_tree().call_deferred("change_scene_to_file", "res://youLost.tscn")

func _on_inimigo_morreu() -> void:
	_atualizar_hud()

func _on_sala_limpa() -> void:
	_atualizar_hud()
	var tween := create_tween()
	tween.tween_property(room_clear_banner, "modulate:a", 1.0, 0.6)

func _on_jogador_dano() -> void:
	# Subtle red damage flash through the existing PostFX shader.
	_psycho_material.set_shader_parameter("flash", 0.35)
	var tween := create_tween()
	tween.tween_property(_psycho_material, "shader_parameter/flash", 0.0, 0.3)

func _on_jogador_hp_alterado(hp_atual: int) -> void:
	hud_lives.text = "❤ ".repeat(max(0, hp_atual)).strip_edges()

func _atualizar_hud() -> void:
	hud_label.text = "Score: %d" % GameState.score
	hud_enemies.text = "Inimigos: %d" % enemy_spawner.vivos
