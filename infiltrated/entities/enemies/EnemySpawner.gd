extends Node

@export var enemy_count: int = 30
@export var powerup_count: int = 15
@export var min_dist_from_player: float = 180.0

@export var ranged_enemy_scene: PackedScene
@export var melee_enemy_scene: PackedScene
@export var power_up_scene: PackedScene
@export var health_power_up_scene: PackedScene

var alive_count: int = 0

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)

func spawn() -> void:
	# Only enemies count toward clearing the room; power-ups do not.
	alive_count = enemy_count

	var positions := _get_spawn_positions(powerup_count + enemy_count)

	for i in powerup_count:
		var scene: PackedScene
		if randf() < 0.4:
			scene = health_power_up_scene
		else:
			scene = power_up_scene

		if scene == null:
			push_error("PowerUP: power_up scene not configured")
			return

		var power_up: Node2D = scene.instantiate()
		power_up.global_position = positions[enemy_count + i]
		get_parent().add_child(power_up)

	for i in enemy_count:
		var scene: PackedScene
		if randf() < 0.7:
			scene = ranged_enemy_scene
		else:
			scene = melee_enemy_scene

		if scene == null:
			push_error("EnemySpawner: enemy scene not configured")
			return

		var enemy: Node2D = scene.instantiate()
		enemy.global_position = positions[i]
		get_parent().add_child(enemy)


func _get_spawn_positions(count: int) -> Array[Vector2]:
	var tilemap := get_parent().get_node("Floor") as TileMapLayer
	var spawn_marker := get_parent().get_node("SpawnPoint") as Marker2D
	var player_pos := spawn_marker.global_position if spawn_marker else Vector2.ZERO

	# Solid layers: no spawn may land on a wall or decoration.
	var blockers: Array[TileMapLayer] = []
	for layer_name in ["Walls", "Decoration"]:
		var layer := get_parent().get_node_or_null(layer_name) as TileMapLayer
		if layer:
			blockers.append(layer)

	var cells := tilemap.get_used_cells()
	cells.shuffle()

	var result: Array[Vector2] = []
	for cell in cells:
		var world_pos := tilemap.to_global(tilemap.map_to_local(cell))
		if _is_blocked(world_pos, blockers):
			continue
		if world_pos.distance_to(player_pos) >= min_dist_from_player:
			result.append(world_pos)
			if result.size() >= count:
				break

	# Fallback in case the map does not have enough valid cells: scatter the
	# remaining spawns around the parent instead of stacking them on one point.
	if result.size() < count:
		push_warning("EnemySpawner: only %d/%d valid spawn cells found" % [result.size(), count])
		while result.size() < count:
			var angle := randf() * TAU
			var dist := randf_range(min_dist_from_player, min_dist_from_player + 200.0)
			result.append(get_parent().global_position + Vector2.from_angle(angle) * dist)

	return result

func _is_blocked(world_pos: Vector2, layers: Array[TileMapLayer]) -> bool:
	for layer in layers:
		var c: Vector2i = layer.local_to_map(layer.to_local(world_pos))
		if layer.get_cell_source_id(c) != -1:
			return true
	return false

func _on_enemy_died() -> void:
	alive_count -= 1
	if alive_count <= 0:
		EventBus.room_cleared.emit()
