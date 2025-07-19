# Priority 1: SaveManager God Object Split

## Overview
**File**: `scripts/core/save/SaveManager.gd` (1,609 lines)  
**Problem**: Single class handling file I/O, validation, game state, UI, and performance tracking  
**Goal**: Split into 5 focused classes, each under 300 lines  
**Timeline**: 12 hours over 3 days  
**Risk Level**: Medium (core system refactor)

## Current Architecture Issues
- Single file with 1,609 lines violates Single Responsibility Principle
- Mixed file I/O, game state, UI, and validation logic
- Difficult to test, debug, and maintain
- Performance monitoring mixed with business logic
- Tight coupling between unrelated concerns

## New Architecture Design

```
scripts/core/save/
├── SaveFileManager.gd          # File I/O operations only (200 lines)
├── SaveDataValidator.gd        # Data validation (already exists - enhance)
├── SaveStateManager.gd         # Game state synchronization (250 lines)
├── SaveUIController.gd         # UI integration and signals (150 lines)
├── SavePerformanceTracker.gd   # Performance monitoring (100 lines)
└── SaveCoordinator.gd          # Main orchestrator (200 lines)
```

## Implementation Plan

### Day 1: Setup and File Operations (4 hours)

#### Step 1: Create SaveFileManager.gd (2 hours)
```gdscript
# SaveFileManager.gd
class_name SaveFileManager
extends RefCounted

# Responsibilities:
# - File I/O operations only
# - Atomic save/load operations
# - Backup file management
# - File corruption detection

var save_directory: String = "user://"

func save_to_file(slot: int, data: Dictionary) -> bool:
    # Atomic save with backup
    var file_path = save_directory + "save_slot_%d.save" % slot
    var backup_path = file_path + ".bak"
    
    # Create backup
    if FileAccess.file_exists(file_path):
        var backup_result = _create_backup(file_path, backup_path)
        if not backup_result:
            push_error("Failed to create backup")
            return false
    
    # Write new file
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        push_error("Cannot open save file: " + file_path)
        return false
    
    file.store_string(JSON.stringify(data))
    file.close()
    
    return true

func load_from_file(slot: int) -> Dictionary:
    var file_path = save_directory + "save_slot_%d.save" % slot
    
    if not FileAccess.file_exists(file_path):
        return {}
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        push_error("Cannot open save file: " + file_path)
        return {}
    
    var json_string = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var parse_result = json.parse(json_string)
    
    if parse_result != OK:
        push_error("Save file corrupted: " + file_path)
        return _try_load_backup(slot)
    
    return json.get_data()

func _create_backup(source: String, backup: String) -> bool:
    # Atomic backup creation
    
func _try_load_backup(slot: int) -> Dictionary:
    # Backup recovery logic
```

#### Step 2: Extract Performance Tracking (2 hours)
```gdscript
# SavePerformanceTracker.gd
class_name SavePerformanceTracker
extends RefCounted

# Responsibilities:
# - Save/load timing
# - Performance metrics
# - Memory usage tracking

signal performance_data_updated(metrics: Dictionary)

var metrics: Dictionary = {}

func start_save_timing(operation: String) -> int:
    var timer_id = Time.get_ticks_msec()
    metrics[operation + "_start"] = timer_id
    return timer_id

func end_save_timing(operation: String, timer_id: int):
    var end_time = Time.get_ticks_msec()
    var duration = end_time - metrics.get(operation + "_start", end_time)
    metrics[operation + "_duration"] = duration
    
    if duration > 100:  # Log slow operations
        print("⚠️ Slow save operation: ", operation, " took ", duration, "ms")
    
    performance_data_updated.emit(metrics)
```

### Day 2: State Management and UI (4 hours)

#### Step 3: Create SaveStateManager.gd (2 hours)
```gdscript
# SaveStateManager.gd
class_name SaveStateManager
extends RefCounted

# Responsibilities:
# - Game state synchronization
# - Wave/player data coordination
# - State validation and consistency

signal state_synchronized()
signal state_error(error: String)

var current_state: Dictionary = {}

func synchronize_from_game() -> Dictionary:
    """Extract current game state from all systems"""
    var state = {}
    
    # Player state
    if _validate_player_data():
        state.player = _extract_player_data()
    
    # Wave state
    if _validate_wave_data():
        state.wave = _extract_wave_data()
    
    # World state
    if _validate_world_data():
        state.world = _extract_world_data()
    
    current_state = state
    state_synchronized.emit()
    return state

func apply_to_game(state: Dictionary) -> bool:
    """Apply saved state to all game systems"""
    var success = true
    
    if "player" in state:
        success = success and _apply_player_data(state.player)
    
    if "wave" in state:
        success = success and _apply_wave_data(state.wave)
    
    if "world" in state:
        success = success and _apply_world_data(state.world)
    
    if not success:
        state_error.emit("Failed to apply game state")
    
    return success

func _extract_player_data() -> Dictionary:
    # Safe player data extraction with validation
    
func _apply_player_data(data: Dictionary) -> bool:
    # Safe player data application
```

