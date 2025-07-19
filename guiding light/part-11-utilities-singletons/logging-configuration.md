# Logging & Configuration Systems

## Logger.gd - Centralized Logging System

**Location**: `res://scripts/Logger.gd` (Autoload)  
**Purpose**: Centralized error tracking and logging across all game systems

### Logging Architecture

#### Log Categories
```gdscript
enum LogCategory {
    GENERAL,        # General system messages
    GAMEEVENTS,     # Event bus messages
    GAMEMANAGER,    # Core game state
    INPUT,          # Input processing
    COLLISION,      # Physics and collision
    PLAYER,         # Player-specific events
    UI,             # User interface
    PERFORMANCE,    # Performance monitoring
    TESTING         # Testing and validation
}
```

#### Logging Levels & Counters
```gdscript
extends Node

# Error tracking counters
var error_count: int = 0
var warning_count: int = 0
var info_count: int = 0

# Log storage for debugging
var error_log: Array = []
var warning_log: Array = []
var max_log_entries: int = 100
```

### Core Logging Functions

#### Error Logging
```gdscript
func log_error(message: String, source: String = "Unknown", category: LogCategory = LogCategory.GENERAL) -> void:
    error_count += 1
    
    var log_entry = {
        "timestamp": Time.get_datetime_string_from_system(),
        "message": message,
        "source": source,
        "category": LogCategory.keys()[category],
        "type": "ERROR"
    }
    
    error_log.append(log_entry)
    _trim_log_if_needed(error_log)
    
    # Console output with formatting
    print("❌ ERROR [" + source + "]: " + message)
    
    # Critical error threshold monitoring
    if error_count > 50:
        push_warning("Logger: High error count detected (" + str(error_count) + "). System stability may be compromised.")
```

#### Warning & Info Logging
```gdscript
func log_warning(message: String, source: String = "Unknown", category: LogCategory = LogCategory.GENERAL) -> void:
    warning_count += 1
    
    var log_entry = {
        "timestamp": Time.get_datetime_string_from_system(),
        "message": message,
        "source": source,
        "category": LogCategory.keys()[category],
        "type": "WARNING"
    }
    
    warning_log.append(log_entry)
    _trim_log_if_needed(warning_log)
    print("⚠️ WARNING [" + source + "]: " + message)

func log_info(message: String, source: String = "Unknown", _category: LogCategory = LogCategory.GENERAL) -> void:
    info_count += 1
    print("ℹ️ INFO [" + source + "]: " + message)
```

### System Health Monitoring

#### Health Assessment
```gdscript
func get_system_health_status() -> String:
    if error_count == 0 and warning_count <= 5:
        return "EXCELLENT"
    elif error_count <= 5 and warning_count <= 15:
        return "GOOD"
    elif error_count <= 15 and warning_count <= 30:
        return "FAIR"
    else:
        return "POOR"

func is_system_healthy() -> bool:
    # System is healthy if error count is low and no critical errors recently
    if error_count > 20:
        return false
    
    var recent_errors = get_recent_errors(10)
    for error in recent_errors:
        if "critical" in error.message.to_lower() or "crash" in error.message.to_lower():
            return false
    
    return true
```

#### Log Analysis & Reporting
```gdscript
func get_error_summary() -> String:
    var summary = "Logger Error Summary:\n"
    summary += "- Total Errors: " + str(error_count) + "\n"
    summary += "- Total Warnings: " + str(warning_count) + "\n"
    summary += "- Total Info Messages: " + str(info_count) + "\n"
    summary += "- Recent Errors: " + str(error_log.size()) + "\n"
    summary += "- Recent Warnings: " + str(warning_log.size()) + "\n"
    summary += "- System Health: " + get_system_health_status() + "\n"
    return summary
```

### Advanced Logging Features

#### Categorized Log Retrieval
```gdscript
func get_errors_by_category(category: LogCategory) -> Array:
    var category_name = LogCategory.keys()[category]
    var filtered_errors = []
    
    for error in error_log:
        if error.category == category_name:
            filtered_errors.append(error)
    
    return filtered_errors

func get_recent_errors(count: int = 10) -> Array:
    var recent_count = min(count, error_log.size())
    return error_log.slice(-recent_count)
```

