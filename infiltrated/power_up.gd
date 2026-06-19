extends Area2D

enum PowerUPType {
	FIRE_RATE,
	LIFE,
}

@export var power_up_type: int = PowerUPType.FIRE_RATE
@export var health_amount: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	match power_up_type:
		PowerUPType.FIRE_RATE:
			EventBus.powerUP.emit()
		PowerUPType.LIFE:
			body.hp += health_amount
			EventBus.jogador_hp_alterado.emit(body.hp)

	queue_free()
