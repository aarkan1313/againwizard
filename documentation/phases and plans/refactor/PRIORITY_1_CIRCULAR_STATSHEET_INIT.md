# Priority 1: Circular StatSheet Initialization Fix

## Overview
**File**: `scripts/entities/Player.gd` lines 89-95  
**Problem**: Player creates StatSheet which references Player during initialization  
**Goal**: Clean dependency injection pattern eliminating circular references  
**Timeline**: 2 hours  
**Risk Level**: Medium (affects player initialization)

## Current Architecture Issues

### Circular Dependency Chain
```
Player._ready() 
  → creates PlayerStatSheet.new()
    → PlayerStatSheet._init(player_entity)
      → needs Player reference for stat calculations
        → Player may not be fully initialized yet
```

### Code Analysis
```gdscript
# Player.gd lines 89-95
func _ready():
    # Create player stat sheet as RefCounted (not a Node)
    if not stat_sheet:
        stat_sheet = PlayerStatSheet.new()
        stat_sheet.owner_entity = self  # CIRCULAR REFERENCE
    
    # Set up health component with stat sheet values
    if health_component and health_component.has_method("setup"):
        health_component.setup(self)  # May need stat_sheet which needs self
```

### Problems This Causes
1. **Race Conditions**: Player may not be fully initialized when StatSheet needs it
2. **Null Reference Errors**: Components may access incomplete Player state
3. **Initialization Order Issues**: Dependent systems can't rely on each other
4. **Tight Coupling**: StatSheet becomes dependent on Player implementation details

## Root Cause Analysis

### Current Initialization Flow (Problematic)
```
1. Player._ready() starts
2. PlayerStatSheet.new(self) called
3. PlayerStatSheet._init() needs Player data
4. Player is not fully ready yet
5. Race condition or incomplete initialization
```

### Dependencies That Create Cycles
- **Player** needs **StatSheet** for health/mana values
- **StatSheet** needs **Player** for entity reference and validation
- **HealthComponent** needs **StatSheet** for max values
- **HealthComponent** needs **Player** for setup coordination

## New Architecture Design

### Dependency Injection Pattern
```
PlayerBuilder (Factory)
├── Creates Player instance
├── Creates PlayerStatSheet instance  
├── Creates HealthComponent instance
├── Injects dependencies in correct order
└── Finalizes initialization
```

### Initialization Phases
```
Phase 1: Object Creation (no dependencies)
├── Player instance created
├── PlayerStatSheet instance created
└── HealthComponent instance created

Phase 2: Dependency Injection
├── StatSheet.set_owner(player)
├── HealthComponent.set_player(player)
└── HealthComponent.set_stat_sheet(stat_sheet)

Phase 3: Initialization
├── StatSheet.initialize()
├── HealthComponent.initialize()
└── Player.finalize_setup()
```

## Implementation Plan

### Step 1: Create PlayerBuilder Factory (30 minutes)
```gdscript
# Create new file: scripts/factories/PlayerBuilder.gd
class_name PlayerBuilder
extends RefCounted

# Factory for creating properly initialized Player instances
# Eliminates circular dependencies through controlled initialization phases

static func create_player() -> Player:
    var player = Player.new()
    var stat_sheet = PlayerStatSheet.new()
    var health_component = HealthComponent.new()
    
    # Phase 1: Basic setup (no cross-references)
    player.name = "Player"
    player.add_to_group("players")
    
    # Phase 2: Dependency injection
    _inject_dependencies(player, stat_sheet, health_component)
    
    # Phase 3: Initialization in correct order
    _initialize_components(player, stat_sheet, health_component)
    
    return player

static func _inject_dependencies(player: Player, stat_sheet: PlayerStatSheet, health_component: HealthComponent):
    # Set up references without triggering initialization
    stat_sheet.set_owner_entity(player)  # New method - doesn't trigger setup
    health_component.set_owner_entity(player)  # New method - doesn't trigger setup
    health_component.set_stat_sheet(stat_sheet)  # New method - doesn't trigger setup
    
    # Inject into player
    player._set_stat_sheet(stat_sheet)  # New private method
    player._set_health_component(health_component)  # New private method

static func _initialize_components(player: Player, stat_sheet: PlayerStatSheet, health_component: HealthComponent):
    # Initialize in dependency order
    
    # 1. StatSheet first (no dependencies)
    stat_sheet.initialize()
    
    # 2. HealthComponent second (depends on StatSheet)
    health_component.initialize()
    
    # 3. Player last (depends on both)
    player.finalize_initialization()
```

