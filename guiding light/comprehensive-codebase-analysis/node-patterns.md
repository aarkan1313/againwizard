# Common Node Patterns

## Overview

This document outlines the common node patterns and architectural conventions used throughout the FFS Wizard RPG project. These patterns provide consistency, maintainability, and performance optimization across all game entities.

---

## Player Setup Patterns

### Component-Based Player Architecture
**Primary Scene**: `scenes/gameplay/Player.tscn`  
**Root Node**: CharacterBody2D

#### Standard Player Node Structure
```
Player (CharacterBody2D) - Player.gd
├── PlayerSprite (Sprite2D)
├── PlayerCollision (CollisionShape2D)
├── DamageReceiver (Area2D)
│   └── DamageCollision (CollisionShape2D)
├── HealthComponent (Node) - HealthComponent.gd
├── MovementComponent (Node) - MovementComponent.gd
├── SpellComponent (Node) - SpellComponent.gd
├── PlayerVisuals (Node) - PlayerVisuals.gd
├── CameraComponent (Node) - CameraComponent.gd
└── StatSheet (Node) - PlayerStatSheet.gd
```

#### Component Initialization Pattern
```gdscript
# Player.gd initialization
@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var spell_component: SpellComponent = $SpellComponent
@onready var player_visuals: PlayerVisuals = $PlayerVisuals
@onready var camera_component: CameraComponent = $CameraComponent
@onready var stat_sheet: PlayerStatSheet = $StatSheet

func _ready():
    initialize_components()
    connect_component_signals()
    validate_component_setup()
```

#### Component Communication Pattern
- **Dependency Injection**: Components receive references during initialization
- **Event Communication**: Components use GameEvents for loose coupling
- **Direct References**: Parent-child communication via @onready references

### Player Factory Pattern
**Script**: `scripts/factories/PlayerBuilder.gd`  
**Purpose**: Safe player instantiation with proper component setup

```gdscript
# PlayerBuilder usage pattern
static func create_player() -> Player:
    var player_scene = preload("res://scenes/gameplay/Player.tscn")
    var player = player_scene.instantiate()
    
    # Initialize components with dependencies
    player.initialize_components()
    return player
```

---

## Enemy/NPC Structures

### Base Enemy Pattern
**Template Scene**: `scenes/Enemy.tscn`  
**Root Node**: CharacterBody2D

#### Standard Enemy Node Structure
```
Enemy (CharacterBody2D) - Enemy.gd
├── EnemySprite (Sprite2D)
├── EnemyCollision (CollisionShape2D)
├── HealthBar (ProgressBar)
├── HealthComponent (Node) - HealthComponent.gd
├── MovementComponent (Node) - MovementComponent.gd
├── AbilityManager (Node) - AbilityManager.gd
└── EnemyAIController (Node) - EnemyAIController.gd
```

#### Enemy Type Variations
Each enemy type inherits the base structure with specialized configurations:

**Wizard Enemy**:
```
Wizard (CharacterBody2D) - Enemy.gd
├── [Base structure]
├── EnemyAbilities (Node) - EnemyAbilities.gd
└── Additional wizard-specific components
```

**Golem Enemy**:
```
Golem (CharacterBody2D) - Enemy.gd
├── [Base structure]
├── HeavyAttackComponent (Node)
└── GroundSlamAbility (Node)
```

#### Enemy Initialization Pattern
```gdscript
# Enemy.gd initialization from data
func initialize_from_data(enemy_data: EnemyData):
    max_health = enemy_data.max_health
    sprite.texture = enemy_data.sprite_texture
    setup_abilities(enemy_data.abilities)
    apply_wave_scaling()
```

### Enemy Spawning Pattern
**Manager**: `scripts/EnemySpawner.gd`  
**Pattern**: Dynamic scene loading based on enemy type

```gdscript
# EnemySpawner pattern
func spawn_enemy_at_position(enemy_type: String, position: Vector2):
    var scene_path = "res://scenes/enemies/" + enemy_type.capitalize() + ".tscn"
    var enemy_scene = load(scene_path)
    var enemy = enemy_scene.instantiate()
    
    enemy.global_position = position
    enemy.initialize_from_data(get_enemy_data(enemy_type))
    get_tree().current_scene.add_child(enemy)
```

---

## Collectible/Pickup Patterns

### XP Orb Pattern
**Scene**: `scenes/items/XPOrb.tscn`  
**Root Node**: Area2D

#### XP Orb Node Structure
```
XPOrb (Area2D) - XPOrb.gd
├── Sprite2D (animated orb visual)
├── CollisionShape2D (pickup detection)
└── PickupTimer (Timer) - prevents immediate pickup
```

