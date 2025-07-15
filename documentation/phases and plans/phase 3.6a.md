func discover_special_chunk(chunk_pos: Vector2):
    """Add discovered special chunk"""
    if chunk_pos not in discovered_special_chunks:
        discovered_special_chunks.append(chunk_pos)

# Player stat modification methods
func increase_base_stat(stat_name: String, amount: int):
    """Increase base stat (for leveling up)"""
    match stat_name:
        "intelligence":
            base_intelligence += amount
        "wisdom":
            base_wisdom += amount
        "vitality":
            base_vitality += amount
        "dexterity":
            base_dexterity += amount

func set_reactive_stat(stat_name: String, value: float):
    """Set reactive stat value (for equipment/temporary effects)"""
    match stat_name:
        "max_health":
            max_health = value
        "max_mana":
            max_mana = value
        "spell_damage_multiplier":
            spell_damage_multiplier = value
        "mana_regen_rate":
            mana_regen_rate = value
        "health_regen_rate":
            health_regen_rate = value
        "cast_speed_multiplier":
            cast_speed_multiplier = value
        "cooldown_reduction":
            cooldown_reduction = value
        "critical_chance":
            critical_chance = value
        "movement_speed":
            movement_speed = value
        "spell_projectile_speed":
            spell_projectile_speed = value
        "spell_range_multiplier":
            spell_range_multiplier = value

func get_base_stat(stat_name: String) -> int:
    """Get base stat value"""
    match stat_name:
        "intelligence":
            return base_intelligence
        "wisdom":
            return base_wisdom
        "vitality":
            return base_vitality
        "dexterity":
            return base_dexterity
        "level":
            return character_level
        _:
            return 0

func get_reactive_stat(stat_name: String) -> float:
    """Get reactive stat value"""
    match stat_name:
        "max_health":
            return max_health
        "max_mana":
            return max_mana
        "spell_damage_multiplier":
            return spell_damage_multiplier
        "mana_regen_rate":
            return mana_regen_rate
        "health_regen_rate":
            return health_regen_rate
        "cast_speed_multiplier":
            return cast_speed_multiplier
        "cooldown_reduction":
            return cooldown_reduction
        "critical_chance":
            return critical_chance
        "movement_speed":
            return movement_speed
        "spell_projectile_speed":
            return spell_projectile_speed
        "spell_range_multiplier":
            return spell_range_multiplier
        _:
            return 0.0

# Spell progression methods
func unlock_spell(spell_name: String):
    """Unlock new spell"""
    if spell_name not in unlocked_spells:
        unlocked_spells.append(spell_name)
        spell_levels[spell_name] = 1
        spell_experience[spell_name] = 0

func add_spell_experience(spell_name: String, exp: int):
    """Add experience to spell"""
    if spell_name in unlocked_spells:
        spell_experience[spell_name] = spell_experience.get(spell_name, 0) + exp

func level_up_spell(spell_name: String):
    """Level up spell"""
    if spell_name in# Phase 3.6A: Core Save Data Structure
**Duration**: 45 minutes  
**Goal**: Create save data structure for current Phase 3 features only

## What We're Saving (Phase 3 Reality Check)

Based on your current Phase 3 implementation, we need to save:

### Player State
- Current health/max health
- Current mana/max mana 
- Player position (x, y coordinates)
- Player level (if implemented)
- Experience points (if implemented)

### Wave Progression
- Current wave number
- Waves completed
- Distance traveled from spawn
- Total kills this run

### World State
- World seed (for regenerating same world)
- Current biome/chunk position
- Any discovered special chunks

### Statistics
- Run duration
- Damage dealt
- Spells cast count

## File Structure
```
scripts/core/save/
├── SaveData.gd (NEW - Simple save structure)
└── SaveDataValidator.gd (NEW - Validation helper)
```

## Implementation

**File: `scripts/core/save/SaveData.gd`**

