# Save/Load System Analysis

**Location**: `/scripts/core/save/SaveManager.gd` and related components  
**Project**: FFS Wizard RPG Game (Godot 4.4.1)  
**Purpose**: Comprehensive analysis of the actual save/load implementation

---

## Save System Architecture

### Core SaveManager System

**Location**: `/scripts/core/save/SaveManager.gd`  
**Extends**: Node (Autoload singleton)  
**Purpose**: Advanced save/load system for Phase 4+ complexity with deep integration

#### Configuration and Multi-Slot Management
```gdscript
# Save configuration
var SAVE_FILE_PATH = "user://current_game.save"  # Dynamic for multi-slot
const BACKUP_SAVE_PATH = "user://current_game_backup.save"
const AUTO_SAVE_INTERVAL = 30.0  # seconds
const SAVE_BACKUP_COUNT = 3

# Multi-slot save system
const MAX_SAVE_SLOTS = 5
const SAVE_FILE_PATTERN = "user://save_slot_%d.save"
const SAVE_METADATA_FILE = "user://save_metadata.json"
```

#### Current Save State Management
```gdscript
# Current save data
var current_save: SaveData = null
var session_start_time: float = 0.0
var auto_save_timer: float = 0.0
var auto_save_enabled: bool = false
var last_save_time: float = 0.0

# Multi-slot variables
var current_slot: int = 0
var save_slots: Array = []
```

#### Performance and Error Tracking
```gdscript
# Performance tracking
var save_operations_count: int = 0
var total_save_time: float = 0.0
var load_operations_count: int = 0
var total_load_time: float = 0.0

# Error tracking
var save_errors: Array = []
var load_errors: Array = []
```

### Signal System for UI Integration
```gdscript
# Signals for UI feedback
signal save_completed(success: bool, message: String)
signal load_completed(success: bool, message: String, save_data: SaveData)
signal auto_save_triggered(success: bool)
signal save_progress_update(step: String, progress: float)
signal game_loaded()  # Emitted when game is fully loaded and ready to play
```

---

## Data Structure Architecture

### SaveData - Main Container Class

**Location**: `/scripts/core/save/SaveData.gd`  
**Extends**: RefCounted  
**Purpose**: Enhanced save data structure with separated architecture

#### Version Management and Metadata
```gdscript
# Save version for future compatibility and migration
const SAVE_VERSION: int = 1
const SAVE_FORMAT_NAME: String = "ExtendoRPG_Enhanced"

# Save metadata
var save_version: int = SAVE_VERSION
var save_format: String = SAVE_FORMAT_NAME
var save_timestamp: String = ""
var save_created_time: String = ""
```

#### Separated Data Architecture
```gdscript
# Separated architecture for proper slot management
var character_data: CharacterData = CharacterData.new()
var run_data: RunData = RunData.new()
```

#### Compatibility Layer
```gdscript
# Compatibility properties for existing code
var character_name: String:
    get:
        return character_data.character_name if character_data else ""
    set(value):
        if character_data:
            character_data.character_name = value

var total_playtime: float:
    get:
        return character_data.total_playtime if character_data else 0.0
    set(value):
        if character_data:
            character_data.total_playtime = value
```

### CharacterData - Persistent Progression

**Location**: `/scripts/core/save/CharacterData.gd`  
**Extends**: RefCounted  
**Purpose**: Persistent character progression data that survives across runs

#### Character Identity and Level Progression
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

#### Base Stats Allocation System
```gdscript
# Base stats (allocated by player)
var base_intelligence: int = 10
var base_wisdom: int = 10
var base_vitality: int = 10
var base_dexterity: int = 10
```

#### Lifetime Statistics and Achievements
```gdscript
# Lifetime achievements and unlocks
var milestone_bonuses_earned: Array = []
var unlocked_spells: Array = ["fireball", "heal"]
var persistent_upgrades: Array = []

# Lifetime statistics
var total_runs_completed: int = 0
var total_kills_lifetime: int = 0
var total_playtime: float = 0.0
var highest_wave_ever: int = 1
var best_run_time: float = 0.0
```

---

## Dependency Management and Validation

