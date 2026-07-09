@tool
class_name StateMachine extends Node

@onready var controlled_node: Node = self.owner

@export var default_state: StateBase

var current_state: StateBase = null

var states: Dictionary[StringName, StateBase]

func _ready() -> void:
	child_entered_tree.connect(_child_entered)
	call_deferred("default_state_start")

func _child_entered(node: Node) -> void:
	if not node is StateBase:
		return

	if not states.has(node.name):
		states[node.name] = node

func _child_exited(node: Node) -> void:
	if not node is StateBase:
		return

	if states.has(node.name):
		states.erase(node.name)

func default_state_start() -> void:
	current_state = default_state
	state_start()

func state_start() -> void:
	print("StateMachine ", controlled_node.name, " start state ", current_state.name)

	current_state.controlled_node = controlled_node
	current_state.state_machine = self
	current_state.start()

func change_state_to(new_state: StringName) -> void:
	if current_state and current_state.has_method("end"): current_state.end()
	if states.has(new_state):
		current_state = states[new_state]
		state_start()
	else:
		push_error("State Machine ", controlled_node.name,
		" new_state is not states")
		assert(false, "State Machine "
		+ controlled_node.name + " new_state is not states")

#region METODOS AUTOMÁTICOS
func _process(delta: float) -> void:
	if current_state and current_state.has_method("on_process"):
		current_state.on_process(delta)

func _physics_process(delta: float) -> void:
	if current_state and current_state.has_method("on_physics_process"):
		current_state.on_physics_process(delta)

func _input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_input"):
		current_state.on_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_input"):
		current_state.on_unhandled_input(event)

func _unhandled_key_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_key_input"):
		current_state.on_unhandled_key_input(event)
#endregion
