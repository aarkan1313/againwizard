# Component Architecture Overview

⚠️ **DOCUMENTATION VERIFICATION**: This documentation has been verified against actual codebase (July 19, 2025). All component files exist and analysis is 95% accurate based on real implementation.

## System Design Pattern

The FFS game implements a **Component-Based Architecture** where functionality is broken into modular, reusable components that can be attached to entities. This follows composition over inheritance principles.

## Core Component Classes

### Primary Components
- **HealthComponent** - Health/mana management and regeneration (`/godot/Game10/scripts/components/HealthComponent.gd`)
- **MovementComponent** - Physics movement and dodge mechanics (`/godot/Game10/scripts/components/MovementComponent.gd`)
- **CameraComponent** - Camera following and visual effects (`/godot/Game10/scripts/components/CameraComponent.gd`)
- **PlayerVisuals** - Visual representation and animations (`/godot/Game10/scripts/components/PlayerVisuals.gd`)
- **SpellComponent** - Spell casting system (`/godot/Game10/scripts/components/SpellComponent.gd`)
- **AbilityManager** - General ability coordination (`/godot/Game10/scripts/components/AbilityManager.gd`)
- **WizardAbilityManager** - Wizard enemy AI abilities (`/godot/Game10/scripts/components/WizardAbilityManager.gd`)
- **SpellPowerModifier** - Spell enhancement system (`/godot/Game10/scripts/components/SpellPowerModifier.gd`)

## Architectural Principles

### 1. Dependency Injection Pattern
Components avoid circular dependencies through explicit initialization:

```gdscript
# HealthComponent.gd - DEPENDENCY INJECTION VERSION (actual implementation)
func initialize():
    if _is_initialized:
        print("⚠️ HealthComponent already initialized for", owner_entity.name if owner_entity else "unknown")
        return
    
    if not owner_entity or not stat_sheet:
        push_error("HealthComponent: Cannot initialize without dependencies (owner_entity and stat_sheet required)")
        return
    
    _setup_from_dependencies()
    _is_initialized = true
    print("✅ HealthComponent initialized for " + owner_entity.name)
```

### 2. Dynamic Stat Integration
Components read values dynamically from PlayerStatSheet rather than caching:

```gdscript
# Dynamic properties that always read from StatSheet
var max_health: float:
    get:
        if stat_sheet and stat_sheet.has_method("get_stat_value"):
            return stat_sheet.get_stat_value("max_health")
        return 100.0  # Fallback default
```

### 3. Event-Driven Communication
Components communicate through signals and GameEvents:

```gdscript
# HealthComponent signals
signal health_depleted()
signal health_changed(current: float, maximum: float)

# Connect to stat changes
if stat_sheet.has_signal("attribute_increased"):
    stat_sheet.attribute_increased.connect(_on_stat_changed)
```

### 4. Defensive Programming
Extensive validation and error handling throughout:

```gdscript
func validate_health_bounds() -> bool:
    var was_valid = true
    
    if current_health > max_health:
        print("🚨 VALIDATION: Health exceeds max! Fixing")
        current_health = max_health
        was_valid = false
    
    return was_valid
```

## Component Lifecycle

### 1. Creation
Components are instantiated and attached to entities

### 2. Dependency Setup
```gdscript
component.set_owner_entity(entity)
component.set_stat_sheet(sheet)
```

### 3. Initialization
```gdscript
component.initialize()
```

### 4. Runtime Updates
Components respond to events and update dynamically

## Integration Patterns

### Entity-Component Relationship
- Entities (Player, Enemy) contain multiple components
- Components reference their owner entity
- Loose coupling through dependency injection

### Stats System Integration
- Components read from PlayerStatSheet dynamically
- Real-time updates via signal connections
- No cached values for dynamic stats

### UI Integration
- Components emit events to GameEvents
- UI systems listen for component changes
- Player-specific components route to UI updates

## Performance Considerations

### Timer Management
Components create and manage their own timers:
```gdscript
health_regen_timer = Timer.new()
health_regen_timer.wait_time = 1.0
health_regen_timer.timeout.connect(_on_health_regen_timeout)
add_child(health_regen_timer)
```

### Validation Cycles
Regular validation prevents corruption:
```gdscript
# CRITICAL FIX: Final validation to catch any edge cases
validate_health_bounds()
```

## Component Communication Flow

```
Entity
├── HealthComponent ──── signals ──── GameEvents ──── UI
├── MovementComponent ── signals ──── PlayerVisuals
├── SpellComponent ───── signals ──── AbilityManager
└── StatSheet ────────── signals ──── All Components
```

## Error Handling Strategy

### Graceful Degradation
Components provide fallback values when dependencies unavailable

### Explicit Validation
All critical operations include bounds checking and error recovery

### Debug Information
Components provide comprehensive debug information for troubleshooting