### Robust Dependency Validation
```gdscript
func _validate_dependencies() -> bool:
    var validation_passed = true
    
    # Check for SaveData class
    var test_save_data = SaveData.new()
    if not test_save_data:
        push_warning("SaveManager: SaveData class not found")
        validation_passed = false
    
    # Check for SaveDataValidator class
    var test_validator = SaveDataValidator.new()
    if not test_validator:
        push_warning("SaveManager: SaveDataValidator class not found")
        validation_passed = false
    
    # Check for GameManager singleton
    if not has_node("/root/GameManager"):
        push_warning("SaveManager: GameManager autoload not found")
    
    return validation_passed
```

---

## PlayerStatSheet Integration

### Reactive Stats System Integration

**Location**: `/scripts/stats/PlayerStatSheet.gd`  
**Extends**: StatSheet  
**Purpose**: Player-specific stat sheet with dependency injection for save compatibility

#### Initialization Pattern for Save Compatibility
```gdscript
# New dependency injection fields
var _is_initialized: bool = false

func _init():
    # NO parameters, NO dependencies for save loading compatibility
    super._init(null, "Player")
    print("🧙 PlayerStatSheet created (awaiting initialization)")

func initialize():
    if _is_initialized:
        return
    
    # Allow initialization without owner_entity for save loading
    if not owner_entity:
        print("⚠️ PlayerStatSheet: Initializing without owner entity (save loading mode)")
    
    setup_player_stats()
    
    # XP progression calculation
    var current_level = int(get_stat_value("level"))
    if current_level > 0:
        xp_to_next_level = base_xp_per_level * pow(xp_scaling_factor, current_level - 1)
    
    _is_initialized = true
    validate_stat_sheet()
```

#### Save-Compatible Progression System
```gdscript
# Player progression - FIXED for SaveManager compatibility
var available_stat_points: int = 0
var current_xp: float = 0.0  # SaveManager expects this name
var xp_to_next_level: float = 100.0
var total_xp: float = 0.0  # Total lifetime XP (SaveManager expects this)

# Experience progression data
var base_xp_per_level: float = 100.0
var xp_scaling_factor: float = 1.5
```

---

## Legacy System Migration

### MetaSaveManager - Deprecated System

**Location**: `/scripts/core/MetaSaveManager.gd`  
**Status**: DEPRECATED - Being phased out

```gdscript
# ⚠️ DEPRECATED: This save manager is being phased out
const SYSTEM_DISABLED = true
const DEPRECATION_WARNING = "MetaSaveManager is deprecated. Use SaveManager instead."

func _ready():
    if SYSTEM_DISABLED:
        push_warning(DEPRECATION_WARNING)
        return
```

### Migration Features
The system includes backward compatibility for old save formats:

```gdscript
# Fallback: migrate old format if character_name exists
var old_name = data.get("character_name", "")
if not old_name.is_empty():
    character_data = CharacterData.new()
    character_data.character_name = old_name
    character_data.total_playtime = data.get("total_playtime", 0.0)
    print("📦 Migrated old save format to new character data structure")
```

---

## File Organization and Storage

### Save File Structure
- **Pattern**: `user://save_slot_%d.save` (slots 0-4)
- **Metadata**: `user://save_metadata.json`
- **Backup**: `user://current_game_backup.save`
- **Format**: JSON serialization with pretty formatting

### Data Serialization
```gdscript
func to_dictionary() -> Dictionary:
    return {
        "save_version": save_version,
        "save_format": save_format,
        "save_timestamp": save_timestamp,
        "save_created_time": save_created_time,
        "character_data": character_data.to_dictionary() if character_data else {},
        "run_data": run_data.to_dictionary() if run_data else {}
    }
```

The save system demonstrates production-ready architecture with comprehensive error handling, performance tracking, and robust data integrity mechanisms suitable for complex RPG progression systems.

# Operation tracking
var save_operation_count: int = 0
var load_operation_count: int = 0
var save_errors: Array[String] = []
var load_errors: Array[String] = []

# Multi-slot management
var slot_metadata: Dictionary = {}  # slot_number -> SaveSlotInfo
var current_slot: int = -1
```

#### **State Machine Loading Process**
**Purpose**: Eliminate timing issues and ensure proper loading order

```gdscript
enum LoadingState {
    CLEAR_WORLD,
    INITIALIZE_PLAYER,
    APPLY_CHARACTER_DATA,
    APPLY_MILESTONE_BONUSES,
    RECALCULATE_STATS,
    APPLY_HEALTH_DATA,
    APPLY_WORLD_STATE,
    FINALIZE
}

