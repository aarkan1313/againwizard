# Wave Progression System

## Overview

The FFS Wizard RPG implements a **kill-based wave progression system** that provides smooth difficulty scaling, strategic enemy composition management, and milestone-driven unlocks. The system abandons traditional time-based waves in favor of player-driven progression that rewards active engagement and provides predictable advancement opportunities.

## Core Wave Progression Architecture

### WaveManager.gd - Kill-Based Progression

**File Path**: `res://scripts/WaveManager.gd`  
**Purpose**: Manages wave advancement through kill count thresholds with dynamic enemy scaling

#### Kill-Based Thresholds

**Wave Advancement System**:
```gdscript
# Progressive kill requirements for wave advancement
var wave_kill_thresholds: Array[int] = [
    25,   # Wave 2 at 25 total kills
    50,   # Wave 3 at 50 total kills  
    100,  # Wave 4 at 100 total kills
    150,  # Wave 5 at 150 total kills
    200,  # Wave 6 at 200 total kills
    300,  # Wave 7 at 300 total kills
    400,  # Wave 8 at 400 total kills
    500,  # Wave 9 at 500 total kills
    750,  # Wave 10 at 750 total kills
    1000  # Wave 11 at 1000 total kills
]
```

**Progression Logic**:
```gdscript
func check_wave_progression():
    var total_kills = GameManager.total_enemies_killed
    
    for i in range(wave_kill_thresholds.size()):
        var threshold = wave_kill_thresholds[i]
        var target_wave = i + 2  # Wave 2, 3, 4, etc.
        
        if total_kills >= threshold and current_wave < target_wave:
            advance_to_wave(target_wave)
            break

func advance_to_wave(new_wave: int):
    previous_wave = current_wave
    current_wave = new_wave
    
    # Notify systems of wave change
    GameEvents.emit_wave_started(current_wave, get_wave_config())
    wave_started.emit(current_wave, get_wave_config())
    
    # Update enemy scaling for new wave
    notify_enemies_of_wave_change()
```

#### Benefits of Kill-Based Progression

**Player Agency**:
- Players control wave advancement through combat engagement
- No artificial time pressure or forced progression
- Allows for strategic preparation between waves

**Predictable Difficulty**:
- Clear milestone targets (25, 50, 100 kills, etc.)
- Consistent scaling regardless of play speed
- Players can gauge their progress toward next wave

**Flexible Pacing**:
- Fast players advance quickly through aggressive combat
- Cautious players can take time to prepare
- No punishment for careful or slow playstyles

### Enemy Scaling System

#### Progressive Stat Scaling

**Wave Multiplier Application**:
```gdscript
func apply_wave_scaling(enemy: Enemy, wave_number: int):
    # Health scaling: +20% per wave beyond wave 1
    var health_multiplier = 1.0 + (wave_number - 1) * 0.20
    
    # Damage scaling: +15% per wave beyond wave 1  
    var damage_multiplier = 1.0 + (wave_number - 1) * 0.15
    
    # Speed scaling: +8% per wave beyond wave 1
    var speed_multiplier = 1.0 + (wave_number - 1) * 0.08
    
    # Apply scaling to enemy stats
    enemy.base_health *= health_multiplier
    enemy.base_damage *= damage_multiplier
    enemy.base_speed *= speed_multiplier
    
    # Recalculate derived stats
    enemy.current_health = enemy.base_health
    enemy.movement_component.update_speed(enemy.base_speed)
```

**Scaling Progression Examples**:
| Wave | Health Mult | Damage Mult | Speed Mult | Total Difficulty |
|------|-------------|-------------|------------|------------------|
| 1    | 1.0x        | 1.0x        | 1.0x       | Baseline         |
| 3    | 1.4x        | 1.3x        | 1.16x      | +58% harder      |
| 5    | 1.8x        | 1.6x        | 1.32x      | +118% harder     |
| 7    | 2.2x        | 1.9x        | 1.48x      | +186% harder     |
| 10   | 2.8x        | 2.35x       | 1.72x      | +310% harder     |

#### Scaling Benefits

**Gradual Difficulty Ramp**:
- 20% health increase maintains combat duration feel
- 15% damage increase keeps threats meaningful
- 8% speed increase adds urgency without overwhelming

**Multiplicative Scaling**:
- All three stats scale together for comprehensive difficulty
- No single stat becomes overwhelming
- Maintains enemy identity while increasing challenge

