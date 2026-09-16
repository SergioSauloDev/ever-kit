@tool
class_name MovmentComponent extends Node

var parent: Node2D


func _ready() -> void:
	parent = get_parent()
	assert(get_parent().is_class("Node2D"), "MovmentComponent must be a child of a Node2D.")


func move_to_position(target_position: Vector2, speed: float) -> void:
	assert(speed > 0, "Speed must be greater than 0.")

	var direction := (target_position - parent.position).normalized()
	parent.position += direction * speed * get_process_delta_time()


func move_to_position_with_offset(target_position: Vector2, offset: Vector2, speed: float) -> void:
	assert(speed > 0, "Speed must be greater than 0.")

	var adjusted_target := target_position + offset
	var direction := (adjusted_target - parent.position).normalized()
	parent.position += direction * speed * get_process_delta_time()


func move_to_target(target: Node2D, speed: float) -> void:
	assert(speed > 0, "Speed must be greater than 0.")

	var direction := (target.position - parent.position).normalized()
	parent.position += direction * speed * get_process_delta_time()


func move_to_target_with_offset(target: Node2D, offset: Vector2, speed: float) -> void:
	assert(speed > 0, "Speed must be greater than 0.")

	var adjusted_target := target.position + offset
	var direction := (adjusted_target - parent.position).normalized()
	parent.position += direction * speed * get_process_delta_time()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if not parent.is_class("Node2D"):
		warnings.append("MovmentComponent must be a child of a Node2D.")

	return warnings