func load_game_with_state_machine(slot_number: int):
    var loading_states = [
        _clear_world_state,
        _initialize_player_entity,
        _apply_character_progression,
        _apply_milestone_bonuses,
        _force_stat_recalculation,
        _apply_health_mana_data,
        _restore_world_state,
        _finalize_loading
    ]
    
    for i in range(loading_states.size()):
        var state_function = loading_states[i]
        var result = await state_function.call()
        if not result:
            _handle_loading_error("Failed at state: " + str(i))
            return false
    
    return true
```

### Fresh Run Detection
**Purpose**: Smart detection of death respawn vs. mid-run save loading

```gdscript
func is_fresh_run_start(save_data: SaveData) -> bool:
    # Detect fresh run after death
    if save_data.run_data.current_wave <= 1:
        if save_data.run_data.run_kills <= 0:
            if save_data.run_data.current_health < save_data.character_data.get_max_health() * 0.8:
                return true  # Likely death respawn
    return false

func prepare_fresh_run(save_data: SaveData):
    # Reset health/mana for fresh start
    save_data.run_data.current_health = save_data.character_data.get_max_health()
    save_data.run_data.current_mana = save_data.character_data.get_max_mana()
    
    # Generate new world seed
    save_data.run_data.world_seed = randi()
    save_data.run_data.run_seed = randi()
```

---

## File Organization and Storage

### File Structure
**Storage Location**: Godot's `user://` directory

```
user://
├── save_slot_0.save          # Character slot 1 save file
├── save_slot_1.save          # Character slot 2 save file
├── save_slot_2.save          # Character slot 3 save file
├── save_slot_3.save          # Character slot 4 save file
├── save_slot_4.save          # Character slot 5 save file
├── save_metadata.json        # Slot metadata for UI display
├── save_slot_0.save.bak      # Backup files (automatic)
├── save_slot_1.save.bak
├── settings.cfg              # User preferences (separate)
└── debug_saves/              # Development backup directory
```

### File Format Specifications

#### **Primary Save Format** - JSON with formatting
```json
{
    "save_version": 1,
    "save_format": "ExtendoRPG_Enhanced",
    "save_timestamp": "2025-07-19T10:30:45Z",
    "save_created_time": "2025-07-15T14:20:30Z",
    "character_data": {
        "character_name": "Gandalf",
        "character_level": 15,
        "total_xp": 1450,
        "base_intelligence": 25,
        "base_wisdom": 20,
        "base_vitality": 18,
        "base_dexterity": 12,
        "milestone_bonuses_earned": ["first_blood", "apprentice_slayer"],
        "total_kills_lifetime": 127,
        "highest_wave_ever": 23
    },
    "run_data": {
        "current_wave": 15,
        "current_health": 185.0,
        "current_mana": 95.0,
        "world_seed": 1234567890,
        "explored_chunks": ["0,0", "1,0", "0,1", "-1,0"],
        "discovered_magical_structures": {
            "5,3": ["crystal_formation"],
            "7,2": ["wizard_tree", "ley_line_node"]
        }
    }
}
```

#### **Metadata Format** - Lightweight slot information
```json
{
    "slots": [
        {
            "slot_number": 0,
            "exists": true,
            "character_name": "Gandalf",
            "level": 15,
            "wave": 15,
            "total_kills": 127,
            "playtime": 3542.5,
            "save_date": "2025-07-19 10:30:45",
            "save_timestamp": 1721380245
        }
    ]
}
```

### Serialization Implementation

#### **JSON Serialization with Pretty Formatting**
```gdscript
func save_to_file(file_path: String, save_data: SaveData) -> bool:
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        _log_error("Failed to open file for writing: " + file_path)
        return false
    
    var data_dict = save_data.to_dictionary()
    var json_string = JSON.stringify(data_dict, "\t")  # Tab formatting for readability
    
    file.store_string(json_string)
    file.close()
    
    return true

func load_from_file(file_path: String) -> SaveData:
    if not FileAccess.file_exists(file_path):
        _log_error("Save file does not exist: " + file_path)
        return null
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        _log_error("Failed to open file for reading: " + file_path)
        return null
    
    var json_string = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var parse_result = json.parse(json_string)
    
    if parse_result != OK:
        _log_error("Failed to parse JSON: " + str(parse_result))
        return null
    
    var save_data = SaveData.new()
    save_data.from_dictionary(json.data)
    
    return save_data
```

