class_name MeleeEnemy
extends EnemyBase

## Enemy that chases the player and deals contact damage on a fixed cadence.

@export var attack_rate: float = 1.0
@export var damage: int = 1

var _attack_timer: float = 0.0

func _on_ready() -> void:
	_attack_timer = randf_range(0.0, attack_rate)

func _attack_state(delta: float, _dist: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()

	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack()
		_attack_timer = attack_rate

func _attack() -> void:
	if player == null:
		return
	player.take_damage(damage)
