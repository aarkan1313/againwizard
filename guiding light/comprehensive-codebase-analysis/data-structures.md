# Data Management

## Overview

This document details the data structures, save file formats, and data management systems used throughout the FFS Wizard RPG project. The game uses a comprehensive data persistence system with multiple save types and robust validation.

---

## Save File Structure

### Primary Save System
**Manager**: `scripts/core/save/SaveManager.gd` (singleton)  
**File Format**: Godot binary resource format (.tres)  
**Location**: User data directory

#### Save Slot Configuration
- **Total Slots**: 5 save slots (0, 1, 2, 3, 4)
- **Current Slot Tracking**: Managed by SaveManager
- **Backup System**: Automatic backups before overwrites

#### Save File Hierarchy
```
User Data Directory/
├── save_slot_0.tres    # Primary save slot 0
├── save_slot_1.tres    # Primary save slot 1  
├── save_slot_2.tres    # Primary save slot 2
├── save_slot_3.tres    # Primary save slot 3
├── save_slot_4.tres    # Primary save slot 4
├── save_slot_0.bak     # Backup files
├── save_slot_1.bak
├── save_slot_2.bak
├── save_slot_3.bak
├── save_slot_4.bak
├── meta_save.tres      # Meta-progression data
└── settings.tres       # Game settings
```

### SaveData Structure
**Script**: `scripts/core/save/SaveData.gd`  
**Extends**: Resource

#### Core Save Data Properties
```gdscript
class_name SaveData
extends Resource

# Save metadata
@export var save_version: String = "1.0"
@export var save_timestamp: String
@export var playtime_seconds: float = 0.0
@export var save_slot: int = -1

# Game progression
@export var current_wave: int = 1
@export var total_enemies_killed: int = 0
@export var total_xp_earned: int = 0

# World state
@export var world_seed: int = 0
@export var player_position: Vector2 = Vector2.ZERO
@export var current_biome: String = "plains"

# Character data
@export var character_data: CharacterData
@export var run_data: RunData

# Game state flags
@export var game_completed: bool = false
@export var achievements_unlocked: Array[String] = []
```

---

## Character Data Structure

### CharacterData Class
**Script**: `scripts/core/save/CharacterData.gd`  
**Purpose**: Player character progression and stats

#### Character Progression Data
```gdscript
class_name CharacterData
extends Resource

# Level and experience
@export var player_level: int = 1
@export var current_xp: int = 0
@export var total_xp_earned: int = 0

# Base stats
@export var base_intelligence: int = 10
@export var base_wisdom: int = 8
@export var base_vitality: int = 12
@export var base_dexterity: int = 6

# Allocated stat points
@export var allocated_intelligence: int = 0
@export var allocated_wisdom: int = 0
@export var allocated_vitality: int = 0
@export var allocated_dexterity: int = 0
@export var available_stat_points: int = 0

# Current state
@export var current_health: float = 100.0
@export var current_mana: float = 50.0
@export var max_health: float = 100.0
@export var max_mana: float = 50.0

# Position and location
@export var player_position: Vector2 = Vector2.ZERO
@export var last_safe_position: Vector2 = Vector2.ZERO

# Spell configuration
@export var equipped_spells: Array[String] = []
@export var spell_slot_assignments: Dictionary = {}
```

#### Character Data Validation
```gdscript
func validate_character_data() -> bool:
    # Level validation
    if player_level < 1 or player_level > 100:
        return false
    
    # XP validation
    if current_xp < 0 or total_xp_earned < 0:
        return false
    
    # Stat validation
    if base_intelligence < 1 or base_wisdom < 1 or base_vitality < 1 or base_dexterity < 1:
        return false
    
    # Health/mana validation
    if current_health < 0 or current_mana < 0:
        return false
    
    return true
```

---

## Run Data Structure

### RunData Class
**Script**: `scripts/core/save/RunData.gd`  
**Purpose**: Session-specific game state

#### Run-Specific Data
```gdscript
class_name RunData
extends Resource

# Run metadata
@export var run_start_time: String
@export var run_duration: float = 0.0
@export var run_seed: int = 0

# Wave progression
@export var current_wave: int = 1
@export var highest_wave_reached: int = 1
@export var enemies_killed_this_wave: int = 0
@export var total_enemies_killed: int = 0

# Enemy spawn tracking
@export var active_enemy_count: int = 0
@export var enemy_spawn_caps: Dictionary = {
    "goblin": 8,
    "orc": 6,
    "skeleton": 6,
    "wizard": 3,
    "golem": 2
}

# World generation state
@export var generated_chunks: Array[Vector2i] = []
@export var active_chunk_center: Vector2i = Vector2i.ZERO
@export var biome_discovery: Dictionary = {}

# Performance metrics
@export var average_fps: float = 60.0
@export var frame_drops: int = 0
@export var memory_usage_peak: float = 0.0
```

#### Run Statistics
```gdscript
# Additional run statistics
@export var statistics: Dictionary = {
    "spells_cast": 0,
    "damage_dealt": 0.0,
    "damage_taken": 0.0,
    "distance_traveled": 0.0,
    "teleports_used": 0,
    "healing_received": 0.0,
    "time_in_combat": 0.0,
    "perfect_waves": 0
}
```

