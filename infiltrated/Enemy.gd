extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK }

@export var speed: float = 80.0
@export var detection_range: float = 350.0
@export var attack_range: float = 220.0
@export var fire_rate: float = 2.0
@export var hp: int = 3
@export var bullet_scene: PackedScene

var state: State = State.IDLE
var player: Node2D = null
var _fire_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	_fire_timer = randf_range(0.5, fire_rate)

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
			elif dist > detection_range * 1.2:
				state = State.IDLE

		State.ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()
			_fire_timer -= delta
			if _fire_timer <= 0.0:
				_atirar()
				_fire_timer = fire_rate
			if dist > attack_range * 1.2:
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
