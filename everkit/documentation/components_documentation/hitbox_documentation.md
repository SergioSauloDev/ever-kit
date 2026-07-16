[**Return to index**](https://github.com/SergioSaulo-design/ever-kit/blob/ced991d1188887c166077242fcc9fd39755f5cc8/everkit/documentation/index.md)

# HitboxComponent

`HitboxComponent` is a reusable combat component that represents an attack area.

It detects `HurtboxComponent` targets and applies damage to them. It can work automatically when a target enters its collision area or manually through `apply_hit()`.

This component is designed to work together with:

- `HurtboxComponent`
- `HealthComponent`

as part of the EverKit combat system.

---

# Features

- Automatic attacks.
- Manual attacks.
- Single-target attacks.
- Multi-target attacks.
- One-hit-per-overlap protection.
- Custom attacker reference.
- Combat event signals.
- Reusable for weapons, abilities and enemies.

---

# How it works

A `HitboxComponent` is an `Area2D` responsible for dealing damage.

When it detects a `HurtboxComponent`, it validates the target and applies damage.

The basic combat flow is:

```
HitboxComponent
        |
        v
Detects HurtboxComponent
        |
        v
Validates target
        |
        v
Calls receive_hit()
        |
        v
HurtboxComponent
        |
        v
HealthComponent loses health
```

---

# Basic Setup

A common player setup:

```
Player
├── Sprite2D
├── HurtboxComponent
└── Sword
    └── HitboxComponent
```

The player receives damage through its `HurtboxComponent`.

The sword deals damage through its `HitboxComponent`.

---

# Requirements

## HitboxComponent

Must inherit from:

```
Area2D
```

and requires a `CollisionShape2D`.

Example:

```
Sword
└── HitboxComponent
    └── CollisionShape2D
```

---

## HurtboxComponent

Targets must have:

```
Enemy
├── HurtboxComponent
│   └── CollisionShape2D
└── HealthComponent
```

---

# Configuration

## Enabled

Controls whether the hitbox can deal damage.

```gdscript
hitbox.enabled = true
```

Disabled hitboxes ignore all targets.

Example:

```gdscript
func stop_attack():
    hitbox.enabled = false
```

---

# Damage

Amount of damage applied by the hitbox.

```gdscript
hitbox.damage = 10
```

The value is automatically clamped between:

```
1 - 20
```

Example:

```gdscript
hitbox.damage *= 2
```

---

# Auto Attack

Controls automatic attacks.

When enabled, every `HurtboxComponent` entering the hitbox will receive damage.

```gdscript
hitbox.auto_attack = true
```

Example:

A sword swing:

```gdscript
func attack():
    hitbox.enable()
```

---

# Manual Attacks

Automatic attacks are optional.

You can manually attack a target:

```gdscript
hitbox.apply_hit(enemy_hurtbox)
```

This is useful for:

- Projectiles.
- Abilities.
- Special attacks.
- Custom combat systems.

---

# Multiple Targets

By default, only one target is attacked.

```gdscript
hitbox.can_hit_multiple = false
```

Example:

A sword normally hits one enemy.

For area attacks:

```gdscript
hitbox.can_hit_multiple = true
```

Example:

- Explosion.
- Magic spell.
- Shockwave.

---

# One Hit Per Overlap

Prevents the same target from receiving damage repeatedly while inside the hitbox.

Enabled by default:

```gdscript
hitbox.hit_once_per_overlap = true
```

Example:

Without this:

```
Enemy inside hitbox
|
Damage
Damage
Damage
Damage
```

With this enabled:

```
Enemy enters
|
Damage once
|
Must leave before being damaged again
```

---

# Attacker Reference

Defines who caused the damage.

Example:

```gdscript
hitbox.attacker = player
```

The attacker is passed to:

```gdscript
HurtboxComponent.receive_hit()
```

This allows systems like:

- Knockback.
- Team checking.
- Damage attribution.
- Effects.

If no attacker is assigned, the parent node is automatically used.

Example:

```
Player
└── Sword
    └── HitboxComponent
```

The attacker becomes:

```
Player
```

---

# Signals

## hit

Emitted when a target is successfully hit.

```gdscript
hitbox.hit.connect(_on_hit)


func _on_hit(target):
    print("Enemy hit!")
```

Useful for:

- Sound effects.
- Particles.
- Animations.

---

## damage_applied

Emitted after damage is applied.

Provides:

- Hurtbox.
- Damage amount.

Example:

```gdscript
hitbox.damage_applied.connect(_on_damage)


func _on_damage(target, amount):
    print(amount)
```

---

## blocked

Reserved for future combat mechanics.

Possible uses:

- Shields.
- Parry.
- Invulnerability.
- Armor.

---

# Methods

## enable()

Enables the hitbox.

```gdscript
hitbox.enable()
```

Also enables collision monitoring.

---

## disable()

Disables the hitbox.

```gdscript
hitbox.disable()
```

Stops it from detecting targets.

---

## can_hit()

Checks if a target can receive damage.

Example:

```gdscript
if hitbox.can_hit(enemy):
    print("Target available")
```

Returns `false` when:

- The hitbox is disabled.
- The target was already hit and one-hit protection is active.

---

## clear_hit_targets()

Clears the internal hit cache.

Useful for:

- Restarting attacks.
- Reusing hitboxes.
- Animation loops.

Example:

```gdscript
hitbox.clear_hit_targets()
```

---

## apply_hit()

Manually applies damage.

Example:

```gdscript
hitbox.apply_hit(enemy_hurtbox)
```

The method:

1. Validates the target.
2. Stores the target if needed.
3. Applies damage.
4. Emits signals.

---

# Examples

---

# Player Sword Attack

Scene:

```
Player
└── Sword
    └── HitboxComponent
```

Code:

```gdscript
func attack():

    hitbox.enable()

    await attack_animation_finished

    hitbox.disable()
```

---

# Enemy Attack

Enemy claw:

```
Enemy
├── HurtboxComponent
└── Claw
    └── HitboxComponent
```

Configuration:

```gdscript
hitbox.damage = 15
hitbox.auto_attack = true
```

---

# Explosion Attack

Multiple targets:

```gdscript
hitbox.damage = 25
hitbox.can_hit_multiple = true
hitbox.auto_attack = true
```

Every enemy inside receives damage.

---

# Projectile Example

Disable automatic detection:

```gdscript
hitbox.auto_attack = false
```

When the projectile collides:

```gdscript
func on_collision(target):

    hitbox.apply_hit(target)
```

---

# Animation Integration

A common melee workflow:

```
Animation starts
        |
        v
Enable hitbox
        |
        v
Attack frame
        |
        v
Disable hitbox
```

Example:

```gdscript
func start_attack():

    hitbox.enable()

    await get_tree().create_timer(0.2).timeout

    hitbox.disable()
```

---

# Best Practices

## Use HitboxComponent only for attacks

Do not use it to store health or receive damage.

Recommended:

```
Character

├── HealthComponent
|
├── HurtboxComponent
|
└── HitboxComponent
```

---

## Keep damage logic separated

The hitbox should only deal damage.

The health system should decide:

- Death.
- Healing.
- Invulnerability.
- Status effects.

---

## Reuse hitboxes

Instead of creating new hitboxes:

```
SwordHitbox
FireballHitbox
ExplosionHitbox
```

reuse the component and change:

- Damage.
- Size.
- Enabled state.
- Attack behavior.

---

# Internal Behavior

When a target enters:

```
area_entered
      |
      v
_check target
      |
      v
can_hit()
      |
      v
apply_hit()
      |
      v
receive_hit()
      |
      v
emit signals
```

When a target exits:

```
area_exited
      |
      v
Remove from hit cache
```

---

# Summary

`HitboxComponent` provides a simple and reusable way to create combat attacks in Godot.

It handles:

- Detecting targets.
- Validating hits.
- Applying damage.
- Managing repeated hits.
- Broadcasting combat events.

Together with `HurtboxComponent` and `HealthComponent`, it creates a flexible modular combat framework for EverKit.