#### Step 4: Create SaveUIController.gd (2 hours)
```gdscript
# SaveUIController.gd
class_name SaveUIController
extends RefCounted

# Responsibilities:
# - UI feedback and progress
# - Save/load status messages
# - User interaction coordination

signal save_progress_updated(percentage: float, message: String)
signal save_completed(success: bool, message: String)
signal load_completed(success: bool, message: String)

func show_save_progress(step: String, current: int, total: int):
    var percentage = float(current) / float(total) * 100.0
    var message = "Saving... %s (%d/%d)" % [step, current, total]
    save_progress_updated.emit(percentage, message)

func show_save_result(success: bool, slot: int, duration_ms: int):
    var message = ""
    if success:
        message = "Game saved to slot %d in %.2fs" % [slot, duration_ms / 1000.0]
    else:
        message = "Failed to save to slot %d" % slot
    
    save_completed.emit(success, message)

func show_load_result(success: bool, slot: int, duration_ms: int):
    var message = ""
    if success:
        message = "Game loaded from slot %d in %.2fs" % [slot, duration_ms / 1000.0]
    else:
        message = "Failed to load from slot %d" % slot
    
    load_completed.emit(success, message)
```

### Day 3: Integration and Testing (4 hours)

#### Step 5: Create SaveCoordinator.gd (2 hours)
```gdscript
# SaveCoordinator.gd (replaces SaveManager in autoloads)
class_name SaveCoordinator
extends Node

# Responsibilities:
# - Orchestrate all save components
# - Public API for game systems
# - Error handling and recovery

var file_manager: SaveFileManager
var state_manager: SaveStateManager
var ui_controller: SaveUIController
var performance_tracker: SavePerformanceTracker
var validator: SaveDataValidator  # Enhanced existing class

signal save_completed(success: bool)
signal load_completed(success: bool)

func _ready():
    _initialize_components()
    _connect_signals()

func save_game(slot: int) -> bool:
    var timer_id = performance_tracker.start_save_timing("full_save")
    ui_controller.show_save_progress("Extracting state", 1, 4)
    
    # Extract game state
    var game_state = state_manager.synchronize_from_game()
    ui_controller.show_save_progress("Validating data", 2, 4)
    
    # Validate data
    var validation_result = validator.validate_save_data(game_state)
    if not validation_result.valid:
        ui_controller.show_save_result(false, slot, 0)
        save_completed.emit(false)
        return false
    
    ui_controller.show_save_progress("Writing file", 3, 4)
    
    # Save to file
    var save_success = file_manager.save_to_file(slot, game_state)
    
    ui_controller.show_save_progress("Complete", 4, 4)
    performance_tracker.end_save_timing("full_save", timer_id)
    
    ui_controller.show_save_result(save_success, slot, 
        performance_tracker.metrics.get("full_save_duration", 0))
    save_completed.emit(save_success)
    
    return save_success

func load_game(slot: int) -> bool:
    # Similar orchestration for loading
```

#### Step 6: Update Autoloads and References (1 hour)
```
# project.godot changes:
# Replace: SaveManager="*res://scripts/core/save/SaveManager.gd"
# With:    SaveCoordinator="*res://scripts/core/save/SaveCoordinator.gd"

# Update all references in codebase:
# SaveManager.save_game() → SaveCoordinator.save_game()
# SaveManager.load_game() → SaveCoordinator.load_game()
```

#### Step 7: Integration Testing (1 hour)
- Test save/load functionality with new architecture
- Verify all UI feedback works correctly
- Check performance metrics are captured
- Validate error handling and recovery

## Testing Strategy

### Unit Tests
```gdscript
# test_save_file_manager.gd
func test_atomic_save():
    var file_manager = SaveFileManager.new()
    var test_data = {"test": "data"}
    var result = file_manager.save_to_file(999, test_data)
    assert_true(result)
    
    var loaded_data = file_manager.load_from_file(999)
    assert_eq(loaded_data.test, "data")

# test_save_state_manager.gd
func test_state_extraction():
    var state_manager = SaveStateManager.new()
    var state = state_manager.synchronize_from_game()
    assert_true(state.has("player"))
    assert_true(state.has("wave"))
```

### Integration Tests
- Full save/load cycle test
- Backup recovery test
- Performance regression test
- UI feedback test

## Migration Strategy

### Phase 1: Parallel Implementation
- Keep original SaveManager.gd functional
- Implement new components alongside
- Add feature flag to switch between systems

### Phase 2: Gradual Migration
- Route save operations through SaveCoordinator
- Test thoroughly with existing save files
- Monitor performance and error rates

### Phase 3: Complete Replacement
- Remove original SaveManager.gd
- Update all references
- Clean up legacy code

## Success Criteria

### Code Quality
- Each file under 300 lines ✓
- Single responsibility per class ✓
- Clear separation of concerns ✓
- Comprehensive error handling ✓

### Performance
- Save/load times within 10% of current performance
- Memory usage not increased
- Better error recovery capabilities

### Maintainability
- Easy to add new save data types
- Simple to modify UI feedback
- Clear debugging and logging
- Testable components

## Risk Mitigation

### Data Loss Prevention
- Comprehensive backup system
- Atomic file operations
- Validation at every step
- Recovery mechanisms

### Performance Risks
- Benchmark before/after performance
- Monitor memory allocation
- Profile critical save/load paths
- Optimize bottlenecks

### Integration Risks
- Maintain backward compatibility
- Gradual rollout with feature flags
- Extensive testing with existing saves
- Quick rollback capability

## Expected Benefits

### Immediate
- **60% reduction in SaveManager complexity**
- **Improved error handling and recovery**
- **Better separation of concerns**
- **Enhanced testability**

### Long-term
- **Easier maintenance and debugging**
- **Simpler addition of new features**
- **Better performance monitoring**
- **Reduced coupling between systems**

This refactor will transform the save system from a monolithic, hard-to-maintain component into a clean, modular architecture that follows SOLID principles and is much easier to extend and debug.