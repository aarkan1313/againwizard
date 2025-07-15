# Part 2: AbilityManager Component
**Abilities-Only Enemy System Implementation**

---

## 🎯 Overview

Create the core AbilityManager component that makes intelligent decisions about which abilities to use based on context (distance, health, cooldowns).

---

## 📁 File Location
`scripts/components/AbilityManager.gd`

---

## 🛠️ Implementation

### **Step 1: Create Base AbilityManager**

```gdscript
# scripts/components/AbilityManager.gd
extends Node
class_name AbilityManager

@export var emergency_health_threshold: float = 0.25  # Per enemy type override
var abilities_component: EnemyAbilities
var health_component: HealthComponent
var ability_cooldowns: Dictionary = {}  # Per-ability cooldown tracking

# Virtual method - can be overridden for custom enemy AI
func evaluate_and_execute(target: Node2D, enemy_position: Vector2):
    var context = _build_context(target, enemy_position)
    var best_ability = _select_best_ability(context)
    
    if best_ability and _can_use_ability(best_ability):
        abilities_component.use_ability_by_name(best_ability.ability_name, target)
        _set_ability_cooldown(best_ability)

func _build_context(target: Node2D, enemy_pos: Vector2) -> Dictionary:
    var distance = enemy_pos.distance_to(target.global_position)
    var health_percent = health_component.current_health / health_component.max_health
    
    return {
        "distance": distance,
        "health_percent": health_percent,
        "player_position": target.global_position,
        "enemy_position": enemy_pos
        # Future context factors (commented for expansion):
        # "player_health_percent": target.health_component.current_health / target.health_component.max_health,
        # "nearby_enemies_count": _count_nearby_enemies(),
        # "time_since_last_hit": Time.get_ticks_msec() / 1000.0 - last_damage_time,
        # "player_velocity": target.velocity.length(),
        # "environment_hazards": _detect_hazards_nearby()
    }

# Virtual method - can be overridden for custom scoring
func _select_best_ability(context: Dictionary) -> AbilityData:
    var available_abilities = abilities_component.get_available_abilities()
    var scored_abilities = []
    
    for ability in available_abilities:
        if _can_use_ability(ability):
            var score = _score_ability(ability, context)
            scored_abilities.append({"ability": ability, "score": score})
    
    scored_abilities.sort_custom(func(a, b): return a.score > b.score)
    return scored_abilities[0].ability if scored_abilities.size() > 0 else null

# Virtual method - can be overridden for custom scoring logic
func _score_ability(ability: AbilityData, context: Dictionary) -> float:
    var score = 0.0
    
    # Distance-based scoring
    match ability.range_type:
        "melee": 
            score += 100.0 if context.distance < 80 else 0.0
        "ranged":
            score += 100.0 if context.distance > 60 else 20.0
        "close_ranged":
            score += 80.0 if context.distance < 150 else 40.0
        "self":
            score += 50.0  # Always available
    
    # Emergency ability scoring (uses per-enemy threshold)
    if ability.is_emergency and context.health_percent < emergency_health_threshold:
        score += 200.0
    
    # Priority modifier (use existing ai_priority or new priority_override)
    var effective_priority = ability.get_effective_priority() if ability.has_method("get_effective_priority") else ability.ai_priority
    score += effective_priority * 10.0
    
    return score

func _can_use_ability(ability: AbilityData) -> bool:
    var ability_name = ability.ability_name  # Use existing field name
    if not ability_cooldowns.has(ability_name):
        return true
    
    var time_since_use = Time.get_ticks_msec() / 1000.0 - ability_cooldowns[ability_name]
    return time_since_use >= ability.cooldown_time  # Use existing field name

func _set_ability_cooldown(ability: AbilityData):
    ability_cooldowns[ability.ability_name] = Time.get_ticks_msec() / 1000.0
```

### **Step 2: Create Custom Wizard AI**

```gdscript
# scripts/components/WizardAbilityManager.gd
extends AbilityManager
class_name WizardAbilityManager

# Wizard-specific behavior: prefers staying at max range, prioritizes escape

func _score_ability(ability: AbilityData, context: Dictionary) -> float:
    var score = super._score_ability(ability, context)
    
    # Wizard-specific modifications:
    match ability.range_type:
        "ranged":
            # Heavily prefer ranged attacks
            score += 50.0
            # Bonus for staying far away
            if context.distance > 120:
                score += 30.0
        "melee":
            # Heavily penalize melee unless desperate
            score -= 80.0
            # Only use melee if very close and no other option
            if context.distance < 40:
                score += 40.0
        "self":
            # Prioritize escape abilities more when cornered
            if context.distance < 100:
                score += 100.0
    
    # Extra emergency behavior - panic earlier
    if ability.is_emergency and context.health_percent < 0.5:
        score += 50.0
    
    return score
```

---

## 🔧 Integration Points

### **AbilityManager requires these methods in EnemyAbilities:**

```gdscript
# EnemyAbilities.gd already has these methods (lines 36-49):
# - available_abilities: Array[AbilityData] (existing)
# - current_cooldowns: Dictionary (existing)
# 
# ADD these new methods to EnemyAbilities.gd:
func get_available_abilities() -> Array[AbilityData]:
    var usable_abilities = []
    for ability in available_abilities:
        if current_cooldowns.get(ability.ability_name, 0.0) <= 0.0:
            usable_abilities.append(ability)
    return usable_abilities

func use_ability_by_name(ability_name: String, target: Node2D) -> bool:
    for ability in available_abilities:
        if ability.ability_name == ability_name:
            return try_use_ability(ability, target)  # Use existing method
    return false
```

### **AbilityManager requires these components:**

```gdscript
# Enemy.gd integration (use existing structure):
# Current Enemy.gd has:
# - var enemy_abilities: EnemyAbilities
# - var health_component: HealthComponent (check if exists)
# - health/max_health variables (lines 11-12)

# AbilityManager will reference:
var abilities_component: EnemyAbilities  # Link to existing enemy_abilities
var health_component: HealthComponent   # Link to existing health component OR use enemy health directly
```

---

## ✅ Validation

Test the component:

1. **Syntax Check**: No parser errors
2. **Logic Test**: Ensure scoring makes sense
3. **Integration Test**: Can access abilities and health components

---

## 🚀 Next Steps

- Part 3: Update Enemy.gd to use AbilityManager
- Part 4: Configure individual enemy scenes with appropriate managers
- Part 5: Create ability resources with proper metadata

---

## 📝 Notes

- **Virtual methods** allow custom AI per enemy type
- **Cooldown system** prevents ability spam
- **Context-aware scoring** makes enemies feel intelligent
- **Emergency threshold** configurable per enemy personality

**Estimated Time: 45 minutes**