---

## Atomic Save Operations

### Overview
Atomic operations prevent data corruption during save/load processes through careful file handling and rollback mechanisms.

### Atomic Save Process

#### **Step-by-Step Atomic Save**
```gdscript
func atomic_save_operation(slot_number: int, save_data: SaveData) -> bool:
    var file_path = _get_slot_file_path(slot_number)
    var temp_path = file_path + ".tmp"
    var backup_path = file_path + ".bak"
    
    # Step 1: Create backup of existing save
    if FileAccess.file_exists(file_path):
        var backup_success = _create_backup(file_path, backup_path)
        if not backup_success:
            _log_error("Failed to create backup before save")
            return false
    
    # Step 2: Write new data to temporary file
    var temp_success = save_to_file(temp_path, save_data)
    if not temp_success:
        _log_error("Failed to write temporary save file")
        return false
    
    # Step 3: Validate temporary file
    var validation_success = _validate_save_file(temp_path)
    if not validation_success:
        _log_error("Temporary save file failed validation")
        _cleanup_temp_file(temp_path)
        return false
    
    # Step 4: Atomic replacement
    var replacement_success = _atomic_file_replacement(temp_path, file_path)
    if not replacement_success:
        _log_error("Failed atomic file replacement")
        _restore_from_backup(backup_path, file_path)
        return false
    
    # Step 5: Update metadata
    _update_slot_metadata(slot_number, save_data)
    
    # Step 6: Cleanup
    _cleanup_temp_file(temp_path)
    
    return true

func _atomic_file_replacement(temp_path: String, target_path: String) -> bool:
    # Remove existing file
    if FileAccess.file_exists(target_path):
        var remove_success = DirAccess.remove_absolute(target_path)
        if remove_success != OK:
            return false
    
    # Rename temporary file to target
    var rename_success = DirAccess.rename_absolute(temp_path, target_path)
    return rename_success == OK
```

### Rollback Mechanisms

#### **Automatic Backup Restoration**
```gdscript
func _restore_from_backup(backup_path: String, target_path: String) -> bool:
    if not FileAccess.file_exists(backup_path):
        _log_error("No backup file available for restoration")
        return false
    
    # Remove corrupted file if it exists
    if FileAccess.file_exists(target_path):
        DirAccess.remove_absolute(target_path)
    
    # Copy backup to target location
    var copy_success = DirAccess.copy_absolute(backup_path, target_path)
    if copy_success == OK:
        _log_info("Successfully restored from backup: " + backup_path)
        return true
    else:
        _log_error("Failed to restore from backup: " + str(copy_success))
        return false

func _emergency_recovery(slot_number: int) -> SaveData:
    var file_path = _get_slot_file_path(slot_number)
    var backup_path = file_path + ".bak"
    
    # Try backup file first
    if FileAccess.file_exists(backup_path):
        var backup_data = load_from_file(backup_path)
        if backup_data and backup_data.is_valid():
            _log_info("Recovered from backup file")
            return backup_data
    
    # Try repair corrupted save
    if FileAccess.file_exists(file_path):
        var repaired_data = _attempt_save_repair(file_path)
        if repaired_data:
            _log_info("Repaired corrupted save file")
            return repaired_data
    
    # Create fresh save with character data only
    _log_warning("Creating fresh save after recovery failure")
    return _create_emergency_save(slot_number)
```

---

## Data Validation and Recovery

### Overview
Comprehensive validation system with automatic repair capabilities for common corruption scenarios.

### SaveDataValidator System

#### **SaveDataValidator** - Comprehensive Validation
**Location**: `/scripts/core/save/SaveDataValidator.gd`  
**Purpose**: Validate and repair save data integrity

