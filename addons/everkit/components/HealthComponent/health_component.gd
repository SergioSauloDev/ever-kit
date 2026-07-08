## A reusable component that manages an entity's health.
##
## The HealthComponent provides a simple API for taking damage,
## healing, killing, and reviving an entity. It is completely
## independent from visuals, animations, or game logic, making
## it suitable for players, enemies, NPCs, destructible objects,
## and other gameplay elements.
##
## Example:
## [codeblock]
## var health := HealthComponent.new()
##
## health.damage(25)
## health.heal(10)
##
## if health.is_alive():
##     print("Still alive!")
## [/codeblock]
@tool
@icon("res://addons/everkit/components/HealthComponent/icon.svg")
class_name HealthComponent extends Node

## The maximum amount of health this component can have.
##
## Changing this value automatically clamps the current health
## so it never exceeds the new maximum.
@export_range(10.0, 200)
var max_health: float = 60.0:
	set(value):
		max_health = value

		if !infinite_health:
			current_health = min(current_health, max_health)

		health_changed.emit(current_health, max_health)

## The current amount of health.
##
## This value is automatically clamped between [code]0[/code]
## and [member max_health].
##
## Setting this property updates the dead state and emits
## [signal health_changed].
var current_health: float:
	set(value):
		current_health = clamp(value, 0, max_health)
		is_dead = current_health <= 0
		health_changed.emit(current_health, max_health)

## If enabled, the component starts with full health.
##
## Otherwise, it starts with the value defined by
## [member start_health].
@export
var start_full_health := true:
	set(value):
		start_full_health = value
		notify_property_list_changed()

## The initial health when [member start_full_health]
## is disabled.
@export
var start_health: float:
	set(value):
		start_health = clamp(value, 0.0, max_health)

## Allows this component to receive healing.
@export
var can_heal := true

## Prevents this component from receiving damage.
@export
var invulnerable := false

## If enabled, this component ignores all incoming damage.
@export
var infinite_health: bool:
	set(value):
		infinite_health = value
		notify_property_list_changed()

## Returns whether this component is currently dead.
var is_dead := false:
	set(value):
		if is_dead == value:
			return

		is_dead = value

		if value:
			dead.emit()
		else:
			revived.emit()

## Emitted whenever the current health changes.
##
## Parameters:
## - current_health: The new health value.
## - max_health: The current maximum health.
signal health_changed(current_health: float, max_health: float)

## Emitted after taking damage.
##
## Parameter:
## - amount: The actual amount of damage received.
signal damaged(amount: float)

## Emitted after being healed.
##
## Parameter:
## - amount: The actual amount of health restored.
signal healed(amount: float)

## Emitted when the component is revived.
signal revived

## Emitted when the component dies.
signal dead

func _ready() -> void:
	reset_health()

## Restores the starting health.
##
## If [member start_full_health] is enabled,
## health is restored to [member max_health].
## Otherwise, it is restored to [member start_health].
func reset_health() -> void:
	if start_full_health:
		current_health = max_health
	else:
		current_health = start_health

## Restores health.
##
## Does nothing if the component is dead or healing
## has been disabled.
##
## Example:
## [codeblock]
## health.heal(20)
## [/codeblock]
func heal(amount: float) -> void:
	if is_dead or !can_heal:
		return

	var old_health := current_health

	current_health += amount

	var healed_amount := current_health - old_health

	if healed_amount > 0:
		healed.emit(healed_amount)

## Returns the current health percentage
## as a value between [code]0.0[/code] and [code]1.0[/code].
##
## Example:
## [codeblock]
## var percent := health.get_health_percent()
## [/codeblock]
func get_health_percent() -> float:
	return current_health / max_health

## Returns [code]true[/code] if this component is alive.
func is_alive() -> bool:
	return !is_dead

## Instantly kills the component.
##
## Has no effect if [member infinite_health] is enabled.
func kill() -> void:
	if infinite_health:
		return

	is_dead = true
	current_health = 0

## Revives the component and restores
## its health to the maximum value.
func revive() -> void:
	if !is_dead:
		return

	is_dead = false
	current_health = max_health

## Sets the current health directly.
##
## The value is automatically clamped between
## [code]0[/code] and [member max_health].
func set_health(value: float) -> void:
	current_health = value

	is_dead = current_health <= 0

## Applies damage to the component.
##
## Does nothing if the component is dead,
## invulnerable, or has infinite health.
##
## Example:
## [codeblock]
## health.damage(15)
## [/codeblock]
func apply_damage(damage: float) -> void:
	if is_dead or invulnerable or infinite_health:
		return

	var old_health := current_health

	current_health -= damage

	var damage_amount := old_health - current_health

	damaged.emit(damage_amount)

func _validate_property(property: Dictionary) -> void:
	if start_full_health:
		if property.name == "start_health":
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if infinite_health:
		if property.name == "max_health":
			property.usage = PROPERTY_USAGE_NO_EDITOR
