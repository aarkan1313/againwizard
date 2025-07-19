# Character Progression System

## Overview

The FFS Wizard RPG implements a comprehensive character progression system that combines traditional RPG elements with modern game design. The system features experience-based leveling, milestone achievements, stat point allocation, and multiple progression paths through the PlayerStatSheet and achievement systems.

## Core Progression Mechanics

### Experience and Leveling System

#### XP Gain and Level-Up Process

**File Path**: `res://scripts/stats/PlayerStatSheet.gd`

The experience system uses a scaling formula for balanced progression:

```gdscript
func gain_experience(amount: float) -> void:
    current_xp += amount
    total_xp += amount
    
    while current_xp >= xp_to_next_level:
        current_xp -= xp_to_next_level
        var current_level = int(get_stat_value("level"))
        current_level += 1
        set_stat_base_value("level", current_level)
        
        # Grant stat points (5 per level)
        available_stat_points += 5
        
        # Calculate next level XP requirement using scaling formula
        xp_to_next_level = base_xp_per_level * pow(xp_scaling_factor, current_level - 1)
        
        level_up.emit(current_level, 5)
```

#### XP Scaling Formula

```gdscript
# Experience progression data
var base_xp_per_level: float = 100.0
var xp_scaling_factor: float = 1.5

# XP requirements scale exponentially
# Level 1: 100 XP
# Level 2: 150 XP  
# Level 3: 225 XP
# Level 4: 337 XP
# etc.
```

This formula provides:
- **Early Accessibility**: First few levels achievable quickly
- **Meaningful Progression**: Each level feels significant
- **Long-term Engagement**: Higher levels require substantial investment
- **Balanced Scaling**: Prevents both trivial and impossibly long progressions

#### Level-Up Rewards

Each level-up grants:
- **5 Stat Points**: For attribute allocation
- **Automatic Health/Mana Increase**: Based on stat scaling formulas
- **Signal Broadcasting**: Triggers UI animations and system updates

## Attribute System

### Core Attributes

The game features four primary attributes that start at 10 and can be increased through stat point allocation:

**Intelligence** (Starting: 10)
- **Primary Effect**: Spell damage multiplier - `1.0 + intelligence * 0.02` (2% per point)
- **Secondary Effects**: Mana pool size, critical chance
- **Formula**: Max Mana = `50 + intelligence * 3 + wisdom * 2 + level * 2`

**Wisdom** (Starting: 10)
- **Primary Effect**: Mana regeneration and cooldown reduction
- **Formula**: Mana Regen = `3.0 + wisdom * 0.8 + intelligence * 0.2`
- **Cooldown Reduction**: `wisdom * 0.005` (0.5% per point)

**Vitality** (Starting: 10)
- **Primary Effect**: Health pool and regeneration
- **Formula**: Max Health = `100 + vitality * 5 + level * 3`
- **Regeneration**: `2.0 + vitality * 0.5`

**Dexterity** (Starting: 10)
- **Primary Effect**: Movement speed and dodge chance
- **Formula**: Movement Speed = `120 + dexterity * 2`
- **Dodge Chance**: `0.05 + vitality * 0.001` (0.1% per point)

### Stat Point Allocation

**File Path**: `res://scripts/ui/allocation/StatAllocationPanel.gd`

The stat allocation system provides an interactive UI for character customization:

```gdscript
func increase_attribute(attribute_name: String, points: int) -> bool:
    if available_stat_points < points or points <= 0:
        return false
    
    # Apply the increase
    var old_value = get_stat_value(attribute_name)
    var new_value = old_value + points
    set_stat_base_value(attribute_name, new_value)
    available_stat_points -= points
    
    # Force immediate recalculation of ALL computed stats
    _force_update_all_computed_stats()
    
    attribute_increased.emit(attribute_name, new_value)
    return true
```

#### Allocation Interface Features

