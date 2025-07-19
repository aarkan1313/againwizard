# Ability & Spell Components Analysis

## SpellComponent.gd

**Location**: `/godot/Game10/scripts/components/SpellComponent.gd`  
**Extends**: Node  
**Purpose**: Handles spell casting logic for player entities with dynamic power adjustment

### Core Spell System

#### Spell Management
```gdscript
var equipped_spells: Array[SpellData] = []
var spell_cooldowns: Dictionary = {}

# OPTIMIZATION: Spell cooldown caching for 30% faster UI updates
var _cooldown_cache: Dictionary = {}
var _cache_dirty: bool = true
```

#### Default Spell Catalog (Actual Implementation)
The component initializes with 10 predefined spells from `_initialize_default_spells()`:
1. **Fireball** - 35 damage, 15 mana, 1.5s cooldown, 280 speed
2. **Magic Missile** - 20 damage, 8 mana, 0.8s cooldown, 400 speed
3. **Ice Shard** - 30 damage, 12 mana, 1.2s cooldown, 300 speed
4. **Lightning Bolt** - 40 damage, 18 mana, 2.0s cooldown, 500 speed
5. **Heal** - -25 damage (healing), 12 mana, 2.0s cooldown, self-cast
6. **Arcane Blast** - 45 damage, 20 mana, 1.8s cooldown, 350 speed
7. **Shadow Bolt** - 32 damage, 14 mana, 1.4s cooldown, 320 speed
8. **Flame Wave** - 28 damage, 16 mana, 1.6s cooldown, 260 speed
9. **Frost Spike** - 38 damage, 17 mana, 1.7s cooldown, 310 speed
10. **Energy Burst** - 42 damage, 19 mana, 2.2s cooldown, 340 speed

### Spell Casting Logic

#### Cast Validation
```gdscript
func cast_spell(spell_index: int) -> bool:
    # Validate spell index
    if spell_index < 0 or spell_index >= equipped_spells.size():
        return false
    
    # Check cooldown
    if spell.spell_name in spell_cooldowns:
        return false
    
    # Check mana cost with power modifier
    var modified_mana_cost = spell.mana_cost
    if power_modifier:
        modified_mana_cost = power_modifier.calculate_modified_mana_cost(spell_index, spell.mana_cost)
    
    # Consume mana
    if not health_component.consume_mana(modified_mana_cost):
        return false
    
    return true
```

#### Enhanced Damage Calculation
```gdscript
func _calculate_enhanced_damage(base_damage: float) -> float:
    if not player_stat_sheet:
        return base_damage
    
    # Get spell damage multiplier from Intelligence
    var damage_multiplier = player_stat_sheet.get_stat_value("spell_damage_multiplier")
    var modified_damage = base_damage * damage_multiplier
    
    # Check for critical hit based on Intelligence
    var critical_chance = player_stat_sheet.get_stat_value("critical_chance")
    if randf() < critical_chance:
        modified_damage *= 2.0
    
    return modified_damage
```

#### Cooldown Reduction System
```gdscript
func _calculate_cooldown_reduction_with_diminishing_returns(raw_reduction: float) -> float:
    # Below 70% reduction: normal scaling
    if raw_reduction <= 0.7:
        return raw_reduction
    
    # Above 70%: extreme diminishing returns
    var excess = raw_reduction - 0.7
    var diminished_excess = excess * 0.1
    var final_reduction = 0.7 + diminished_excess
    
    # Hard cap at 75%
    return min(final_reduction, 0.75)
```

### Special Spell Features

#### Healing Spells
- Negative damage values indicate healing spells
- Self-cast with no projectile
- Beautiful heal effect with floating green orbs
- Fallback to code-based effects if scene unavailable

#### Projectile System
```gdscript
func _create_projectile(spell: SpellData, direction: Vector2, spell_index: int) -> bool:
    var projectile = projectile_scene.instantiate()
    
    # Apply power modifier to base damage first
    var base_damage = spell.base_damage
    if power_modifier:
        base_damage = power_modifier.calculate_modified_damage(spell_index, spell.base_damage)
    
    var final_damage = _calculate_enhanced_damage(base_damage)
    
    # Setup projectile BEFORE adding to scene tree
    projectile.setup(spell, final_damage, direction)
    get_tree().current_scene.add_child(projectile)
    
    return true
```

### Performance Optimizations

#### Cooldown Caching
```gdscript
func get_spell_cooldown_remaining(spell_index: int) -> float:
    var spell_name = equipped_spells[spell_index].spell_name
    
    # Use cached value if available and cache is valid
    if not _cache_dirty and _cooldown_cache.has(spell_name):
        return _cooldown_cache[spell_name]
    
    # Calculate and cache cooldown
    var cooldown = spell_cooldowns.get(spell_name, 0.0)
    _cooldown_cache[spell_name] = cooldown
    
    return cooldown
```

---

## AbilityManager.gd

**Location**: `/godot/Game10/scripts/components/AbilityManager.gd`  
**Extends**: Node  
**Purpose**: Core ability manager for abilities-only enemy system

### Core Functionality

#### Ability Evaluation
```gdscript
func evaluate_and_use_ability():
    # Get current context
    var health_ratio = health_component.get_health_ratio()
    var distance_to_player = enemy.global_position.distance_to(player_reference.global_position)
    var has_line_of_sight = check_line_of_sight_to_player()
    
    # Find best ability for current context
    var best_ability = select_best_ability(health_ratio, distance_to_player, has_line_of_sight)
    
    if best_ability:
        use_ability(best_ability)
```

