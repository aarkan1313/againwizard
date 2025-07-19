# Health & Movement Components Analysis

## HealthComponent.gd

**Location**: `/godot/Game10/scripts/components/HealthComponent.gd`  
**Extends**: Node  
**Purpose**: Manages health/mana tracking, regeneration, and damage handling with dependency injection pattern

### Core Functionality

#### Health/Mana Tracking
```gdscript
# Current values only - max values read dynamically from StatSheet
var current_health: float = 100.0
var current_mana: float = 50.0

# Dynamic properties that always read from StatSheet
var max_health: float:
    get:
        if stat_sheet and stat_sheet.has_method("get_stat_value"):
            return stat_sheet.get_stat_value("max_health")
        return 100.0
```

#### Regeneration System
```gdscript
# Actual timer setup from HealthComponent.gd
func _setup_regeneration_timers():
    # Health regeneration timer
    health_regen_timer = Timer.new()
    health_regen_timer.wait_time = 1.0  # Regenerate every second
    health_regen_timer.timeout.connect(_on_health_regen_timeout)
    health_regen_timer.autostart = true
    add_child(health_regen_timer)
    
    # Mana regeneration timer  
    mana_regen_timer = Timer.new()
    mana_regen_timer.wait_time = 0.5  # Regenerate twice per second
    mana_regen_timer.timeout.connect(_on_mana_regen_timeout)
    mana_regen_timer.autostart = true
    add_child(mana_regen_timer)
```

#### Damage & Healing
```gdscript
func take_damage(amount: float) -> bool:
    if invincible or current_health <= 0:
        return false
    
    # Check for dodge chance (vitality bonus)
    if stat_sheet and owner_entity.is_in_group("players"):
        var dodge_chance = stat_sheet.get_stat_value("dodge_chance")
        if randf() < dodge_chance:
            return false  # Damage avoided
    
    current_health = max(0, current_health - amount)
    return true
```

#### Special Features
- **Invincibility Mode**: For debugging/power-ups
- **Infinite Mana**: Debug feature
- **Damage Flash**: Visual feedback on damage
- **Bounds Validation**: Prevents health/mana exceeding limits

### Dependency Integration

#### Stat Sheet Connection
```gdscript
func set_stat_sheet(sheet: PlayerStatSheet):
    stat_sheet = sheet

func _connect_to_stats():
    if stat_sheet.has_signal("attribute_increased"):
        stat_sheet.attribute_increased.connect(_on_stat_changed)
```

#### Event System Integration
```gdscript
# Route to GameEvents for UI updates - ONLY FOR PLAYERS
if GameEvents and owner_entity and owner_entity.is_in_group("players"):
    GameEvents.emit_player_health_changed(current_health, max_health)
    GameEvents.emit_player_mana_changed(current_mana, max_mana)
```

---

## MovementComponent.gd

**Location**: `/godot/Game10/scripts/components/MovementComponent.gd`  
**Extends**: Node  
**Purpose**: Handles player movement physics without interfering with Player.gd dodge coordination

### Core Functionality

#### Movement Physics
```gdscript
# Movement stats - all from stat system
var base_speed: float = 0.0
var acceleration: float = 0.0
var friction: float = 0.0

func _handle_movement(delta: float) -> void:
    var input_vector = InputHandler.get_movement_vector()
    
    if input_vector.length() > 0:
        input_vector = input_vector.normalized()
        var target_velocity = input_vector * base_speed
        player.velocity = player.velocity.move_toward(target_velocity, acceleration * delta * 100)
    else:
        player.velocity = player.velocity.move_toward(Vector2.ZERO, friction * delta * 100)
```

#### Dodge System
```gdscript
# Dodge system - all values from stats
var dodge_speed: float = 0.0
var dodge_duration: float = 0.0
var dodge_cooldown: float = 0.0
var is_dodging: bool = false

func can_dodge() -> bool:
    return dodge_cooldown_timer <= 0 and not is_dodging
```

#### Stat Integration (Actual Implementation)
```gdscript
func _initialize_from_stats():
    # Get movement stats from stat sheet
    base_speed = player_stat_sheet.get_stat_value("movement_speed")
    
    # Get dodge stats with fallbacks
    if player_stat_sheet.has_stat("dodge_speed"):
        dodge_speed = player_stat_sheet.get_stat_value("dodge_speed")
    else:
        dodge_speed = 600.0  # Fallback
    
    if player_stat_sheet.has_stat("dodge_duration"):
        dodge_duration = player_stat_sheet.get_stat_value("dodge_duration")
    else:
        dodge_duration = 0.4  # Fallback
    
    # Get physics stats with fallbacks
    if player_stat_sheet.has_stat("acceleration"):
        acceleration = player_stat_sheet.get_stat_value("acceleration")
    else:
        acceleration = 10.0  # Fallback
```

### Advanced Features

#### Screen Boundaries
- Prevents player from moving outside screen bounds
- Smooth clamping with velocity correction
- Dynamic screen size detection

#### Movement States
```gdscript
func get_movement_state() -> String:
    if player.has_method("get_is_teleporting") and player.get_is_teleporting():
        return "teleporting"
    elif is_moving():
        return "moving"
    else:
        return "idle"
```

#### Collision Coordination
- Coordinates with Player.gd to avoid dodge conflicts
- Let Player.gd handle dodge collision changes
- MovementComponent only tracks timers and provides info

### Performance Optimizations

#### Stat-Based Values
- All movement parameters read from PlayerStatSheet
- Real-time updates when stats change
- Fallback values for missing stats

#### Boundary Checks
```gdscript
# Safety check for invalid positions - increased bounds
var max_bound = 2500000.0  # 2.5 million units = 2500km
if player.global_position.y > max_bound:
    player.global_position = viewport_size / 2
    player.velocity = Vector2.ZERO
```

## Component Interaction Patterns

### Health ↔ Stats
- Health reads max values dynamically from stats
- Stats changes trigger health recalculation
- Level up fully restores health/mana

### Movement ↔ Stats  
- Movement speed calculated from dexterity stat
- Dodge parameters read from stat system
- Real-time updates on stat changes

### Both Components ↔ GameEvents
- Health changes routed to UI updates
- Movement events trigger position updates
- Player-specific events only for player entities

## Error Handling & Validation

### Health Component
- Bounds validation prevents invalid health/mana
- Emergency sync functions for stat mismatches
- Comprehensive debug information

### Movement Component
- Invalid position detection and correction
- Stat integration validation
- Fallback values for missing stats

## Debug & Monitoring

Both components provide extensive debug information:
```gdscript
func get_debug_info() -> Dictionary:
    return {
        "current_health": current_health,
        "max_health": max_health,
        "health_bounds_valid": current_health <= max_health,
        # ... more debug data
    }
```