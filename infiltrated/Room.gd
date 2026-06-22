extends Node2D

@export var portal_scene: PackedScene

@onready var spawner: Node = $EnemySpawner
@onready var portal_spawn: Marker2D = $ExitPortalSpawnPoint
@onready var tilemap: TileMapLayer = $Floor

func _ready() -> void:
	_criar_fronteiras()
	EventBus.sala_limpa.connect(_on_sala_limpa)
	EventBus.you_won.connect(_on_you_won)
	spawner.spawnar(spawner.enemy_count)

func _on_sala_limpa() -> void:
	if portal_scene == null:
		return
	var portal: Node2D = portal_scene.instantiate()
	portal.global_position = portal_spawn.global_position
	call_deferred("add_child", portal)

func _on_you_won() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://you_won.tscn")

func _criar_fronteiras() -> void:
	var cells := tilemap.get_used_cells()
	if cells.is_empty():
		return

	# Bounding box em coordenadas de tile
	var min_x := cells[0].x
	var max_x := cells[0].x
	var min_y := cells[0].y
	var max_y := cells[0].y
	for cell in cells:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)

	# Set de células com tile para lookup rápido O(1)
	var usadas := {}
	for cell in cells:
		usadas[cell] = true

	var tile_size := Vector2(tilemap.tile_set.tile_size) * tilemap.scale
	var half      := tile_size / 2.0

	# Um único StaticBody2D para todos os colisores internos
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask  = 0
	add_child(body)

	# Célula vazia dentro do bounding box = parede interna
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if not usadas.has(Vector2i(x, y)):
				var local_pos := to_local(tilemap.to_global(tilemap.map_to_local(Vector2i(x, y))))
				var shape     := CollisionShape2D.new()
				var rect      := RectangleShape2D.new()
				rect.size      = tile_size
				shape.shape    = rect
				shape.position = local_pos
				body.add_child(shape)

	# 4 paredes externas ao redor do bounding box
	var tl   := to_local(tilemap.to_global(tilemap.map_to_local(Vector2i(min_x, min_y)))) - half
	var br   := to_local(tilemap.to_global(tilemap.map_to_local(Vector2i(max_x, max_y)))) + half
	var esq  := tl.x
	var dir  := br.x
	var cima := tl.y
	var baixo := br.y
	var larg := dir - esq
	var alt  := baixo - cima
	var t    := tile_size.x
	var cx   := (esq + dir) / 2.0
	var cy   := (cima + baixo) / 2.0

	var bordas := [
		[Vector2(esq  - t / 2.0, cy),   Vector2(t, alt + t * 2.0)],
		[Vector2(dir  + t / 2.0, cy),   Vector2(t, alt + t * 2.0)],
		[Vector2(cx, cima  - t / 2.0),  Vector2(larg + t * 2.0, t)],
		[Vector2(cx, baixo + t / 2.0),  Vector2(larg + t * 2.0, t)],
	]

	for b in bordas:
		var parede  := StaticBody2D.new()
		parede.collision_layer = 1
		parede.collision_mask  = 0
		parede.position        = b[0]
		var shape := CollisionShape2D.new()
		var rect  := RectangleShape2D.new()
		rect.size   = b[1]
		shape.shape = rect
		parede.add_child(shape)
		add_child(parede)
