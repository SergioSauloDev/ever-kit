class_name StateBase extends Node

var controlled_node: Node

var state_machine: StateMachine

func start() -> void:
	pass

func end() -> void:
	pass

#region METODOS
@warning_ignore("unused_parameter")
func on_process(delta: float) -> void:
	pass
@warning_ignore("unused_parameter")
func on_physics_process(delta: float) -> void:
	pass
@warning_ignore("unused_parameter")
func on_input(event: InputEvent) -> void:
	pass
@warning_ignore("unused_parameter")
func on_unhandled_input(event: InputEvent) -> void:
	pass
@warning_ignore("unused_parameter")
func on_unhandled_key_input(event: InputEvent) -> void:
	pass
#endregion