### Enemy Type Unlocks

#### Progressive Enemy Introduction

**Wave-Based Unlocks**:
```gdscript
func get_available_enemy_types(wave_number: int) -> Array[String]:
    var available_types = ["goblin", "skeleton", "orc"]  # Base types always available
    
    match wave_number:
        3, 4, 5, 6, 7, 8, 9, 10, 11:
            available_types.append("dark_wizard")  # Unlocked at wave 3
        5, 6, 7, 8, 9, 10, 11:
            available_types.append("stone_golem")  # Unlocked at wave 5
        # Future waves could unlock additional enemy types
    
    return available_types
```

**Unlock Strategy**:
- **Wave 3**: Dark Wizard (magical ranged enemy)
- **Wave 5**: Stone Golem (heavy tank enemy)
- **Future Expansions**: Additional enemy types at higher waves

**Benefits**:
- **Progressive Complexity**: New mechanics introduced gradually
- **Strategic Depth**: Each new enemy type requires different tactics
- **Sustained Interest**: Regular unlocks maintain engagement

## Enemy Spawning Architecture

### EnemySpawner.gd - Dynamic Composition Management

**File Path**: `res://scripts/EnemySpawner.gd`  
**Purpose**: Manages dynamic enemy spawning with weighted distribution and wave-appropriate composition

#### Weighted Distribution System

**Enemy Spawn Configuration**:
```gdscript
var enemy_spawn_config: Dictionary = {
    "goblin": {
        "weight": 35,
        "max_percentage": 45,
        "base_spawn_rate": 2.0
    },
    "skeleton": {
        "weight": 30, 
        "max_percentage": 35,
        "base_spawn_rate": 1.8
    },
    "orc": {
        "weight": 20,
        "max_percentage": 25,
        "base_spawn_rate": 1.5
    },
    "dark_wizard": {
        "weight": 10,
        "max_percentage": 15,
        "base_spawn_rate": 1.0,
        "unlock_wave": 3
    },
    "stone_golem": {
        "weight": 5,
        "max_percentage": 7,
        "base_spawn_rate": 0.8,
        "unlock_wave": 5
    }
}
```

#### Spawn Rate Scaling

**Wave-Based Spawn Rate Increase**:
```gdscript
func calculate_wave_spawn_rate(base_rate: float, wave_number: int) -> float:
    # Spawn rate increases by 12% per wave
    var wave_multiplier = 1.0 + (wave_number - 1) * 0.12
    
    # Cap maximum spawn rate to prevent overwhelming
    var max_multiplier = 3.0  # Maximum 3x spawn rate
    wave_multiplier = min(wave_multiplier, max_multiplier)
    
    return base_rate * wave_multiplier
```

**Spawn Rate Progression**:
| Wave | Spawn Rate Multiplier | Effective Increase |
|------|----------------------|-------------------|
| 1    | 1.0x                 | Baseline          |
| 3    | 1.24x                | +24% more enemies |
| 5    | 1.48x                | +48% more enemies |
| 7    | 1.72x                | +72% more enemies |
| 10   | 2.08x                | +108% more enemies|

#### Dynamic Scene Loading

**Enemy Type Instantiation**:
```gdscript
func spawn_enemy(enemy_type: String) -> Enemy:
    # Dynamic scene loading per enemy type
    var scene_path = "res://scenes/enemies/" + enemy_type.capitalize() + ".tscn"
    
    if not ResourceLoader.exists(scene_path):
        print("Warning: Enemy scene not found: ", scene_path)
        scene_path = "res://scenes/Enemy.tscn"  # Fallback to base enemy
    
    var enemy_scene = load(scene_path)
    var enemy = enemy_scene.instantiate()
    
    # Apply wave scaling
    WaveManager.apply_wave_scaling(enemy, current_wave)
    
    # Set spawn position
    enemy.global_position = get_random_spawn_position()
    
    # Add to game world
    get_tree().current_scene.add_child(enemy)
    active_enemies.append(enemy)
    
    return enemy
```

#### Composition Balance

