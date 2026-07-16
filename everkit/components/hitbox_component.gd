@tool
## A reusable component that represents an attack hitbox.
##
## A HitboxComponent detects [HurtboxComponent]s and applies damage to them.
## It can attack automatically when a hurtbox enters its collision area or
## manually through [method apply_hit].
##
## This component is designed to work together with [HurtboxComponent] and
## [HealthComponent] as part of the EverKit combat system.
##
## Features:
## - Automatic or manual attacks.
## - Single-target or multi-target attacks.
## - Optional one-hit-per-overlap behavior.
## - Configurable attacker reference.
## - Built-in signals for combat events.
##
## Basic setup:
## [codeblock]
## Player
## ├── Sprite2D
## ├── HurtboxComponent
## └── Sword
##     └── HitboxComponent
## [/codeblock]
##
## Manual attack example:
## [codeblock]
## hitbox.apply_hit(enemy_hurtbox)
## [/codeblock]
##
## Automatic attack example:
## [codeblock]
## hitbox.auto_attack = true
## [/codeblock]
@icon("res://addons/everkit/icons/hitbox.svg")
class_name HitboxComponent extends Area2D

# CONFIG

## Enables or disables this hitbox.
##
## When disabled, the hitbox cannot damage any target.
##
## This value is automatically updated by [method enable] and
## [method disable].
##
## Example:
## [codeblock]
## hitbox.enabled = false
## [/codeblock]
@export var enabled: bool = true

## Amount of damage applied to every successful hit.
##
## The value is automatically clamped between 1 and 20.
##
## Example:
## [codeblock]
## hitbox.damage = 10
## [/codeblock]
##
## Damage boost example:
## [codeblock]
## hitbox.damage *= 2
## [/codeblock]
@export_range(1.0, 20.0) var damage: float = 5.0:
	set(value):
		damage = clamp(value, 1.0, 20.0)

## If enabled, the hitbox attacks automatically whenever a
## [HurtboxComponent] enters its collision area.
##
## If disabled, attacks must be performed manually using
## [method apply_hit].
##
## Example:
## [codeblock]
## hitbox.auto_attack = true
## [/codeblock]
@export var auto_attack: bool = false

## Allows the hitbox to damage multiple hurtboxes at the same time.
##
## When disabled, only the hurtbox that triggered the collision
## will be attacked.
##
## Example:
## [codeblock]
## hitbox.can_hit_multiple = true
## [/codeblock]
@export var can_hit_multiple: bool = false

## Prevents the same hurtbox from being damaged multiple times
## while remaining inside this hitbox.
##
## When enabled, a target must leave the hitbox before it can
## receive damage again.
##
## Example:
## [codeblock]
## hitbox.hit_once_per_overlap = true
## [/codeblock]
@export var hit_once_per_overlap: bool = true

## Node considered as the attacker.
##
## If left empty, the parent node is automatically assigned
## during [method _ready].
##
## Usually this is the player, enemy or weapon owner.
##
## Example:
## [codeblock]
## hitbox.attacker = player
## [/codeblock]
@export var attacker: Node:
	set(value):
		attacker = value
		if attacker == null:
			attacker = get_parent()

## Stores hurtboxes that have already been damaged while
## [member hit_once_per_overlap] is enabled.
##
## This array is managed automatically.
var _hit_targets: Array[HurtboxComponent] = []

# SIGNALS

## Emitted whenever a hurtbox is successfully hit.
##
## Example:
## [codeblock]
## hitbox.hit.connect(_on_hit)
##
## func _on_hit(hurtbox):
##     print("Enemy hit!")
## [/codeblock]
signal hit(hurtbox: HurtboxComponent)

## Emitted after damage has been applied.
##
## Parameters:
## - hurtbox: The hurtbox that received damage.
## - damage: Damage value applied.
##
## Example:
## [codeblock]
## hitbox.damage_applied.connect(_on_damage)
## [/codeblock]
signal damage_applied(hurtbox: HurtboxComponent, damage: float)

## Reserved for future combat mechanics such as shields,
## invulnerability or parries.
signal blocked(hurtbox: HurtboxComponent)

## Initializes the component.
##
## Connects internal signals and automatically assigns
## the attacker if none has been specified.
func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

	if not area_exited.is_connected(_on_area_exited):
		area_exited.connect(_on_area_exited)

	if attacker == null:
		attacker = get_parent()

## Enables the hitbox.
##
## This also enables collision monitoring.
##
## Example:
## [codeblock]
## hitbox.enable()
## [/codeblock]
func enable() -> void:
	enabled = true
	monitoring = true

## Disables the hitbox.
##
## This also disables collision monitoring.
##
## Example:
## [codeblock]
## hitbox.disable()
## [/codeblock]
func disable() -> void:
	enabled = false
	monitoring = false

## Returns whether the specified hurtbox can currently be hit.
##
## Returns [code]false[/code] if:
## - The hitbox is disabled.
## - The hurtbox has already been hit and
##   [member hit_once_per_overlap] is enabled.
##
## Example:
## [codeblock]
## if hitbox.can_hit(enemy_hurtbox):
##     print("Target can be damaged.")
## [/codeblock]
func can_hit(hurtbox: HurtboxComponent) -> bool:
	if not enabled:
		return false

	if hit_once_per_overlap and hurtbox in _hit_targets:
		return false

	return true

## Clears every stored hurtbox.
##
## Useful when restarting an attack animation or
## reusing the hitbox.
##
## Example:
## [codeblock]
## hitbox.clear_hit_targets()
## [/codeblock]
func clear_hit_targets() -> void:
	_hit_targets.clear()

## Applies damage to the specified hurtbox.
##
## This method performs all hit validation before
## damaging the target.
##
## It emits:
## - [signal hit]
## - [signal damage_applied]
##
## Example:
## [codeblock]
## hitbox.apply_hit(enemy_hurtbox)
## [/codeblock]
func apply_hit(hurtbox: HurtboxComponent) -> void:
	if not can_hit(hurtbox):
		return

	if hit_once_per_overlap:
		_hit_targets.append(hurtbox)

	hurtbox.receive_hit(damage, attacker)

	hit.emit(hurtbox)
	damage_applied.emit(hurtbox, damage)

## Called whenever an area exits this hitbox.
##
## Removes the hurtbox from the internal cache so it
## can be damaged again.
func _on_area_exited(area: Node2D) -> void:
	if area is HurtboxComponent:
		_hit_targets.erase(area)

## Called whenever an area enters this hitbox.
##
## If [member auto_attack] is enabled, damage is applied
## automatically.
##
## When [member can_hit_multiple] is enabled, every
## overlapping hurtbox is attacked.
func _on_area_entered(area: Node2D) -> void:
	if not auto_attack:
		return

	if can_hit_multiple:
		for target in get_overlapping_areas():
			if target is HurtboxComponent:
				apply_hit(target)
	else:
		if area is HurtboxComponent:
			apply_hit(area)
