extends Area2D

@export var speed: float = 450.0
@export var lifetime: float = 2.5
@export var dano: int = 1
@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.RIGHT
var from_player: bool = true

var _elapsed: float = 0.0
var _exploding: bool = false

func _ready() -> void:
	music.play()
	if from_player:
		collision_layer = 8
		collision_mask = 4 | 1
	else:
		collision_layer = 16
		collision_mask = 2 | 1
	body_entered.connect(_on_body_entered)

	_sprite.rotation = direction.angle()
	_sprite.play("fly")
	_sprite.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if _exploding:
		return
	position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if _exploding:
		return
	if from_player and body.is_in_group("enemies"):
		body.receber_dano(dano)
		_start_explode()
	elif not from_player and body.is_in_group("player"):
		body.receber_dano(dano)
		_start_explode()
	elif body is StaticBody2D or body is TileMapLayer:
		_start_explode()

func _start_explode() -> void:
	_exploding = true
	set_deferred("monitoring", false)
	_sprite.play("explode")

func _on_animation_finished() -> void:
	if _sprite.animation == &"explode":
		queue_free()
