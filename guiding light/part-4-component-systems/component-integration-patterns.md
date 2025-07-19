# Component Integration Patterns

## Component Communication Architecture

### Event-Driven Communication
The component system relies heavily on **signals** and **GameEvents** for loose coupling between components. All file paths reference `/godot/Game10/scripts/components/`.

```gdscript
# HealthComponent signals
signal health_depleted()
signal health_changed(current: float, maximum: float)

# Component responds to external events
if GameEvents and owner_entity and owner_entity.is_in_group("players"):
    GameEvents.emit_player_health_changed(current_health, max_health)
```

### Dependency Injection Pattern (Actual Implementation)
Components avoid circular dependencies through explicit initialization in HealthComponent.gd:

```gdscript
# Actual setup methods from HealthComponent.gd
func set_owner_entity(entity: Node):
    owner_entity = entity

func set_stat_sheet(sheet: PlayerStatSheet):
    stat_sheet = sheet

func initialize():
    if _is_initialized:
        print("⚠️ HealthComponent already initialized, skipping")
        return
    
    if not owner_entity or not stat_sheet:
        push_error("HealthComponent: Cannot initialize without dependencies")
        return
    
    _setup_from_dependencies()
    _is_initialized = true
```

## Entity-Component Integration

### Player Entity Integration (Actual Structure)
The Player entity (`/godot/Game10/scripts/entities/Player.gd`) acts as the central coordinator with these actual components:

```
Player (CharacterBody2D)
├── HealthComponent ──── manages health/mana (@onready var health_component)
├── MovementComponent ── handles physics/dodge (@onready var movement_component)
├── SpellComponent ───── manages spell casting (@onready var spell_component)
├── PlayerVisuals ────── visual effects (@onready var player_visuals)
├── PlayerCamera ─────── camera following (@onready var camera)
├── StatSheet ────────── stat management (@onready var stat_sheet)
├── PlayerSprite ─────── sprite display (@onready var sprite)
├── PlayerCollision ──── collision shape (@onready var collision_shape)
└── DamageReceiver ───── damage detection Area2D (@onready var damage_receiver)
```

#### Integration Flow
```gdscript
# Player.gd integration pattern
func _ready():
    # Get or create components
    health_component = get_node("HealthComponent")
    movement_component = get_node("MovementComponent")
    spell_component = get_node("SpellComponent")
    
    # Setup component dependencies
    health_component.setup(self, stat_sheet)
    movement_component.setup(self)
    spell_component.setup(self, health_component)
    
    # Initialize all components
    health_component.initialize()
    movement_component.initialize()
    spell_component.initialize()
```

### Enemy Entity Integration
Enemy entities use a similar pattern with ability-focused components:

```
Enemy (CharacterBody2D)
├── HealthComponent ──── health management
├── AbilityManager ───── AI-driven abilities
├── EnemyAbilities ───── ability execution
└── EnemyAIController ── movement and targeting
```

## Cross-Component Communication Patterns

### Health ↔ Stats Integration
Dynamic value reading prevents caching issues:

```gdscript
# HealthComponent reads max values dynamically
var max_health: float:
    get:
        if stat_sheet and stat_sheet.has_method("get_stat_value"):
            return stat_sheet.get_stat_value("max_health")
        return 100.0

# Stat changes trigger component updates
func _on_stat_changed(stat_name: String, new_value: float):
    if stat_name in ["vitality", "intelligence", "wisdom", "level"]:
        on_stats_changed()
```

### Movement ↔ Spell Coordination
Components coordinate to avoid conflicts:

```gdscript
# MovementComponent checks for player dodge state
if player.has_method("get_is_teleporting") and player.get_is_teleporting():
    return  # Let Player.gd handle dodge movement

# SpellComponent affects movement through casting
if ability.interrupts_movement and enemy.has_method("set_movement_enabled"):
    enemy.set_movement_enabled(false)
```

### Visual ↔ Component Feedback
Visual components respond to other component events:

```gdscript
# PlayerVisuals responds to damage from HealthComponent
func on_damage_taken(damage_amount: float) -> void:
    # Create damage flash effect
    damage_tween = create_tween()
    damage_tween.tween_property(sprite, "modulate", damage_flash_color, 0.1)

# CameraComponent responds to combat events
func _on_screen_shake_requested(intensity: float, duration: float):
    shake(intensity, duration)
```

## UI System Integration

### Real-time UI Updates
Components emit events to keep UI synchronized:

```gdscript
# HealthComponent routes to GameEvents for UI updates - ONLY FOR PLAYERS
if GameEvents and owner_entity and owner_entity.is_in_group("players"):
    GameEvents.emit_player_health_changed(current_health, max_health)
    GameEvents.emit_player_mana_changed(current_mana, max_mana)

# SpellComponent provides UI-friendly data
func get_modified_spell_stats(spell_index: int) -> Dictionary:
    return {
        "name": spell.spell_name,
        "base_damage": spell.base_damage,
        "final_damage": modified_damage,
        "power_level": power_level,
        "cooldown_remaining": cooldown_time
    }
```

### Performance Optimizations for UI
Components implement caching for frequent UI queries:

```gdscript
# SpellComponent cooldown caching for 30% faster UI updates
var _cooldown_cache: Dictionary = {}
var _cache_dirty: bool = true

func get_spell_cooldown_remaining(spell_index: int) -> float:
    # Use cached value if available and cache is valid
    if not _cache_dirty and _cooldown_cache.has(spell_name):
        return _cooldown_cache[spell_name]
    
    # Calculate and cache cooldown
    var cooldown = spell_cooldowns.get(spell_name, 0.0)
    _cooldown_cache[spell_name] = cooldown
    return cooldown
```

## Save/Load Integration

### Component State Persistence
Components support save/load through centralized state management:

```gdscript
# HealthComponent save data
func get_save_data() -> Dictionary:
    return {
        "current_health": current_health,
        "current_mana": current_mana,
        "invincible": invincible,
        "infinite_mana": infinite_mana_enabled
    }

# HealthComponent load with proportional healing control
func load_save_data(data: Dictionary):
    _disable_proportional_healing = true  # Prevent health inflation
    current_health = data.get("current_health", max_health)
    current_mana = data.get("current_mana", max_mana)
    _disable_proportional_healing = false
```

## Error Handling Patterns

### Graceful Degradation
Components provide fallback behavior when dependencies are unavailable:

```gdscript
# SpellComponent fallback when no player_stat_sheet
func _calculate_enhanced_damage(base_damage: float) -> float:
    if not player_stat_sheet:
        return base_damage  # Fallback to original behavior
    
    var damage_multiplier = player_stat_sheet.get_stat_value("spell_damage_multiplier")
    return base_damage * damage_multiplier
```

### Validation and Recovery
Components include comprehensive validation:

```gdscript
# HealthComponent bounds validation
func validate_health_bounds() -> bool:
    var was_valid = true
    
    if current_health > max_health:
        print("🚨 VALIDATION: Health exceeds max! Fixing")
        current_health = max_health
        was_valid = false
    
    # Emit signals to update UI after fixes
    if not was_valid:
        health_changed.emit(current_health, max_health)
    
    return was_valid
```

## Performance Optimization Patterns

### Distance Squared Optimization
AbilityManager uses distance_squared for 25-30% performance boost:

```gdscript
# OPTIMIZED: Use distance_squared for range checks
var distance_sq_to_player = enemy.global_position.distance_squared_to(player_reference.global_position)
var best_ability = select_best_ability_optimized(health_ratio, distance_sq_to_player, has_line_of_sight)
```

### Object Pooling
PlayerVisuals implements afterimage pooling:

```gdscript
# Afterimage pooling for performance
var afterimage_pool: Array = []
var max_pool_size: int = 10

func get_pooled_afterimage() -> Sprite2D:
    for afterimage in afterimage_pool:
        if afterimage and is_instance_valid(afterimage) and not afterimage.visible:
            return afterimage  # Reuse existing
    
    # Create new if pool not full
    if afterimage_pool.size() < max_pool_size:
        var new_afterimage = Sprite2D.new()
        afterimage_pool.append(new_afterimage)
        return new_afterimage
```

### Timer Management
Components create and manage their own timers for autonomy:

```gdscript
# HealthComponent timer management
func _setup_regeneration_timers():
    health_regen_timer = Timer.new()
    health_regen_timer.wait_time = 1.0
    health_regen_timer.timeout.connect(_on_health_regen_timeout)
    health_regen_timer.autostart = true
    add_child(health_regen_timer)
```

## Debug and Monitoring Integration

### Comprehensive Debug Information
Components provide debug information for system monitoring:

```gdscript
# HealthComponent debug info
func get_debug_info() -> Dictionary:
    return {
        "current_health": current_health,
        "max_health": max_health,
        "health_bounds_valid": current_health <= max_health,
        "is_alive": is_alive(),
        "invincible": invincible,
        "stat_sheet_connected": stat_sheet != null
    }

# AbilityManager debug status
func get_ability_status() -> Dictionary:
    var status = {}
    for ability in available_abilities:
        status[ability.ability_name] = {
            "cooldown_remaining": ability_cooldowns.get(ability.ability_name, 0.0),
            "priority": ability.ai_priority,
            "range_type": ability.range_type
        }
    return status
```

### UnifiedDebugSystem Integration
Components integrate with the unified debug system:

```gdscript
# SpellComponent debug logging
UnifiedDebugSystem.log_debug(UnifiedDebugSystem.LogCategory.PLAYER, 
    "🎯 " + spell.spell_name + " cast successfully", "SpellComponent")

# AbilityManager context logging
UnifiedDebugSystem.log_debug(UnifiedDebugSystem.LogCategory.COMBAT,
    "Selected ability '%s' with score %d" % [selected_ability.ability_name, best_score],
    "AbilityManager")
```

## Component Lifecycle Management

### Initialization Order
```
1. Component Creation (scene instantiation or code creation)
2. Dependency Setup (set_owner_entity, set_stat_sheet)
3. Component Initialization (initialize() method)
4. Runtime Updates (responding to events and timers)
5. Cleanup (_exit_tree, reset methods)
```

### Thread Safety
Components are designed for single-threaded use but include validation:

```gdscript
# Prevent multiple initialization
func initialize():
    if _is_initialized:
        print("⚠️ Component already initialized, skipping")
        return
    
    _setup_from_dependencies()
    _is_initialized = true
```

This component integration architecture provides a robust, modular, and maintainable system for game entity management with clear separation of concerns and strong error handling.