---

## Configuration Structure

### Settings Management
**Script**: `scripts/core/SettingsManager.gd` (singleton)  
**Purpose**: Game configuration persistence

#### Settings Data Structure
```gdscript
# SettingsManager.gd settings data
var settings_data: Dictionary = {
    "display": {
        "fullscreen": true,
        "vsync": true,
        "resolution": Vector2i(1920, 1080),
        "ui_scale": 1.0
    },
    "audio": {
        "master_volume": 1.0,
        "music_volume": 0.8,
        "sfx_volume": 1.0,
        "ui_sound": true
    },
    "gameplay": {
        "auto_pause": true,
        "damage_numbers": true,
        "screen_shake": true,
        "particle_density": 1.0,
        "autosave_enabled": true,
        "autosave_interval": 300.0
    },
    "controls": {
        "mouse_sensitivity": 1.0,
        "key_bindings": {},
        "input_buffer_time": 0.1
    },
    "debug": {
        "show_fps": false,
        "show_debug_info": false,
        "verbose_logging": false,
        "collision_debug": false
    }
}
```

#### Settings Persistence
```gdscript
func save_settings():
    var settings_file = FileAccess.open("user://settings.tres", FileAccess.WRITE)
    if settings_file:
        settings_file.store_string(JSON.stringify(settings_data))
        settings_file.close()
        return true
    return false

func load_settings():
    if FileAccess.file_exists("user://settings.tres"):
        var settings_file = FileAccess.open("user://settings.tres", FileAccess.READ)
        if settings_file:
            var json_text = settings_file.get_as_text()
            settings_file.close()
            var json = JSON.new()
            var parse_result = json.parse(json_text)
            if parse_result == OK:
                settings_data = json.data
                apply_settings()
                return true
    return false
```

---

## Game Data Resources

### Enemy Data Structure
**Script**: `scripts/data/EnemyData.gd`  
**Type**: Resource (.tres files)

#### EnemyData Properties
```gdscript
class_name EnemyData
extends Resource

# Basic enemy properties
@export var enemy_name: String = ""
@export var display_name: String = ""
@export var enemy_type: String = ""

# Combat stats
@export var max_health: float = 50.0
@export var base_damage: float = 10.0
@export var movement_speed: float = 100.0
@export var attack_range: float = 50.0

# Progression scaling
@export var health_scaling_per_wave: float = 0.2  # 20% per wave
@export var damage_scaling_per_wave: float = 0.15  # 15% per wave
@export var speed_scaling_per_wave: float = 0.08   # 8% per wave

# Rewards
@export var xp_reward: int = 10
@export var xp_scaling_per_wave: float = 0.1

# Visual assets
@export var sprite_texture: Texture2D
@export var death_effect: PackedScene

# AI behavior
@export var ai_behavior_type: String = "basic"
@export var detection_range: float = 200.0
@export var abilities: Array[AbilityData] = []

# Spawn constraints
@export var spawn_weight: float = 1.0
@export var min_wave: int = 1
@export var max_concurrent: int = -1  # -1 = no limit
```

### Ability Data Structure
**Script**: `scripts/data/AbilityData.gd`  
**Type**: Resource (.tres files)

#### AbilityData Properties
```gdscript
class_name AbilityData
extends Resource

# Ability identification
@export var ability_name: String = ""
@export var ability_type: String = "damage"  # damage, heal, buff, utility

# Damage and effects
@export var damage: float = 10.0
@export var healing: float = 0.0
@export var status_effects: Array[String] = []

# Timing and cooldowns
@export var cooldown: float = 2.0
@export var cast_time: float = 0.5
@export var channel_time: float = 0.0

# Range and area
@export var range: float = 100.0
@export var area_radius: float = 0.0  # 0 = single target
@export var line_of_sight_required: bool = true

# Projectile properties (for ranged abilities)
@export var is_projectile: bool = false
@export var projectile_speed: float = 300.0
@export var projectile_lifetime: float = 3.0
@export var projectile_scene: PackedScene

# Visual and audio
@export var cast_effect: PackedScene
@export var impact_effect: PackedScene
@export var sound_effect: AudioStream

# AI usage parameters
@export var ai_priority: float = 1.0
@export var ai_min_distance: float = 0.0
@export var ai_max_distance: float = 999.0
@export var ai_requires_target: bool = true
```

---

## Dialogue/Text Systems

### Localization Structure (Planned)
**Future Implementation**: Text localization system

#### Text Resource Format
```gdscript
# Planned localization structure
var localized_text: Dictionary = {
    "en": {
        "ui": {
            "health": "Health",
            "mana": "Mana",
            "level": "Level",
            "experience": "Experience"
        },
        "spells": {
            "fireball": "Fireball",
            "ice_shard": "Ice Shard",
            "lightning_bolt": "Lightning Bolt"
        },
        "enemies": {
            "goblin": "Goblin",
            "orc": "Orc",
            "skeleton": "Skeleton Archer"
        }
    }
}
```

---

## Inventory/Item Data