```gdscript
# SaveData.gd - Phase 3 save data structure
extends RefCounted
class_name SaveData

# Save version for future compatibility
const SAVE_VERSION: int = 1

# Save metadata
var save_version: int = SAVE_VERSION
var save_timestamp: String = ""
var character_name: String = ""
var total_playtime: float = 0.0

# Current run state (Phase 3 features only)
var run_data: RunData = RunData.new()

func _init():
    save_timestamp = Time.get_datetime_string_from_system()

func to_dictionary() -> Dictionary:
    """Convert to dictionary for JSON serialization"""
    return {
        "save_version": save_version,
        "save_timestamp": save_timestamp,
        "character_name": character_name,
        "total_playtime": total_playtime,
        "run_data": run_data.to_dictionary()
    }

func from_dictionary(data: Dictionary) -> bool:
    """Load from dictionary with validation"""
    if not data.has("save_version"):
        push_error("Invalid save data: missing version")
        return false
    
    save_version = data.get("save_version", SAVE_VERSION)
    save_timestamp = data.get("save_timestamp", "")
    character_name = data.get("character_name", "")
    total_playtime = data.get("total_playtime", 0.0)
    
    var run_dict = data.get("run_data", {})
    return run_data.from_dictionary(run_dict)

func is_valid() -> bool:
    """Validate save data integrity"""
    if character_name.is_empty():
        return false
    if total_playtime < 0:
        return false
    return run_data.is_valid()

func update_playtime(session_time: float):
    """Update total playtime"""
    total_playtime += session_time
    save_timestamp = Time.get_datetime_string_from_system()

# RunData class for current run state
class_name RunData
extends RefCounted

# Player state
var player_health: float = 100.0
var player_max_health: float = 100.0
var player_mana: float = 100.0
var player_max_mana: float = 100.0
var player_position: Vector2 = Vector2.ZERO
var player_level: int = 1
var player_experience: int = 0

# Player stats/attributes (Phase 3 reactive stats system)
var base_intelligence: int = 10
var base_wisdom: int = 10
var base_vitality: int = 10
var base_dexterity: int = 10
var character_level: int = 1

# Reactive stats (calculated values that get saved)
var max_health: float = 100.0
var max_mana: float = 50.0
var spell_damage_multiplier: float = 1.0
var mana_regen_rate: float = 3.0
var health_regen_rate: float = 2.0
var cast_speed_multiplier: float = 1.0
var cooldown_reduction: float = 0.0
var critical_chance: float = 0.05
var movement_speed: float = 120.0
var spell_projectile_speed: float = 300.0
var spell_range_multiplier: float = 1.0

# Equipment and gear (placeholder for future equipment system)
var equipped_items: Dictionary = {}  # slot_name: item_data
var inventory_items: Array[Dictionary] = []

# Spell progression
var unlocked_spells: Array[String] = ["fireball", "heal"]  # Starting spells
var spell_levels: Dictionary = {}  # spell_name: level
var spell_experience: Dictionary = {}  # spell_name: experience

# Wave progression
var current_wave: int = 1
var waves_completed: int = 0
var distance_from_spawn: float = 0.0
var total_kills: int = 0

# World state
var world_seed: int = 0
var current_chunk_position: Vector2 = Vector2.ZERO
var discovered_special_chunks: Array[Vector2] = []

# Session statistics
var run_start_time: float = 0.0
var run_duration: float = 0.0
var damage_dealt: float = 0.0
var spells_cast: int = 0

# Game settings (basic for Phase 3)
var master_volume: float = 1.0
var sfx_volume: float = 1.0

func to_dictionary() -> Dictionary:
    """Convert run data to dictionary"""
    return {
        # Player state
        "player_health": player_health,
        "player_max_health": player_max_health,
        "player_mana": player_mana,
        "player_max_mana": player_max_mana,
        "player_position": {"x": player_position.x, "y": player_position.y},
        "player_level": player_level,
        "player_experience": player_experience,
        
        # Player stats/attributes
        "base_intelligence": base_intelligence,
        "base_wisdom": base_wisdom,
        "base_vitality": base_vitality,
        "base_dexterity": base_dexterity,
        "character_level": character_level,
        
        # Reactive stats
        "max_health": max_health,
        "max_mana": max_mana,
        "spell_damage_multiplier": spell_damage_multiplier,
        "mana_regen_rate": mana_regen_rate,
        "health_regen_rate": health_regen_rate,
        "cast_speed_multiplier": cast_speed_multiplier,
        "cooldown_reduction": cooldown_reduction,
        "critical_chance": critical_chance,
        "movement_speed": movement_speed,
        "spell_projectile_speed": spell_projectile_speed,
        "spell_range_multiplier": spell_range_multiplier,
        
        # Equipment and gear
        "equipped_items": equipped_items,
        "inventory_items": inventory_items,
        
        # Spell progression
        "unlocked_spells": unlocked_spells,
        "spell_levels": spell_levels,
        "spell_experience": spell_experience,
        
        # Wave progression
        "current_wave": current_wave,
        "waves_completed": waves_completed,
        "distance_from_spawn": distance_from_spawn,
        "total_kills": total_kills,
        
        # World state
        "world_seed": world_seed,
        "current_chunk_position": {"x": current_chunk_position.x, "y": current_chunk_position.y},
        "discovered_special_chunks": discovered_special_chunks.map(func(v): return {"x": v.x, "y": v.y}),
        
        # Session statistics
        "run_start_time": run_start_time,
        "run_duration": run_duration,
        "damage_dealt": damage_dealt,
        "spells_cast": spells_cast,
        
        # Settings
        "master_volume": master_volume,
        "sfx_volume": sfx_volume
    }

func from_dictionary(data: Dictionary) -> bool:
    """Load run data from dictionary"""
    try:
        # Player state
        player_health = data.get("player_health", 100.0)
        player_max_health = data.get("player_max_health", 100.0)
        player_mana = data.get("player_mana", 100.0)
        player_max_mana = data.get("player_max_mana", 100.0)
        
        var pos_data = data.get("player_position", {"x": 0, "y": 0})
        player_position = Vector2(pos_data.x, pos_data.y)
        
        player_level = data.get("player_level", 1)
        player_experience = data.get("player_experience", 0)
        
        # Player stats/attributes
        base_intelligence = data.get("base_intelligence", 10)
        base_wisdom = data.get("base_wisdom", 10)
        base_vitality = data.get("base_vitality", 10)
        base_dexterity = data.get("base_dexterity", 10)
        character_level = data.get("character_level", 1)
        
        # Reactive stats
        max_health = data.get("max_health", 100.0)
        max_mana = data.get("max_mana", 50.0)
        spell_damage_multiplier = data.get("spell_damage_multiplier", 1.0)
        mana_regen_rate = data.get("mana_regen_rate", 3.0)
        health_regen_rate = data.get("health_regen_rate", 2.0)
        cast_speed_multiplier = data.get("cast_speed_multiplier", 1.0)
        cooldown_reduction = data.get("cooldown_reduction", 0.0)
        critical_chance = data.get("critical_chance", 0.05)
        movement_speed = data.get("movement_speed", 120.0)
        spell_projectile_speed = data.get("spell_projectile_speed", 300.0)
        spell_range_multiplier = data.get("spell_range_multiplier", 1.0)
        
        # Equipment and gear
        equipped_items = data.get("equipped_items", {})
        inventory_items = data.get("inventory_items", [])
        
        # Spell progression
        unlocked_spells = data.get("unlocked_spells", ["fireball", "heal"])
        spell_levels = data.get("spell_levels", {})
        spell_experience = data.get("spell_experience", {})
        
        # Wave progression
        current_wave = data.get("current_wave", 1)
        waves_completed = data.get("waves_completed", 0)
        distance_from_spawn = data.get("distance_from_spawn", 0.0)
        total_kills = data.get("total_kills", 0)
        
        # World state
        world_seed = data.get("world_seed", 0)
        
        var chunk_data = data.get("current_chunk_position", {"x": 0, "y": 0})
        current_chunk_position = Vector2(chunk_data.x, chunk_data.y)
        
        var special_chunks_data = data.get("discovered_special_chunks", [])
        discovered_special_chunks = special_chunks_data.map(func(v): return Vector2(v.x, v.y))
        
        # Session statistics
        run_start_time = data.get("run_start_time", 0.0)
        run_duration = data.get("run_duration", 0.0)
        damage_dealt = data.get("damage_dealt", 0.0)
        spells_cast = data.get("spells_cast", 0)
        
        # Settings
        master_volume = data.get("master_volume", 1.0)
        sfx_volume = data.get("sfx_volume", 1.0)
        
        return true
        
    except:
        push_error("Failed to parse run data")
        return false

func is_valid() -> bool:
    """Validate run data"""
    # Basic sanity checks
    if player_health < 0 or player_max_health <= 0:
        return false
    if player_mana < 0 or player_max_mana <= 0:
        return false
    if current_wave < 1:
        return false
    if player_level < 1:
        return false
    return true

func start_new_run(seed: int = 0):
    """Initialize for new run"""
    # Reset player state to defaults
    player_health = 100.0
    player_max_health = 100.0
    player_mana = 100.0
    player_max_mana = 100.0
    player_position = Vector2.ZERO
    player_level = 1
    player_experience = 0
    
    # Initialize base stats (match Phase 3 defaults)
    base_intelligence = 10
    base_wisdom = 10
    base_vitality = 10
    base_dexterity = 10
    character_level = 1
    
    # Reset reactive stats to Phase 3 defaults
    max_health = 100.0  # Base + vitality * 5 + level * 3 = 100 + 50 + 3
    max_mana = 50.0     # Base + intelligence * 3 + wisdom * 2 + level * 2 = 50 + 30 + 20 + 2
    spell_damage_multiplier = 1.0  # 1.0 + intelligence * 0.02 = 1.0 + 0.2
    mana_regen_rate = 3.0          # 3.0 + wisdom * 0.8 + intelligence * 0.2 = 3.0 + 8 + 2
    health_regen_rate = 2.0        # 2.0 + vitality * 0.5 = 2.0 + 5
    cast_speed_multiplier = 1.0    # 1.0 + dexterity * 0.015 = 1.0 + 0.15
    cooldown_reduction = 0.0       # wisdom * 0.01 = 0.1
    critical_chance = 0.05         # 0.05 + intelligence * 0.001 = 0.05 + 0.01
    movement_speed = 120.0         # 120 + dexterity * 2 = 120 + 20
    spell_projectile_speed = 300.0
    spell_range_multiplier = 1.0
    
    # Clear equipment and inventory for new run
    equipped_items.clear()
    inventory_items.clear()
    
    # Reset spell progression to starting spells
    unlocked_spells = ["fireball", "heal"]
    spell_levels.clear()
    spell_experience.clear()
    
    # Reset wave progression
    current_wave = 1
    waves_completed = 0
    distance_from_spawn = 0.0
    total_kills = 0
    
    # Set world
    world_seed = seed if seed != 0 else randi()
    current_chunk_position = Vector2.ZERO
    discovered_special_chunks.clear()
    
    # Reset statistics
    run_start_time = Time.get_ticks_msec() / 1000.0
    run_duration = 0.0
    damage_dealt = 0.0
    spells_cast = 0

func update_run_duration():
    """Update current run duration"""
    var current_time = Time.get_ticks_msec() / 1000.0
    run_duration = current_time - run_start_time

func add_kill():
    """Add enemy kill"""
    total_kills += 1

func advance_wave():
    """Advance to next wave"""
    waves_completed += 1
    current_wave += 1

func add_spell_cast():
    """Add spell cast count"""
    spells_cast += 1

func add_damage_dealt(damage: float):
    """Add damage dealt"""
    damage_dealt += damage

func update_position(new_position: Vector2):
    """Update player position and distance"""
    player_position = new_position
    distance_from_spawn = player_position.length()

func discover_special_chunk(chunk_pos: Vector2):
    """Add discovered special chunk"""
    if chunk_pos not in discovered_special_chunks:
        discovered_special_chunks.append(chunk_pos)
```

