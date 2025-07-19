# Singleton Architecture Analysis

## Autoload System Overview

The FFS game uses **18 autoload singletons** for global state management and cross-system coordination. These are defined in `project.godot` and form the backbone of the game's architecture.

### Autoload Hierarchy & Dependencies

#### Tier 1: Foundation Systems (No Dependencies)
```gdscript
# Core infrastructure singletons
UnifiedDebugSystem="*res://scripts/debug/UnifiedDebugSystem.gd"
CollisionValidator="*res://scripts/CollisionValidator.gd" 
GameConfig="*res://scripts/singletons/GameConfig.gd"
```

#### Tier 2: Event & State Management
```gdscript
# Event bus and core state
GameEvents="*res://scripts/GameEvents.gd"
GameStateManager="*res://scripts/core/GameStateManager.gd"
SettingsManager="*res://scripts/core/SettingsManager.gd"
```

#### Tier 3: Game Logic Coordinators
```gdscript
# Primary game systems
GameManager="*res://scripts/GameManager.gd"
WaveManager="*res://scripts/WaveManager.gd"
InputHandler="*res://scripts/InputHandler.gd"
BiomeService="*res://scripts/BiomeService.gd"
```

#### Tier 4: Data & Persistence
```gdscript
# Save system hierarchy
SaveManager="*res://scripts/core/save/SaveManager.gd"
MetaSaveManager="*res://scripts/core/MetaSaveManager.gd"
RunSaveManager="*res://scripts/core/RunSaveManager.gd"
```

#### Tier 5: Specialized Systems
```gdscript
# UI and specialized managers
SceneTransition="*res://scripts/ui/SceneTransition.gd"
StatAllocationManager="*res://scripts/items/managers/StatAllocationManager.gd"
CharacterSheetManager="*res://scripts/items/managers/CharacterSheetManager.gd"
AchievementNotificationManager="*res://scripts/singletons/AchievementNotificationManager.gd"
PlayerTracker="*res://scripts/singletons/PlayerTracker.gd"
```

## Core Singleton Analysis

### GameManager.gd - Central Game Coordinator

**Location**: `res://scripts/GameManager.gd`  
**Purpose**: Central game state management and coordination

```gdscript
extends Node

# Core game state
enum GameState { PLAYING, PAUSED, GAME_OVER }
var current_state: GameState = GameState.PLAYING
var previous_state: GameState = GameState.PLAYING

# Player state tracking
var player_reference = null
var player_health: float = 100.0
var player_max_health: float = 100.0

# Game progression
var current_wave: int = 1
var enemies_killed_this_wave: int = 0
var total_enemies_killed: int = 0
var total_xp_earned: int = 0
```

**Key Responsibilities**:
- Game state machine management (PLAYING/PAUSED/GAME_OVER)
- Player reference management and state tracking
- Game progression coordination
- Integration with chunk system for world management

### GameEvents.gd - Event Bus System

**Location**: `res://scripts/GameEvents.gd`  
**Purpose**: Global event bus for cross-system communication

```gdscript
extends Node

# Core game events
signal player_died
signal player_health_changed(current_health: float, max_health: float)
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy_type: String, xp_value: int)
signal spell_cast(spell_name: String, caster: Node)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal xp_gained(amount: int)
signal achievement_unlocked(achievement_id: String)
```

**Architecture Pattern**: Implements mediator pattern for loose coupling between systems.

### GameConfig.gd - Configuration Management

**Location**: `res://scripts/singletons/GameConfig.gd`  
**Purpose**: Centralized configuration with live tuning support

```gdscript
extends Node

signal config_loaded()
signal config_error(error_message: String)

var constants: GameConstants
var config_file_path: String = "res://data/game_constants.tres"
var is_loaded: bool = false
var debug_mode: bool = true
```

**Configuration Categories**:
- **AI Performance**: Update intervals, caching, spam prevention
- **Enemy Behavior**: Separation, contact damage, immunity
- **Visual Effects**: Flash duration, fade effects, pulse speed
- **Performance**: Enemy limits, particle scaling, logging probability
- **Debug Logging**: Categories, levels, filtering

**Live Tuning Support**:
```gdscript
func set_ai_update_interval(value: float):
    if is_loaded and value > 0:
        constants.ai_update_interval = value
        print("🔧 GameConfig: AI update interval set to ", value)

func set_particle_multiplier(value: float):
    if is_loaded and value >= 0:
        constants.particle_count_multiplier = value
        print("🔧 GameConfig: Particle multiplier set to ", value)
```

## Save System Singleton Hierarchy

### SaveManager.gd - Primary Save Coordination

**Location**: `res://scripts/core/save/SaveManager.gd`  
**Purpose**: Coordinate all save/load operations

**Integration Pattern**: Orchestrates MetaSaveManager and RunSaveManager for layered persistence.