**Percentage Cap Enforcement**:
```gdscript
func select_enemy_type_for_spawn() -> String:
    var available_types = WaveManager.get_available_enemy_types(current_wave)
    var current_composition = calculate_current_composition()
    
    # Filter types that haven't exceeded their percentage cap
    var valid_types = []
    for enemy_type in available_types:
        var config = enemy_spawn_config[enemy_type]
        var current_percentage = current_composition.get(enemy_type, 0.0)
        
        if current_percentage < config.max_percentage:
            valid_types.append(enemy_type)
    
    # Weighted selection from valid types
    return select_weighted_enemy_type(valid_types)

func calculate_current_composition() -> Dictionary:
    var composition = {}
    var total_enemies = active_enemies.size()
    
    if total_enemies == 0:
        return composition
    
    # Count each enemy type
    for enemy in active_enemies:
        var enemy_type = enemy.enemy_type
        composition[enemy_type] = composition.get(enemy_type, 0) + 1
    
    # Convert to percentages
    for enemy_type in composition:
        composition[enemy_type] = float(composition[enemy_type]) / total_enemies
    
    return composition
```

### Chunk-Aware Spawning

#### Integration with World System

**Spatial Spawn Distribution**:
```gdscript
func get_chunk_aware_spawn_position() -> Vector2:
    if UnifiedWorldManager:
        # Get active chunks around player
        var active_chunks = UnifiedWorldManager.get_active_chunks()
        var player_chunk = UnifiedWorldManager.get_chunk_at_position(player.global_position)
        
        # Prefer spawning in chunks adjacent to player chunk
        var spawn_chunk = select_spawn_chunk(active_chunks, player_chunk)
        return get_random_position_in_chunk(spawn_chunk)
    else:
        # Fallback to circular spawning around player
        return get_circular_spawn_position()

func select_spawn_chunk(active_chunks: Array, player_chunk: Vector2) -> Vector2:
    # Get chunks within 2-3 chunk radius of player
    var valid_chunks = []
    
    for chunk in active_chunks:
        var distance = chunk.distance_to(player_chunk)
        if distance >= 2.0 and distance <= 3.0:  # 2-3 chunks away
            valid_chunks.append(chunk)
    
    if valid_chunks.is_empty():
        return player_chunk  # Fallback to player chunk
    
    return valid_chunks[randi() % valid_chunks.size()]
```

## Milestone Integration

### Character Progression Milestones

**Kill Milestone System** (Integration with Part 2):
```gdscript
func check_kill_milestones(total_kills: int):
    var milestones = [25, 50, 100, 200, 500, 1000]
    
    for milestone in milestones:
        if total_kills >= milestone and not milestone in achieved_milestones:
            achieved_milestones.append(milestone)
            award_milestone_bonus(milestone)
            
            # Broadcast milestone achievement
            GameEvents.emit_milestone_reached(milestone)

func award_milestone_bonus(milestone: int):
    match milestone:
        25:   # First Blood
            player.stat_sheet.add_permanent_stat_bonus("vitality", 2)
            show_milestone_notification("First Blood", "+2 Vitality")
        50:   # Apprentice Destroyer  
            player.stat_sheet.add_permanent_stat_bonus("intelligence", 2)
            show_milestone_notification("Apprentice Destroyer", "+2 Intelligence")
        100:  # Seasoned Warrior
            player.stat_sheet.add_permanent_stat_bonus("wisdom", 2)
            show_milestone_notification("Seasoned Warrior", "+2 Wisdom")
        200:  # Elite Slayer
            player.stat_sheet.add_permanent_stat_bonus("dexterity", 2)
            show_milestone_notification("Elite Slayer", "+2 Dexterity")
        500:  # Master of Destruction
            player.stat_sheet.add_permanent_stat_bonus("all_stats", 1)
            show_milestone_notification("Master of Destruction", "+1 All Stats")
        1000: # Legendary Annihilator
            player.stat_sheet.add_permanent_stat_bonus("all_stats", 2)
            unlock_special_ability("legendary_power")
            show_milestone_notification("Legendary Annihilator", "+2 All Stats + Special Ability")
```

### Wave Milestone Rewards

