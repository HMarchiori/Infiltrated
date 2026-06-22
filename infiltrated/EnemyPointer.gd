extends Node2D

## Seta que aparece após matar um inimigo e aponta para o inimigo vivo mais
## próximo, ajudando a localizar os últimos restantes. Deve ser filho do Player.

@export var radius: float = 60.0       # distância da seta até o jogador
@export var display_time: float = 3.0  # tempo visível após cada abate
@export var color: Color = Color(1.0, 0.85, 0.2)

var _timer: float = 0.0

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

	var alvo := _nearest_enemy()
	if alvo == null:
		visible = false
		_timer = 0.0
		return

	_timer -= delta
	visible = true
	rotation = (alvo.global_position - global_position).angle()
	queue_redraw()

func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var d := global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best = e
	return best

func _draw() -> void:
	# Triângulo apontando para +X local (o nó é rotacionado para o inimigo).
	var tip := Vector2(radius + 16.0, 0.0)
	var back_left := Vector2(radius, -9.0)
	var back_right := Vector2(radius, 9.0)
	draw_colored_polygon(PackedVector2Array([tip, back_left, back_right]), color)
