extends Area2D

enum PowerUPType {
	SPEED,
	LIFE,
}

@export var power_up_type: int = PowerUPType.SPEED
@export var health_amount: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	match power_up_type:
		PowerUPType.SPEED:
			EventBus.speed_powerup_collected.emit()
		PowerUPType.LIFE:
			body.hp += health_amount
			EventBus.player_hp_changed.emit(body.hp)

	queue_free()