### Step 2: Modify PlayerStatSheet (30 minutes)
```gdscript
# PlayerStatSheet.gd modifications
class_name PlayerStatSheet
extends StatSheet

var owner_entity: Node
var _is_initialized: bool = false

func _init():
    # NO parameters, NO dependencies
    # Just create the basic stat structure
    super._init(null, "Player")

func set_owner_entity(entity: Node):
    """Set owner entity without triggering initialization"""
    owner_entity = entity
    # Don't trigger setup yet - wait for explicit initialize() call

func initialize():
    """Initialize stat sheet after all dependencies are set"""
    if _is_initialized:
        return
    
    if not owner_entity:
        push_error("PlayerStatSheet: Cannot initialize without owner entity")
        return
    
    # Now safe to set up stats
    setup_player_stats()
    _is_initialized = true
    
    print("🧙 PlayerStatSheet initialized for: ", owner_entity.name)

func setup_player_stats():
    # Existing implementation - now safe because owner_entity is guaranteed to exist
    setup_base_attributes()
    setup_direct_computed_stats()  # From optimization plan
    setup_combat_stats()
    setup_utility_stats()
    
    validate_stat_sheet()

# Remove the current _init(player_entity) constructor
# Replace with parameterless constructor + explicit initialize()
```

### Step 3: Modify HealthComponent (30 minutes)
```gdscript
# HealthComponent.gd modifications
class_name HealthComponent
extends Node

var owner_entity: Node
var stat_sheet: PlayerStatSheet
var _is_initialized: bool = false

func _ready():
    # NO automatic setup - wait for explicit initialization
    name = "HealthComponent"

func set_owner_entity(entity: Node):
    """Set owner entity without triggering initialization"""
    owner_entity = entity

func set_stat_sheet(sheet: PlayerStatSheet):
    """Set stat sheet reference without triggering initialization"""
    stat_sheet = sheet

func initialize():
    """Initialize component after all dependencies are set"""
    if _is_initialized:
        return
    
    if not owner_entity:
        push_error("HealthComponent: Cannot initialize without owner entity")
        return
    
    if not stat_sheet:
        push_error("HealthComponent: Cannot initialize without stat sheet")
        return
    
    # Now safe to set up health component
    _setup_from_dependencies()
    _is_initialized = true
    
    print("✅ HealthComponent initialized for: ", owner_entity.name)

func _setup_from_dependencies():
    # Setup regeneration timers
    _setup_regeneration_timers()
    
    # Connect to stat changes
    _connect_to_stats()
    
    # Initialize health/mana from stats
    on_stats_changed()

# Remove the current setup(entity) method that causes circular calls
# Replace with explicit initialize() after dependency injection
```

### Step 4: Modify Player Class (30 minutes)
```gdscript
# Player.gd modifications
class_name Player
extends CharacterBody2D

var stat_sheet: PlayerStatSheet
var health_component: HealthComponent
var _is_initialized: bool = false

func _ready():
    # NO component creation here - handled by PlayerBuilder
    # Just basic node setup
    add_to_group("players")
    name = "Player"

func _set_stat_sheet(sheet: PlayerStatSheet):
    """Private method for PlayerBuilder to inject stat sheet"""
    stat_sheet = sheet

func _set_health_component(component: HealthComponent):
    """Private method for PlayerBuilder to inject health component"""
    health_component = component
    add_child(health_component)  # Add to scene tree

func finalize_initialization():
    """Complete player setup after all dependencies are initialized"""
    if _is_initialized:
        return
    
    if not stat_sheet:
        push_error("Player: Cannot finalize without stat sheet")
        return
    
    if not health_component:
        push_error("Player: Cannot finalize without health component")
        return
    
    # Now safe to complete player setup
    _setup_from_dependencies()
    _is_initialized = true
    
    print("🎮 Player initialization complete")

func _setup_from_dependencies():
    # Update movement speed from stats
    if stat_sheet:
        speed = stat_sheet.get_stat_value("movement_speed")
        base_speed = speed
    
    # Setup other components that depend on stat sheet
    _setup_remaining_components()

func _setup_remaining_components():
    # Setup movement component if available
    if movement_component and movement_component.has_method("setup"):
        movement_component.setup(self)
    
    # Setup spell component
    if spell_component and spell_component.has_method("setup"):
        spell_component.setup(self)
    
    # Any other component setup that needs stat_sheet

# Remove the current _ready() component creation logic
# Remove circular setup calls
```

