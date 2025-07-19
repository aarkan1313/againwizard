# Enemy System Analysis

## Overview

The FFS Wizard RPG implements a sophisticated, modular enemy system built on Godot 4.4.1's CharacterBody2D physics with abilities-only combat, data-driven configuration, and performance optimization for large-scale encounters. The system supports multiple AI behaviors, visual attack indicators, and scalable spawning for wave-based survival gameplay.

## Core Enemy Architecture

### Main Enemy Class

**File Path**: `res://scripts/Enemy.gd`  
**Extends**: CharacterBody2D  
**Scene Path**: `res://scenes/Enemy.tscn`

The primary enemy implementation uses a component-based architecture with abilities-only combat:

```gdscript
extends CharacterBody2D
class_name Enemy

# Core properties (preserved from original)
@export var enemy_data: EnemyData
@export var enemy_type: String = "goblin"
var health: float = 100.0
var max_health: float = 100.0
var damage: float = 20.0
var speed: float = 150.0
var xp_reward: int = 10
var wave_multipliers: Dictionary = {}

# NEW: Abilities-only system components
var health_component: HealthComponent
var movement_component: MovementComponent
var ability_manager: AbilityManager  # NEW: Single combat system
var enemy_abilities: EnemyAbilitiesSimple  # Execution component
```

#### Component Initialization

```gdscript
func setup_components():
    """Setup core components for abilities-only system"""
    
    # Health component (unchanged)
    health_component = HealthComponent.new()
    health_component.name = "HealthComponent"
    add_child(health_component)
    health_component.max_health = max_health
    health_component.current_health = min(health, max_health)  # CRITICAL FIX: Ensure health doesn't exceed max
    
    # Movement component (unchanged)
    movement_component = MovementComponent.new()
    movement_component.name = "MovementComponent"
```

#### Performance Optimizations

**Lazy Health Bar Updates** - 40-50% UI update reduction:
```gdscript
# OPTIMIZATION: Lazy health bar updates for 40-50% UI update reduction
var _last_health_ratio: float = 1.0
const HEALTH_UPDATE_THRESHOLD: float = 0.05  # Only update if health changes by 5%
```

**Collision Layer Configuration**:
```gdscript
func _force_collision_settings():
    """Force collision settings to override scene file values"""
    collision_layer = 2  # Enemies are on layer 2
    collision_mask = 5   # Collide with player (1) and environment (4)
```

## Enemy Spawning System

**File Path**: `res://scripts/EnemySpawner.gd`  
**Purpose**: Manages enemy spawning with wave progression and weighted distribution

### Dynamic Enemy Loading

```gdscript
extends Node
class_name EnemySpawner

# Enemy spawn percentage caps and weights
var enemy_spawn_config: Dictionary = {
    "goblin": {"weight": 35, "max_percentage": 45},
    "skeleton": {"weight": 30, "max_percentage": 35},
    "orc": {"weight": 20, "max_percentage": 25},
    "wizard": {"weight": 10, "max_percentage": 15},
    "golem": {"weight": 5, "max_percentage": 7}
}
```

### Wave-Based Spawn Rate Scaling

```gdscript
func _update_spawn_settings():
    if not WaveManager:
        current_spawn_interval = base_spawn_interval
        return
    
    var wave_info = WaveManager.get_wave_info()
    
    # Increase spawn rate with higher waves (shorter intervals)
    var wave_multiplier = 1.0 - (wave_info.current_wave - 1) * 0.15
    wave_multiplier = max(wave_multiplier, 0.15)  # Minimum 0.15x interval (6.67x spawn rate)
    
    current_spawn_interval = base_spawn_interval * wave_multiplier
```

### Dynamic Scene Loading

The spawner loads specific enemy scenes based on type:
```gdscript
# No longer load a single enemy scene - we load specific ones per enemy type
# Individual enemy scenes: res://scenes/enemies/{Type}.tscn
```

## AI Controller System

**File Path**: `res://scripts/enemies/EnemyAIController.gd`  
**Purpose**: Advanced enemy AI with multiple behavior patterns and state management

### AI State Machine

```gdscript
extends Node
class_name EnemyAIController

var state: String = "chasing"  # idle, chasing, attacking, retreating, casting - Start chasing immediately
var state_timer: float = 0.0
var min_state_duration: float = 0.0  # Prevents state thrashing

# State duration constants
const MIN_ATTACKING_DURATION: float = 0.5
const MIN_CASTING_DURATION: float = 0.2
const MIN_STATE_CHANGE_INTERVAL: float = 0.3
```

### Behavior-Specific Configuration

```gdscript
func setup(parent_enemy: Node, data: EnemyData):
    # Set preferred distance based on AI behavior
    match enemy_data.ai_behavior:
        "melee_aggressive":
            preferred_distance = attack_range * 0.8
        "ranged_kiting":
            preferred_distance = attack_range * 0.5  # Closer for more frequent attacks
        "support_healing":
            preferred_distance = attack_range * 0.9
```

