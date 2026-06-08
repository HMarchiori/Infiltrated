extends Node

@export var enemy_count: int = 20
@export var min_dist_from_player: float = 180.0

@export var ranged_enemy_scene: PackedScene
@export var melee_enemy_scene: PackedScene

var _vivos: int = 0

func _ready() -> void:
	EventBus.inimigo_morreu.connect(_on_inimigo_morreu)

func spawnar(quantidade: int) -> void:
	_vivos = quantidade
	var posicoes := _get_spawn_positions(quantidade)

	for i in quantidade:
		var cena: PackedScene

		if randf() < 0.7:
			cena = ranged_enemy_scene
		else:
			cena = melee_enemy_scene

		if cena == null:
			push_error("EnemySpawner: cena de inimigo não configurada")
			return

		var inimigo: Node2D = cena.instantiate()
		inimigo.global_position = posicoes[i]
		get_parent().add_child(inimigo)
		
func _get_spawn_positions(count: int) -> Array[Vector2]:
	var tilemap := get_parent().get_node("TileMapLayer") as TileMapLayer
	var spawn_marker := get_parent().get_node("SpawnPoint") as Marker2D
	var player_pos := spawn_marker.global_position if spawn_marker else Vector2.ZERO

	var cells := tilemap.get_used_cells()
	cells.shuffle()

	var result: Array[Vector2] = []
	for cell in cells:
		var world_pos := tilemap.to_global(tilemap.map_to_local(cell))
		if world_pos.distance_to(player_pos) >= min_dist_from_player:
			result.append(world_pos)
			if result.size() >= count:
				break

	# Fallback caso o mapa não tenha células suficientes
	while result.size() < count:
		result.append(get_parent().global_position)

	return result

func _on_inimigo_morreu() -> void:
	_vivos -= 1
	if _vivos <= 0:
		EventBus.sala_limpa.emit()