#### Pickup Behavior Pattern
```gdscript
# XPOrb.gd pickup pattern
@export var xp_value: int = 10
@export var magnet_range: float = 150.0
@export var magnet_speed: float = 400.0

func _ready():
    body_entered.connect(_on_body_entered)
    create_spawn_animation()
    create_floating_animation()

func _physics_process(delta):
    if can_pickup:
        handle_magnet_behavior(delta)

func collect(player: Node2D):
    GameEvents.emit_signal("xp_collected", xp_value)
    create_collection_effect()
    queue_free()
```

### Item Drop Pattern
**Usage**: Enemy death drops, environmental pickups

```gdscript
# Generic item drop creation
func create_item_drop(item_type: String, position: Vector2, value: int):
    var item_scene = preload("res://scenes/items/" + item_type + ".tscn")
    var item = item_scene.instantiate()
    item.global_position = position
    item.set_value(value)
    get_tree().current_scene.add_child(item)
```

---

## UI Component Patterns

### HUD Component Structure
**Scene**: `scenes/ui/PlayerUI.tscn`  
**Root Node**: Control

#### PlayerUI Node Structure
```
PlayerUI (Control) - PlayerUI.gd
├── HealthContainer (HBoxContainer)
│   ├── HealthLabel (Label)
│   └── HealthBar (ProgressBar)
├── ManaContainer (HBoxContainer)
│   ├── ManaLabel (Label)
│   └── ManaBar (ProgressBar)
├── XPContainer (VBoxContainer)
│   ├── XPLabel (Label)
│   ├── XPBar (ProgressBar)
│   └── LevelLabel (Label)
└── SpellToolbar (Control) - instance of SpellToolbar.tscn
```

#### UI Update Pattern
```gdscript
# PlayerUI.gd update pattern
func _ready():
    GameEvents.player_health_changed.connect(_on_health_changed)
    GameEvents.player_mana_changed.connect(_on_mana_changed)
    GameEvents.experience_gained.connect(_on_xp_gained)

func _on_health_changed(current: float, maximum: float):
    health_bar.value = (current / maximum) * 100.0
    health_label.text = "%d / %d" % [current, maximum]
```

### Spell Toolbar Pattern
**Scene**: `scenes/ui/SpellToolbar.tscn`  
**Root Node**: Control

#### Spell Toolbar Structure
```
SpellToolbar (Control) - SpellToolbar.gd
└── SpellContainer (HBoxContainer)
    ├── SpellSlot1 (Button) - SpellSlot.gd
    ├── SpellSlot2 (Button) - SpellSlot.gd
    └── [...up to 10 slots]
```

#### Spell Slot Pattern
```gdscript
# SpellSlot.gd pattern
@export var slot_index: int = 0
@export var assigned_spell: SpellData

func _ready():
    pressed.connect(_on_spell_activated)
    update_visual_state()

func assign_spell(spell_data: SpellData):
    assigned_spell = spell_data
    update_icon()
    update_tooltip()

func _on_spell_activated():
    if assigned_spell and can_cast():
        GameEvents.emit_signal("spell_cast_requested", slot_index)
```

### Menu Pattern
**Examples**: MainMenu.tscn, EscapeMenu.tscn  
**Root Node**: Control

#### Standard Menu Structure
```
Menu (Control) - [Menu].gd
├── Background (ColorRect/TextureRect)
├── MainPanel (VBoxContainer)
│   ├── TitleLabel (Label)
│   ├── ButtonContainer (VBoxContainer)
│   │   ├── Button1 (Button)
│   │   ├── Button2 (Button)
│   │   └── Button3 (Button)
│   └── VersionLabel (Label)
└── ConfirmationDialog (AcceptDialog)
```

---

## Particle System Usage

### Heal Effect Pattern
**Scene**: `scenes/effects/HealEffect.tscn`  
**Root Node**: Node2D

#### Heal Effect Structure
```
HealEffect (Node2D) - HealEffect.gd
├── MainParticles (GPUParticles2D)
├── OrbitalCluster1 (Node2D)
├── OrbitalCluster2 (Node2D)
├── OrbitalCluster3 (Node2D)
└── EffectTimer (Timer)
```

#### Particle Effect Pattern
```gdscript
# HealEffect.gd pattern
func _ready():
    setup_particles()
    create_orbital_motion()
    start_effect()

func setup_particles():
    particles.emitting = true
    particles.amount = particle_count
    particles.lifetime = effect_duration
    configure_particle_material()

func create_orbital_motion():
    for i in range(3):
        var cluster = create_orbital_cluster(i * 120.0)
        add_child(cluster)
```

### Damage Number Pattern
**Scene**: `scenes/ui/DamageNumber.tscn`  
**Root Node**: Node2D