- **Real-time Preview**: Shows impact of pending stat changes
- **Computed Stat Display**: Previews how attributes affect derived stats
- **Validation**: Prevents invalid allocations
- **Batch Allocation**: Apply multiple changes at once

```gdscript
# Real-time preview calculation
func _update_computed_stat_preview() -> void:
    var preview_attributes = {}
    for attribute in pending_allocations.keys():
        preview_attributes[attribute] = current_attributes[attribute] + pending_allocations[attribute]
    
    # Calculate health changes
    var current_max_health = player_stat_sheet.get_stat_value("max_health")
    var preview_max_health = 100 + preview_attributes.vitality * 5 + current_level * 3
    var health_change = preview_max_health - current_max_health
```

## Milestone Achievement System

**File Path**: `res://scripts/singletons/AchievementNotificationManager.gd`

The game features a comprehensive milestone system that provides permanent bonuses:

### Kill-Based Milestones

```gdscript
func apply_milestone_bonus(milestone_name: String):
    var modifier_source = "milestone_" + milestone_name
    
    match milestone_name:
        "first_blood":  # 25 kills
            add_flat_modifier_to_stat("max_health", 25.0, modifier_source)
            
        "apprentice_slayer":  # 50 kills
            add_flat_modifier_to_stat("mana_regen_rate", 1.0, modifier_source)
            
        "monster_hunter":  # 100 kills
            add_flat_modifier_to_stat("critical_chance", 0.02, modifier_source)
            
        "death_dealer":  # 250 kills
            add_percent_modifier_to_stat("spell_damage_multiplier", 0.15, modifier_source)
            
        "destroyer":  # 500 kills
            add_flat_modifier_to_stat("max_health", 50.0, modifier_source)
            add_percent_modifier_to_stat("spell_damage_multiplier", 0.25, modifier_source)
            
        "legend":  # 1000 kills - Ultimate bonuses
            add_flat_modifier_to_stat("max_health", 100.0, modifier_source)
            add_percent_modifier_to_stat("spell_damage_multiplier", 0.50, modifier_source)
            add_flat_modifier_to_stat("critical_chance", 0.05, modifier_source)
```

### Milestone Benefits

- **Permanent Stat Bonuses**: Persist across all future runs
- **Achievement Unlocks**: Meta-progression recognition  
- **Visual Rewards**: Special effects and notifications
- **Progressive Power**: Each milestone provides meaningful upgrades

## Build Progression Paths

### Build Archetypes

The attribute system supports multiple viable build strategies:

#### Glass Cannon (Intelligence Focus)
- **Primary**: Intelligence → Spell Damage
- **Secondary**: Wisdom → Mana Sustain  
- **Playstyle**: High damage, moderate survivability
- **Endgame**: Maximize spell power with sufficient mana

#### Battle Mage (Balanced)
- **Primary**: Intelligence + Vitality
- **Secondary**: Wisdom + Dexterity
- **Playstyle**: Balanced offense and defense
- **Endgame**: Versatile character capable of any content

#### Evasion Specialist (Dexterity Focus)
- **Primary**: Dexterity → Movement + Dodge
- **Secondary**: Vitality → Health Pool
- **Playstyle**: Avoid damage through mobility
- **Endgame**: High mobility with good survivability

#### Sustain Caster (Wisdom Focus)
- **Primary**: Wisdom → Mana Efficiency
- **Secondary**: Intelligence → Damage
- **Playstyle**: Continuous spell casting
- **Endgame**: Unlimited mana with rapid spell rotation

### Progression Curves

#### Early Game (Levels 1-10)
- **Focus**: Establish core identity through attribute selection
- **Goals**: Reach 15-20 points in primary attribute
- **Strategy**: Prioritize one attribute for immediate impact

#### Mid Game (Levels 10-25)  
- **Focus**: Develop secondary attributes for survivability
- **Goals**: Achieve 25+ primary, 15+ secondary attributes
- **Strategy**: Balance primary focus with defensive stats

