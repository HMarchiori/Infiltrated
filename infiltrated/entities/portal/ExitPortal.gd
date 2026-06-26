extends Area2D

func _ready() -> void:
	collision_layer = Layers.PICKUP
	collision_mask = Layers.PLAYER
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		EventBus.you_won.emit()
