extends Area2D

@export var speed: float = 450.0
@export var lifetime: float = 2.5
@export var dano: int = 1
@onready var music: AudioStreamPlayer = $AudioStreamPlayer

var direction: Vector2 = Vector2.RIGHT
var from_player: bool = true

var _elapsed: float = 0.0

func _ready() -> void:
	music.play()
	if from_player:
		collision_layer = 8
		collision_mask = 4
	else:
		collision_layer = 16
		collision_mask = 2
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if from_player and body.is_in_group("enemies"):
		body.receber_dano(dano)
		queue_free()
	elif not from_player and body.is_in_group("player"):
		body.receber_dano(dano)
		queue_free()
