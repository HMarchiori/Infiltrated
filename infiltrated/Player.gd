extends CharacterBody2D

@export var speed: float = 200.0
@export var fire_rate: float = 0.1
@export var hp: int = 3
@export var bullet_scene: PackedScene
@export var invincibility_duration: float = 2

var _invincible: bool = false
var _invincibility_timer: float = 0.0
var _blink_timer: float = 0.1
var _fire_timer: float = 0.0
var _last_dir: Vector2 = Vector2.DOWN

func _ready() -> void:
	add_to_group("player")
	EventBus.jogador_hp_alterado.emit(hp)

func _physics_process(delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = dir.normalized() * speed
	move_and_slide()

	if dir != Vector2.ZERO:
		_last_dir = dir.normalized()

	_fire_timer -= delta

	if Input.is_action_pressed("ui_accept") and _fire_timer <= 0.0:
		_shoot()
		_fire_timer = fire_rate

	if _invincible:
		_invincibility_timer -= delta
		_blink_timer -= delta
		if _blink_timer <= 0.0:
			_blink_timer = 0.1
			modulate.a = 0.3 if modulate.a > 0.5 else 1.0
		if _invincibility_timer <= 0.0:
			_invincible = false
			modulate.a = 1.0

func _shoot() -> void:
	if bullet_scene == null:
		return
	var bullet: Node2D = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = _last_dir
	bullet.from_player = true
	get_tree().current_scene.add_child(bullet)

func receber_dano(dano: int) -> void:
	if _invincible:
		return
	hp -= dano
	EventBus.jogador_hp_alterado.emit(hp)
	if hp <= 0:
		EventBus.jogador_morreu.emit()
		queue_free()
		return
	_invincible = true
	_invincibility_timer = invincibility_duration