**File: `scripts/core/save/SaveDataValidator.gd`**

```gdscript
# SaveDataValidator.gd - Validation helper for save data
extends RefCounted
class_name SaveDataValidator

static func validate_json_string(json_string: String) -> Dictionary:
    """Validate and parse JSON save data"""
    var result = {"valid": false, "data": null, "error": ""}
    
    if json_string.is_empty():
        result.error = "Empty save data"
        return result
    
    var json = JSON.new()
    var parse_result = json.parse(json_string)
    
    if parse_result != OK:
        result.error = "Invalid JSON format"
        return result
    
    var data = json.data
    if not data is Dictionary:
        result.error = "Save data is not a dictionary"
        return result
    
    # Validate required fields
    if not data.has("save_version"):
        result.error = "Missing save version"
        return result
    
    if not data.has("character_name"):
        result.error = "Missing character name"
        return result
    
    if not data.has("run_data"):
        result.error = "Missing run data"
        return result
    
    result.valid = true
    result.data = data
    return result

static func validate_save_file_path(file_path: String) -> bool:
    """Validate save file path"""
    if not file_path.begins_with("user://"):
        return false
    
    if not file_path.ends_with(".save"):
        return false
    
    return true

static func can_create_save_file(file_path: String) -> bool:
    """Check if save file can be created"""
    if not validate_save_file_path(file_path):
        return false
    
    # Try to create and delete test file
    var test_file = FileAccess.open(file_path + ".test", FileAccess.WRITE)
    if not test_file:
        return false
    
    test_file.close()
    DirAccess.open("user://").remove(file_path + ".test")
    return true

static func sanitize_character_name(name: String) -> String:
    """Sanitize character name for safe usage"""
    # Remove invalid characters for filenames
    var sanitized = name.strip_edges()
    sanitized = sanitized.replace("/", "_")
    sanitized = sanitized.replace("\\", "_")
    sanitized = sanitized.replace(":", "_")
    sanitized = sanitized.replace("*", "_")
    sanitized = sanitized.replace("?", "_")
    sanitized = sanitized.replace("\"", "_")
    sanitized = sanitized.replace("<", "_")
    sanitized = sanitized.replace(">", "_")
    sanitized = sanitized.replace("|", "_")
    
    # Limit length
    if sanitized.length() > 50:
        sanitized = sanitized.substr(0, 50)
    
    return sanitized

static func generate_safe_filename(character_name: String, timestamp: String = "") -> String:
    """Generate safe filename from character name"""
    var safe_name = sanitize_character_name(character_name)
    
    if safe_name.is_empty():
        safe_name = "unnamed_wizard"
    
    if timestamp.is_empty():
        timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
    
    return safe_name + "_" + timestamp + ".save"
```

