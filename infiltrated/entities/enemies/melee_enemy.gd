extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK }

@export var speed: float = 150.0
@export var detection_range: float = 400.0
@export var attack_range: float = 50.0
@export var attack_rate: float = 1.0
@export var damage: int = 1
@export var hp: int = 2
@export var invincibility_duration: float = 0.25

var state: State = State.IDLE
var player: Node2D = null
var _attack_timer: float = 0.0
var _invincible: bool = false
var _invincibility_timer: float = 0.0
var _blink_timer: float = 0.1

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
				_attack()
				_attack_timer = attack_rate

			if dist > attack_range * 1.2:
				state = State.CHASE

	if _invincible:
		_invincibility_timer -= delta
		_blink_timer -= delta
		if _blink_timer <= 0.0:
			_blink_timer = 0.1
			modulate.a = 0.3 if modulate.a > 0.5 else 1.0
		if _invincibility_timer <= 0.0:
			_invincible = false
			modulate.a = 1.0

func _attack() -> void:
	if player == null:
		return

	player.take_damage(damage)

func take_damage(amount: int) -> void:
	if _invincible:
		return
	hp -= amount
	if hp <= 0:
		GameState.add_points(150)
		EventBus.enemy_died.emit()
		queue_free()
		return
	_invincible = true
	_invincibility_timer = invincibility_duration