#### Ability Selection Algorithm
```gdscript
func select_best_ability(health_ratio: float, distance: float, has_line_of_sight: bool) -> AbilityData:
    var valid_abilities: Array[AbilityData] = []
    var ability_scores: Array[int] = []
    
    for ability in available_abilities:
        # Check cooldown
        if is_ability_on_cooldown(ability):
            continue
        
        # Check context validity
        if not ability.is_valid_for_context(health_ratio, distance, has_line_of_sight):
            continue
        
        # Calculate priority score
        var score = ability.get_effective_priority(health_ratio, distance)
        score += get_context_bonus(ability, health_ratio, distance)
        
        valid_abilities.append(ability)
        ability_scores.append(score)
    
    # Return highest scoring ability
    return find_highest_scored_ability(valid_abilities, ability_scores)
```

#### Context-Based Bonuses
```gdscript
func get_context_bonus(ability: AbilityData, health_ratio: float, distance: float) -> int:
    var bonus = 0
    
    # Emergency situations
    if health_ratio < emergency_health_threshold:
        if ability.range_type == "escape" or ability.ability_type == "heal":
            bonus += 15
    
    # Distance optimization
    var distance_from_preferred = abs(distance - ability.preferred_distance)
    if distance_from_preferred < 25.0:
        bonus += 5
    
    # Range type bonuses
    match ability.range_type:
        "melee": bonus += 3 if distance < 120.0 else 0
        "ranged": bonus += 3 if distance > 150.0 and distance < 400.0 else 0
        "escape": bonus += 10 if health_ratio < 0.4 else 0
    
    return bonus
```

### Ability Execution System

#### Casting Logic
```gdscript
func use_ability(ability: AbilityData):
    # Set target position
    if is_instance_valid(player_reference):
        ability_target_position = player_reference.global_position
    
    # Start casting if ability has cast time
    if ability.cast_time > 0:
        start_casting(ability)
    else:
        # Execute immediately in background (async)
        _execute_ability_background(ability)
```

#### Ability Type Delegation
```gdscript
func execute_ability_immediately(ability: AbilityData):
    var abilities_component = enemy.get_node_or_null("EnemyAbilities")
    
    var success = false
    match ability.ability_type:
        "ranged", "projectile":
            success = await abilities_component.execute_ranged_ability(ability, ability_target_position)
        "melee", "melee_rush":
            success = await abilities_component.execute_melee_ability(ability, ability_target_position)
        "aoe", "heavy_slam", "melee_aoe":
            success = await abilities_component.execute_aoe_ability(ability, ability_target_position)
        "speed_boost", "buff":
            success = abilities_component.execute_buff_ability(ability)
        "heal":
            success = abilities_component.execute_heal_ability(ability)
    
    if success:
        ability_cooldowns[ability.ability_name] = ability.cooldown_time
```

### Performance Optimizations

#### Player Caching
```gdscript
var player_reference: Node2D = null
var player_cache_timer: float = 0.0
var player_cache_interval: float = 1.0

func update_player_cache(delta: float):
    player_cache_timer -= delta
    if player_cache_timer <= 0:
        player_cache_timer = player_cache_interval
        find_player()
```

#### Distance Squared Optimization
```gdscript
# OPTIMIZED: Use distance_squared for 25-30% performance boost
var distance_sq_to_player = enemy.global_position.distance_squared_to(player_reference.global_position)
var best_ability = select_best_ability_optimized(health_ratio, distance_sq_to_player, has_line_of_sight)
```

#### Line of Sight Check
```gdscript
func check_line_of_sight_to_player() -> bool:
    var space_state = enemy.get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.new()
    query.from = enemy.global_position
    query.to = player_reference.global_position
    query.collision_mask = 4  # Environment layer only
    query.exclude = [enemy]
    
    var result = space_state.intersect_ray(query)
    return result.is_empty()  # No obstacles = clear line of sight
```

## Component Integration Patterns

### SpellComponent ↔ HealthComponent
- Mana consumption validation before casting
- Health restoration for healing spells
- Real-time mana tracking during combat

### SpellComponent ↔ PlayerStatSheet  
- Dynamic damage calculation from intelligence
- Cooldown reduction from wisdom stats
- Critical hit chance from computed stats

### AbilityManager ↔ EnemyAbilities
- Ability execution delegation by type
- Async ability execution with visual indicators
- Success/failure feedback for cooldown management

### Both Components ↔ GameEvents
- Spell cast events for UI updates
- Ability completion signals
- Combat state notifications

## Debug & Monitoring Features

### SpellComponent Debug
```gdscript
func get_debug_info() -> String:
    var info = "SpellComponent Debug:\n"
    for i in range(equipped_spells.size()):
        var spell = equipped_spells[i]
        var cooldown = get_spell_cooldown(i)
        var is_ready = is_spell_ready(i)
        info += "  [%d] %s - Cooldown: %.1fs - Ready: %s\n" % [i, spell.spell_name, cooldown, is_ready]
    return info
```

### AbilityManager Debug
```gdscript
func get_ability_status() -> Dictionary:
    var status = {}
    for ability in available_abilities:
        status[ability.ability_name] = {
            "cooldown_remaining": ability_cooldowns.get(ability.ability_name, 0.0),
            "priority": ability.ai_priority,
            "range_type": ability.range_type,
            "is_emergency": ability.is_emergency
        }
    return status
```