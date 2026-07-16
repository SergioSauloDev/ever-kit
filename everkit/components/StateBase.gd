@icon("res://addons/everkit/icons/state_base.svg")
class_name StateBase extends Node

## Base class for creating [StateMachine] states.
##
## StateBase provides the structure required for creating reusable states.
## Each state is managed by a [StateMachine] and can receive lifecycle events
## and automatic callbacks.
##
## States should inherit from this class:
##
## [codeblock]
## class_name IdleState
## extends StateBase
## 
## func start() -> void:
##     print("Entering Idle State")
## 
## func end() -> void:
##     print("Leaving Idle State")
## [/codeblock]
##
## Example structure:
##
## [codeblock]
## Player
## └── StateMachine
##     ├── IdleState
##     ├── RunState
##     └── AttackState
##[/codeblock]

## The node controlled by this state.
##
## Automatically assigned by the [StateMachine] when the state is registered.
var controlled_node: Node

## The StateMachine that manages this state.
##
## Automatically assigned by the [StateMachine] when the state is registered.
var state_machine: StateMachine

## Called when this state becomes active.
##
## Use this method to initialize behavior when entering the state.
##
## Example:
##
## [codeblock]
## func start() -> void:
##     controlled_node.animation.play("idle")
## [/codeblock]
func start() -> void:
	pass

## Called when this state stops being active.
##
## Use this method to clean up behavior before changing to another state.
##
## Example:
##
## [codeblock]
## func end() -> void:
##     controlled_node.animation.stop()
## [/codeblock]
func end() -> void:
	pass

#region STATE CALLBACKS

## Called every frame while this state is active.
##
## This method is called automatically by the [StateMachine].
##
## Example:
##
## [codeblock]
## func on_process(delta: float) -> void:
##     update_animation(delta)
## [/codeblock]
@warning_ignore("unused_parameter")
func on_process(delta: float) -> void:
	pass

## Called every physics frame while this state is active.
##
## This method is called automatically by the [StateMachine].
##
## Example:
##
## [codeblock]
## func on_physics_process(delta: float) -> void:
##     controlled_node.move_and_slide()
## [/codeblock]
@warning_ignore("unused_parameter")
func on_physics_process(delta: float) -> void:
	pass

## Called when an input event is received.
##
## Example:
##
## [codeblock]
## func on_input(event: InputEvent) -> void:
##     if event.is_action_pressed("attack"):
##         state_machine.change_state_to("Attack")
## [/codeblock]
@warning_ignore("unused_parameter")
func on_input(event: InputEvent) -> void:
	pass

## Called when an unhandled input event is received.
##
## Example:
##
## [codeblock]
## func on_unhandled_input(event: InputEvent) -> void:
##     print(event)
## [/codeblock]
@warning_ignore("unused_parameter")
func on_unhandled_input(event: InputEvent) -> void:
	pass


## Called when an unhandled key input event is received.
##
## Example:
##
## [codeblock]
## func on_unhandled_key_input(event: InputEvent) -> void:
##     print(event.keycode)
## [/codeblock]
@warning_ignore("unused_parameter")
func on_unhandled_key_input(event: InputEvent) -> void:
	pass

#endregion