```gdscript
class_name SaveDataValidator extends RefCounted

# Validation categories
enum ValidationLevel {
    BASIC,      # Structure and required fields
    EXTENDED,   # Range checking and relationships
    DEEP        # Cross-references and computed values
}

var validation_errors: Array[String] = []
var validation_warnings: Array[String] = []
var repair_log: Array[String] = []

func validate_save_data(save_data: SaveData, level: ValidationLevel = ValidationLevel.EXTENDED) -> bool:
    validation_errors.clear()
    validation_warnings.clear()
    
    if not save_data:
        validation_errors.append("Save data is null")
        return false
    
    # Basic structure validation
    if not _validate_basic_structure(save_data):
        return false
    
    if level >= ValidationLevel.EXTENDED:
        if not _validate_extended_ranges(save_data):
            return false
    
    if level >= ValidationLevel.DEEP:
        if not _validate_deep_relationships(save_data):
            return false
    
    return validation_errors.is_empty()

func _validate_basic_structure(save_data: SaveData) -> bool:
    var is_valid = true
    
    # Required objects
    if not save_data.character_data:
        validation_errors.append("Missing character_data")
        is_valid = false
    
    if not save_data.run_data:
        validation_errors.append("Missing run_data")
        is_valid = false
    
    # Required fields
    if save_data.character_data and save_data.character_data.character_name.is_empty():
        validation_errors.append("Character name is empty")
        is_valid = false
    
    return is_valid

func _validate_extended_ranges(save_data: SaveData) -> bool:
    var is_valid = true
    var char_data = save_data.character_data
    var run_data = save_data.run_data
    
    # Character level validation
    if char_data.character_level < 1 or char_data.character_level > 1000:
        validation_errors.append("Invalid character level: " + str(char_data.character_level))
        is_valid = false
    
    # Stats validation
    for stat_name in ["base_intelligence", "base_wisdom", "base_vitality", "base_dexterity"]:
        var stat_value = char_data.get(stat_name)
        if stat_value < 1 or stat_value > 1000:
            validation_errors.append("Invalid %s: %s" % [stat_name, str(stat_value)])
            is_valid = false
    
    # Health/mana validation
    if run_data.current_health < 0 or run_data.current_health > 10000:
        validation_errors.append("Invalid current health: " + str(run_data.current_health))
        is_valid = false
    
    # Wave validation
    if run_data.current_wave < 1 or run_data.current_wave > 10000:
        validation_errors.append("Invalid wave number: " + str(run_data.current_wave))
        is_valid = false
    
    return is_valid
```

### Automatic Repair System

#### **Data Repair Functions**
```gdscript
func attempt_repair(save_data: SaveData) -> bool:
    repair_log.clear()
    var repair_successful = true
    
    # Repair character name
    if save_data.character_data.character_name.is_empty():
        save_data.character_data.character_name = "Unnamed Wizard"
        repair_log.append("Repaired empty character name")
    
    # Repair invalid stats
    for stat_name in ["base_intelligence", "base_wisdom", "base_vitality", "base_dexterity"]:
        var stat_value = save_data.character_data.get(stat_name)
        if stat_value < 1:
            save_data.character_data.set(stat_name, 10)
            repair_log.append("Repaired %s from %s to 10" % [stat_name, str(stat_value)])
        elif stat_value > 1000:
            save_data.character_data.set(stat_name, 100)
            repair_log.append("Clamped %s from %s to 100" % [stat_name, str(stat_value)])
    
    # Repair health/mana based on stats
    var max_health = _calculate_max_health(save_data.character_data)
    var max_mana = _calculate_max_mana(save_data.character_data)
    
    if save_data.run_data.current_health > max_health:
        save_data.run_data.current_health = max_health
        repair_log.append("Clamped health to maximum: " + str(max_health))
    elif save_data.run_data.current_health <= 0:
        save_data.run_data.current_health = max_health
        repair_log.append("Restored health from invalid value")
    
    # Repair wave number
    if save_data.run_data.current_wave < 1:
        save_data.run_data.current_wave = 1
        repair_log.append("Reset wave to 1")
    
    return repair_successful

func sanitize_character_name(name: String) -> String:
    # Remove invalid filesystem characters
    var invalid_chars = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"]
    var sanitized = name
    
    for char in invalid_chars:
        sanitized = sanitized.replace(char, "_")
    
    # Limit length
    if sanitized.length() > 50:
        sanitized = sanitized.substr(0, 50)
    
    # Ensure not empty
    if sanitized.is_empty():
        sanitized = "Wizard"
    
    return sanitized
```

