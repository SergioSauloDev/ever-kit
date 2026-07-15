@tool
@icon("res://addons/everkit/icons/machine.svg")
class_name StateMachine extends Node
## StateMachine is a node-based state management system.
##
## It automatically detects child nodes that inherit from [StateBase] and manages
## their lifecycle, allowing easy creation of reusable state-driven behaviors.
##
## Each state must be a child of this node:
##
## [codeblock]
## StateMachine
## ├── IdleState
## ├── RunState
## └── AttackState
## [/codeblock]
##
## Example scene:
##
## [codeblock]
## Player
## ├── Sprite2D
## ├── StateMachine
## │   ├── IdleState
## │   └── RunState
## └── CharacterBody2D
## [/codeblock]

## The node controlled by this StateMachine.
##
## Automatically assigned using the owner of this node.
@onready var controlled_node: Node = self.owner

## The state that will be activated when the StateMachine starts.
##
## The assigned state must be a child of this StateMachine.
@export var default_state: StateBase:
	set(value):
		default_state = value
		update_configuration_warnings()

## The currently active state.
var current_state: StateBase = null

## Dictionary containing all registered states.
##
## States are automatically added and removed when StateBase children enter
## or exit the scene tree.
var states: Dictionary[StringName, StateBase]

## Emitted when the active state changes.
##
## old_state:
##     The previous active state.
##
## new_state:
##     The newly activated state.
signal changed_state(old_state: StateBase, new_state: StateBase)

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		set_process_unhandled_input(false)
		set_process_unhandled_key_input(false)
		return

	assert(
		default_state != null,
		"StateMachine '" + controlled_node.name + "' Default State is null."
	)

	assert(
		default_state.get_parent() == self,
		"Default State must be a child of this StateMachine."
	)

	# Register existing states.
	for child in get_children():
		_child_entered(child)

	child_entered_tree.connect(_child_entered)
	child_exiting_tree.connect(_child_exited)

	# Start the default state after initialization.
	call_deferred("default_state_start")

## Registers a new StateBase child.
##
## This is called automatically when a StateBase enters the scene tree.
func _child_entered(node: Node) -> void:
	if not node is StateBase:
		return

	if not states.has(node.name):
		node.controlled_node = controlled_node
		node.state_machine = self

		states[node.name] = node

## Removes a StateBase child from the state dictionary.
##
## This is called automatically when a StateBase exits the scene tree.
func _child_exited(node: Node) -> void:
	if not node is StateBase:
		return

	if states.has(node.name):
		states.erase(node.name)

## Starts the configured default state.
func default_state_start() -> void:
	current_state = default_state
	state_start()

## Initializes the current state.
##
## This calls the StateBase.start() method.
func state_start() -> void:
	if current_state == null:
		return

	if OS.is_debug_build():
		print("StateMachine ", controlled_node.name,
		" start state ", current_state.name)

	current_state.start()

## Checks if a state exists.
##
## Example:
##
## [codeblock]
## if state_machine.has_state("Attack"):
##     state_machine.change_state_to("Attack")
## [/codeblock]
func has_state(state_name: StringName) -> bool:
	return states.has(state_name)

## Returns a state by its name.
##
## Returns null if the state does not exist.
##
## Example:
##
## [codeblock]
## var idle_state = state_machine.get_state("Idle")
## [/codeblock]
func get_state(state_name: StringName) -> StateBase:
	if not has_state(state_name):
		return null

	return states[state_name]

## Returns the name of the currently active state.
##
## Returns an empty StringName if no state is active.
##
## Example:
##
## [codeblock]
## if state_machine.get_current_state_name() == "Run":
##     print("Player is running")
## [/codeblock]
func get_current_state_name() -> StringName:
	return current_state.name if current_state else &""

## Changes the current active state.
##
## The current state will receive end() before changing.
## The new state will receive start() after changing.
##
## Example:
##
## [codeblock]
## func _physics_process(delta):
##     if Input.is_action_pressed("move"):
##         state_machine.change_state_to("Run")
## [/codeblock]
func change_state_to(new_state: StringName) -> void:
	if current_state == states[new_state]:
		return

	if current_state and current_state.has_method("end"):
		current_state.end()

	var old_state := current_state

	if has_state(new_state):
		current_state = states[new_state]

		changed_state.emit(old_state, current_state)

		state_start()

	else:
		assert(
			false,
			"StateMachine '" + controlled_node.name +
			"' State '" + str(new_state) + "' not found."
		)

#region AUTO METHODS

## Sends the process callback to the current state.
##
## Any StateBase child can receive this callback:
##
## [codeblock]
## func on_process(delta):
##     update_animation()
## [/codeblock]
func _process(delta: float) -> void:
	if current_state and current_state.has_method("on_process"):
		current_state.on_process(delta)

## Sends the physics process callback to the current state.
##
## Any StateBase child can receive this callback:
##
## [codeblock]
## func on_physics_process(delta):
##     controlled_node.move_and_slide()
## [/codeblock]
func _physics_process(delta: float) -> void:
	if current_state and current_state.has_method("on_physics_process"):
		current_state.on_physics_process(delta)

## Sends input events to the current state.
##
## Example:
##
## [codeblock]
## func on_input(event):
##     if event.is_action_pressed("attack"):
##         state_machine.change_state_to("Attack")
## [/codeblock]
func _input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_input"):
		current_state.on_input(event)

## Sends unhandled input events to the current state.
func _unhandled_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_input"):
		current_state.on_unhandled_input(event)

## Sends unhandled key input events to the current state.
func _unhandled_key_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_key_input"):
		current_state.on_unhandled_key_input(event)

#endregion

## Displays configuration warnings in the editor.
##
## Warns when no default state has been assigned.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if not is_instance_valid(default_state):
		warnings.append("The Default State is not assigned.")

	return warnings