### MetaSaveManager.gd - Persistent Progression

**Location**: `res://scripts/core/MetaSaveManager.gd`  
**Purpose**: Meta-progression and achievements across all runs

```gdscript
extends Node

# Meta progression data structure
var meta_data: Dictionary = {
    "total_playtime": 0.0,
    "achievements_unlocked": [],
    "global_stats": {
        "total_enemies_killed": 0,
        "total_spells_cast": 0,
        "highest_wave_reached": 1
    },
    "unlocked_content": [],
    "preferences": {}
}
```

### RunSaveManager.gd - Session Data

**Location**: `res://scripts/core/RunSaveManager.gd`  
**Purpose**: Current session-specific save data

```gdscript
extends Node

# Current session data
var run_data: Dictionary = {
    "session_start_time": "",
    "current_run_stats": {
        "enemies_killed_this_run": 0,
        "spells_cast_this_run": 0,
        "damage_taken_this_run": 0
    },
    "temporary_bonuses": [],
    "session_achievements": []
}
```

## Specialized Singleton Systems

### PlayerTracker.gd - Player State Management

**Location**: `res://scripts/singletons/PlayerTracker.gd`  
**Purpose**: Track player state across scene transitions

### AchievementNotificationManager.gd - Achievement System

**Location**: `res://scripts/singletons/AchievementNotificationManager.gd`  
**Purpose**: Achievement unlocking and notification display

### InputHandler.gd - Global Input Processing

**Location**: `res://scripts/InputHandler.gd`  
**Purpose**: Centralized input processing and action mapping

```gdscript
extends Node

# Input action processing
func get_movement_vector() -> Vector2:
    var vector = Vector2.ZERO
    vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    return vector

func is_spell_cast_pressed(slot: int) -> bool:
    return Input.is_action_just_pressed("spell_" + str(slot))
```

## Singleton Initialization Patterns

### Standard Singleton Pattern
```gdscript
extends Node

var _instance_ready: bool = false

func _ready():
    print("✅ [SingletonName] initialized")
    _instance_ready = true
    _initialize_systems()

func _initialize_systems():
    # System-specific initialization
    pass
```

### Dependency-Aware Initialization
```gdscript
func _ready():
    # Wait for dependencies if needed
    if not _check_dependencies():
        await get_tree().process_frame
        call_deferred("_check_dependencies")
    else:
        _initialize_with_dependencies()
```

### Signal-Based Coordination
```gdscript
func _ready():
    # Connect to other singletons
    if GameEvents:
        GameEvents.player_died.connect(_on_player_died)
    
    # Emit ready signal for dependent systems
    singleton_ready.emit()
```

## Cross-Singleton Communication Patterns

### Event Bus Pattern (Preferred)
```gdscript
# Instead of direct singleton calls
func notify_player_death():
    GameEvents.player_died.emit()
    # Other singletons listen to this event
```

### Direct Reference Pattern (When Needed)
```gdscript
# For immediate data access
func get_player_health() -> float:
    if GameManager and GameManager.player_reference:
        return GameManager.player_health
    return 0.0
```

### Weak Reference Pattern (Debug/Tracking)
```gdscript
# For temporary tracking without memory leaks
var player_ref: WeakRef = weakref(player)
```

## Singleton Performance Considerations

### Memory Management
- **Persistent Data**: Singletons persist across scene changes
- **Memory Monitoring**: QualityGate tracks singleton memory usage
- **Data Cleanup**: Periodic cleanup of temporary data

### Update Frequency Optimization
```gdscript
# Variable update intervals for performance
var update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.5

func _process(delta):
    update_timer += delta
    if update_timer >= UPDATE_INTERVAL:
        _perform_update()
        update_timer = 0.0
```

### Conditional Processing
```gdscript
# Skip processing when not needed
func _process(delta):
    if current_state != GameState.PLAYING:
        return
    
    _process_game_logic(delta)
```

## Singleton Testing & Validation

### Accessibility Validation
```gdscript
# QualityGate validates singleton accessibility
func _check_autoload_health(check_result: Dictionary):
    var critical_autoloads = [
        {"name": "GameEvents", "ref": GameEvents},
        {"name": "GameManager", "ref": GameManager},
        {"name": "InputHandler", "ref": InputHandler}
    ]
    
    for autoload in critical_autoloads:
        if not autoload.ref:
            check_result.issues.append("Autoload failure: " + autoload.name)
```

### Dependency Validation
```gdscript
# DependencyValidator checks singleton relationships
static func validate_singleton_dependencies() -> bool:
    # Check critical singleton chains
    if not GameEvents or not GameManager:
        return false
    
    # Validate initialization order
    return _check_initialization_order()
```

---

*The singleton architecture provides robust global state management while maintaining clear separation of concerns and testable interfaces.*