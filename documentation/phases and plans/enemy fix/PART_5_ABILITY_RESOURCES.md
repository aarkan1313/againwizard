# Part 5: Ability Resource Creation
**Abilities-Only Enemy System Implementation**

---

## 🎯 Overview

Create AbilityData resources (.tres files) for each enemy type with proper metadata for smart prioritization.

---

## 📁 File Locations
`data/abilities/` folder

---

## 🛠️ Implementation

### **Step 1: Goblin Abilities**

#### **goblin_melee_attack.tres**
```gdscript
[gd_resource type="AbilityData" format=3]

[resource]
ability_name = "Goblin Swipe"  # Use existing field name
ability_type = "melee"         # Use existing field name
damage = 15
cooldown_time = 0.8            # Use existing field name
ai_priority = 6                # Use existing field name
range_type = "melee"           # NEW field
is_emergency = false           # NEW field
distance_min = 0.0             # NEW field  
distance_max = 80.0            # NEW field
```

#### **goblin_speed_boost.tres** (Update existing)
```gdscript
# MODIFY existing goblin_speed_boost.tres by adding new fields:

[resource]
# EXISTING fields (keep all current values):
ability_name = "Goblin Speed Boost"
ability_type = "speed_boost"
cooldown_time = 8.0
ai_priority = 3
effect_duration = 3.0
speed_multiplier = 1.5

# ADD these NEW fields:
range_type = "self"
is_emergency = true
distance_min = 0.0
distance_max = 1000.0
```

### **Step 2: Orc Abilities**

#### **orc_melee_attack.tres**
```gdscript
[gd_resource type="AbilityData" format=3]

[resource]
name = "Orc Heavy Strike"
damage = 25.0
cooldown = 1.5
range_type = "melee"
priority = 6
is_emergency = false
ability_type = "damage"
effect_duration = 0.0
```

### **Step 3: Skeleton Abilities**

#### **skeleton_bone_arrow.tres** (Update existing)
```gdscript
# MODIFY existing skeleton_bone_arrow.tres by adding new fields:

[resource]
# EXISTING fields (keep all current values from lines 7-50):
ability_name = "Bone Arrow"
ability_type = "ranged"
damage = 15
cooldown_time = 1.95
ai_priority = 6
projectile_speed = 560.0
# ... keep all other existing fields

# ADD these NEW fields:
range_type = "ranged"
is_emergency = false
distance_min = 60.0
distance_max = 600.0
```

### **Step 4: Wizard Abilities**

#### **wizard_ranged_attack.tres** (Create new, based on existing wizard_fireball.tres)
```gdscript
[gd_resource type="AbilityData" format=3]

[resource]
ability_name = "Magic Missile"
ability_type = "ranged"
damage = 20
cooldown_time = 1.8
ai_priority = 8
projectile_speed = 250.0
# Copy other fields from existing wizard_fireball.tres

# ADD these NEW fields:
range_type = "ranged"
is_emergency = false
distance_min = 100.0
distance_max = 500.0
```

#### **wizard_heal.tres** (Create new)
```gdscript
[gd_resource type="AbilityData" format=3]

[resource]
ability_name = "Wizard Self Heal"
ability_type = "heal"
heal_amount = 30               # Use existing heal field instead of negative damage
cooldown_time = 12.0
ai_priority = 9
effect_duration = 0.0

# ADD these NEW fields:
range_type = "self"
is_emergency = true
distance_min = 0.0
distance_max = 1000.0
```

### **Step 5: Golem Abilities**

#### **golem_aoe_stomp.tres** (Create new, based on existing golem_stone_stomp.tres)
```gdscript
[gd_resource type="AbilityData" format=3]

[resource]
ability_name = "Ground Stomp"
ability_type = "aoe"            # Or use existing ability_type from golem_stone_stomp.tres
damage = 30
cooldown_time = 2.5
ai_priority = 6
# Copy other relevant fields from existing golem_stone_stomp.tres

# ADD these NEW fields:
range_type = "close_ranged"
is_emergency = false
distance_min = 0.0
distance_max = 150.0
```

---

## 🔗 Ability Assignment

### **Link Abilities to Enemy Data**

Update enemy data resources or EnemyAbilities components:

#### **goblin_data.tres**
```gdscript
[gd_resource type="EnemyData" format=3]

[resource]
name = "Goblin"
max_health = 100.0
movement_speed = 120.0
abilities = [
    preload("res://data/abilities/goblin_melee_attack.tres"),
    preload("res://data/abilities/goblin_speed_boost.tres")
]
```

#### **orc_data.tres**
```gdscript
[gd_resource type="EnemyData" format=3]

[resource]
name = "Orc"
max_health = 150.0
movement_speed = 80.0
abilities = [
    preload("res://data/abilities/orc_melee_attack.tres")
]
```

#### **skeleton_data.tres**
```gdscript
[gd_resource type="EnemyData" format=3]

[resource]
name = "Skeleton"
max_health = 100.0
movement_speed = 100.0
abilities = [
    preload("res://data/abilities/skeleton_bone_arrow.tres")
]
```

#### **wizard_data.tres**
```gdscript
[gd_resource type="EnemyData" format=3]

[resource]
name = "Wizard"
max_health = 80.0
movement_speed = 100.0
abilities = [
    preload("res://data/abilities/wizard_ranged_attack.tres"),
    preload("res://data/abilities/wizard_heal.tres")
]
```

#### **golem_data.tres**
```gdscript
[gd_resource type="EnemyData" format=3]

[resource]
name = "Golem"
max_health = 200.0
movement_speed = 60.0
abilities = [
    preload("res://data/abilities/golem_aoe_stomp.tres")
]
```

---

## 🎯 Priority & Range Guide

### **Range Types**
- **"melee"**: < 80 units (close combat)
- **"ranged"**: > 60 units (projectiles)
- **"close_ranged"**: 60-150 units (AoE abilities)
- **"self"**: Any distance (buffs, heals)

### **Priority Scale**
- **1-3**: Desperation moves
- **4-6**: Standard abilities  
- **7-10**: Preferred abilities

### **Emergency Abilities**
- Set `is_emergency = true` for:
  - Healing abilities
  - Escape abilities  
  - Panic buffs
  - Last resort attacks

---

## ✅ Validation

For each ability resource:

1. **File Creates Successfully**: .tres file saves without errors
2. **Inspector Display**: Fields show correctly in Godot Inspector
3. **Type Validation**: AbilityData class recognized
4. **Metadata Present**: range_type, priority, is_emergency fields set

---

## 🚀 Next Steps

- Part 6: Test complete system and cleanup old files

---

## 📝 Notes

- **Start Simple**: Basic abilities first, can enhance later
- **Consistent Naming**: Clear, descriptive ability names
- **Balanced Values**: Damage/cooldown appropriate for enemy role
- **Metadata Critical**: Prioritization depends on correct metadata

**Estimated Time: 60 minutes**