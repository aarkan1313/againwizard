# Priority 2: Error Handler Standardization

## Overview
**Problem**: 61 files with inconsistent error handling patterns  
**Goal**: Unified error handling system across entire codebase  
**Timeline**: 3 hours over 1 day  
**Risk Level**: Low (improves reliability and debugging)

## Current Error Handling Issues

### Inconsistent Patterns Analysis
```bash
# Count of different error handling patterns:
grep -r "push_error(" scripts/ | wc -l     # 127 instances
grep -r "push_warning(" scripts/ | wc -l   # 89 instances  
grep -r "print_debug(" scripts/ | wc -l    # 23 instances
grep -r "print(" scripts/ | wc -l          # 1,847 instances (many for errors)
```

### Problem Examples

#### Mixed Error Levels for Similar Issues
```gdscript
# SaveManager.gd - uses push_error
if not file_exists:
    push_error("Save file not found: " + file_path)

# GameManager.gd - uses print for same type of issue  
if not file_exists:
    print("❌ ERROR: Save file not found: " + file_path)

# PlayerStatSheet.gd - uses push_warning for error condition
if not stat_sheet:
    push_warning("StatSheet: Stat not found: " + stat_name + " - returning 0")
```

#### Inconsistent Formatting
```gdscript
# Different prefixes and formats across files:
push_error("Error: Cannot load file")                    # Format 1
push_error("❌ CRITICAL: File system failure")          # Format 2  
print("ERROR [COMBAT]: Invalid ability data")           # Format 3
print("⚠️ WARNING: Performance degradation detected")    # Format 4
UnifiedDebugSystem.log_error("Component failed", ...)   # Format 5
```

#### Missing Context Information
```gdscript
# Insufficient context for debugging:
push_error("Validation failed")                         # What validation?
print("❌ Setup failed")                               # Which component?
push_warning("Invalid data")                           # What data? Where?
```

## Solution Architecture

### Centralized ErrorHandler System
```
ErrorHandler (Static Class)
├── Standardized Log Levels
├── Consistent Formatting  
├── Context Tracking
├── Performance Monitoring
└── Debug Integration
```

### Error Level Hierarchy
```
CRITICAL → Application may crash, data loss possible
ERROR    → Feature broken, but application continues  
WARNING  → Degraded performance or unexpected behavior
INFO     → Important information for debugging
DEBUG    → Detailed information for development
```

## Implementation Plan

