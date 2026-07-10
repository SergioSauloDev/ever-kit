# HealthComponent

The `HealthComponent` is a reusable Godot Node script that manages an entity’s health. It provides a simple API for taking damage, healing, killing, and reviving a game object, without depending on any visuals or game logic. This makes it suitable for players, enemies, NPCs, destructible objects, and other gameplay elements. For example, the Godot Essentials documentation notes that such a component “handles all aspects related to taking damage and managing health on the parent node”, and the `HealthComponent` class here follows that pattern.

Example usage:
```gdscript
var health = HealthComponent.new()
# Attach the component to the scene or parent node before using it
add_child(health)

health.apply_damage(25)  # Subtract 25 health
health.heal(10)          # Add 10 health

if health.is_alive():
    print("Still alive!")
else:
    print("Entity died.")
```

## Adding to a Node
The `HealthComponent` script uses `@class_name`, so it appears as a node type ("HealthComponent") in the Godot editor. To use it, open the **Create New Node** dialog, search for "health", and add a **HealthComponent** node as a child of your game object (e.g. a player or enemy node). Once added, configure its exported properties (shown in the Inspector) such as **Max Health**, **Start Health**, etc. The component will then manage the parent node’s health according to these settings when the scene runs.

## Properties
- `max_health` (float, default `60.0`): The maximum health value. This property is exported with a range of 10.0 to 200. Changing `max_health` automatically clamps the current health to the new maximum (unless `infinite_health` is enabled) and emits the `health_changed` signal.
- `current_health` (float): The current health value, automatically kept between 0 and `max_health`. Setting `current_health` updates the `is_dead` state and emits the `health_changed(current_health, max_health)` signal.
- `start_full_health` (bool, default `true`): If `true`, the component starts with full health (`max_health`) when the scene is ready. If `false`, it starts with the value of `start_health`.
- `start_health` (float, default `0.0`): The initial health used when `start_full_health` is disabled. This value is clamped between 0 and `max_health`.
- `can_heal` (bool, default `true`): If `false`, the component cannot be healed (`heal()` calls have no effect).
- `invulnerable` (bool, default `false`): If `true`, the component ignores incoming damage (`apply_damage()` does nothing while invulnerable).
- `infinite_health` (bool, default `false`): If `true`, the component ignores all incoming damage and cannot be killed. In this mode, `max_health` becomes non-editable in the Inspector.
- `is_dead` (bool, read-only): `true` if `current_health <= 0`. Changing from `false` to `true` emits the `dead` signal; changing from `true` to `false` emits the `revived` signal. Use the method `is_alive()` to check this state.

## Methods
- `reset_health()`: Restores health to the initial starting value. If `start_full_health` is `true`, sets `current_health = max_health`; otherwise sets `current_health = start_health`.
- `heal(amount: float)`: Increases health by the given amount. If the component is dead (`is_dead == true`) or `can_heal` is `false`, this does nothing. After adding health, it emits `healed(amount)` with the actual healed amount.
- `get_health_percent() -> float`: Returns the current health ratio `current_health / max_health`, as a value from 0.0 (0%) to 1.0 (100%).
- `is_alive() -> bool`: Returns `true` if the entity is not dead (i.e. `is_dead == false`).
- `kill()`: Instantly kills the component by setting `current_health = 0` and `is_dead = true`. If `infinite_health` is enabled, `kill()` has no effect.
- `revive()`: If the component is currently dead, this restores it to full health (`current_health = max_health`) and clears the dead state (`is_dead = false`), emitting `revived`.
- `reset_to_max_health()`: Shortcut to set `current_health = max_health`.
- `set_health(value: float)`: Directly sets `current_health` to `value` (clamped between 0 and `max_health`) and updates the dead state.
- `apply_damage(amount: float)`: Subtracts the given damage from `current_health`. Does nothing if the component is already dead, `invulnerable`, or `infinite_health` is `true`. After applying damage, it emits `damaged(amount)` with the actual damage received (clamped if necessary).

## Signals
- `health_changed(current_health: float, max_health: float)`: Emitted whenever the current health value changes (due to damage or healing). Provides the new current and max health.
- `damaged(amount: float)`: Emitted right after damage is applied. Parameter `amount` is the actual damage subtracted.
- `healed(amount: float)`: Emitted right after healing is applied. Parameter `amount` is the actual health restored.
- `dead`: Emitted when the component’s health drops to zero (entity dies).
- `revived`: Emitted when the entity is revived from death.

## Examples

**Basic Usage:** Create and attach a HealthComponent to a node, then apply damage and healing.
```gdscript
var health = HealthComponent.new()
add_child(health)  # ensure component is part of the scene

health.max_health = 100
health.start_full_health = false
health.start_health = 50
health.reset_health()  # sets current_health to 50

health.apply_damage(20)  # health goes to 30
health.heal(10)          # health goes to 40
```

**Death and Revival:** Damage that reduces health to 0 triggers the `dead` signal.
```gdscript
health.apply_damage(1000)  # health is now 0 (dead)
if not health.is_alive():
    print("Entity has died.")

health.revive()  # entity is revived at full health
```

**Using Flags:** Demonstrate `invulnerable` and `infinite_health`.
```gdscript
health.invulnerable = true
health.apply_damage(50)   # health unchanged while invulnerable
health.invulnerable = false

health.infinite_health = true
health.apply_damage(100)  # still unchanged, cannot be killed
health.kill()             # does nothing
```

**Connecting Signals:** Listen to health events to update game UI or logic.
```gdscript
func _ready():
    health.connect("health_changed", self, "_on_health_changed")
    health.connect("dead", self, "_on_entity_dead")

func _on_health_changed(current, max):
    print("Health changed to %d/%d" % [current, max])

func _on_entity_dead():
    print("Entity is dead!")
```

**Health Percentage for UI:** Use `get_health_percent()` to update a progress bar.
```gdscript
# Example: updating a health bar's value (0 to 100)
$HealthBar.max_value = 100
$HealthBar.value = health.get_health_percent() * 100
```

With these APIs and examples, you can fully integrate the `HealthComponent` into your Godot project to manage entity health in a flexible way.

**Sources:** Godot Essentials: Health Component documentation. (Implementation based on the provided `HealthComponent.gd` script.)