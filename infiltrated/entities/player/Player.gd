class_name Player
extends CharacterBody2D

@export var speed: float = 250.0
@export var fire_rate: float = 0.35
@export var hp: int = 5
@export var bullet_scene: PackedScene
@export var invincibility_duration: float = 2.0

var _invincible: bool = false
var _invincibility_timer: float = 0.0
var _fire_timer: float = 0.0
var _last_dir: Vector2 = Vector2.DOWN

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	EventBus.player_hp_changed.emit(hp)
	EventBus.speed_powerup_collected.connect(_on_speed_powerup)


func _physics_process(delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = dir.normalized() * speed
	move_and_slide()

	if dir != Vector2.ZERO:
		_last_dir = dir.normalized()
		_sprite.play(_dir_to_anim(_last_dir))
	else:
		_sprite.stop()

	_fire_timer -= delta

	if Input.is_action_pressed("ui_accept") and _fire_timer <= 0.0:
		_shoot()
		_fire_timer = fire_rate

	if _invincible:
		_invincibility_timer -= delta
		if _invincibility_timer <= 0.0:
			_invincible = false

func _dir_to_anim(dir: Vector2) -> StringName:
	var angle := rad_to_deg(dir.angle())
	if angle < 0:
		angle += 360.0
	# angle 0=E, 45=SE, 90=S, 135=SW, 180=W, 225=NW, 270=N, 315=NE
	if angle < 22.5 or angle >= 337.5:
		return &"walk_e"
	elif angle < 67.5:
		return &"walk_se"
	elif angle < 112.5:
		return &"walk_s"
	elif angle < 157.5:
		return &"walk_sw"
	elif angle < 202.5:
		return &"walk_w"
	elif angle < 247.5:
		return &"walk_nw"
	elif angle < 292.5:
		return &"walk_n"
	else:
		return &"walk_ne"

func _shoot() -> void:
	if bullet_scene == null:
		return
	var bullet: Node2D = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = _last_dir
	bullet.from_player = true
	bullet.speed = speed + 150
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int) -> void:
	if _invincible:
		return
	hp -= amount
	EventBus.player_hp_changed.emit(hp)
	if hp <= 0:
		EventBus.player_died.emit()
		queue_free()
		return
	_invincible = true
	_invincibility_timer = invincibility_duration
	EventBus.player_damaged.emit()

func _on_speed_powerup() -> void:
	speed = min(450.0, speed + 30.0)
