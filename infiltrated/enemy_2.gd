extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK }

@export var speed: float = 120.0
@export var detection_range: float = 500.0
@export var attack_range: float = 70.0
@export var attack_rate: float = 1.0
@export var damage: int = 1
@export var hp: int = 2

var state: State = State.IDLE
var player: Node2D = null
var _attack_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	_attack_timer = randf_range(0.0, attack_rate)

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

			if dist < detection_range:
				state = State.CHASE

		State.CHASE:
			var dir := (player.global_position - global_position).normalized()
			velocity = dir * speed
			move_and_slide()

			if dist < attack_range:
				state = State.ATTACK

		State.ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()

			_attack_timer -= delta

			if _attack_timer <= 0.0:
				_atacar()
				_attack_timer = attack_rate

			if dist > attack_range * 1.2:
				state = State.CHASE

func _atacar() -> void:
	if player == null:
		return

	player.receber_dano(damage)

func receber_dano(dano: int) -> void:
	hp -= dano

	if hp <= 0:
		GameState.adicionar_pontos(150)
		EventBus.inimigo_morreu.emit()
		queue_free()
