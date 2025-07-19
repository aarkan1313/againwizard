# Data Structures Analysis

**Location**: Based on actual codebase analysis  
**Project**: FFS Wizard RPG Game (Godot 4.4.1)  
**Purpose**: Comprehensive analysis of data structures, reactive systems, and serialization

---

## Core Data Architecture

### SaveData Container System

**Location**: `/scripts/core/save/SaveData.gd`  
**Extends**: RefCounted  
**Purpose**: Main container implementing separated data architecture

#### Hierarchical Data Structure
```gdscript
# Save version management
const SAVE_VERSION: int = 1
const SAVE_FORMAT_NAME: String = "ExtendoRPG_Enhanced"

# Separated architecture for proper slot management
var character_data: CharacterData = CharacterData.new()  # Meta-progression
var run_data: RunData = RunData.new()                    # Session-specific data
```

#### Compatibility Layer for Legacy Code
```gdscript
# Compatibility properties for existing code transitions
var character_name: String:
    get: return character_data.character_name if character_data else ""
    set(value): if character_data: character_data.character_name = value

var total_playtime: float:
    get: return character_data.total_playtime if character_data else 0.0
    set(value): if character_data: character_data.total_playtime = value
```

### CharacterData - Persistent Progression

**Location**: `/scripts/core/save/CharacterData.gd`  
**Extends**: RefCounted  
**Purpose**: Meta-progression data that survives across runs

#### Character Identity and Core Progression
```gdscript
# Character identity
var character_name: String = ""
var character_created: String = ""

# Persistent progression (survives runs)
var character_level: int = 1
var total_xp: int = 0
var current_xp: float = 0.0  # Current XP towards next level
var available_stat_points: int = 0
```

#### Allocated Stats System
```gdscript
# Base stats (allocated by player - persistent)
var base_intelligence: int = 10
var base_wisdom: int = 10
var base_vitality: int = 10
var base_dexterity: int = 10
```

#### Achievement and Milestone System
```gdscript
# Lifetime achievements and unlocks
var milestone_bonuses_earned: Array = []
var unlocked_spells: Array = ["fireball", "heal"]
var persistent_upgrades: Array = []

# Lifetime statistics tracking
var total_runs_completed: int = 0
var total_kills_lifetime: int = 0
var total_playtime: float = 0.0
var highest_wave_ever: int = 1
var best_run_time: float = 0.0

# Future expansion support
var unlocked_tower_areas: Array = []
var tower_upgrades: Array = []
```

---

## Reactive Stats System

### ReactiveStat - Self-Updating Stats

**Location**: `/scripts/stats/ReactiveStat.gd`  
**Extends**: RefCounted  
**Purpose**: Self-updating stat with dirty flagging and recursion protection

#### Core Reactive Implementation
```gdscript
# Signals for reactive updates
signal value_changed(old_value: float, new_value: float)
signal modifier_added(modifier: StatModifier)
signal modifier_removed(modifier: StatModifier)

# Core stat data with caching
var base_value: float = 0.0
var modifiers: Array[StatModifier] = []
var cached_value: float = 0.0
var is_dirty: bool = true

# Stat metadata
var stat_name: String = ""
var stat_description: String = ""
```

#### Advanced Calculation with Recursion Protection
```gdscript
var _is_calculating: bool = false

func get_final_value() -> float:
    # Prevent infinite recursion in complex stat dependencies
    if _is_calculating:
        push_warning("ReactiveStat: Recursion detected for " + stat_name)
        return cached_value
    
    if is_dirty:
        _is_calculating = true  # Set recursion flag
        var old_value = cached_value
        cached_value = calculate_final_value()
        is_dirty = false
        _is_calculating = false  # Clear recursion flag
        
        # Emit change signal with tolerance for float comparison
        if abs(old_value - cached_value) > 0.001:
            value_changed.emit(old_value, cached_value)
            print("📊 ", stat_name, " changed: ", old_value, " → ", cached_value)
    
    return cached_value
```