#### Damage Number Structure
```
DamageNumber (Node2D) - DamageNumber.gd
├── DamageLabel (Label)
└── AnimationPlayer (AnimationPlayer) [optional]
```

#### Floating Text Pattern
```gdscript
# DamageNumber.gd pattern
func setup(damage: float, position: Vector2, color: Color):
    damage_amount = damage
    global_position = position
    damage_label.text = str(int(damage))
    damage_label.modulate = color
    play_animation()

func play_animation():
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position", position + Vector2(0, -40), 1.4)
    tween.tween_property(damage_label, "modulate:a", 0.0, 0.7).set_delay(0.7)
```

---

## Camera2D Setup and Following

### Camera Component Pattern
**Script**: `scripts/components/CameraComponent.gd`  
**Purpose**: Player camera management

#### Camera Setup Structure
```
Player (CharacterBody2D)
└── CameraComponent (Node)
    └── PlayerCamera (Camera2D)
```

#### Camera Following Pattern
```gdscript
# CameraComponent.gd pattern
@export var follow_speed: float = 5.0
@export var look_ahead_distance: float = 100.0

func _ready():
    camera = Camera2D.new()
    add_child(camera)
    camera.enabled = true

func _process(delta):
    update_camera_position(delta)
    apply_screen_shake(delta)

func update_camera_position(delta):
    var target_position = player.global_position
    if player.velocity.length() > 50:
        target_position += player.velocity.normalized() * look_ahead_distance
    
    camera.global_position = camera.global_position.lerp(target_position, follow_speed * delta)
```

---

## Area2D Usage Patterns

### Trigger Zone Pattern
**Purpose**: Environmental triggers, pickup detection, spell areas

#### Basic Trigger Structure
```
TriggerZone (Area2D)
├── TriggerCollision (CollisionShape2D)
└── Optional visual feedback
```

#### Trigger Implementation Pattern
```gdscript
# Generic trigger pattern
extends Area2D

signal triggered(body)

func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body):
    if body.is_in_group("player"):
        handle_trigger_activation(body)
        triggered.emit(body)

func handle_trigger_activation(body):
    # Override in specific trigger implementations
    pass
```

### Damage Area Pattern
**Purpose**: Spell areas, enemy attacks, environmental hazards

#### Damage Area Structure
```
DamageArea (Area2D) - DamageArea.gd
├── DamageCollision (CollisionShape2D)
├── VisualEffect (Node2D) [optional]
└── DamageTimer (Timer) [for DOT effects]
```

#### Damage Area Implementation
```gdscript
# DamageArea.gd pattern
@export var damage: float = 10.0
@export var damage_interval: float = 1.0
@export var affects_groups: Array[String] = ["player"]

func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body):
    if should_affect_body(body):
        apply_damage(body)
        start_continuous_damage(body)

func should_affect_body(body: Node) -> bool:
    for group in affects_groups:
        if body.is_in_group(group):
            return true
    return false
```

---

## Performance Optimization Patterns

### Object Pooling Pattern
**Usage**: Projectiles, damage numbers, particle effects

#### Pool Manager Structure
```gdscript
# ObjectPool.gd pattern
class_name ObjectPool

var pool: Array = []
var scene_template: PackedScene
var max_pool_size: int = 50

func get_object():
    if pool.size() > 0:
        return pool.pop_back()
    else:
        return scene_template.instantiate()

func return_object(obj):
    if pool.size() < max_pool_size:
        obj.reset() # Implement in pooled objects
        pool.append(obj)
    else:
        obj.queue_free()
```

### Component Caching Pattern
**Purpose**: Optimize frequent component access

```gdscript
# Component caching pattern
@onready var cached_health: HealthComponent = $HealthComponent
@onready var cached_movement: MovementComponent = $MovementComponent

func _ready():
    # Cache expensive lookups
    cache_component_references()
    validate_cached_components()

func cache_component_references():
    # Pre-cache any get_node() calls that happen frequently
    pass
```

### Update Throttling Pattern
**Purpose**: Reduce update frequency for distant or inactive objects

```gdscript
# Update throttling pattern
var update_interval: float = 0.1
var update_timer: float = 0.0

func _process(delta):
    update_timer += delta
    if update_timer >= update_interval:
        perform_update()
        update_timer = 0.0
        
        # Adjust interval based on distance to player
        var distance_to_player = global_position.distance_to(player_position)
        update_interval = min(0.5, distance_to_player / 1000.0)
```

These common node patterns provide a consistent foundation for all game entities while supporting performance optimization and maintainable code architecture. Each pattern includes proper initialization, communication, and cleanup procedures essential for a robust game system.