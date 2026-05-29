extends Node2D

@export var enemy_count: int = 6
@export var portal_scene: PackedScene

@onready var spawner: Node = $EnemySpawner
@onready var portal_spawn: Marker2D = $ExitPortalSpawnPoint

func _ready() -> void:
	_criar_fronteiras()
	EventBus.sala_limpa.connect(_on_sala_limpa)
	EventBus.you_won.connect(_on_you_won)
	spawner.spawnar(enemy_count)

func _on_sala_limpa() -> void:
	if portal_scene == null:
		return
	var portal: Node2D = portal_scene.instantiate()
	portal.global_position = portal_spawn.global_position
	call_deferred("add_child", portal)  # ← deferred

func _on_you_won() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://you_won.tscn")

func _criar_fronteiras() -> void:
	var paredes := [
		[Vector2(-420, 0),   Vector2(20, 900)],
		[Vector2(620, 0),    Vector2(20, 900)],
		[Vector2(100, -470), Vector2(1060, 20)],
		[Vector2(100, 470),  Vector2(1060, 20)],
	]
	for p in paredes:
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		body.position = p[0]
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = p[1]
		shape.shape = rect
		body.add_child(shape)
		add_child(body)