#### Late Game (Levels 25+)
- **Focus**: Optimization and specialization
- **Goals**: 40+ primary attribute, milestone completion
- **Strategy**: Min-max for specific content, achieve milestones

## User Interface Integration

### Character Sheet System

**File Path**: `res://scripts/ui/DraggableCharacterSheet.gd`

The character sheet provides comprehensive stat viewing:

```gdscript
func _update_stats_display():
    var text = ""
    
    # Base Attributes
    text += "[color=cyan][b]━━━ BASE ATTRIBUTES ━━━[/b][/color]\n"
    text += _format_stat("Level", player_stat_sheet.get_stat_value("level"), true)
    text += _format_stat("Intelligence", player_stat_sheet.get_stat_value("intelligence"), true)
    text += _format_stat("Wisdom", player_stat_sheet.get_stat_value("wisdom"), true)
    text += _format_stat("Vitality", player_stat_sheet.get_stat_value("vitality"), true)
    text += _format_stat("Dexterity", player_stat_sheet.get_stat_value("dexterity"), true)
    
    # Combat Stats
    text += "\n[color=orange][b]━━━ COMBAT STATS ━━━[/b][/color]\n"
    text += _format_stat("Spell Damage", player_stat_sheet.get_stat_value("spell_damage_multiplier"), false, "x")
    text += _format_stat("Critical Chance", player_stat_sheet.get_stat_value("critical_chance") * 100, false, "%")
```

### Real-Time Updates

All UI systems connect to stat changes for immediate feedback:

```gdscript
# In PlayerUI.gd
func _on_stat_changed(stat_name: String, old_value: float, new_value: float) -> void:
    if stat_name in ["vitality", "level", "intelligence", "wisdom"]:
        _schedule_update()
```

## Achievement Notification System

**File Path**: `res://scripts/singletons/AchievementNotificationManager.gd`

The system provides visual feedback for progression milestones:

```gdscript
func show_milestone_achievement(milestone_name: String, description: String):
    var notification_data = {
        "title": "MILESTONE ACHIEVED!",
        "subtitle": milestone_name,
        "description": description,
        "type": "milestone"
    }
    
    notification_queue.push_back(notification_data)
    if not is_showing_notification:
        _show_next_notification()
```

### Notification Features

- **Queued Display**: Multiple achievements shown in sequence
- **Visual Polish**: Animated notifications with appropriate styling
- **Audio Feedback**: Achievement sounds for milestone completion
- **Persistence**: Achievement status saved across sessions

## Integration with Game Systems

### Save/Load System

The progression system integrates seamlessly with the save system:

```gdscript
func get_all_stats() -> Dictionary:
    var all_stats = {}
    
    # Base stats
    for stat_name in stats.keys():
        all_stats[stat_name] = get_stat_value(stat_name)
    
    # Progression data
    all_stats["available_stat_points"] = available_stat_points
    all_stats["current_xp"] = current_xp
    all_stats["total_xp"] = total_xp
    
    return all_stats
```

### Component Integration

All player components automatically respond to stat changes:

- **HealthComponent**: Updates max values when vitality/level changes
- **MovementComponent**: Adjusts speed when dexterity changes
- **SpellComponent**: Recalculates damage when intelligence changes
- **PlayerUI**: Updates displays when any relevant stat changes

## Performance Considerations

### Optimization Strategies

- **Direct Function Calls**: Critical stat calculations bypass signal overhead
- **Cached Values**: Frequently accessed stats cached until invalidated
- **Batched Updates**: UI updates grouped to reduce processing overhead
- **Validation**: Bounds checking prevents invalid states

### Memory Management

- **Cleanup Systems**: Proper disposal of UI elements and timers
- **Weak References**: Prevent memory leaks in signal connections
- **Object Pooling**: Achievement notifications reuse UI elements

This comprehensive progression system provides meaningful character development through multiple advancement paths, permanent milestone bonuses, and real-time feedback systems while maintaining excellent performance and integration with all game systems.