**Wave Achievement System**:
```gdscript
func check_wave_milestones(wave_number: int):
    var wave_milestones = [5, 10, 15, 20, 25]
    
    for milestone in wave_milestones:
        if wave_number >= milestone and not milestone in achieved_wave_milestones:
            achieved_wave_milestones.append(milestone)
            award_wave_milestone_bonus(milestone)

func award_wave_milestone_bonus(wave: int):
    match wave:
        5:  # Survivor
            apply_temporary_stat_bonus("all_stats", 1, 300.0)  # 5 minutes
            show_milestone_notification("Survivor", "Temporary +1 All Stats")
        10: # Veteran
            apply_temporary_stat_bonus("max_health", 50, 600.0)  # 10 minutes
            show_milestone_notification("Veteran", "Temporary +50 Max Health")
        15: # Elite Survivor
            apply_temporary_stat_bonus("spell_damage", 0.25, 600.0)  # 25% boost
            show_milestone_notification("Elite Survivor", "Temporary +25% Spell Damage")
        20: # Master Survivor
            apply_temporary_stat_bonus("all_stats", 2, 900.0)  # 15 minutes
            show_milestone_notification("Master Survivor", "Temporary +2 All Stats")
        25: # Legendary Survivor
            apply_permanent_stat_bonus("all_stats", 3)
            unlock_legendary_title()
            show_milestone_notification("Legendary Survivor", "Permanent +3 All Stats + Title")
```

## Performance Optimization

### Efficient Enemy Tracking

**Active Enemy Management**:
```gdscript
var active_enemies: Array[Enemy] = []
var enemy_cleanup_timer: float = 0.0
const CLEANUP_INTERVAL: float = 5.0  # Clean up every 5 seconds

func _process(delta):
    enemy_cleanup_timer -= delta
    if enemy_cleanup_timer <= 0:
        cleanup_inactive_enemies()
        enemy_cleanup_timer = CLEANUP_INTERVAL

func cleanup_inactive_enemies():
    # Remove dead or invalid enemies from tracking
    for i in range(active_enemies.size() - 1, -1, -1):
        var enemy = active_enemies[i]
        if not is_instance_valid(enemy) or enemy.is_dead:
            active_enemies.remove_at(i)
```

### Spawn Rate Limiting

**Performance-Conscious Spawning**:
```gdscript
var max_concurrent_enemies: int = 50
var spawn_cooldown: float = 0.0
const MIN_SPAWN_INTERVAL: float = 0.1  # 100ms between spawns

func attempt_enemy_spawn():
    if spawn_cooldown > 0:
        return false
    
    if active_enemies.size() >= max_concurrent_enemies:
        return false
    
    # Spawn enemy and start cooldown
    spawn_random_enemy()
    spawn_cooldown = MIN_SPAWN_INTERVAL
    
    return true

func _process(delta):
    if spawn_cooldown > 0:
        spawn_cooldown -= delta
```

### Wave Transition Optimization

**Smooth Wave Changes**:
```gdscript
func transition_to_wave(new_wave: int):
    # Batch update all existing enemies
    var enemies_to_update = active_enemies.duplicate()
    
    # Use call_deferred to spread updates across frames
    for enemy in enemies_to_update:
        if is_instance_valid(enemy):
            call_deferred("apply_wave_scaling_deferred", enemy, new_wave)

func apply_wave_scaling_deferred(enemy: Enemy, wave_number: int):
    if is_instance_valid(enemy):
        apply_wave_scaling(enemy, wave_number)
```

## Integration with Game Systems

### GameEvents Integration

**Wave Event Broadcasting**:
```gdscript
func advance_to_wave(new_wave: int):
    # Local wave manager state
    current_wave = new_wave
    
    # Broadcast to global event system
    GameEvents.emit_wave_started(new_wave, get_wave_configuration())
    
    # Update GameManager state
    GameManager.set_current_wave(new_wave)
    
    # Trigger UI updates
    GameplayController.update_wave_display(new_wave)
```

### Save/Load Integration

**Wave Progress Persistence**:
```gdscript
func serialize_wave_state() -> Dictionary:
    return {
        "current_wave": current_wave,
        "total_kills": GameManager.total_enemies_killed,
        "achieved_milestones": achieved_milestones,
        "achieved_wave_milestones": achieved_wave_milestones,
        "enemy_type_unlocks": get_unlocked_enemy_types()
    }

func deserialize_wave_state(data: Dictionary):
    current_wave = data.get("current_wave", 1)
    achieved_milestones = data.get("achieved_milestones", [])
    achieved_wave_milestones = data.get("achieved_wave_milestones", [])
    
    # Restore enemy type availability
    var unlocked_types = data.get("enemy_type_unlocks", [])
    update_available_enemy_types(unlocked_types)
```

The wave progression system provides engaging, player-driven difficulty scaling that maintains long-term interest through milestone rewards, enemy variety unlocks, and predictable progression paths. The kill-based approach ensures players feel agency in their advancement while the sophisticated scaling mechanics maintain appropriate challenge levels throughout extended play sessions.