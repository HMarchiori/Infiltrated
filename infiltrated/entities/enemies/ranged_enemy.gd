class_name RangedEnemy
extends EnemyBase

## Enemy that shoots projectiles from range and backs away (kites) when the
## player gets too close, instead of standing still next to them.

@export var fire_rate: float = 2.0
@export var bullet_scene: PackedScene
@export var kite_range: float = 150.0   # retreat if the player is closer than this

var _fire_timer: float = 0.0

func _on_ready() -> void:
	_fire_timer = randf_range(0.6, fire_rate)

func _attack_state(delta: float, dist: float) -> void:
	# Keep distance while shooting: retreat when the player is too close.
	if dist < kite_range:
		velocity = (global_position - player.global_position).normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_shoot()
		_fire_timer = fire_rate

func _shoot() -> void:
	if bullet_scene == null or player == null:
		return
	var bullet: Node2D = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.from_player = false
	get_tree().current_scene.add_child(bullet)
