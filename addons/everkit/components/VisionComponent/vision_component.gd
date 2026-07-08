## VisionComponent detects a target inside a configurable vision cone
## and validates line of sight using a RayCast2D.
##
## This component is useful for AI enemies, NPCs, turrets, or any
## game object that needs to perceive one or multiple targets.
##
## Features:
## - Configurable vision angle and range.
## - Single and multiple target modes.
## - Optional target tracking.
## - Line-of-sight validation.
## - Debug visualization.
## - Detection and loss signals.
##
## Example:
## [codeblock]
## @onready var vision: VisionComponent = $VisionComponent
##
## func _ready() -> void:
## 	vision.target_detected.connect(_on_target_detected)
## 	vision.target_lost.connect(_on_target_lost)
##
## func _on_target_detected(target: Node2D) -> void:
## 	print("Target detected: ", target.name)
##
## func _on_target_lost(target: Node2D) -> void:
## 	print("Target lost: ", target.name)
## [/codeblock]
@tool
@icon("res://addons/everkit/components/VisionComponent/icon.svg")
class_name VisionComponent extends Node2D
## Vision cone angle in degrees.
##
## The value is clamped between 30 and 180 degrees.
@export_range(30.0, 180.0) var angle: float = 90.0:
	set(value):
		angle = clampf(value, 30.0, 180.0)
		queue_redraw()
		update_cone()

## Maximum detection distance.
@export_range(50.0, 500.0) var length: float = 100.0:
	set(value):
		length = value
		queue_redraw()

## Defines how the component searches for targets.
enum TargetMode {
	## Searches and tracks one target from a group.
	SINGLE,
	## Searches multiple groups and selects the closest visible target.
	MULTIPLE}

## Variable that defines the vision mode according
##to the [enum TargetMode] enum.
@export var target_mode := TargetMode.SINGLE:
	set(value):
		target_mode = value
		notify_property_list_changed()
		update_configuration_warnings()

## Group name used to search for a single target.
##
## The component will use the first node found inside this group.
@export var target_group: StringName:
	set(value):
		target_group = value
		update_configuration_warnings()

## Groups used when searching multiple targets.
##
## Every Node2D inside these groups will be considered
## as a possible target.
@export var target_groups: Array[StringName]:
	set(value):
		target_groups = value
		update_configuration_warnings()

## If enabled, the vision direction will automatically follow
## the target while it is visible.
@export var track_target := true

## Enables debug visualization of the vision cone.
##
## The cone will be drawn inside the editor and during runtime.
@export var debug_mode: bool = false:
	set(value):
		debug_mode = value
		notify_property_list_changed()
		queue_redraw()

## The color for the [member debug_mode]
@export var debug_color: Color = Color.DARK_RED:
	set(value):
		debug_color = value
		queue_redraw()

## Forward direction of the vision cone.
##
## Defines the initial looking direction.
@export var direction: Vector2 = Vector2.RIGHT:
	set(value):
		if value != Vector2.ZERO:direction = value.normalized()
		original_direction = direction
		queue_redraw()
## Original vision direction.
##
## Used to restore the initial direction when tracking ends.
@onready var original_direction: Vector2 = direction

## RayCast2D used to validate line of sight.
##
## It must be assigned for detection to work correctly.
@export var ray_cast: RayCast2D:
	set(value):
		ray_cast = value
		update_configuration_warnings()

## Half of the vision angle converted to radians.
var half_angle_rads: float

## Current detected target.
var current_target: Node2D

## All currently visible targets.
var visible_targets: Array[Node2D] = []

## Emitted when a target enters the vision cone
## and becomes visible.
signal target_detected(target: Node2D)

## Emitted when the current target is no longer visible.
signal target_lost(target: Node2D)

## Indicates whether the current target is visible.
var can_see_target: bool = false

func _ready() -> void:
	if target_mode == TargetMode.SINGLE and !target_group:
		push_error("VisionComponent: target_group is null")
		assert(false, "VisionComponent: target_group is null")
		set_physics_process(false)
		return

	if !ray_cast:
		push_error("VisionComponent: ray_cast is null")
		assert(false, "VisionComponent: ray_cast is null")
		set_physics_process(false)
		return

	update_cone()
	original_direction = direction.normalized()
	initialize_target()

## Updates cached vision cone values.
##
## This should be called whenever the vision angle changes.
func update_cone() -> void:
	half_angle_rads = deg_to_rad(angle / 2.0)

func _process(_delta: float) -> void:
	if can_see_target and track_target and current_target:
		direction = (
			to_local(current_target.global_position).normalized())
	else:
		direction = original_direction

	if debug_mode and Engine.is_editor_hint():
		queue_redraw()

## Returns configuration warnings displayed in the editor.
##
## Helps detect incorrect component setup.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := []

	if target_mode == TargetMode.SINGLE:
		if target_group == &"":
			warnings.append("No target group has been assigned.")

	if target_mode == TargetMode.MULTIPLE:
		if target_groups.is_empty():
			warnings.append("No target groups have been assigned.")

	if ray_cast == null:
		warnings.append("No RayCast has been assigned.")

	return warnings

