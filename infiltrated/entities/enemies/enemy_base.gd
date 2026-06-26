class_name EnemyBase
extends CharacterBody2D

## Shared enemy behaviour: an IDLE → CHASE → ATTACK state machine plus damage,
## death scoring and invincibility frames. Subclasses override only the attack
## behaviour via [method _attack_state].

enum State { IDLE, CHASE, ATTACK }

@export var speed: float = 80.0
@export var detection_range: float = 400.0
@export var attack_range: float = 220.0
@export var hp: int = 2
@export var score_value: int = 100
@export var invincibility_duration: float = 0.25

var state: State = State.IDLE
var player: Node2D = null
var _invincible: bool = false
var _invincibility_timer: float = 0.0
var _blink_timer: float = 0.1

func _ready() -> void:
	add_to_group("enemies")
	_on_ready()

## Hook for subclass initialisation (replaces overriding _ready).
func _on_ready() -> void:
	pass

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
			_chase()
			if dist < attack_range:
				state = State.ATTACK
			elif dist > detection_range * 1.2:
				state = State.IDLE

		State.ATTACK:
			_attack_state(delta, dist)
			if dist > attack_range * 1.2:
				state = State.CHASE

	_update_invincibility(delta)

func _chase() -> void:
	var dir := (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

## Subclasses implement the attack behaviour (shooting, melee, kiting, …).
func _attack_state(_delta: float, _dist: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()

func take_damage(amount: int) -> void:
	if _invincible:
		return
	hp -= amount
	if hp <= 0:
		GameState.add_points(score_value)
		EventBus.enemy_died.emit()
		queue_free()
		return
	_invincible = true
	_invincibility_timer = invincibility_duration

func _update_invincibility(delta: float) -> void:
	if not _invincible:
		return
	_invincibility_timer -= delta
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink_timer = 0.1
		modulate.a = 0.3 if modulate.a > 0.5 else 1.0
	if _invincibility_timer <= 0.0:
		_invincible = false
		modulate.a = 1.0
