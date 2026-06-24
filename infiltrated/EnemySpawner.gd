extends Node

@export var enemy_count: int = 30
@export var powerUP_count: int = 15
@export var min_dist_from_player: float = 180.0

@export var ranged_enemy_scene: PackedScene
@export var melee_enemy_scene: PackedScene
@export var power_up_scene: PackedScene
@export var health_power_up_scene: PackedScene

var vivos: int = 0

func _ready() -> void:
	EventBus.inimigo_morreu.connect(_on_inimigo_morreu)

func spawnar(quantidade: int) -> void:
	# Só inimigos contam para limpar a sala; power-ups não.
	vivos = enemy_count

	var posicoes := _get_spawn_positions(powerUP_count + enemy_count)
	
	for i in powerUP_count:
		var cena: PackedScene
		if randf() < 0.4 :
			cena = health_power_up_scene
		else:
			cena = power_up_scene

		if cena == null:
			push_error("PowerUP: cena de power_up não configurada")
			return

		var power_ups: Node2D = cena.instantiate()
		power_ups.global_position = posicoes[enemy_count + i]
		get_parent().add_child(power_ups)
	

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
	var tilemap := get_parent().get_node("Floor") as TileMapLayer
	var spawn_marker := get_parent().get_node("SpawnPoint") as Marker2D
	var player_pos := spawn_marker.global_position if spawn_marker else Vector2.ZERO

	# Camadas sólidas: nenhum spawn pode cair sobre uma parede ou decoração.
	var bloqueadores: Array[TileMapLayer] = []
	for layer_name in ["Walls", "Decoration"]:
		var layer := get_parent().get_node_or_null(layer_name) as TileMapLayer
		if layer:
			bloqueadores.append(layer)

	var cells := tilemap.get_used_cells()
	cells.shuffle()

	var result: Array[Vector2] = []
	for cell in cells:
		var world_pos := tilemap.to_global(tilemap.map_to_local(cell))
		if _esta_bloqueado(world_pos, bloqueadores):
			continue
		if world_pos.distance_to(player_pos) >= min_dist_from_player:
			result.append(world_pos)
			if result.size() >= count:
				break

	# Fallback caso o mapa não tenha células suficientes
	while result.size() < count:
		result.append(get_parent().global_position)

	return result

func _esta_bloqueado(world_pos: Vector2, layers: Array[TileMapLayer]) -> bool:
	for layer in layers:
		var c: Vector2i = layer.local_to_map(layer.to_local(world_pos))
		if layer.get_cell_source_id(c) != -1:
			return true
	return false

func _on_inimigo_morreu() -> void:
	vivos -= 1
	if vivos <= 0:
		EventBus.sala_limpa.emit()
