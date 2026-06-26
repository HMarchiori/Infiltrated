class_name PowerUp
extends Area2D

enum PowerupType {
	SPEED,
	LIFE,
}

@export var power_up_type: PowerupType = PowerupType.SPEED
@export var health_amount: int = 1

func _ready() -> void:
	collision_layer = Layers.PICKUP
	collision_mask = Layers.PLAYER
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	match power_up_type:
		PowerupType.SPEED:
			EventBus.speed_powerup_collected.emit()
		PowerupType.LIFE:
			body.hp += health_amount
			EventBus.player_hp_changed.emit(body.hp)

	queue_free()
