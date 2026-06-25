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

	EventBus.player_died.connect(_on_player_died)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.player_hp_changed.connect(_on_player_hp_changed)
	EventBus.player_damaged.connect(_on_player_damaged)
	_on_player_hp_changed(player.hp)
	_update_hud()

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
	hud_timer.text = "Time: %d:%02d" % [mins, secs]
	if time_left <= 30.0:
		hud_timer.add_theme_color_override("font_color", Color(1.0, 0.2, 0.1, 1.0))
	if time_left <= 0.0:
		_on_player_died()

func _on_player_died() -> void:
	if _game_over:
		return
	_game_over = true
	get_tree().call_deferred("change_scene_to_file", "res://youLost.tscn")

func _on_enemy_died() -> void:
	_update_hud()

func _on_room_cleared() -> void:
	_update_hud()
	var tween := create_tween()
	tween.tween_property(room_clear_banner, "modulate:a", 1.0, 0.6)

func _on_player_damaged() -> void:
	# Subtle red damage flash through the existing PostFX shader.
	_psycho_material.set_shader_parameter("flash", 0.35)
	var tween := create_tween()
	tween.tween_property(_psycho_material, "shader_parameter/flash", 0.0, 0.3)

func _on_player_hp_changed(current_hp: int) -> void:
	hud_lives.text = "❤ ".repeat(max(0, current_hp)).strip_edges()

func _update_hud() -> void:
	hud_label.text = "Score: %d" % GameState.score
	hud_enemies.text = "Enemies: %d" % enemy_spawner.alive_count