### Performance Optimizations

**Cached Player References**:
```gdscript
var cached_player_reference: Node = null
var player_cache_timer: float = 0.0
const PLAYER_CACHE_INTERVAL: float = 1.0  # Cache player for 1 second
```

**Position Update Throttling**:
```gdscript
var position_update_interval: float = 0.2  # Update desired position every 200ms
```

## Data-Driven Enemy Configuration

**File Path**: `res://scripts/data/EnemyData.gd`  
**Extends**: Resource

### Enemy Data Structure

```gdscript
extends Resource
class_name EnemyData

@export_group("Basic Info")
@export var enemy_name: String = "Goblin"
@export var enemy_type: String = "goblin"
@export var description: String = "A small, aggressive creature"

@export_group("Base Stats")
@export var base_health: float = 40.0
@export var base_damage: float = 8.0
@export var base_speed: float = 120.0
@export var base_xp: float = 8.0

@export_group("Behavior")
@export var ai_behavior: String = "melee_aggressive"  # melee_aggressive, ranged_kiting, support_healing
@export var attack_range: float = 50.0
@export var detection_range: float = 200.0
@export var movement_pattern: String = "direct"  # direct, circling, hit_and_run
```

### Collision Configuration

```gdscript
@export_group("Collision Settings")
@export var collision_radius: float = 20.0  # Main hitbox size (for movement/spells hitting enemy)
@export var damage_area_radius: float = 32.0  # Contact damage reach (how close player needs to be)
@export var main_collision_offset: Vector2 = Vector2.ZERO  # Position offset for main collision shape
@export var damage_area_offset: Vector2 = Vector2.ZERO  # Position offset for damage area shape
```

### Auto-Collision Adjustment

```gdscript
func auto_adjust_collision_to_sprite() -> bool:
    # Auto-adjust collision sizes based on sprite dimensions
    var texture = load(sprite_path) as Texture2D
    var sprite_size = texture.get_size()
    var scaled_size = Vector2(sprite_size.x * sprite_scale.x, sprite_size.y * sprite_scale.y)
    
    # Calculate collision sizes based on sprite bounds
    # Main collision: 70% of sprite width/height (smaller, tighter collision)
    collision_radius = min(scaled_size.x, scaled_size.y) * 0.35
    
    # Damage area: 85% of sprite width/height (larger, for contact damage)
    damage_area_radius = min(scaled_size.x, scaled_size.y) * 0.425
```

### Individual Enemy Data Files

The system uses individual `.tres` resource files for each enemy type:

- **`goblin_data.tres`**: Melee aggressive, earth affinity, fire weakness
- **`wizard_data.tres`**: Ranged kiting, dark affinity, light weakness  
- **`golem_data.tres`**: Heavy tank, earth affinity, lightning weakness
- **`skeleton_data.tres`**: Ranged with bone arrow projectiles
- **`orc_data.tres`**: Melee warrior with cleave attacks
- **`slime_data.tres`**: Bouncing creature with unique movement

## Enemy Abilities System

**File Path**: `res://scripts/enemies/EnemyAbilities.gd`  
**Purpose**: Executes enemy abilities with visual indicators and 360-degree attack capability

### Ability Types and Visual Indicators

```gdscript
# Ability types: ranged, melee, AOE, buff, heal
# Visual attack indicators with warning periods
# 360-degree attack capability
# Accelerating flash effects during casting
```

The abilities system provides visual attack indicators that warn players of incoming attacks, with flash effects that accelerate during casting phases.

### Projectile Management

**File Path**: `res://scripts/enemies/EnemyProjectile.gd**  
**Purpose**: Enemy-fired projectiles with proper collision detection

```gdscript
# Collision layers: Layer 4 for enemy projectiles, detects player layer
# Damage types: physical, fire, ice, poison, arcane with visual modulation
# Piercing capability with target tracking
# Range and lifetime management
```

## Performance Optimization Systems

### Enemy Pool System

**File Path**: `res://scripts/pools/EnemyPool.gd`  
**Purpose**: Object pooling for enemy recycling to reduce memory allocation

Features:
- State reset on enemy reuse
- Health restoration 
- Component cleanup
- Memory leak prevention

### LOD (Level of Detail) Management

**File Path**: `res://spatial_collision_system/autoloads/EnemyLODManager.gd`  
**Purpose**: Performance scaling for massive enemy counts

#### LOD Levels and Thresholds

```gdscript
# LOD Levels:
# FULL: Full physics, AI, collision (max 50 enemies)
# SIMPLIFIED: Reduced physics, basic AI (max 150 enemies)  
# MINIMAL: Movement only, no collision
# DISABLED: No updates except position

# Distance thresholds: 200m, 500m, 1000m for LOD transitions
```