## Integration Points for Phase 3

This save structure maps directly to your current Phase 3 systems:

### Player.gd Integration
```gdscript
# Add to Player.gd
func get_save_data() -> Dictionary:
    return {
        "health": current_health,
        "max_health": max_health,
        "mana": current_mana,
        "max_mana": max_mana,
        "position": {"x": global_position.x, "y": global_position.y},
        "level": player_level,  # if you have this
        "experience": player_experience  # if you have this
    }

func load_from_save_data(data: Dictionary):
    current_health = data.get("health", max_health)
    current_mana = data.get("mana", max_mana)
    var pos = data.get("position", {"x": 0, "y": 0})
    global_position = Vector2(pos.x, pos.y)
    # Load level/experience if implemented
```

### GameManager.gd Integration
```gdscript
# Add to GameManager.gd
func get_save_data() -> Dictionary:
    return {
        "current_wave": current_wave,
        "waves_completed": waves_completed,
        "total_kills": total_enemy_kills,  # if you track this
        "world_seed": world_seed  # if you have this
    }

func load_from_save_data(data: Dictionary):
    current_wave = data.get("current_wave", 1)
    waves_completed = data.get("waves_completed", 0)
    # Load other progression data
```

## Next Steps

Once this structure is working, we'll build:
- **Phase 3.6B**: Simple Save Manager (just save/load one file)
- **Phase 3.6C**: Auto-save System (saves every 30 seconds)
- **Phase 3.6D**: Basic UI (simple save/load buttons)

Does this save structure cover everything you need for Phase 3? Should I adjust any of the data fields or add anything I missed?