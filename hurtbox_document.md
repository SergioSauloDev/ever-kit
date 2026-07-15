# HurtboxComponent

A reusable damage receiver for Godot 4.

`HurtboxComponent` is responsible for receiving incoming hits and forwarding the damage to a `HealthComponent`. It acts as the target of attacks while remaining completely independent from combat logic, making it reusable for players, enemies, NPCs, bosses, and destructible objects.

Unlike `HitboxComponent`, the `HurtboxComponent` does not detect collisions by itself. Instead, another system (typically a `HitboxComponent`) calls `receive_hit()` whenever a valid hit occurs.

---

# Features

- ❤️ Forwards damage to a `HealthComponent`.
- 💥 Receives hits from any external source.
- 🚫 Can be enabled or disabled at runtime.
- 📡 Emits a signal whenever damage is successfully received.
- 🧩 Independent from gameplay logic.
- 🔄 Works seamlessly with `HitboxComponent`.
- ♻️ Reusable across multiple projects.

---

# Scene Setup

A `HurtboxComponent` is usually attached to any object that can receive damage.

Example:

```text
Player
├── Sprite2D
├── CollisionShape2D
├── HealthComponent
└── HurtboxComponent
```

Enemy example:

```text
Enemy
├── AnimatedSprite2D
├── HealthComponent
├── HurtboxComponent
└── HitboxComponent
```

Assign the `HealthComponent` in the Inspector.

---

# Inspector Properties

## Health Component

```gdscript
@export
var health_component: HealthComponent
```

The `HealthComponent` that receives the damage.

Every successful hit is forwarded to this component.

Example:

```
Health Component = PlayerHealth
```

---

## Enabled

```gdscript
@export
var enabled := true
```

Determines whether the Hurtbox can receive hits.

If disabled:

- Damage is ignored.
- Signals are not emitted.

Default:

```
true
```

---

# Signals

## hit_received

```gdscript
signal hit_received(amount, source)
```

Emitted after a valid hit has been processed.

Parameters:

| Name | Description |
|------|-------------|
| amount | Damage applied |
| source | Node that caused the hit |

Example:

```gdscript
hurtbox.hit_received.connect(_on_hit)

func _on_hit(amount, source):
    print(source.name, "dealt", amount, "damage")
```

---

# Methods

## receive_hit()

```gdscript
receive_hit(amount, source)
```

Receives an incoming hit.

If the Hurtbox is enabled and a valid `HealthComponent` exists:

- Damage is applied.
- `hit_received` is emitted.

Example:

```gdscript
hurtbox.receive_hit(15, enemy)
```

---

## enable()

```gdscript
enable()
```

Enables the Hurtbox.

Example:

```gdscript
hurtbox.enable()
```

---

## disable()

```gdscript
disable()
```

Disables the Hurtbox.

While disabled, every incoming hit is ignored.

Example:

```gdscript
hurtbox.disable()
```

---

# Basic Example

```gdscript
@onready var hurtbox := $HurtboxComponent

func _ready():
    hurtbox.hit_received.connect(_on_hit)

func _on_hit(amount, source):
    print("Received", amount, "damage from", source.name)
```

---

# Working with HitboxComponent

The most common usage is together with a `HitboxComponent`.

```gdscript
func _on_hit_detected(target):
    target.receive_hit(20, self)
```

The Hitbox detects the collision.

The Hurtbox applies the damage.

---

# Player Example

```text
Player
├── HealthComponent
└── HurtboxComponent
```

```gdscript
func _on_enemy_attack(damage):
    hurtbox.receive_hit(damage, enemy)
```

---

# Enemy Example

```gdscript
func _on_player_attack():
    hurtbox.receive_hit(10, player)
```

---

# Boss Example

```gdscript
func _on_special_attack():
    hurtbox.receive_hit(50, player)
```

---

# Destructible Object Example

```gdscript
func _on_pickaxe_hit():
    hurtbox.receive_hit(5, player)
```

---

# Temporary Invulnerability

Disable the Hurtbox during invulnerability frames.

```gdscript
hurtbox.disable()

await get_tree().create_timer(1.0).timeout

hurtbox.enable()
```

This is commonly used after taking damage.

---

# Damage Zones

A lava area could damage the player like this:

```gdscript
player_hurtbox.receive_hit(5, self)
```

No additional combat system is required.

---

# Receiving Hits from Different Sources

```gdscript
hurtbox.receive_hit(10, sword)

hurtbox.receive_hit(25, explosion)

hurtbox.receive_hit(100, boss)
```

The source can be any node.

---

# Typical Combat Flow

```text
Player attacks
        │
        ▼
HitboxComponent
        │
Collision detected
        │
        ▼
HurtboxComponent.receive_hit()
        │
        ▼
HealthComponent.apply_damage()
        │
        ▼
Health updated
        │
        ▼
Signals emitted
```

---

# Best Practices

- Always assign a `HealthComponent`.
- Use `HitboxComponent` to detect collisions.
- Keep gameplay logic outside of the Hurtbox.
- Use the `hit_received` signal for visual or audio feedback.
- Disable the Hurtbox instead of removing it when temporary invulnerability is needed.

---

# Common Use Cases

- Players
- Enemies
- Bosses
- NPCs
- Breakable crates
- Doors
- Towers
- Vehicles
- Interactive objects

---

# Common Mistakes

## No HealthComponent Assigned

Incorrect:

```text
Enemy
└── HurtboxComponent
```

Correct:

```text
Enemy
├── HealthComponent
└── HurtboxComponent
```

---

## Calling receive_hit() with Zero Damage

Incorrect:

```gdscript
hurtbox.receive_hit(0, enemy)
```

The call is ignored.

---

## Forgetting to Enable the Hurtbox

If the Hurtbox is disabled:

```gdscript
hurtbox.disable()
```

No damage will be processed until:

```gdscript
hurtbox.enable()
```

---

## Applying Damage Directly

Instead of:

```gdscript
health.apply_damage(20)
```

Prefer:

```gdscript
hurtbox.receive_hit(20, enemy)
```

This ensures the Hurtbox remains the single entry point for incoming damage.

---

# Notes

- `HurtboxComponent` does not perform collision detection.
- It only receives validated hits from external systems.
- Damage values less than or equal to zero are ignored.
- A valid `HealthComponent` is required for damage to be applied.
- Designed to work together with `HitboxComponent` and `HealthComponent` as part of EverKit's modular combat system.