### Step 1: Create ErrorHandler Singleton (1 hour)
```gdscript
# Create new file: scripts/core/ErrorHandler.gd
class_name ErrorHandler
extends RefCounted

# Centralized error handling system for consistent logging across codebase
# Replaces mixed push_error(), push_warning(), print() patterns

enum Level {
    DEBUG,      # Detailed development information
    INFO,       # Important runtime information  
    WARNING,    # Degraded performance or unexpected behavior
    ERROR,      # Feature broken but application continues
    CRITICAL    # Application may crash or data loss possible
}

# Error statistics for monitoring
static var error_counts: Dictionary = {
    Level.DEBUG: 0,
    Level.INFO: 0, 
    Level.WARNING: 0,
    Level.ERROR: 0,
    Level.CRITICAL: 0
}

static var recent_errors: Array[Dictionary] = []
const MAX_RECENT_ERRORS = 100

# Configuration
static var log_level: Level = Level.INFO
static var enable_stack_traces: bool = false
static var enable_performance_tracking: bool = true

# Performance tracking
static var error_performance_impact: Dictionary = {}

static func log(level: Level, message: String, context: String = "", category: String = ""):
    """Main logging function - replaces all error handling calls"""
    
    # Check if we should log this level
    if level < log_level and level != Level.CRITICAL:
        return
    
    # Track error statistics
    error_counts[level] += 1
    
    # Format message with consistent structure
    var formatted_message = _format_message(level, message, context, category)
    
    # Route to appropriate Godot logging system
    match level:
        Level.CRITICAL:
            push_error(formatted_message)
            _handle_critical_error(message, context)
        Level.ERROR:
            push_error(formatted_message)
        Level.WARNING:
            push_warning(formatted_message)
        Level.INFO, Level.DEBUG:
            print(formatted_message)
    
    # Store for recent errors tracking
    _store_recent_error(level, message, context, category)
    
    # Performance impact tracking
    if enable_performance_tracking:
        _track_performance_impact(level, context)
    
    # Integration with UnifiedDebugSystem if available
    if UnifiedDebugSystem:
        _integrate_with_debug_system(level, message, context, category)

static func _format_message(level: Level, message: String, context: String, category: String) -> String:
    """Consistent message formatting across all error types"""
    
    var level_prefix = _get_level_prefix(level)
    var timestamp = Time.get_datetime_string_from_system()
    
    var formatted = "%s [%s]" % [level_prefix, timestamp]
    
    if not category.is_empty():
        formatted += " [%s]" % category.to_upper()
    
    if not context.is_empty():
        formatted += " (%s):" % context
    else:
        formatted += ":"
    
    formatted += " " + message
    
    # Add stack trace for errors and critical issues
    if level >= Level.ERROR and enable_stack_traces:
        var stack = get_stack()
        if stack.size() > 2:  # Skip ErrorHandler frames
            formatted += "\n  Stack: " + stack[2].source + ":" + str(stack[2].line)
    
    return formatted

static func _get_level_prefix(level: Level) -> String:
    """Get consistent prefix for each log level"""
    match level:
        Level.CRITICAL: return "🚨 CRITICAL"
        Level.ERROR:    return "❌ ERROR"  
        Level.WARNING:  return "⚠️ WARNING"
        Level.INFO:     return "ℹ️ INFO"
        Level.DEBUG:    return "🔍 DEBUG"
        _:              return "📝 LOG"

static func _store_recent_error(level: Level, message: String, context: String, category: String):
    """Store error for recent errors tracking"""
    var error_entry = {
        "timestamp": Time.get_ticks_msec(),
        "level": level,
        "message": message,
        "context": context,
        "category": category,
        "frame": Engine.get_process_frames()
    }
    
    recent_errors.append(error_entry)
    
    # Maintain size limit
    if recent_errors.size() > MAX_RECENT_ERRORS:
        recent_errors.pop_front()

static func _track_performance_impact(level: Level, context: String):
    """Track performance impact of frequent errors"""
    if context.is_empty():
        return
    
    if not error_performance_impact.has(context):
        error_performance_impact[context] = {
            "count": 0,
            "first_seen": Time.get_ticks_msec(),
            "last_seen": Time.get_ticks_msec()
        }
    
    var impact = error_performance_impact[context]
    impact.count += 1
    impact.last_seen = Time.get_ticks_msec()
    
    # Warn about frequent errors from same context
    if impact.count > 10 and (impact.last_seen - impact.first_seen) < 10000:  # 10 errors in 10 seconds
        push_warning("🔥 PERFORMANCE: Frequent errors from context '%s' (%d errors in %dms)" % [
            context, impact.count, impact.last_seen - impact.first_seen
        ])

static func _handle_critical_error(message: String, context: String):
    """Special handling for critical errors"""
    # Log to file for post-crash analysis
    var file = FileAccess.open("user://critical_errors.log", FileAccess.WRITE)
    if file:
        var entry = "[%s] CRITICAL in %s: %s\n" % [
            Time.get_datetime_string_from_system(),
            context,
            message
        ]
        file.store_string(entry)
        file.close()
    
    # Consider triggering emergency save
    if GameManager and GameManager.has_method("emergency_save"):
        GameManager.emergency_save()

static func _integrate_with_debug_system(level: Level, message: String, context: String, category: String):
    """Integration with existing UnifiedDebugSystem"""
    
    # Map to UnifiedDebugSystem categories
    var debug_category = UnifiedDebugSystem.LogCategory.GENERAL
    match category.to_lower():
        "player":    debug_category = UnifiedDebugSystem.LogCategory.PLAYER
        "combat":    debug_category = UnifiedDebugSystem.LogCategory.COMBAT
        "world":     debug_category = UnifiedDebugSystem.LogCategory.WORLD
        "ui":        debug_category = UnifiedDebugSystem.LogCategory.UI
        "save":      debug_category = UnifiedDebugSystem.LogCategory.SAVE
    
    # Route to appropriate UnifiedDebugSystem method
    match level:
        Level.CRITICAL, Level.ERROR:
            UnifiedDebugSystem.log_error(message, context, debug_category)
        Level.WARNING:
            UnifiedDebugSystem.log_warning(message, context, debug_category)
        Level.INFO:
            UnifiedDebugSystem.log_info(debug_category, message, context)
        Level.DEBUG:
            UnifiedDebugSystem.log_debug(debug_category, message, context)

# Convenience methods for common use cases
static func critical(message: String, context: String = "", category: String = ""):
    log(Level.CRITICAL, message, context, category)

static func error(message: String, context: String = "", category: String = ""):
    log(Level.ERROR, message, context, category)

static func warning(message: String, context: String = "", category: String = ""):
    log(Level.WARNING, message, context, category)

static func info(message: String, context: String = "", category: String = ""):
    log(Level.INFO, message, context, category)

static func debug(message: String, context: String = "", category: String = ""):
    log(Level.DEBUG, message, context, category)

# Performance and monitoring methods
static func get_error_statistics() -> Dictionary:
    """Get error statistics for monitoring"""
    return {
        "counts": error_counts.duplicate(),
        "recent_errors": recent_errors.size(),
        "performance_impacts": error_performance_impact.size(),
        "current_log_level": log_level
    }

static func get_recent_errors(count: int = 10) -> Array:
    """Get recent errors for debugging"""
    var recent = recent_errors.duplicate()
    recent.reverse()  # Most recent first
    return recent.slice(0, min(count, recent.size()))

static func clear_statistics():
    """Clear error statistics (for testing)"""
    error_counts = {
        Level.DEBUG: 0,
        Level.INFO: 0,
        Level.WARNING: 0, 
        Level.ERROR: 0,
        Level.CRITICAL: 0
    }
    recent_errors.clear()
    error_performance_impact.clear()

static func set_log_level(level: Level):
    """Set minimum log level"""
    log_level = level
    print("🔧 ErrorHandler: Log level set to ", Level.keys()[level])

static func enable_debug_features(enable: bool):
    """Enable/disable debug features like stack traces"""
    enable_stack_traces = enable
    enable_performance_tracking = enable
```

