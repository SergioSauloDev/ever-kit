@tool
@icon("res://addons/everkit/icons/hurtbox.svg")
class_name HurtboxComponent extends Area2D

## A component responsible for receiving incoming hits and forwarding
## the damage to an assigned HealthComponent.
##
## The HurtboxComponent does not perform collision detection itself.
## Instead, it exposes the receive_hit() method, which is typically
## called by a HitboxComponent when a collision occurs.
##
## Features:
## • Receives damage from external sources.
## • Applies damage to a HealthComponent.
## • Can be enabled or disabled at runtime.
## • Emits a signal whenever a valid hit is received.
##
## Example:
## ```gdscript
## hitbox.hit_detected.connect(func(target):
## 	target.receive_hit(10.0, self)
## )
## ```
##
## See also:
## - HealthComponent
## - HitboxComponent

@export var health_component: HealthComponent:
	set(value):
		health_component = value
		update_configuration_warnings()

## Enables or disables this Hurtbox.
##
## When disabled, incoming hits are ignored.
@export var enabled: bool = true:
	set(value):
		enabled = value
		monitoring = value

## Emitted after a valid hit has been processed.
##
## Parameters:
## • amount: Damage applied.
## • source: Node that caused the hit.
signal hit_received(amount: float, source: Node)

func _ready():
	if Engine.is_editor_hint():
		return

	if not is_instance_valid(health_component):
		push_warning("HurtboxComponent has no HealthComponent assigned.")

## Receives an incoming hit.
##
## If the Hurtbox is enabled and a valid HealthComponent exists,
## the damage is applied and the hit_received signal is emitted.
##
## Parameters:
## • amount: Amount of damage to apply.
## • source: Node responsible for the hit.
func receive_hit(amount: float, source: Node) -> void:
	if not _can_receive_hit():
		return

	if amount <= 0.0:
		return

	if not is_instance_valid(health_component):
		return

	health_component.apply_damage(amount)
	hit_received.emit(amount, source)

## Enables this Hurtbox.
##
## After calling this method, the Hurtbox can receive hits again.
func enable() -> void:
	enabled = true

## Disables this Hurtbox.
##
## While disabled, all incoming hits are ignored.
func disable() -> void:
	enabled = false

## Returns whether this Hurtbox is currently able to receive hits.
func _can_receive_hit() -> bool:
	return enabled and monitoring

## Displays warnings inside the Godot editor when the component
## is not properly configured.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if not is_instance_valid(health_component):
		warnings.append("HealthComponent is not assigned.")

	return warnings
