@tool
class_name MovementComponent extends Node

var parent: Node2D


func _ready() -> void:
	parent = get_parent()
	assert(get_parent() is Node2D, "MovementComponent must be a child of a Node2D.")


func move_to_position(
	target_position: Vector2,
	speed: float,
	offset: Vector2 = Vector2(0.0, 0.0),
) -> void:
	assert(speed > 0, "Speed must be greater than 0.")

	var adjusted_target := target_position + offset
	var direction := (adjusted_target - parent.position).normalized()
	parent.position += direction * speed * get_process_delta_time()


func move_to_target(target: Node2D, speed: float, offset: Vector2 = Vector2(0.0, 0.0)) -> void:
	assert(speed > 0, "Speed must be greater than 0.")

	var adjusted_target := target.position + offset
	var direction := (adjusted_target - parent.position).normalized()
	parent.position += direction * speed * get_process_delta_time()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if not get_parent() is Node2D:
		warnings.append("MovementComponent must be a child of a Node2D.")

	return warnings