### Step 2: Migration Patterns (1.5 hours)

#### Replace Direct push_error() Calls
```gdscript
# OLD:
push_error("Save file not found: " + file_path)

# NEW:
ErrorHandler.error("Save file not found: " + file_path, "SaveManager", "save")
```

#### Replace Direct push_warning() Calls
```gdscript
# OLD:
push_warning("StatSheet: Stat not found: " + stat_name + " - returning 0")

# NEW:
ErrorHandler.warning("Stat not found: " + stat_name + " - returning 0", "PlayerStatSheet", "stats")
```

#### Replace Mixed Print Statements
```gdscript
# OLD:
print("❌ ERROR: Component setup failed")
print("⚠️ WARNING: Performance degraded")  
print("ℹ️ INFO: System initialized")

# NEW:
ErrorHandler.error("Component setup failed", "ComponentName", "initialization")
ErrorHandler.warning("Performance degraded", "ComponentName", "performance")
ErrorHandler.info("System initialized", "ComponentName", "initialization")
```

### Step 3: Update High-Impact Files (30 minutes)

#### SaveManager.gd Updates
```gdscript
# Replace all error handling:
# OLD:
if not file:
    push_error("Cannot open save file: " + file_path)
    return false

# NEW:  
if not file:
    ErrorHandler.error("Cannot open save file: " + file_path, "SaveManager", "save")
    return false
```

#### GameManager.gd Updates
```gdscript
# OLD:
print("🎮 GameManager initialized")
print("❌ Player not found for chunk system")

# NEW:
ErrorHandler.info("GameManager initialized", "GameManager", "initialization")
ErrorHandler.warning("Player not found for chunk system", "GameManager", "world")
```

#### Enemy.gd Updates
```gdscript
# OLD:
print("DEBUG: No abilities setup for ", enemy_type)
push_warning("Enemy health component not found")

# NEW:
ErrorHandler.debug("No abilities setup for " + enemy_type, "Enemy", "combat")
ErrorHandler.warning("Health component not found", "Enemy", "combat")
```