### PlayerStatSheet - Complete Stat System

**Location**: `/scripts/stats/PlayerStatSheet.gd`  
**Extends**: StatSheet  
**Purpose**: Player-specific stat sheet with dependency injection pattern

#### Dependency Injection for Save Compatibility
```gdscript
# Dependency injection fields for save system compatibility
var _is_initialized: bool = false

func _init():
    # NO parameters, NO dependencies for save loading compatibility
    super._init(null, "Player")

func initialize():
    if _is_initialized:
        return
    
    # Allow initialization without owner_entity for save loading mode
    if not owner_entity:
        print("⚠️ PlayerStatSheet: Initializing without owner entity (save loading mode)")
    
    setup_player_stats()
    _is_initialized = true
```

---

## Settings and Configuration System

### SettingsManager - Configuration Management

**Location**: `/scripts/core/SettingsManager.gd`  
**Extends**: Node (Autoload singleton)  
**Purpose**: Centralized settings management with validation

#### Settings Structure
```gdscript
var default_settings = {
    "graphics": {
        "fullscreen": false,
        "vsync": true
    },
    "audio": {
        "master_volume": 0.8,
        "sfx_volume": 0.8,
        "music_volume": 0.6
    },
    "gameplay": {
        "show_damage_numbers": true,
        "auto_save_interval": 60.0  # seconds
    }
}
```

#### Settings Validation System
```gdscript
func _validate_setting(category: String, key: String, value):
    match category:
        "audio":
            if key.ends_with("_volume"):
                return clamp(value, 0.0, 1.0)  # Volume range validation
        "gameplay":
            if key == "auto_save_interval":
                return max(30.0, value)  # Minimum 30 seconds
    return value
```

The data structure system demonstrates sophisticated separation of concerns with reactive programming patterns, comprehensive validation, and robust persistence mechanisms.

---

## Table of Contents