### Item System Structure (Future Enhancement)
**Current Status**: Basic XP orb system implemented

#### XP Orb Data
```gdscript
# XPOrb.gd current data structure
@export var xp_value: int = 10
@export var magnet_range: float = 150.0
@export var magnet_speed: float = 400.0

# Visual properties
var scale_animation: Tween
var floating_animation: Tween
var collection_effect: PackedScene
```

#### Planned Item System
```gdscript
# Future ItemData structure
class_name ItemData
extends Resource

@export var item_id: String = ""
@export var item_name: String = ""
@export var item_type: String = ""  # consumable, equipment, material
@export var rarity: String = "common"  # common, rare, epic, legendary
@export var max_stack: int = 1
@export var value: int = 0
@export var icon: Texture2D
@export var description: String = ""
@export var effects: Array[ItemEffect] = []
```

---

## Score/Stats Tracking

### Player Statistics
**Integration**: PlayerStatSheet.gd and RunData.gd

#### Comprehensive Statistics Tracking
```gdscript
# PlayerStatSheet.gd statistics
var lifetime_stats: Dictionary = {
    # Combat statistics
    "total_damage_dealt": 0.0,
    "total_damage_taken": 0.0,
    "total_healing_received": 0.0,
    "enemies_defeated": 0,
    "spells_cast": 0,
    "critical_hits": 0,
    
    # Movement statistics
    "distance_traveled": 0.0,
    "teleports_used": 0,
    "time_in_combat": 0.0,
    
    # Progression statistics
    "levels_gained": 0,
    "stat_points_allocated": 0,
    "highest_wave_reached": 0,
    "perfect_waves_completed": 0,
    
    # Efficiency statistics
    "average_damage_per_spell": 0.0,
    "damage_per_second": 0.0,
    "survival_time": 0.0
}
```

#### Statistics Update System
```gdscript
# Statistics update through GameEvents
func _ready():
    GameEvents.spell_cast.connect(_on_spell_cast)
    GameEvents.enemy_died.connect(_on_enemy_died)
    GameEvents.player_damaged.connect(_on_player_damaged)
    GameEvents.level_up.connect(_on_level_up)

func _on_spell_cast(spell_name: String, damage: float):
    lifetime_stats.spells_cast += 1
    lifetime_stats.total_damage_dealt += damage
    update_damage_per_second()

func update_damage_per_second():
    if lifetime_stats.time_in_combat > 0:
        lifetime_stats.damage_per_second = lifetime_stats.total_damage_dealt / lifetime_stats.time_in_combat
```

---

## Data Validation System

### Save Data Validation
**Script**: `scripts/core/save/SaveDataValidator.gd`

#### Validation Rules
```gdscript
class_name SaveDataValidator

static func validate_save_data(save_data: SaveData) -> ValidationResult:
    var result = ValidationResult.new()
    
    # Version validation
    if not is_valid_version(save_data.save_version):
        result.add_error("Invalid save version: " + save_data.save_version)
    
    # Character data validation
    if save_data.character_data:
        validate_character_data(save_data.character_data, result)
    else:
        result.add_error("Missing character data")
    
    # Run data validation
    if save_data.run_data:
        validate_run_data(save_data.run_data, result)
    
    # Timestamp validation
    if not is_valid_timestamp(save_data.save_timestamp):
        result.add_error("Invalid timestamp format")
    
    return result

static func validate_character_data(char_data: CharacterData, result: ValidationResult):
    # Level bounds checking
    if char_data.player_level < 1 or char_data.player_level > MAX_LEVEL:
        result.add_error("Player level out of bounds: " + str(char_data.player_level))
    
    # Stat validation
    var total_allocated = char_data.allocated_intelligence + char_data.allocated_wisdom + 
                         char_data.allocated_vitality + char_data.allocated_dexterity
    var expected_points = (char_data.player_level - 1) * STAT_POINTS_PER_LEVEL
    
    if total_allocated + char_data.available_stat_points != expected_points:
        result.add_error("Stat point allocation mismatch")
    
    # Health/mana bounds
    if char_data.current_health > char_data.max_health:
        result.add_error("Current health exceeds maximum")
```

### Error Recovery System
```gdscript
# SaveManager.gd error recovery
func load_with_recovery(slot_index: int) -> bool:
    var save_data = load_save_data(slot_index)
    if not save_data:
        return try_backup_recovery(slot_index)
    
    var validation = SaveDataValidator.validate_save_data(save_data)
    if validation.has_errors():
        print("Save validation failed: ", validation.get_errors())
        return try_backup_recovery(slot_index)
    
    apply_save_data(save_data)
    return true

func try_backup_recovery(slot_index: int) -> bool:
    print("Attempting backup recovery for slot ", slot_index)
    var backup_data = load_backup_save(slot_index)
    if backup_data:
        var validation = SaveDataValidator.validate_save_data(backup_data)
        if not validation.has_errors():
            apply_save_data(backup_data)
            return true
    
    print("Recovery failed, starting new game")
    return false
```

This comprehensive data management system ensures robust save/load functionality with validation, error recovery, and extensible data structures supporting both current features and future enhancements.