#### Performance Integration
```gdscript
func log_performance_warning(fps: float, source: String = "Performance Monitor") -> void:
    if fps < 30:
        log_error("Critical FPS drop detected: " + str(fps) + " FPS", source, LogCategory.PERFORMANCE)
    elif fps < 45:
        log_warning("Low FPS detected: " + str(fps) + " FPS", source, LogCategory.PERFORMANCE)
```

## GameConfig.gd - Configuration Management

**Location**: `res://scripts/singletons/GameConfig.gd` (Autoload)  
**Purpose**: Centralized configuration with live tuning and debug logging

### Configuration Architecture

#### Configuration Loading
```gdscript
extends Node

signal config_loaded()
signal config_error(error_message: String)

var constants: GameConstants
var config_file_path: String = "res://data/game_constants.tres"
var is_loaded: bool = false
var debug_mode: bool = true
```

#### Debug Logging System Integration
```gdscript
# Enhanced Debug Logging Categories
const DEBUG_CATEGORY_COMBAT = 0
const DEBUG_CATEGORY_ENEMY_AI = 1
const DEBUG_CATEGORY_PLAYER = 2
const DEBUG_CATEGORY_PROJECTILES = 3
const DEBUG_CATEGORY_INDICATORS = 4
const DEBUG_CATEGORY_SPAWNING = 5
const DEBUG_CATEGORY_PERFORMANCE = 6
const DEBUG_CATEGORY_SYSTEMS = 7

var debug_level: int = DEBUG_LEVEL_ERRORS
var debug_categories: Dictionary = {}
```

### Configuration Categories

#### AI Performance Settings
```gdscript
func get_ai_update_interval() -> float:
    return constants.ai_update_interval if is_loaded else 0.3

func get_player_cache_lifetime() -> float:
    return constants.player_cache_lifetime if is_loaded else 2.0

func get_ability_spam_prevention() -> float:
    return constants.ability_spam_prevention if is_loaded else 0.5
```

#### Enemy Behavior Configuration
```gdscript
func get_separation_distance() -> float:
    return constants.enemy_separation_distance if is_loaded else 50.0

func get_contact_damage_immunity() -> float:
    return constants.contact_damage_immunity if is_loaded else 0.5

func get_damage_immunity_duration() -> float:
    return constants.damage_immunity_duration if is_loaded else 0.1
```

#### Performance Settings
```gdscript
func get_max_simultaneous_enemies() -> int:
    return constants.max_simultaneous_enemies if is_loaded else 25

func get_particle_count_multiplier() -> float:
    return constants.particle_count_multiplier if is_loaded else 1.0

func get_logging_probability() -> float:
    return constants.logging_probability if is_loaded else 0.2
```

### Live Configuration Tuning

#### Runtime Configuration Changes
```gdscript
func set_ai_update_interval(value: float):
    if is_loaded and value > 0:
        constants.ai_update_interval = value
        print("🔧 GameConfig: AI update interval set to ", value)

func set_particle_multiplier(value: float):
    if is_loaded and value >= 0:
        constants.particle_count_multiplier = value
        print("🔧 GameConfig: Particle multiplier set to ", value)

func toggle_debug_mode():
    if is_loaded:
        constants.debug_mode_enabled = not constants.debug_mode_enabled
        debug_mode = constants.debug_mode_enabled
        print("🔧 GameConfig: Debug mode ", "enabled" if constants.debug_mode_enabled else "disabled")
```

#### Configuration Persistence
```gdscript
func save_configuration():
    if not constants:
        push_error("❌ GameConfig: No configuration to save")
        return false
        
    var error = ResourceSaver.save(constants, config_file_path)
    if error == OK:
        print("💾 GameConfig: Configuration saved to " + config_file_path)
        return true
    else:
        push_error("❌ GameConfig: Failed to save configuration: " + str(error))
        return false
```

### Advanced Debug Logging

#### Category-Based Logging
```gdscript
func should_log(category: int, level: int = DEBUG_LEVEL_INFO) -> bool:
    if debug_level == DEBUG_LEVEL_OFF:
        return false
    if debug_level >= level and debug_categories.get(category, false):
        return true
    return false

func log_debug(category: int, message: String, level: int = DEBUG_LEVEL_INFO):
    if should_log(category, level):
        var prefix = _get_category_prefix(category)
        print(prefix + message)

func _get_category_prefix(category: int) -> String:
    match category:
        DEBUG_CATEGORY_COMBAT: return "⚔️ "
        DEBUG_CATEGORY_ENEMY_AI: return "🤖 "
        DEBUG_CATEGORY_PLAYER: return "🎮 "
        DEBUG_CATEGORY_PROJECTILES: return "💥 "
        DEBUG_CATEGORY_PERFORMANCE: return "📊 "
        _: return "❓ "
```

