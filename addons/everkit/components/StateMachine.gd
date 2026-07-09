@tool
class_name StateMachine extends Node

@onready var controlled_node: Node = self.owner

@export var default_state: StateBase

var current_state: StateBase = null

var states: Dictionary[StringName, StateBase]

func _ready() -> void:
	assert(
    default_state != null,
    "StateMachine '" + controlled_node.name + "' Default State is null."
)

	for child in get_children():
    	_child_entered(child)

	child_entered_tree.connect(_child_entered)
	child_exiting_tree.connect(_child_exited)
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
		push_error("StateMachine '" + controlled_node.name +
    	"' State '" + str(new_state) + "' not found.")
		assert(
    	false,
    	"StateMachine '" + controlled_node.name +
    	"' State '" + str(new_state) + "' not found.")

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
