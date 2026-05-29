extends CharacterBody2D

@export var speed: float = 200.0
@export var fire_rate: float = 0.25
@export var hp: int = 3
@export var bullet_scene: PackedScene

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
	if Input.is_action_just_pressed("ui_accept") and _fire_timer <= 0.0:
		_shoot()
		_fire_timer = fire_rate

func _shoot() -> void:
	if bullet_scene == null:
		return
	var bullet: Node2D = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = _last_dir
	bullet.from_player = true
	get_tree().current_scene.add_child(bullet)

func receber_dano(dano: int) -> void:
	hp -= dano
	EventBus.jogador_hp_alterado.emit(hp)
	if hp <= 0:
		EventBus.jogador_morreu.emit()
		queue_free()
