[**Return to index**](https://github.com/SergioSaulo-design/ever-kit/blob/ced991d1188887c166077242fcc9fd39755f5cc8/everkit/documentation/index.md)

# StateMachine

A reusable node-based finite state machine for Godot 4.

`StateMachine` is a lightweight and modular state management system that automatically discovers and manages child states derived from `StateBase`. It forwards Godot callbacks to the active state, making it easy to separate behaviors into reusable, maintainable classes.

Unlike traditional switch statements or large `_process()` methods, `StateMachine` encourages clean architecture by isolating each behavior into its own node.

---

# Features

- ⚙️ Automatic state registration.
- 🔄 Easy state transitions.
- 🧩 Fully node-based architecture.
- 📡 Built-in state change signal.
- 🎯 Automatic callback forwarding.
- 👤 Automatic controlled node assignment.
- 📂 Runtime state registration/removal.
- ♻️ Reusable across different projects.
- 🚀 No manual initialization required.

---

# Scene Setup

Every state must inherit from `StateBase` and be a child of the `StateMachine`.

Example:

```text
Player
├── Sprite2D
├── CharacterBody2D
└── StateMachine
    ├── IdleState
    ├── RunState
    ├── JumpState
    └── AttackState
```

The `StateMachine` automatically detects every `StateBase` child when the scene starts.

---

# Inspector Properties

## Default State

```gdscript
@export
var default_state: StateBase
```

The state that becomes active when the scene starts.

Requirements:

- Must inherit from `StateBase`
- Must be a child of this `StateMachine`

Example:

```
Default State = IdleState
```

The machine immediately starts in the Idle state.

---

# Runtime Properties

## Controlled Node

```gdscript
controlled_node
```

Automatically references the owner of the `StateMachine`.

For example:

```text
Player
└── StateMachine
```

Inside every state:

```gdscript
controlled_node
```

references the **Player**.

No manual assignment is required.

---

## Current State

```gdscript
current_state
```

Returns the active state.

Example:

```gdscript
print(state_machine.current_state.name)
```

Output:

```
RunState
```

---

## States

```gdscript
states
```

Dictionary containing every registered state.

Example:

```
IdleState
RunState
JumpState
AttackState
```

States are added and removed automatically.

---

# Signals

## changed_state

```gdscript
signal changed_state(old_state, new_state)
```

Emitted whenever the active state changes.

Example:

```gdscript
state_machine.changed_state.connect(_on_state_changed)

func _on_state_changed(old_state, new_state):
    print(old_state.name, "->", new_state.name)
```

Output:

```
IdleState -> RunState
```

---

# State Lifecycle

Every state follows the same lifecycle.

```text
start()
    ↓
on_process()
    ↓
on_physics_process()
    ↓
on_input()
    ↓
end()
```

When changing states:

```
Current State
        │
        ▼
end()
        │
        ▼
New State
        │
        ▼
start()
```

---

# Methods

## change_state_to()

```gdscript
change_state_to(state_name)
```

Changes the active state.

The current state receives:

```gdscript
end()
```

The next state receives:

```gdscript
start()
```

Example:

```gdscript
state_machine.change_state_to("RunState")
```

---

## has_state()

```gdscript
has_state(state_name)
```

Returns whether a state exists.

Example:

```gdscript
if state_machine.has_state("AttackState"):
    state_machine.change_state_to("AttackState")
```

---

## get_state()

```gdscript
get_state(state_name)
```

Returns a reference to a state.

Example:

```gdscript
var run = state_machine.get_state("RunState")
```

---

## get_current_state_name()

```gdscript
get_current_state_name()
```

Returns the current state's name.

Example:

```gdscript
print(state_machine.get_current_state_name())
```

Output:

```
IdleState
```

---

# Automatic Callback Forwarding

The `StateMachine` automatically forwards Godot callbacks to the active state.

You never need to manually call them.

---

## Process

```gdscript
func on_process(delta):
    pass
```

Automatically receives:

```gdscript
_process(delta)
```

---

## Physics Process

```gdscript
func on_physics_process(delta):
    pass
```

Automatically receives:

```gdscript
_physics_process(delta)
```

---

## Input

```gdscript
func on_input(event):
    pass
```

Automatically receives:

```gdscript
_input(event)
```

---

## Unhandled Input

```gdscript
func on_unhandled_input(event):
    pass
```

Automatically receives:

```gdscript
_unhandled_input(event)
```

---

## Unhandled Key Input

```gdscript
func on_unhandled_key_input(event):
    pass
```

Automatically receives:

```gdscript
_unhandled_key_input(event)
```

---

# Basic Example

## Idle State

```gdscript
extends StateBase

func start():
    print("Idle")

func on_input(event):
    if event.is_action_pressed("move"):
        state_machine.change_state_to("RunState")
```

---

## Run State

```gdscript
extends StateBase

func start():
    print("Running")

func on_input(event):
    if event.is_action_just_released("move"):
        state_machine.change_state_to("IdleState")
```

---

# Character Example

```text
Player
├── CharacterBody2D
└── StateMachine
    ├── IdleState
    ├── WalkState
    ├── JumpState
    ├── FallState
    └── AttackState
```

Transitions:

```
Idle
 │
 ▼
Walk
 │
 ▼
Jump
 │
 ▼
Fall
 │
 ▼
Idle
```

---

# Enemy AI Example

```text
Enemy
└── StateMachine
    ├── PatrolState
    ├── ChaseState
    ├── AttackState
    └── DeadState
```

Example:

```gdscript
func _on_player_detected():
    state_machine.change_state_to("ChaseState")
```

---

# Boss Example

```text
Boss
└── StateMachine
    ├── IdleState
    ├── Phase1State
    ├── Phase2State
    ├── RageState
    └── DeadState
```

---

# NPC Example

```text
Villager
└── StateMachine
    ├── WanderState
    ├── TalkState
    └── SleepState
```

---

# State Transitions

A typical transition flow:

```text
Idle
 │
 ▼
Run
 │
 ▼
Jump
 │
 ▼
Fall
 │
 ▼
Idle
```

Another example:

```text
Patrol
 │
 ▼
Investigate
 │
 ▼
Chase
 │
 ▼
Attack
 │
 ▼
Patrol
```

---

# Best Practices

- Keep each state responsible for only one behavior.
- Use `change_state_to()` instead of modifying `current_state` directly.
- Use `controlled_node` instead of manually storing references.
- Connect to `changed_state` if other systems need to react.
- Prefer many small states over one large state.

---

# Common Use Cases

- Player controllers
- Enemy AI
- NPC behaviors
- Boss phases
- Menus
- Dialogue systems
- Weapons
- Vehicles
- Companion AI
- Cutscenes

---

# Common Mistakes

## Default State is null

Always assign a default state.

Incorrect:

```
StateMachine
├── IdleState
└── RunState
```

(Default State not assigned.)

Correct:

```
Default State = IdleState
```

---

## State is not a child

Every state **must** be a direct child of the `StateMachine`.

Incorrect:

```text
Player
├── IdleState
└── StateMachine
```

Correct:

```text
Player
└── StateMachine
    └── IdleState
```

---

## Changing current_state manually

Avoid:

```gdscript
current_state = states["RunState"]
```

Instead:

```gdscript
change_state_to("RunState")
```

This ensures:

- `end()` is called
- `start()` is called
- `changed_state` is emitted

---

# Notes

- States are automatically registered when entering the scene tree.
- States are automatically removed when freed.
- Callback forwarding only affects the currently active state.
- The `StateMachine` itself contains no gameplay logic.
- Any node inheriting from `StateBase` can become a state.
- Designed to work seamlessly with other EverKit components such as `HealthComponent`, `VisionComponent`, `HitboxComponent`, and `HurtboxComponent`.
