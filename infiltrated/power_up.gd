extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.fire_rate = max(0.07, body.fire_rate - 0.06)
		print("sla")
		queue_free()