## Migration Strategy

### Phase 1: Core Systems (High Priority)
Update systems that produce the most errors:
- SaveManager.gd
- GameManager.gd  
- PlayerStatSheet.gd
- Enemy.gd
- UnifiedWorldManager.gd

### Phase 2: Components (Medium Priority)
- HealthComponent.gd
- SpellComponent.gd
- EnemyAIController.gd
- All manager classes

### Phase 3: UI and Utilities (Low Priority)
- UI controllers
- Debug systems
- Validation scripts
- Test files

### Automated Migration Script
```bash
#!/bin/bash
# Script to help with migration - identifies files needing updates

echo "Finding files with error handling patterns..."

# Find files with push_error
echo "Files with push_error():"
grep -l "push_error(" scripts/**/*.gd

# Find files with push_warning  
echo "Files with push_warning():"
grep -l "push_warning(" scripts/**/*.gd

# Find files with error print statements
echo "Files with error print statements:"
grep -l "print.*ERROR\|print.*❌" scripts/**/*.gd

echo "Run manual migration on these files using ErrorHandler patterns"
```

## Testing Strategy

### Unit Tests
```gdscript
# test_error_handler.gd
func test_error_level_routing():
    ErrorHandler.clear_statistics()
    
    ErrorHandler.critical("Test critical", "Test", "test")
    ErrorHandler.error("Test error", "Test", "test")  
    ErrorHandler.warning("Test warning", "Test", "test")
    
    var stats = ErrorHandler.get_error_statistics()
    assert_eq(stats.counts[ErrorHandler.Level.CRITICAL], 1)
    assert_eq(stats.counts[ErrorHandler.Level.ERROR], 1)
    assert_eq(stats.counts[ErrorHandler.Level.WARNING], 1)

func test_message_formatting():
    # Test that messages are formatted consistently
    ErrorHandler.error("Test message", "TestContext", "test")
    
    var recent = ErrorHandler.get_recent_errors(1)
    assert_eq(recent.size(), 1)
    assert_eq(recent[0].message, "Test message")
    assert_eq(recent[0].context, "TestContext")

func test_performance_tracking():
    ErrorHandler.clear_statistics()
    
    # Generate frequent errors from same context
    for i in range(5):
        ErrorHandler.error("Frequent error", "TestContext", "test")
    
    # Should track performance impact
    var stats = ErrorHandler.get_error_statistics()
    assert_gt(stats.performance_impacts, 0)
```

### Integration Tests
```gdscript
func test_unified_debug_integration():
    # Test integration with existing UnifiedDebugSystem
    ErrorHandler.error("Test error", "TestComponent", "combat")
    
    # Should appear in UnifiedDebugSystem logs
    # (This would need UnifiedDebugSystem testing support)
```

## Success Criteria

### Code Quality
- **100% consistent error formatting** across codebase
- **Proper categorization** of all error types
- **Meaningful context** in all error messages
- **Elimination of mixed error patterns**

### Performance Monitoring
- **Error frequency tracking** per component
- **Performance impact detection** for frequent errors
- **Critical error logging** for post-crash analysis

### Developer Experience
- **Easier debugging** with consistent formats
- **Better error context** for faster problem resolution
- **Performance insights** from error patterns

## Risk Mitigation

### Backward Compatibility
- Keep existing error functions working during transition
- Gradual migration to avoid breaking changes
- Feature flag to switch between old/new systems

### Performance Impact
- Minimal overhead from error handling improvements
- Efficient storage of error statistics
- Configurable log levels to reduce noise

## Expected Benefits

### Immediate
- **Consistent error formatting** across entire codebase
- **Better error context** for faster debugging
- **Centralized error statistics** for monitoring

### Long-term
- **Easier maintenance** with standardized patterns
- **Better performance monitoring** through error tracking
- **Improved reliability** through better error handling
- **Foundation for automated error analysis**

This standardization will eliminate the confusion of mixed error handling patterns and provide a solid foundation for reliable error reporting and debugging throughout the codebase.