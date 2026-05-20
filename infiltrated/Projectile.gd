extends Area2D

const SPEED := 450.0
const LIFETIME := 2.5

var direction: Vector2 = Vector2.RIGHT
var from_player: bool = true
var dano: int = 1

var _elapsed: float = 0.0

func _ready() -> void:
	if from_player:
		collision_layer = 8
		collision_mask = 4
	else:
		collision_layer = 16
		collision_mask = 2
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	var cor := Color(1.0, 0.9, 0.2) if from_player else Color(1.0, 0.3, 0.2)
	draw_circle(Vector2.ZERO, 5.0, cor)

func _process(delta: float) -> void:
	position += direction * SPEED * delta
	_elapsed += delta
	if _elapsed >= LIFETIME:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if from_player and body.is_in_group("enemies"):
		body.receber_dano(dano)
		queue_free()
	elif not from_player and body.is_in_group("player"):
		body.receber_dano(dano)
		queue_free()