---

## Multi-Slot Save Management

### Overview
Sophisticated slot management system with metadata caching and efficient UI integration.

### Slot Management Architecture

#### **Multi-Slot System**
```gdscript
# SaveManager slot management
const MAX_SAVE_SLOTS = 5
var loaded_slots: Dictionary = {}  # slot_number -> SaveData (cached)
var slot_metadata: Dictionary = {} # slot_number -> SaveSlotInfo

func get_available_slots() -> Array[int]:
    var available = []
    for i in range(MAX_SAVE_SLOTS):
        if not FileAccess.file_exists(_get_slot_file_path(i)):
            available.append(i)
    return available

func get_occupied_slots() -> Array[int]:
    var occupied = []
    for i in range(MAX_SAVE_SLOTS):
        if FileAccess.file_exists(_get_slot_file_path(i)):
            occupied.append(i)
    return occupied

func scan_all_slots():
    slot_metadata.clear()
    
    for slot_number in range(MAX_SAVE_SLOTS):
        var slot_info = _scan_slot(slot_number)
        slot_metadata[slot_number] = slot_info
    
    _save_metadata_cache()
```

#### **Efficient Slot Scanning**
```gdscript
func _scan_slot(slot_number: int) -> SaveSlotInfo:
    var slot_info = SaveSlotInfo.new()
    slot_info.slot_number = slot_number
    slot_info.file_path = _get_slot_file_path(slot_number)
    
    if not FileAccess.file_exists(slot_info.file_path):
        slot_info.exists = false
        return slot_info
    
    # Get file modification time
    var file_time = FileAccess.get_modified_time(slot_info.file_path)
    slot_info.save_timestamp = file_time
    slot_info.save_date = Time.get_datetime_string_from_unix_time(file_time)
    
    # Load minimal data for UI display
    var save_data = load_from_file(slot_info.file_path)
    if save_data and save_data.is_valid():
        slot_info.exists = true
        slot_info.character_name = save_data.character_data.character_name
        slot_info.level = save_data.character_data.character_level
        slot_info.wave = save_data.run_data.current_wave
        slot_info.total_kills = save_data.character_data.total_kills_lifetime
        slot_info.playtime = save_data.character_data.total_playtime
    else:
        slot_info.exists = false
    
    return slot_info
```

### Slot Operations

#### **Save to Specific Slot**
```gdscript
func save_to_slot(slot_number: int, save_data: SaveData) -> bool:
    if slot_number < 0 or slot_number >= MAX_SAVE_SLOTS:
        _log_error("Invalid slot number: " + str(slot_number))
        return false
    
    # Update timestamp
    save_data.save_timestamp = Time.get_datetime_string_from_system()
    
    # Perform atomic save
    var save_success = atomic_save_operation(slot_number, save_data)
    if save_success:
        # Update cache
        loaded_slots[slot_number] = save_data
        current_slot = slot_number
        
        # Update metadata
        var slot_info = _create_slot_info_from_save_data(slot_number, save_data)
        slot_metadata[slot_number] = slot_info
        _save_metadata_cache()
        
        last_save_time = Time.get_time_dict_from_system()["unix"]
        save_operation_count += 1
        
        _log_info("Successfully saved to slot %d" % slot_number)
        GameEvents.emit_save_completed(slot_number)
    
    return save_success

func load_from_slot(slot_number: int) -> SaveData:
    if slot_number < 0 or slot_number >= MAX_SAVE_SLOTS:
        _log_error("Invalid slot number: " + str(slot_number))
        return null
    
    # Check cache first
    if slot_number in loaded_slots:
        var cached_data = loaded_slots[slot_number]
        if cached_data and cached_data.is_valid():
            return cached_data
    
    # Load from file
    var file_path = _get_slot_file_path(slot_number)
    var save_data = load_from_file(file_path)
    
    if save_data and save_data.is_valid():
        # Cache loaded data
        loaded_slots[slot_number] = save_data
        current_slot = slot_number
        load_operation_count += 1
        
        _log_info("Successfully loaded from slot %d" % slot_number)
        GameEvents.emit_load_completed(slot_number)
        
        return save_data
    else:
        _log_error("Failed to load valid data from slot %d" % slot_number)
        return null

func delete_slot(slot_number: int) -> bool:
    if slot_number < 0 or slot_number >= MAX_SAVE_SLOTS:
        return false
    
    var file_path = _get_slot_file_path(slot_number)
    var backup_path = file_path + ".bak"
    
    # Remove main file
    var main_removed = true
    if FileAccess.file_exists(file_path):
        main_removed = DirAccess.remove_absolute(file_path) == OK
    
    # Remove backup file
    var backup_removed = true
    if FileAccess.file_exists(backup_path):
        backup_removed = DirAccess.remove_absolute(backup_path) == OK
    
    if main_removed and backup_removed:
        # Clear cache
        if slot_number in loaded_slots:
            loaded_slots.erase(slot_number)
        
        # Update metadata
        var slot_info = SaveSlotInfo.new()
        slot_info.slot_number = slot_number
        slot_info.exists = false
        slot_metadata[slot_number] = slot_info
        _save_metadata_cache()
        
        _log_info("Successfully deleted slot %d" % slot_number)
        GameEvents.emit_slot_deleted(slot_number)
        return true
    
    return false
```