#### Debug Presets
```gdscript
func apply_debug_preset(preset_name: String):
    match preset_name:
        "production":
            debug_level = DEBUG_LEVEL_OFF
            _disable_all_categories()
        "testing":
            debug_level = DEBUG_LEVEL_ERRORS
            debug_categories[DEBUG_CATEGORY_COMBAT] = true
            debug_categories[DEBUG_CATEGORY_PERFORMANCE] = true
        "combat_debug":
            debug_level = DEBUG_LEVEL_VERBOSE
            debug_categories[DEBUG_CATEGORY_COMBAT] = true
            debug_categories[DEBUG_CATEGORY_ENEMY_AI] = true
        "developer":
            debug_level = DEBUG_LEVEL_DEV
            _enable_all_categories()
```

## Integration with Quality Systems

### Logger-QualityGate Integration
```gdscript
# QualityGate.gd uses Logger for error tracking
func _perform_comprehensive_check() -> Dictionary:
    var check_result = {}
    
    # Get error/warning counts from Logger
    if Logger:
        check_result.error_count = Logger.error_count
        check_result.warning_count = Logger.warning_count
    
    return check_result
```

### Configuration-Performance Integration
```gdscript
# Performance systems use GameConfig for settings
func should_log_event() -> bool:
    return GameConfig.should_log_event() if GameConfig.is_loaded else (randf() < 0.2)

func get_scaled_particle_count(base_count: int) -> int:
    return GameConfig.get_scaled_particle_count(base_count) if GameConfig.is_loaded else base_count
```

## Modding & Extension Support

### Modding Configuration Support
```gdscript
func apply_mod_configuration(mod_constants: Dictionary):
    if not is_loaded:
        return false
        
    var applied_count = 0
    for key in mod_constants:
        if key in constants:
            var old_value = constants.get(key)
            constants.set(key, mod_constants[key])
            print("🔧 Mod Config: ", key, " changed from ", old_value, " to ", mod_constants[key])
            applied_count += 1
    
    if applied_count > 0:
        print("✅ Mod Config: Applied ", applied_count, " configuration overrides")
        return constants.validate()
    
    return true
```

### Configuration Snapshot Export
```gdscript
func get_configuration_snapshot() -> Dictionary:
    if not is_loaded:
        return {}
    
    var snapshot = {}
    var property_list = constants.get_property_list()
    for property in property_list:
        if property.usage & PROPERTY_USAGE_STORAGE:
            snapshot[property.name] = constants.get(property.name)
    
    return snapshot
```

## Testing & Validation Integration

### Logger Testing
```gdscript
func test_logger_functionality() -> bool:
    print("🧪 Testing Logger functionality...")
    
    var initial_error_count = error_count
    var initial_warning_count = warning_count
    
    # Test basic logging
    log_error("Test error message", "Logger Test", LogCategory.TESTING)
    log_warning("Test warning message", "Logger Test", LogCategory.TESTING)
    log_info("Test info message", "Logger Test", LogCategory.TESTING)
    
    # Verify counts increased
    var errors_increased = (error_count == initial_error_count + 1)
    var warnings_increased = (warning_count == initial_warning_count + 1)
    
    if errors_increased and warnings_increased:
        log_info("Logger functionality test PASSED", "Logger Test", LogCategory.TESTING)
        return true
    else:
        print("❌ Logger functionality test FAILED")
        return false
```

### Configuration Validation
```gdscript
func validate_configuration() -> bool:
    if not is_loaded:
        return false
    
    return constants.validate() if constants else false
```

## Performance Considerations

### Logging Performance
- **Conditional Logging**: Debug logging disabled in release builds
- **Log Rotation**: Automatic cleanup of old log entries
- **Categorized Filtering**: Only log relevant categories
- **String Optimization**: Minimize string allocation in logging

### Configuration Performance
- **Cached Access**: Frequently used values cached in GameConfig
- **Lazy Loading**: Configuration loaded only when needed
- **Change Notifications**: Signal-based updates for configuration changes

---

*The logging and configuration systems provide robust development support while maintaining performance in release builds through conditional compilation and efficient data structures.*