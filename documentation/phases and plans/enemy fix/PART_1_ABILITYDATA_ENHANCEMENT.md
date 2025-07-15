# Part 1: AbilityData Enhancement
**Abilities-Only Enemy System Implementation**

---

## 🎯 Overview

First step is enhancing the AbilityData class to support smart prioritization. We're adding metadata fields that the AbilityManager will use to make intelligent decisions.

---

## 📁 File Location
`scripts/data/AbilityData.gd`

---

## 🛠️ Implementation

### **Step 1: Locate and Read Current AbilityData**

First, examine the current AbilityData structure:

```bash
# Check current structure
cat scripts/data/AbilityData.gd
```

### **Step 2: Add Metadata Fields**

Add these new @export fields to the existing AbilityData.gd structure:

```gdscript
# scripts/data/AbilityData.gd - ADD these fields to the existing class

# EXISTING FIELDS (keep all current fields from lines 1-123)
# Keep: ability_name, ability_type, damage, cooldown_time, ai_priority, etc.

# NEW METADATA FIELDS for smart prioritization (add after line 123):
@export_group("Smart AI Prioritization")
@export var range_type: String = "melee"  # "melee", "ranged", "close_ranged", "self"
@export var priority_override: int = -1   # Override ai_priority if set (1-10, -1 = use ai_priority)
@export var is_emergency: bool = false    # Emergency ability (used when health low)
@export var distance_min: float = 0.0     # Minimum effective distance
@export var distance_max: float = 1000.0  # Maximum effective distance

# Optional: Additional context metadata (for future expansion)
@export_group("Advanced Context (Future)")
@export var preferred_player_health_range: Vector2 = Vector2(0, 1)  # 0-1 (any health)
@export var environmental_requirements: Array[String] = []  # Future: "open_space", "near_walls", etc.

# Helper function to get effective priority
func get_effective_priority() -> int:
    return priority_override if priority_override > 0 else ai_priority
```

### **Step 3: Documentation Comments**

Add clear documentation for each field:

```gdscript
# Range Type Options:
# - "melee": Close combat (< 80 units)
# - "ranged": Long distance (> 60 units)  
# - "close_ranged": Medium distance (60-150 units)
# - "self": Self-targeting (buffs, heals, movement)

# Priority Scale:
# 1-3: Low priority (desperation moves)
# 4-6: Normal priority (standard attacks)
# 7-10: High priority (preferred abilities)

# Emergency Flag:
# true: Only use when health below enemy's emergency threshold
# false: Can use any time when appropriate
```

---

## ✅ Validation

After making changes:

1. **Syntax Check**: Ensure no parser errors
2. **Editor Test**: Open Godot and verify fields appear in Inspector
3. **Backward Compatibility**: Existing .tres files should still load

---

## 🚀 Next Steps

After completing this enhancement:
- Part 2: Create AbilityManager component
- Part 3: Update Enemy.gd to use new system
- Part 4: Configure individual enemy scenes
- Part 5: Create ability resources with metadata
- Part 6: Test and cleanup

---

## 📝 Notes

- **Preserve existing fields** - Don't remove anything currently used
- **Use @export_group** - Organizes Inspector for better usability  
- **Default values** - Ensure all new fields have sensible defaults
- **Future-proof** - Commented fields ready for expansion

**Estimated Time: 15 minutes**