---

## Auto-Save System

### Overview
Configurable auto-save system with multiple triggers and performance tracking.

### Auto-Save Implementation

#### **Timer-Based Auto-Save**
```gdscript
# Auto-save management
var auto_save_timer: Timer
var auto_save_enabled: bool = true
var auto_save_interval: float = 30.0  # configurable

func _ready():
    auto_save_timer = Timer.new()
    auto_save_timer.wait_time = auto_save_interval
    auto_save_timer.timeout.connect(_on_auto_save_timer_timeout)
    auto_save_timer.autostart = true
    add_child(auto_save_timer)

func _on_auto_save_timer_timeout():
    if auto_save_enabled and current_slot >= 0:
        var current_save_data = _gather_current_save_data()
        if current_save_data:
            save_to_slot(current_slot, current_save_data)
            _log_info("Auto-save completed")

func set_auto_save_interval(new_interval: float):
    auto_save_interval = clamp(new_interval, 10.0, 300.0)  # 10 seconds to 5 minutes
    if auto_save_timer:
        auto_save_timer.wait_time = auto_save_interval
    SettingsManager.set_setting("gameplay", "auto_save_interval", auto_save_interval)
```

#### **Event-Triggered Auto-Save**
```gdscript
func _ready():
    # Connect to game events for auto-save triggers
    GameEvents.player_level_up.connect(_on_player_level_up)
    GameEvents.wave_completed.connect(_on_wave_completed)
    GameEvents.milestone_achieved.connect(_on_milestone_achieved)
    GameStateManager.state_changed.connect(_on_game_state_changed)

func _on_player_level_up(new_level: int):
    if auto_save_enabled:
        _trigger_auto_save("level_up")

func _on_wave_completed(wave_number: int):
    if auto_save_enabled and wave_number % 5 == 0:  # Every 5 waves
        _trigger_auto_save("wave_milestone")

func _on_milestone_achieved(milestone_name: String, bonus: String):
    if auto_save_enabled:
        _trigger_auto_save("milestone_achieved")

func _on_game_state_changed(new_state, old_state):
    if new_state == GameStateManager.Phase4GameState.PAUSED:
        if auto_save_enabled:
            _trigger_auto_save("pause")

func _trigger_auto_save(reason: String):
    if current_slot >= 0:
        var save_data = _gather_current_save_data()
        if save_data:
            save_to_slot(current_slot, save_data)
            _log_info("Auto-save triggered by: " + reason)
```

---

## Error Handling and Recovery

### Overview
Comprehensive error handling with logging, recovery mechanisms, and user feedback.

### Error Categories and Handling

#### **Error Classification System**
```gdscript
enum ErrorType {
    FILE_ACCESS,        # Cannot read/write files
    JSON_PARSE,         # Malformed JSON data
    DATA_VALIDATION,    # Invalid data values
    CORRUPTION,         # File corruption detected
    DISK_SPACE,        # Insufficient storage
    PERMISSION         # File permission issues
}

var error_history: Array[Dictionary] = []

func _log_error(message: String, error_type: ErrorType = ErrorType.FILE_ACCESS):
    var error_entry = {
        "timestamp": Time.get_datetime_string_from_system(),
        "message": message,
        "type": error_type,
        "stack_trace": get_stack()
    }
    
    error_history.append(error_entry)
    save_errors.append(message)
    
    # Limit error history size
    if error_history.size() > 100:
        error_history = error_history.slice(-50)  # Keep last 50
    
    print_rich("[color=red]SaveManager Error: %s[/color]" % message)
```