### Step 5: Update Scene Creation (30 minutes)
```gdscript
# Anywhere Player is instantiated, replace:
# var player = Player.new()

# With:
# var player = PlayerBuilder.create_player()

# This includes:
# - Main.gd scene loading
# - Save/load system player creation
# - Any test or debug player spawning
```

## Testing Strategy

### Unit Tests
```gdscript
# test_player_initialization.gd
func test_player_builder():
    var player = PlayerBuilder.create_player()
    
    # Verify all components exist
    assert_not_null(player.stat_sheet)
    assert_not_null(player.health_component)
    
    # Verify initialization completed
    assert_true(player.stat_sheet._is_initialized)
    assert_true(player.health_component._is_initialized)
    
    # Verify dependencies are correctly set
    assert_eq(player.stat_sheet.owner_entity, player)
    assert_eq(player.health_component.owner_entity, player)
    assert_eq(player.health_component.stat_sheet, player.stat_sheet)

func test_initialization_order():
    # Test that components can't be used before initialization
    var stat_sheet = PlayerStatSheet.new()
    assert_false(stat_sheet._is_initialized)
    
    # Should not work before owner is set
    var result = stat_sheet.get_stat_value("max_health")
    assert_eq(result, 0.0)  # Default/safe value
    
    # After proper setup should work
    var player = PlayerBuilder.create_player()
    assert_gt(player.stat_sheet.get_stat_value("max_health"), 0.0)
```

### Integration Tests
```gdscript
func test_save_load_compatibility():
    # Test that PlayerBuilder creates players compatible with save system
    var player = PlayerBuilder.create_player()
    
    # Should be able to save/load without issues
    var save_data = _extract_player_data(player)
    var loaded_player = PlayerBuilder.create_player()
    _apply_player_data(loaded_player, save_data)
    
    assert_eq(loaded_player.stat_sheet.get_stat_value("level"), player.stat_sheet.get_stat_value("level"))
```

## Migration Strategy

### Phase 1: Implement Factory Pattern
- Create PlayerBuilder class
- Modify component classes for dependency injection
- Keep existing initialization as fallback

### Phase 2: Update Creation Points
- Find all Player instantiation points
- Replace with PlayerBuilder.create_player()
- Test each replacement thoroughly

### Phase 3: Remove Legacy Code
- Remove circular initialization logic
- Clean up deprecated setup methods
- Validate no regression in functionality

## Success Criteria

### Code Quality
- ✅ **No circular dependencies**
- ✅ **Clear initialization order**
- ✅ **Proper dependency injection**
- ✅ **Consistent error handling**

### Functionality
- ✅ **Player initializes correctly**
- ✅ **All stats work as before**
- ✅ **Health/mana calculations accurate**
- ✅ **Save/load compatibility maintained**

### Maintainability
- ✅ **Easy to add new components**
- ✅ **Clear dependency relationships**
- ✅ **Debuggable initialization process**
- ✅ **Testable components**

## Risk Mitigation

### Regression Prevention
- Comprehensive testing of player creation
- Validation of all stat calculations
- Save/load compatibility testing

### Rollback Plan
- Keep original Player._ready() as fallback
- Feature flag to switch between old/new initialization
- Easy revert if issues arise

## Expected Benefits

### Immediate
- **Elimination of circular dependency issues**
- **More reliable player initialization**
- **Clearer error messages when setup fails**
- **Better testability of components**

### Long-term
- **Easier addition of new player components**
- **More predictable initialization behavior**
- **Better separation of concerns**
- **Foundation for dependency injection throughout codebase**

This refactor will solve the circular dependency issue that can cause subtle bugs and initialization race conditions, replacing it with a clean, predictable factory pattern that ensures all dependencies are properly initialized in the correct order.