1. [Save File Structure](#save-file-structure)
2. [Configuration and Settings Data](#configuration-and-settings-data)
3. [Character Progression Data](#character-progression-data)
4. [World and Level Data](#world-and-level-data)
5. [Spell and Combat Data](#spell-and-combat-data)
6. [Achievement and Notification Systems](#achievement-and-notification-systems)
7. [Data Flow and Relationships](#data-flow-and-relationships)

---

## Save File Structure

### Overview
The save system implements a **separated architecture** distinguishing between meta-progression (persistent across runs) and session-specific data (temporary per-run).

### Core Save Architecture

#### **SaveData** - Primary Container
**Location**: `/scripts/core/save/SaveData.gd`  
**Purpose**: Top-level container for all save information

```gdscript
class_name SaveData extends RefCounted

# Hierarchical structure
var character_data: CharacterData  # Persistent progression
var run_data: RunData             # Current session data

# Metadata
var save_version: int = 1
var save_format: String = "ExtendoRPG_Enhanced"
var save_timestamp: String
var save_created_time: String

# Compatibility properties (legacy access)
var player_name: String:
    get: return character_data.character_name if character_data else ""
var player_level: int:
    get: return character_data.character_level if character_data else 1
```

**Key Features**:
- **Version control** for save migration and compatibility
- **Separated architecture** prevents data mixing
- **JSON serialization** with `to_dictionary()` and `from_dictionary()`
- **Validation system** with `is_valid()` method
- **Legacy compatibility** through property getters

#### **CharacterData** - Meta-Progression
**Location**: `/scripts/core/save/CharacterData.gd`  
**Purpose**: Persistent character advancement that survives death/runs

```gdscript
class_name CharacterData extends RefCounted

# Character identity
var character_name: String
var character_created: String

# Persistent progression
var character_level: int = 1
var total_xp: int = 0
var current_xp: float = 0.0
var available_stat_points: int = 0

# Base stats (allocated by player)
var base_intelligence: int = 10
var base_wisdom: int = 10
var base_vitality: int = 10
var base_dexterity: int = 10

# Lifetime achievements
var milestone_bonuses_earned: Array = []
var unlocked_spells: Array = ["fireball", "heal"]
var persistent_upgrades: Array = []

# Lifetime statistics
var total_runs_completed: int = 0
var total_kills_lifetime: int = 0
var total_playtime: float = 0.0
var highest_wave_ever: int = 1
var best_run_time: float = 0.0

# Tower/Hub progression (future expansion)
var unlocked_tower_areas: Array = []
var tower_upgrades: Array = []
```

**Progression Mechanics**:
- **XP-based leveling**: `level = int(total_xp / 100) + 1`
- **Stat point allocation**: 2 points per level up
- **Milestone system**: Kill-based achievement thresholds
- **Computed health/mana**: Based on allocated stats

#### **RunData** - Session-Specific
**Location**: `/scripts/core/save/RunData.gd`  
**Purpose**: Current session state that resets between runs

```gdscript
class_name RunData extends RefCounted

# Run session info
var run_start_time: float = 0.0
var run_duration: float = 0.0
var run_seed: int = 0

# Current state
var current_wave: int = 1
var current_health: float = 100.0
var current_mana: float = 50.0
var player_position: Vector2 = Vector2.ZERO

# World persistence
var world_seed: int = 0
var current_chunk_position: Vector2 = Vector2.ZERO
var explored_chunks: Array = []

# Phase 5 Enhanced World Features
var discovered_magical_structures: Dictionary = {}
var activated_crystal_formations: Array = []
var wizard_tree_interactions: Dictionary = {}
var ley_line_discoveries: Array = []
var l_system_seeds: Dictionary = {}
var saved_magical_terrain: Dictionary = {}
var elemental_region_data: Dictionary = {}
var biome_evolution_states: Dictionary = {}

# Run-specific upgrades (temporary)
var run_spell_upgrades: Dictionary = {}
var run_temporary_bonuses: Dictionary = {}
var run_equipment: Array = []
```

**Serialization Features**:
- **Vector2i dictionary handling** with string-based keys
- **Magical world persistence** for procedural content
- **L-System seed management** for deterministic generation
- **Environmental modification tracking**

### Save Slot Management

#### **SaveSlotInfo** - Metadata Only
**Location**: `/scripts/core/save/SaveSlotInfo.gd`  
**Purpose**: Lightweight metadata for UI display without full save loading

```gdscript
class_name SaveSlotInfo extends Resource

var slot_number: int = 0
var exists: bool = false
var character_name: String = ""
var level: int = 1
var wave: int = 1
var total_kills: int = 0
var playtime: float = 0.0
var save_date: String = ""
var save_timestamp: int = 0
var file_path: String = ""

func get_display_text() -> String:
    if not exists:
        return "Empty Slot"
    return "%s - Level %d - Wave %d" % [character_name, level, wave]

func get_detailed_info() -> String:
    if not exists:
        return "No save data"
    return "Kills: %d | Time: %s | Saved: %s" % [
        total_kills,
        _format_playtime(playtime),
        save_date
    ]
```

**UI Integration Benefits**:
- Fast slot browsing without heavy loading
- Formatted display text for consistent UI
- Timestamp-based sorting capabilities
- Detailed tooltips and information display

---

## Configuration and Settings Data

### SettingsManager - User Preferences
**Location**: `/scripts/core/SettingsManager.gd`  
**Purpose**: Persistent user configuration and preferences

```gdscript
extends Node

var config = ConfigFile.new()
var settings_path = "user://settings.cfg"

var default_settings = {
    "graphics": {
        "fullscreen": false,
        "vsync": true,
        "resolution": "1920x1080"
    },
    "audio": {
        "master_volume": 0.8,
        "sfx_volume": 0.8,
        "music_volume": 0.6
    },
    "gameplay": {
        "show_damage_numbers": true,
        "auto_save_interval": 60.0,
        "difficulty_scaling": 1.0
    },
    "controls": {
        "mouse_sensitivity": 1.0,
        "keyboard_repeat_delay": 0.5
    }
}
```

**Features**:
- **ConfigFile-based** persistence using Godot's built-in system
- **Validation system** with `_validate_setting()` for type checking
- **Live application** of settings changes via signals
- **Category-based** organization for UI management
- **Default fallbacks** for missing or corrupted values

### GameConstants - Game Configuration
**Location**: `/scripts/data/GameConstants.gd`  
**Purpose**: Data-driven game balance and configuration

```gdscript
class_name GameConstants extends Resource

# Performance tuning
@export var ai_update_interval: float = 0.3
@export var max_simultaneous_enemies: int = 25
@export var chunk_load_distance: int = 3

# Combat balance
@export var base_wave_multiplier: float = 1.2
@export var health_scaling_per_wave: float = 0.2
@export var damage_scaling_factor: float = 1.15

# Character progression
@export var xp_base_requirement: float = 100.0
@export var stat_points_per_level: int = 2
@export var milestone_thresholds: Array[int] = [10, 25, 50, 100, 250, 500, 1000]

# World generation
@export var world_chunk_size: int = 64
@export var biome_transition_distance: float = 32.0
@export var magical_structure_rarity: float = 0.15
```

**Data-Driven Design Benefits**:
- **@export properties** for easy editor tuning
- **Categorized groups** for organized modification
- **Validation methods** for configuration integrity
- **Helper functions** for calculated values

---

## Character Progression Data

### PlayerStatSheet - Reactive Stats System
**Location**: `/scripts/stats/PlayerStatSheet.gd`  
**Purpose**: Player-specific reactive stat calculations with optimization

```gdscript
class_name PlayerStatSheet extends StatSheet

# XP and progression
var current_xp: float = 0.0
var xp_to_next_level: float = 100.0
var total_xp: float = 0.0
var available_stat_points: int = 0

# Direct function calculations (performance optimized)
func get_max_health() -> float:
    var base_value = 100.0 + get_stat_value("vitality") * 5.0 + get_stat_value("level") * 3.0
    var milestone_bonus = _get_milestone_health_bonus()
    return apply_modifiers_to_stat("max_health", base_value + milestone_bonus)

func get_max_mana() -> float:
    var base_value = 50.0 + get_stat_value("intelligence") * 3.0 + get_stat_value("wisdom") * 2.0
    var milestone_bonus = _get_milestone_mana_bonus()
    return apply_modifiers_to_stat("max_mana", base_value + milestone_bonus)

func get_movement_speed() -> float:
    var base_value = 300.0 + get_stat_value("dexterity") * 2.0
    return apply_modifiers_to_stat("movement_speed", base_value)
```

### StatSheet - Base Stats Architecture
**Location**: `/scripts/stats/StatSheet.gd`  
**Purpose**: Foundation for all stat systems with reactive updates

```gdscript
class_name StatSheet extends Node

# Core collections
var stats: Dictionary = {}          # String -> ReactiveStat
var computed_stats: Dictionary = {} # String -> ComputedStat
var stat_dependencies: Dictionary = {} # Dependency tracking

# Registration system
func register_stat(name: String, base_value: float, description: String = "") -> ReactiveStat:
    var stat = ReactiveStat.new()
    stat.initialize(name, base_value, description)
    stat.value_changed.connect(_on_stat_changed.bind(name))
    stats[name] = stat
    return stat

func register_computed_stat(name: String, formula: String, dependencies: Array[String], description: String = "") -> ComputedStat:
    var computed_stat = ComputedStat.new()
    computed_stat.initialize(name, formula, dependencies, description)
    computed_stats[name] = computed_stat
    _register_dependencies(name, dependencies)
    return computed_stat
```

### ReactiveStat & StatModifier System
**Location**: `/scripts/stats/StatModifier.gd`  
**Purpose**: Flexible stat modification system with multiple modifier types

```gdscript
class_name StatModifier extends Resource

enum ModifierType {
    FLAT_ADD,     # +10 damage
    PERCENT_ADD,  # +25% damage (stacks additively)
    PERCENT_MULT, # ×1.25 damage (multiplicative)
    OVERRIDE      # Force to specific value
}

var value: float = 0.0
var type: ModifierType = ModifierType.FLAT_ADD
var source: String = ""
var priority: int = 0
var duration: float = -1.0  # -1 = permanent
var tags: Array[String] = []

func apply_to_base_value(base_value: float) -> float:
    match type:
        ModifierType.FLAT_ADD:
            return base_value + value
        ModifierType.PERCENT_ADD:
            return base_value + (base_value * value / 100.0)
        ModifierType.PERCENT_MULT:
            return base_value * (1.0 + value / 100.0)
        ModifierType.OVERRIDE:
            return value
        _:
            return base_value
```

### ComputedStat - Formula-Based Stats
**Location**: `/scripts/stats/ComputedStat.gd`  
**Purpose**: Stats calculated from formulas with dependency tracking

```gdscript
class_name ComputedStat extends RefCounted

# Formula system
var formula: String = ""
var dependencies: Array[String] = []
var cached_value: float = 0.0
var is_dirty: bool = true

# Performance optimization
var use_direct_function: bool = false
var direct_function: Callable

# Dependency management
var dependency_versions: Dictionary = {}

func recalculate(stat_sheet: StatSheet) -> float:
    if not is_dirty and not _dependencies_changed(stat_sheet):
        return cached_value
    
    if use_direct_function and direct_function.is_valid():
        cached_value = direct_function.call(stat_sheet)
    else:
        cached_value = _evaluate_formula(stat_sheet)
    
    is_dirty = false
    _update_dependency_versions(stat_sheet)
    return cached_value
```

### Milestone System
**Location**: Various files with milestone integration  
**Purpose**: Achievement-based permanent character bonuses

```gdscript
# Milestone definitions in CharacterData
func check_and_award_milestones():
    var milestones = [
        {"name": "first_blood", "kills": 10, "bonus": "+25 HP"},
        {"name": "apprentice_slayer", "kills": 50, "bonus": "+1.0 mana regen"},
        {"name": "monster_hunter", "kills": 100, "bonus": "+5% damage"},
        {"name": "elite_warrior", "kills": 250, "bonus": "+50 HP, +25 MP"},
        {"name": "demon_slayer", "kills": 500, "bonus": "+10% damage, +2.0 mana regen"},
        {"name": "legend", "kills": 1000, "bonus": "+100 HP, +50 MP, +15% damage"}
    ]
    
    for milestone in milestones:
        if total_kills_lifetime >= milestone.kills and not milestone.name in milestone_bonuses_earned:
            milestone_bonuses_earned.append(milestone.name)
            GameEvents.emit_milestone_achieved(milestone.name, milestone.bonus)
```

---

## World and Level Data

### Procedural World Persistence (Phase 5 Features)
**Location**: Integrated throughout RunData and world management systems  
**Purpose**: Persistent state for procedurally generated magical world

```gdscript
# Enhanced world features in RunData
var discovered_magical_structures: Dictionary = {}
# Format: chunk_coordinate_string -> Array[structure_types]
# Example: "15,23" -> ["crystal_formation", "wizard_tree"]

var activated_crystal_formations: Array = []
# Format: Array[Vector2i] coordinates of activated crystals

var wizard_tree_interactions: Dictionary = {}
# Format: tree_id -> interaction_data Dictionary
# Contains growth stage, spells learned, enhancement effects

var ley_line_discoveries: Array = []
# Format: Array[Dictionary] with connection data
# Each entry: {"start": Vector2i, "end": Vector2i, "power_level": float}

# L-System generation seeds
var l_system_seeds: Dictionary = {}
# Format: chunk_coordinate_string -> generation_seed int
# Ensures deterministic chunk regeneration

var saved_magical_terrain: Dictionary = {}
# Format: chunk_coordinate_string -> terrain_modifications Dictionary
# Persistent environmental changes from spells/events

var elemental_region_data: Dictionary = {}
# Format: region_id -> elemental_properties Dictionary
# Current elemental dominance, magical weather, etc.

# Biome evolution tracking
var biome_evolution_states: Dictionary = {}
# Format: chunk_coordinate_string -> evolution_level int
# Tracks how biomes change over time due to player actions
```

**Serialization Helpers**:
```gdscript
# Vector2i dictionary serialization for JSON compatibility
func _serialize_dictionary_with_vector2i_keys(dict: Dictionary) -> Dictionary:
    var result = {}
    for key in dict.keys():
        if key is Vector2i:
            var key_string = str(key.x) + "," + str(key.y)
            result[key_string] = dict[key]
        else:
            result[key] = dict[key]
    return result

func _deserialize_dictionary_with_vector2i_keys(dict: Dictionary) -> Dictionary:
    var result = {}
    for key_string in dict.keys():
        if "," in key_string:
            var parts = key_string.split(",")
            if parts.size() == 2:
                var vector_key = Vector2i(int(parts[0]), int(parts[1]))
                result[vector_key] = dict[key_string]
        else:
            result[key_string] = dict[key_string]
    return result
```

### Chunk System Data
**Location**: Various world management files  
**Purpose**: Spatial organization and persistence of world data

```gdscript
# Chunk identification and organization
var current_chunk_position: Vector2 = Vector2.ZERO
var explored_chunks: Array = []  # Array[Vector2i] of discovered chunks

# Per-chunk data structures
var chunk_biomes: Dictionary = {}        # chunk_coord -> biome_type
var chunk_enemy_spawns: Dictionary = {}  # chunk_coord -> spawn_data
var chunk_resource_nodes: Dictionary = {} # chunk_coord -> resource_locations
var chunk_magical_effects: Dictionary = {} # chunk_coord -> active_effects

# Procedural generation consistency
var world_seed: int = 0  # Master seed for world generation
var chunk_generation_seeds: Dictionary = {}  # Per-chunk generation seeds
```

---

## Spell and Combat Data

### SpellData - Resource-Based Spells
**Location**: `/scripts/SpellData.gd`  
**Purpose**: Data-driven spell definitions with resource management

```gdscript
class_name SpellData extends Resource

@export var spell_name: String = ""
@export var description: String = ""
@export var spell_id: String = ""

# Combat stats
@export var base_damage: float = 25.0
@export var mana_cost: int = 10
@export var cooldown_duration: float = 1.0
@export var cast_time: float = 0.0

# Projectile properties
@export var projectile_speed: float = 300.0
@export var projectile_range: float = 600.0
@export var projectile_pierce: int = 0
@export var area_of_effect: float = 0.0

# Visual and audio references
@export var projectile_scene: PackedScene
@export var projectile_texture: Texture2D
@export var cast_effect: PackedScene
@export var impact_effect: PackedScene
@export var cast_sound: AudioStream
@export var impact_sound: AudioStream

# Scaling and upgrades
@export var damage_scaling: float = 1.0
@export var level_requirements: Array[int] = []
@export var upgrade_paths: Array[String] = []
```

### AbilityData - Enhanced Spell System
**Location**: `/scripts/data/AbilityData.gd`  
**Purpose**: Advanced ability system with power levels and modifications

```gdscript
class_name AbilityData extends Resource

@export var ability_name: String = ""
@export var ability_id: String = ""
@export var description: String = ""

# Power level system
@export var min_power_level: int = 1
@export var max_power_level: int = 10
@export var power_scaling_factor: float = 1.2

# Modification system
@export var available_modifications: Array[String] = []
@export var modification_effects: Dictionary = {}

# Resource requirements
@export var base_mana_cost: int = 10
@export var cast_time: float = 0.5
@export var cooldown: float = 1.0

# Effect data
@export var base_damage: float = 25.0
@export var damage_type: String = "magical"
@export var status_effects: Array[String] = []

func get_scaled_damage(power_level: int) -> float:
    return base_damage * pow(power_scaling_factor, power_level - 1)

func get_scaled_mana_cost(power_level: int) -> int:
    return int(base_mana_cost * pow(1.1, power_level - 1))
```

---

## Achievement and Notification Systems

### AchievementNotificationManager - Singleton
**Location**: `/scripts/singletons/AchievementNotificationManager.gd`  
**Purpose**: Achievement tracking and notification display

```gdscript
extends Node

# Achievement definitions
var achievements: Dictionary = {
    "first_blood": {
        "name": "First Blood",
        "description": "Kill your first enemy",
        "requirement": 1,
        "type": "kills",
        "reward": "+25 Max Health"
    },
    "apprentice_slayer": {
        "name": "Apprentice Slayer", 
        "description": "Kill 50 enemies",
        "requirement": 50,
        "type": "kills",
        "reward": "+1.0 Mana Regeneration"
    }
    # ... more achievements
}

# Notification queue system
var notification_queue: Array[Dictionary] = []
var is_showing_notification: bool = false
var notification_layer: CanvasLayer = null

func show_milestone_achievement(milestone_name: String, bonus_description: String):
    var notification_data = {
        "type": "milestone",
        "title": "Milestone Achieved!",
        "message": milestone_name.replace("_", " ").capitalize(),
        "bonus": bonus_description,
        "duration": 4.0
    }
    _queue_notification(notification_data)
```

### Statistics Tracking
**Location**: Integrated throughout CharacterData and GameEvents  
**Purpose**: Comprehensive player performance tracking

```gdscript
# Lifetime statistics in CharacterData
var total_runs_completed: int = 0
var total_kills_lifetime: int = 0
var total_damage_dealt: float = 0.0
var total_damage_taken: float = 0.0
var total_healing_received: float = 0.0
var total_spells_cast: int = 0
var total_playtime: float = 0.0
var highest_wave_ever: int = 1
var best_run_time: float = 0.0
var fastest_kill_time: float = 0.0

# Per-run statistics (in RunData)
var run_kills: int = 0
var run_damage_dealt: float = 0.0
var run_spells_cast: int = 0
var run_distance_traveled: float = 0.0
var run_chunks_explored: int = 0
var run_magical_structures_found: int = 0
```

---

## Data Flow and Relationships

### Save System Architecture
```
SaveManager (Unified save/load system)
├── SaveData (Top-level container)
│   ├── CharacterData (Meta-progression)
│   │   ├── Base stats and progression
│   │   ├── Milestone achievements
│   │   └── Lifetime statistics
│   └── RunData (Session data)
│       ├── Current game state
│       ├── World persistence
│       └── Temporary upgrades
├── SaveSlotInfo (UI metadata)
└── SaveDataValidator (Data integrity)
```

### Stat System Hierarchy
```
PlayerStatSheet (Player-specific calculations)
└── StatSheet (Base reactive system)
    ├── ReactiveStat (Basic stats with modifiers)
    │   └── StatModifier (Temporary bonuses)
    ├── ComputedStat (Formula-based calculations)
    └── Dependency tracking system
```

### Configuration System
```
SettingsManager (User preferences)
├── Graphics settings
├── Audio settings  
├── Gameplay preferences
└── Control settings

GameConstants (Game balance)
├── Performance tuning
├── Combat balance
├── Progression rates
└── World generation parameters
```

### Data Persistence Layers
1. **Settings Layer**: User preferences (ConfigFile format)
2. **Meta-progression Layer**: Character advancement across runs (JSON)
3. **Session Layer**: Current run state and world data (JSON)
4. **Constants Layer**: Game balance and configuration (Resource format)

### Integration Points
- **GameEvents**: Signal-based communication between data systems
- **SaveManager**: Centralized persistence coordination
- **StatSheet**: Reactive stat updates throughout game systems
- **GameStateManager**: State coordination for save/load operations

This data architecture demonstrates sophisticated separation of concerns with reactive systems, comprehensive persistence, and extensible progression mechanics suitable for a complex roguelike RPG with persistent character advancement and procedural world generation.