#### **Recovery Strategies**
```gdscript
func handle_save_failure(slot_number: int, error_type: ErrorType):
    match error_type:
        ErrorType.DISK_SPACE:
            _cleanup_old_backups()
            _show_disk_space_warning()
        
        ErrorType.PERMISSION:
            _show_permission_error()
        
        ErrorType.FILE_ACCESS:
            _attempt_alternative_save_location(slot_number)
        
        ErrorType.CORRUPTION:
            _restore_from_backup(slot_number)
        
        _:
            _show_generic_save_error()

func _cleanup_old_backups():
    var backup_dir = "user://backup_saves/"
    if not DirAccess.dir_exists_absolute(backup_dir):
        return
    
    var dir = DirAccess.open(backup_dir)
    if dir:
        var files = []
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".bak"):
                var file_path = backup_dir + file_name
                var file_time = FileAccess.get_modified_time(file_path)
                files.append({"path": file_path, "time": file_time})
            file_name = dir.get_next()
        
        # Sort by time and remove oldest if more than 10 backups
        files.sort_custom(func(a, b): return a.time > b.time)
        
        while files.size() > 10:
            var oldest = files.pop_back()
            DirAccess.remove_absolute(oldest.path)
```

---

## Performance and Optimization

### Overview
Performance monitoring and optimization for save/load operations with timing metrics and caching strategies.

### Performance Tracking

#### **Operation Timing**
```gdscript
var performance_metrics: Dictionary = {
    "save_times": [],
    "load_times": [],
    "validation_times": [],
    "average_save_time": 0.0,
    "average_load_time": 0.0,
    "slowest_save": 0.0,
    "slowest_load": 0.0
}

func _track_save_performance(start_time: float, end_time: float):
    var duration = end_time - start_time
    performance_metrics.save_times.append(duration)
    
    # Keep only last 50 measurements
    if performance_metrics.save_times.size() > 50:
        performance_metrics.save_times = performance_metrics.save_times.slice(-50)
    
    # Update averages
    var total = 0.0
    for time in performance_metrics.save_times:
        total += time
    performance_metrics.average_save_time = total / performance_metrics.save_times.size()
    
    # Track slowest
    if duration > performance_metrics.slowest_save:
        performance_metrics.slowest_save = duration

func get_performance_report() -> String:
    return """
Save/Load Performance Report:
- Average save time: %.3f seconds
- Average load time: %.3f seconds
- Total saves: %d
- Total loads: %d
- Save errors: %d
- Load errors: %d
- Slowest save: %.3f seconds
- Slowest load: %.3f seconds
""" % [
    performance_metrics.average_save_time,
    performance_metrics.average_load_time,
    save_operation_count,
    load_operation_count,
    save_errors.size(),
    load_errors.size(),
    performance_metrics.slowest_save,
    performance_metrics.slowest_load
]
```

### Caching and Optimization

#### **Metadata Caching**
```gdscript
# Cached metadata for fast UI updates
var metadata_cache_valid: bool = false
var metadata_cache_timestamp: float = 0.0
const METADATA_CACHE_DURATION = 30.0  # 30 seconds

func get_slot_info(slot_number: int) -> SaveSlotInfo:
    # Check cache validity
    var current_time = Time.get_time_dict_from_system()["unix"]
    if metadata_cache_valid and (current_time - metadata_cache_timestamp) < METADATA_CACHE_DURATION:
        if slot_number in slot_metadata:
            return slot_metadata[slot_number]
    
    # Refresh cache if invalid
    if not metadata_cache_valid:
        scan_all_slots()
        metadata_cache_valid = true
        metadata_cache_timestamp = current_time
    
    return slot_metadata.get(slot_number, SaveSlotInfo.new())
```

This save/load system demonstrates a production-ready implementation with atomic operations, comprehensive error handling, data validation, and performance optimization suitable for a complex RPG with persistent character progression and procedural world state.