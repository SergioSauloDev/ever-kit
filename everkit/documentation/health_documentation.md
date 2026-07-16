# HealthComponent

A reusable health system for Godot 4.

`HealthComponent` is a lightweight and modular component that manages an entity's health independently from gameplay logic, animations, or visuals. It provides an easy-to-use API for applying damage, healing, killing, reviving, and monitoring an entity's life state.

Because it inherits from `Node`, it can be attached to any scene without affecting its hierarchy or physics.

---

# Features

- ❤️ Configurable maximum health.
- 💥 Damage and healing support.
- ☠️ Death and revive system.
- 🛡️ Invulnerability mode.
- ♾️ Infinite health mode.
- 🔄 Reset to initial or maximum health.
- 📊 Health percentage calculation.
- 📡 Built-in signals for health changes.
- 🧩 Completely reusable and independent from gameplay logic.
- 👤 Suitable for players, enemies, NPCs, bosses, and destructible objects.

---

# Scene Setup

Simply add a **HealthComponent** as a child of any node that needs health.

Example:

```text
Player
├── Sprite2D
├── CollisionShape2D
└── HealthComponent
```

Or:

```text
Enemy
├── AnimatedSprite2D
├── HitboxComponent
├── HurtboxComponent
└── HealthComponent
```

The component automatically initializes itself when the scene starts.

---

# Inspector Properties

## Max Health

```gdscript
@export_range(10.0, 200)
var max_health := 60.0
```

Defines the maximum amount of health.

Changing this value automatically clamps the current health.

Default:

```
60
```

---

## Start Full Health

```gdscript
@export
var start_full_health := true
```

If enabled, the component starts with full health.

Otherwise, it starts with the value stored in **Start Health**.

Default:

```
true
```

---

## Start Health

```gdscript
@export
var start_health
```

Initial health when **Start Full Health** is disabled.

Example:

```
Max Health = 100

Start Full Health = false

Start Health = 40
```

The entity begins with **40 HP**.

---

## Can Heal

```gdscript
@export
var can_heal := true
```

Determines whether healing is allowed.

If disabled, every call to `heal()` is ignored.

---

## Invulnerable

```gdscript
@export
var invulnerable := false
```

When enabled, damage is ignored.

Healing still works normally.

---

## Infinite Health

```gdscript
@export
var infinite_health := false
```

Makes the entity immune to all damage.

Unlike **Invulnerable**, this mode also hides the **Max Health** property since health becomes irrelevant.

---

# Runtime Properties

## Current Health

```gdscript
current_health
```

Stores the current health.

The value is always clamped between:

```
0 <= current_health <= max_health
```

---

## Is Dead

```gdscript
is_dead
```

Returns whether the entity is dead.

This value updates automatically whenever the health changes.

---

# Signals

## health_changed

```gdscript
signal health_changed(current_health, max_health)
```

Emitted every time the health changes.

Example:

```gdscript
health.health_changed.connect(_on_health_changed)

func _on_health_changed(current, maximum):
    health_bar.value = current / maximum
```

---

## damaged

```gdscript
signal damaged(amount)
```

Emitted after taking damage.

Example:

```gdscript
health.damaged.connect(_on_damaged)

func _on_damaged(amount):
    print("Received", amount, "damage")
```

---

## healed

```gdscript
signal healed(amount)
```

Emitted after restoring health.

Example:

```gdscript
health.healed.connect(_on_healed)

func _on_healed(amount):
    print("Recovered", amount, "HP")
```

---

## dead

```gdscript
signal dead
```

Emitted when health reaches zero.

Example:

```gdscript
health.dead.connect(_on_dead)

func _on_dead():
    queue_free()
```

---

## revived

```gdscript
signal revived
```

Emitted when the entity comes back to life.

Example:

```gdscript
health.revived.connect(_on_revived)
```

---

# Methods

## apply_damage()

```gdscript
apply_damage(amount)
```

Applies damage to the entity.

Damage is ignored if:

- the entity is already dead
- Invulnerable is enabled
- Infinite Health is enabled

Example:

```gdscript
health.apply_damage(20)
```

---

## heal()

```gdscript
heal(amount)
```

Restores health.

Healing is ignored if:

- the entity is dead
- Can Heal is disabled

Example:

```gdscript
health.heal(15)
```

---

## kill()

```gdscript
kill()
```

Immediately kills the entity.

Equivalent to setting the current health to zero.

Example:

```gdscript
health.kill()
```

---

## revive()

```gdscript
revive()
```

Revives the entity and restores its health to the maximum value.

Example:

```gdscript
health.revive()
```

---

## reset_health()

```gdscript
reset_health()
```

Restores the initial health.

If **Start Full Health** is enabled:

```
Current Health = Max Health
```

Otherwise:

```
Current Health = Start Health
```

Example:

```gdscript
health.reset_health()
```

---

## reset_to_max_health()

```gdscript
reset_to_max_health()
```

Fully restores the entity.

Example:

```gdscript
health.reset_to_max_health()
```

---

## set_health()

```gdscript
set_health(value)
```

Directly changes the health.

The value is automatically clamped.

Example:

```gdscript
health.set_health(50)
```

---

## get_health_percent()

```gdscript
get_health_percent()
```

Returns a value between **0.0** and **1.0**.

Example:

```gdscript
var percent = health.get_health_percent()
```

Can be used for UI:

```gdscript
health_bar.value = health.get_health_percent()
```

---

## is_alive()

```gdscript
is_alive()
```

Returns whether the entity is alive.

Example:

```gdscript
if health.is_alive():
    print("Still alive!")
```

---

# Basic Example

```gdscript
@onready var health: HealthComponent = $HealthComponent

func _ready():
    health.dead.connect(_on_dead)
    health.health_changed.connect(_on_health_changed)

func _on_dead():
    print("Game Over")

func _on_health_changed(current, maximum):
    print(current, "/", maximum)
```

---

# Enemy Example

```gdscript
func _on_hit(damage):
    health.apply_damage(damage)

func _on_dead():
    animation_player.play("death")
```

---

# Healing Item Example

```gdscript
func use_potion():
    player_health.heal(25)
```

---

# Boss Example

```gdscript
func _process(delta):
    boss_bar.value = boss_health.get_health_percent()
```

---

# Respawn Example

```gdscript
func respawn():
    health.revive()
    global_position = spawn_position
```

---

# Destructible Object Example

```gdscript
func _on_dead():
    spawn_loot()
    queue_free()
```

---

# Health Bar Example

```gdscript
func _ready():
    health.health_changed.connect(update_health_bar)

func update_health_bar(current, maximum):
    progress_bar.value = current / maximum * 100
```

---

# Best Practices

- Keep gameplay logic outside of the component.
- Connect to signals instead of modifying the component internally.
- Pair it with `HitboxComponent` and `HurtboxComponent` for a complete combat system.
- Use `get_health_percent()` for UI instead of calculating the percentage yourself.
- Avoid modifying `current_health` directly unless absolutely necessary.

---

# Common Use Cases

- Player health
- Enemy health
- Bosses
- NPCs
- Breakable objects
- Survival mechanics
- RPG characters
- Roguelike entities
- Tower defense units

---

# Notes

- The component automatically clamps every health value.
- Health can never become negative.
- Health can never exceed the maximum.
- Signals are emitted automatically whenever the health changes.
- The component contains no gameplay-specific logic, making it fully reusable across different projects.
