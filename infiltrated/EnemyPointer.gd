extends Node2D

## Guia que aparece após matar um inimigo: para cada inimigo vivo desenha um
## arco sobre um círculo imaginário ao redor do jogador, apontando a direção de
## cada um por um breve instante. Deve ser filho do Player.

@export var radius: float = 60.0          # raio do círculo imaginário
@export var max_arrows: int = 3           # quantos inimigos mais próximos indicar
@export var display_time: float = 2.5     # tempo visível após cada abate
@export var arc_span_deg: float = 18.0    # largura angular de cada arco
@export var thickness: float = 6.0        # espessura do arco
@export var color: Color = Color(0.708, 0.184, 0.243, 1.0)

var _timer: float = 0.0
var _angles: PackedFloat32Array = PackedFloat32Array()

func _ready() -> void:
	visible = false
	z_index = 100
	EventBus.inimigo_morreu.connect(_on_inimigo_morreu)

func _on_inimigo_morreu() -> void:
	# Reinicia a contagem a cada abate.
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
	# Coleta (distância, ângulo) dos inimigos vivos e mantém só os mais próximos.
	var enemies: Array = []
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var offset: Vector2 = e.global_position - global_position
		# Subtrai global_rotation para ficar correto mesmo se o pai girar.
		enemies.append({"dist": offset.length(), "ang": offset.angle() - global_rotation})

	enemies.sort_custom(func(a, b): return a.dist < b.dist)

	var result := PackedFloat32Array()
	for i in mini(max_arrows, enemies.size()):
		result.append(enemies[i].ang)
	return result

func _draw() -> void:
	# Some suavemente conforme o tempo restante acaba.
	var alpha := clampf(_timer / display_time, 0.0, 1.0)
	var c := Color(color.r, color.g, color.b, color.a * alpha)
	var half := deg_to_rad(arc_span_deg) * 0.5
	for ang in _angles:
		draw_arc(Vector2.ZERO, radius, ang - half, ang + half, 12, c, thickness, true)
