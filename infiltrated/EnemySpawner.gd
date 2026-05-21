extends Node

@export var enemy_scene: PackedScene
@export var enemy_count: int = 6

var _vivos: int = 0

const POSICOES: Array = [
	Vector2(-220, -180),
	Vector2(220, -180),
	Vector2(-250,   50),
	Vector2(250,   50),
	Vector2(  0, -280),
	Vector2(-200,  220),
	Vector2(200,  220),
	Vector2(  0,  280),
]

func _ready() -> void:
	EventBus.inimigo_morreu.connect(_on_inimigo_morreu)

func spawnar(quantidade: int) -> void:
	_vivos = quantidade
	for i in quantidade:
		if enemy_scene == null:
			push_error("EnemySpawner: enemy_scene não configurada")
			return
		var inimigo: Node2D = enemy_scene.instantiate()
		inimigo.global_position = get_parent().global_position + POSICOES[i % POSICOES.size()]
		get_parent().add_child(inimigo)

func _on_inimigo_morreu() -> void:
	_vivos -= 1
	if _vivos <= 0:
		EventBus.sala_limpa.emit()