func _validate_property(property: Dictionary) -> void:
	match target_mode:
		TargetMode.SINGLE:

			if property.name == "target_groups":
				property.usage = PROPERTY_USAGE_NO_EDITOR

		TargetMode.MULTIPLE:

			if property.name == "target_group":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if !debug_mode:
		if property.name == "debug_color":
			property.usage = PROPERTY_USAGE_NO_EDITOR

func _physics_process(_delta: float) -> void:
	if Engine.get_physics_frames() % 2 != 0:
		return

	match target_mode:
		TargetMode.SINGLE:
			update_single_target()

		TargetMode.MULTIPLE:
			update_multiple_targets()

func _draw() -> void:
	if debug_mode:

		var left_direction := (
			direction.rotated(-half_angle_rads)
			* length
		)

		var right_direction := (
			direction.rotated(half_angle_rads)
			* length
		)

		draw_line(Vector2.ZERO, left_direction, debug_color, 1)

		draw_line(Vector2.ZERO, right_direction, debug_color, 1)

		var direction_angle := direction.angle()

		draw_arc(Vector2.ZERO, length,
			direction_angle - half_angle_rads,
			direction_angle + half_angle_rads,
			16,
			debug_color
		)

		draw_circle(Vector2.ZERO, 2.0, debug_color)

#region FUNCTIONS

## Returns true if the target is inside the vision cone.
##
## Example:
## [codeblock]
## if vision.is_in_cone(enemy):
## 	print("Enemy is inside vision range")
## [/codeblock]
func is_in_cone(node: Node2D) -> bool:

	var target_local_position := to_local(
		node.global_position
	)

	var angle_to_target := direction.angle_to(
		target_local_position
	)

	var distance := target_local_position.length()

	if distance > length:
		return false

	return abs(angle_to_target) <= half_angle_rads

## Returns true if there is a clear line of sight
## between the component and the target.
##
## Example:
## [codeblock]
## if vision.has_line_of_sight(enemy):
## 	print("No obstacles detected")
## [/codeblock]
func has_line_of_sight(node: Node2D) -> bool:

	ray_cast.target_position = (
		ray_cast.to_local(node.global_position)
	)

	ray_cast.force_raycast_update()

	if !ray_cast.is_colliding():
		return false

	return ray_cast.get_collider() == node

## Returns true if the component can currently see the target.
func can_see(node: Node2D) -> bool:

	if !is_instance_valid(node):
		return false

	return (is_in_cone(node) and has_line_of_sight(node))

## Returns the current detected target.
##
## Example:
## [codeblock]
## var enemy = vision.get_target()
## [/codeblock]
func get_target() -> Node2D:
	return current_target

## Returns every possible target from the configured groups.
func get_targets() -> Array[Node2D]:
	var targets: Array[Node2D] = []

	if target_groups.is_empty():
		push_error("VisionComponent: target_groups is empty")
		assert(false, "VisionComponent: target_groups is empty")
		return targets

	for group in target_groups:
		for node in get_tree().get_nodes_in_group(group):
			if node is Node2D:
				targets.append(node)

	return targets

## Returns all targets currently visible.
func get_visible_targets() -> Array[Node2D]:
	var visibles: Array[Node2D] = []

	for target in get_targets():
		if can_see(target):
			visibles.append(target)

	return visibles

## Returns the closest target from an array.
func get_closest_visible_target(targets: Array[Node2D]) -> Node2D:
	var closest: Node2D = null
	var closest_distance := INF

	for target in targets:
		var distance := global_position.distance_to(
			target.global_position)

		if distance < closest_distance:
			closest_distance = distance
			closest = target

	return closest

## Initializes the first target when the component starts.
func initialize_target() -> void:
	match target_mode:

		TargetMode.SINGLE:

			current_target = (
				get_tree().
				get_first_node_in_group(
					target_group))

		TargetMode.MULTIPLE:

			visible_targets = get_visible_targets()

			current_target = (
				get_closest_visible_target(
					visible_targets))

## Updates detection state for SINGLE mode.
func update_single_target() -> void:

	if !is_instance_valid(current_target):

		current_target = (
			get_tree().
			get_first_node_in_group(
				target_group))

		return

	if can_see(current_target):
		if can_see_target:
			return

		can_see_target = true
		target_detected.emit(current_target)
	else:
		if !can_see_target:
			return

		can_see_target = false

		target_lost.emit(current_target)

## Updates detection state for MULTIPLE mode.
##
## Selects the closest visible target automatically.
func update_multiple_targets() -> void:
	visible_targets = get_visible_targets()

	var new_target := (get_closest_visible_target(visible_targets))

	if new_target == current_target:
		return

	if current_target:
		target_lost.emit(current_target)

	current_target = new_target

	if current_target:
		target_detected.emit(current_target)

## Returns true if a valid target exists.
##
## Example:
## [codeblock]
## if vision.has_target():
## 	print("Target available")
## [/codeblock]
func has_target() -> bool:
	return is_instance_valid(current_target)
#endregion
