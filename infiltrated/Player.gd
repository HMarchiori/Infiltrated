extends CharacterBody2D

const SPEED := 200.0
const FIRE_RATE := 0.25

@export var bullet_scene: PackedScene

var _fire_timer: float = 0.0
var hp: int = 20

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = dir.normalized() * SPEED
	move_and_slide()

	_fire_timer -= delta
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _fire_timer <= 0.0:
		_shoot()
		_fire_timer = FIRE_RATE

func _shoot() -> void:
	if bullet_scene == null:
		return
	var bullet: Node2D = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.from_player = true
	get_tree().current_scene.add_child(bullet)

func receber_dano(dano: int) -> void:
	hp -= dano
	if hp <= 0:
		EventBus.jogador_morreu.emit()
		queue_free()
