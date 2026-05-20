extends Area2D

func _ready() -> void:
	collision_layer = 32
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 28.0, Color(0.4, 0.0, 0.8, 0.7))
	draw_circle(Vector2.ZERO, 18.0, Color(0.8, 0.4, 1.0, 0.9))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().reload_current_scene()
