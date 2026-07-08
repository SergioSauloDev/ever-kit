@tool
class_name HurtboxComponent extends Area2D

@export var health_component: HealthComponent
@export var enabled: bool = true

signal hit_received(amount: float, source: Node)

func receive_hit(amount: float, source: Node) -> void:
	if not _can_receive_hit():
		return

	if is_instance_valid(health_component):
		health_component.apply_damage(amount)

	hit_received.emit(amount, source)

func set_enabled(value: bool) -> void:
	enabled = value

func _can_receive_hit() -> bool:
	return enabled
