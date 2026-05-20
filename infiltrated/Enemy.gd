extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK }

const SPEED := 80.0
const DETECTION_RANGE := 350.0
const ATTACK_RANGE := 220.0
const FIRE_RATE := 2.0

@export var bullet_scene: PackedScene

var state: State = State.IDLE
var player: Node2D = null
var _fire_timer: float = 0.0
var hp: int = 3

func _ready() -> void:
	add_to_group("enemies")
	_fire_timer = randf_range(0.5, FIRE_RATE)

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var dist := global_position.distance_to(player.global_position)

	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()
			if dist < DETECTION_RANGE:
				state = State.CHASE

		State.CHASE:
			var dir := (player.global_position - global_position).normalized()
			velocity = dir * SPEED
			move_and_slide()
			if dist < ATTACK_RANGE:
				state = State.ATTACK
			elif dist > DETECTION_RANGE * 1.2:
				state = State.IDLE

		State.ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()
			_fire_timer -= delta
			if _fire_timer <= 0.0:
				_atirar()
				_fire_timer = FIRE_RATE
			if dist > ATTACK_RANGE * 1.2:
				state = State.CHASE

func _atirar() -> void:
	if bullet_scene == null or player == null:
		return
	var bullet: Node2D = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.from_player = false
	get_tree().current_scene.add_child(bullet)

func receber_dano(dano: int) -> void:
	hp -= dano
	if hp <= 0:
		GameState.adicionar_pontos(100)
		EventBus.inimigo_morreu.emit()
		queue_free()
