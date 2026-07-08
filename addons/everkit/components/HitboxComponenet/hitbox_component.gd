@tool
class_name HitboxComponent extends Area2D

# CONFIG
@export var enabled: bool = true

@export_range(1.0, 20.0) var damage: float = 5.0:
	set(value):
		damage = clamp(value, 1.0, 20.0)

@export var auto_attack: bool = false

@export var can_hit_multiple: bool = false

@export var hit_once_per_overlap: bool = true

@export_range(0.1, 1) var hit_time: float = 0.15

@export var attacker: Node = get_parent():
	set(value):
		attacker = value
		if attacker == null:
			attacker = get_parent()

var _hit_targets: Array[HurtboxComponent] = []

# SIGNALS
signal hit(hurtbox: HurtboxComponent)
signal damage_applied(hurtbox: HurtboxComponent, damage: float)
signal blocked(hurtbox: HurtboxComponent)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	if attacker == null:
		attacker = get_parent()

func enable() -> void:
	enabled = true
	monitoring = true

func disable() -> void:
	enabled = false
	monitoring = false

func clear_hit_targets():
	_hit_targets.clear()

func apply_hit(hurtbox: HurtboxComponent) -> void:
	if not enabled:
		return

	if hit_once_per_overlap:
		if hurtbox in _hit_targets:
			return

	_hit_targets.append(hurtbox)

	hurtbox.receive_hit(damage, attacker)
	hit.emit(hurtbox)
	damage_applied.emit(hurtbox, damage)

func _on_area_exited(area: Node2D) -> void:
	if area is HurtboxComponent:
		_hit_targets.erase(area)

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
