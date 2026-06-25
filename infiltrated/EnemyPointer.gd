extends Node2D

## Guide that appears after killing an enemy: for each living enemy it draws an
## arc on an imaginary circle around the player, pointing toward each one for a
## brief moment. Must be a child of the Player.

@export var radius: float = 60.0          # radius of the imaginary circle
@export var max_arrows: int = 3           # how many nearest enemies to indicate
@export var display_time: float = 2.5     # time visible after each kill
@export var arc_span_deg: float = 18.0    # angular width of each arc
@export var thickness: float = 6.0        # arc thickness
@export var color: Color = Color(0.708, 0.184, 0.243, 1.0)

var _timer: float = 0.0
var _angles: PackedFloat32Array = PackedFloat32Array()

func _ready() -> void:
	visible = false
	z_index = 100
	EventBus.enemy_died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	# Restart the countdown on each kill.
	_timer = display_time

func _process(delta: float) -> void:
	if _timer <= 0.0:
		visible = false
		return

	_angles = _enemy_angles()
	if _angles.is_empty():
		visible = false
		_timer = 0.0
		return

	_timer -= delta
	visible = true
	queue_redraw()

func _enemy_angles() -> PackedFloat32Array:
	# Collect (distance, angle) of living enemies and keep only the nearest ones.
	var enemies: Array = []
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var offset: Vector2 = e.global_position - global_position
		# Subtract global_rotation so it stays correct even if the parent rotates.
		enemies.append({"dist": offset.length(), "ang": offset.angle() - global_rotation})

	enemies.sort_custom(func(a, b): return a.dist < b.dist)

	var result := PackedFloat32Array()
	for i in mini(max_arrows, enemies.size()):
		result.append(enemies[i].ang)
	return result

func _draw() -> void:
	# Fade out smoothly as the remaining time runs out.
	var alpha := clampf(_timer / display_time, 0.0, 1.0)
	var c := Color(color.r, color.g, color.b, color.a * alpha)
	var half := deg_to_rad(arc_span_deg) * 0.5
	for ang in _angles:
		draw_arc(Vector2.ZERO, radius, ang - half, ang + half, 12, c, thickness, true)
