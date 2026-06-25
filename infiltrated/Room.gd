extends Node2D

@export var portal_scene: PackedScene

@onready var spawner: Node = $EnemySpawner
@onready var portal_spawn: Marker2D = $ExitPortalSpawnPoint

func _ready() -> void:
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.you_won.connect(_on_you_won)
	spawner.spawn(spawner.enemy_count)

func _on_room_cleared() -> void:
	if portal_scene == null:
		return
	var portal: Node2D = portal_scene.instantiate()
	portal.global_position = portal_spawn.global_position
	call_deferred("add_child", portal)

func _on_you_won() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://you_won.tscn")
