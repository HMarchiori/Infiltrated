class_name Projectile
extends Area2D

@export var speed: float = 450
@export var lifetime: float = 2.5
@export var damage: int = 1
@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.RIGHT
var from_player: bool = true

var _elapsed: float = 0.0
var _exploding: bool = false

func _ready() -> void:
	music.play()
	if from_player:
		collision_layer = Layers.PLAYER_PROJECTILE
		collision_mask = Layers.ENEMY | Layers.ENVIRONMENT
	else:
		collision_layer = Layers.ENEMY_PROJECTILE
		collision_mask = Layers.PLAYER | Layers.ENVIRONMENT
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
		body.take_damage(damage)
		_start_explode()
	elif not from_player and body.is_in_group("player"):
		body.take_damage(damage)
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