### Enhanced Collision System

**Files**: 
- `/mnt/c/FFS/spatial_collision_system/integration/Enemy_Enhanced.gd`
- `/mnt/c/FFS/spatial_collision_system/integration/EnemyAIController_Enhanced.gd`

Features:
- Mass-based collision forces
- Spatial grid registration for O(1) neighbor detection
- Separation force system to prevent enemy clustering

## Enemy Scene Structure

### Individual Enemy Scenes

The system uses separate scene files for each enemy type:

- `/mnt/c/FFS/godot/Game10/scenes/enemies/Goblin.tscn`
- `/mnt/c/FFS/godot/Game10/scenes/enemies/Wizard.tscn`
- `/mnt/c/FFS/godot/Game10/scenes/enemies/Golem.tscn`
- `/mnt/c/FFS/godot/Game10/scenes/enemies/Skeleton.tscn`
- `/mnt/c/FFS/godot/Game10/scenes/enemies/Orc.tscn`
- `/mnt/c/FFS/godot/Game10/scenes/enemies/Slime.tscn`
- `/mnt/c/FFS/godot/Game10/scenes/enemies/Elemental.tscn`

### Supporting Scene Files

- `/mnt/c/FFS/godot/Game10/scenes/Enemy.tscn` - Base enemy template
- `/mnt/c/FFS/godot/Game10/scenes/projectiles/EnemyProjectile.tscn` - Enemy projectile template
- `/mnt/c/FFS/godot/Game10/scenes/effects/EnemyDeath.tscn` - Death effect
- `/mnt/c/FFS/godot/Game10/scenes/test/EnemyTestScene.tscn` - Testing environment

## Enemy Types and Behaviors

### 1. Goblin
- **AI Behavior**: `melee_aggressive`
- **Combat Style**: Fast melee aggressor with speed boost ability
- **Stats**: Low health, moderate damage, high speed
- **Special**: Earth affinity, fire weakness

### 2. Wizard  
- **AI Behavior**: `ranged_kiting`
- **Combat Style**: Ranged kiter with fireball projectiles
- **Stats**: Moderate health, high damage, low speed
- **Special**: Dark affinity, light weakness

### 3. Golem
- **AI Behavior**: Tank focused
- **Combat Style**: Tank with AOE earth slam and stone strike
- **Stats**: High health, high damage, very low speed
- **Special**: Earth affinity, lightning weakness

### 4. Skeleton
- **AI Behavior**: `ranged_kiting`
- **Combat Style**: Ranged with bone arrow projectiles
- **Stats**: Low health, moderate damage, moderate speed

### 5. Orc
- **AI Behavior**: `melee_aggressive`
- **Combat Style**: Melee warrior with cleave attacks
- **Stats**: High health, high damage, low speed

### 6. Slime
- **AI Behavior**: Unique bouncing movement
- **Combat Style**: Bouncing creature with unique movement patterns
- **Stats**: Moderate health, low damage, variable speed

## Debug and Monitoring Systems

### Debug Tracking System

**File Path**: `res://scripts/debug/EnemyDebugTracker.gd`  
**Purpose**: Combat tracking and enemy monitoring

Features:
- Numbered enemy naming (Goblin #1, Wizard #3)
- Ability usage tracking
- Damage dealt statistics  
- Spawn count monitoring by type

### Component Interface

**File Path**: `res://scripts/interfaces/IEnemyComponent.gd`  
**Purpose**: Standardized component communication

Features:
- Lifecycle management
- Error handling
- State validation

## Integration with Game Systems

### Wave System Integration

The enemy system integrates with WaveManager for progressive difficulty:
- Wave-based spawn rate increases
- Enemy stat multipliers based on wave number
- Dynamic enemy type distribution

### Player Interaction

- Collision detection with player spells (Layer 2)
- XP reward system integration
- Damage feedback and visual effects
- Death event broadcasting through GameEvents

### Performance Integration

- Chunk-based spawning for open-world systems
- Spatial grid optimization for collision detection
- LOD system for performance scaling
- Object pooling for memory management

## Technical Implementation Highlights

### Abilities-Only Combat System

The enemy system uses a unified abilities-only combat approach, removing three overlapping attack systems:
- Single AbilityManager for all combat decisions
- Consistent ability execution through EnemyAbilities component
- 360-degree attack capability with circular collision detection

### Memory Management

- Proper cleanup systems prevent memory leaks
- Object pooling reduces garbage collection
- Weak references in signal connections
- Safe node validation throughout the system

### Visual Polish

- Attack indicators warn players of incoming attacks
- Damage feedback with color flashing
- Death animations and effects
- Health bar optimization with threshold-based updates

This comprehensive enemy system demonstrates production-quality implementation with excellent scalability, performance optimization, and gameplay polish suitable for both small encounters and large-scale horde survival gameplay.