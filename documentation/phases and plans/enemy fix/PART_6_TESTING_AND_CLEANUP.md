# Part 6: Testing and Cleanup
**Abilities-Only Enemy System Implementation**

---

## 🎯 Overview

Test the complete abilities-only system, verify all enemy types work correctly, and clean up redundant old systems.

---

## 🧪 Testing Phase

### **Step 1: Individual Enemy Testing**

Test each enemy type separately:

#### **Goblin Testing**
```bash
# Test scenario:
1. Spawn goblin near player
2. Verify melee attack triggers at close range
3. Damage goblin to 25% health
4. Verify speed boost activates (emergency ability)
5. Check cooldown system prevents spam
```

#### **Orc Testing**
```bash
# Test scenario:
1. Spawn orc near player
2. Verify heavy melee attack
3. Check damage output (should be higher than goblin)
4. Verify no emergency abilities (orc only has melee)
```

#### **Skeleton Testing**
```bash
# Test scenario:
1. Spawn skeleton at medium distance
2. Verify bone arrow projectile fires
3. Move player closer, verify still uses ranged attack
4. Check projectile damage and trajectory
```

#### **Wizard Testing**
```bash
# Test scenario:
1. Spawn wizard at long range
2. Verify magic missile projectile
3. Damage wizard to 30% health
4. Verify heal ability activates (emergency)
5. Test WizardAbilityManager prefers staying distant
```

#### **Golem Testing**
```bash
# Test scenario:
1. Spawn golem near player
2. Verify AoE stomp ability
3. Check area damage affects player within range
4. Verify cooldown prevents constant stomping
```

### **Step 2: Multi-Enemy Testing**

Test mixed enemy encounters:

```bash
# Mixed combat scenario:
1. Spawn goblin + skeleton + wizard
2. Verify each uses appropriate abilities
3. Check no interference between enemy AI
4. Verify performance with multiple AbilityManagers
```

### **Step 3: Edge Case Testing**

Test boundary conditions:

```bash
# Edge cases:
1. Player at exact range boundaries (60, 80, 150 units)
2. Multiple enemies at different health levels
3. Abilities on cooldown - verify fallback behavior
4. Enemy with no available abilities
5. Enemy death during ability execution
```

---

## 🧹 Cleanup Phase

### **Step 1: Remove Redundant Systems**

Delete these old files:

```bash
# Files to DELETE:
scripts/components/EnemyAttackComponent.gd
scripts/components/EnemyAttackPattern.gd
scripts/managers/TelegraphSystem.gd
scenes/effects/*Telegraph*.tscn

# Optional - can keep for reference:
# Comment out instead of deleting initially
```

### **Step 2: Clean Enemy.gd**

Remove commented-out old code:

```gdscript
# In Enemy.gd, remove these commented sections:
# - Old attack logic
# - Telegraph system calls  
# - Manual damage dealing
# - State machine code
```

### **Step 3: Update EnemyAbilities.gd**

Ensure EnemyAbilities supports the new system:

```gdscript
# Required methods in EnemyAbilities.gd:
func get_available_abilities() -> Array[AbilityData]:
    # Return abilities that aren't on cooldown
    # (AbilityManager handles cooldowns, but this ensures abilities exist)
    return abilities

func use_ability(ability_name: String, target: Node2D) -> bool:
    for ability in abilities:
        if ability.name == ability_name:
            execute_ability(ability, target)
            return true
    return false

func execute_ability(ability: AbilityData, target: Node2D):
    match ability.ability_type:
        "damage":
            apply_direct_damage(ability, target)
        "projectile":
            spawn_projectile(ability, target)
        "aoe":
            apply_aoe_damage(ability, target)
        "heal":
            heal_self(ability)
        "buff":
            apply_buff(ability)
```

---

## 📊 Performance Validation

### **Step 1: Frame Rate Check**

```bash
# Monitor performance:
1. Spawn 10+ enemies of mixed types
2. Check FPS remains stable (60 FPS target)
3. Profile AbilityManager.evaluate_and_execute() calls
4. Verify no memory leaks in ability execution
```

### **Step 2: Memory Usage**

```bash
# Memory validation:
1. Long-duration combat scenarios
2. Check Dictionary cooldown tracking doesn't grow indefinitely
3. Verify ability resources load/unload correctly
```

---

## 🔧 Troubleshooting Guide

### **Common Issues & Solutions**

#### **Enemy Not Attacking**
```bash
Symptoms: Enemy moves but never uses abilities
Check:
1. EnemyAbilities has ability resources assigned
2. AbilityManager properly connected to components  
3. ability_manager.evaluate_and_execute() being called
4. Abilities have correct range_type for distance
```

#### **Wrong Ability Selected**
```bash
Symptoms: Enemy uses inappropriate ability for situation
Check:
1. Ability metadata (range_type, priority, is_emergency)
2. AbilityManager scoring logic
3. Distance calculations in _build_context()
```

#### **Ability Spam**
```bash
Symptoms: Same ability used repeatedly without cooldown
Check:
1. _set_ability_cooldown() being called
2. _can_use_ability() checking cooldowns correctly
3. Time.get_ticks_msec() calculations
```

#### **Emergency Abilities Not Triggering**
```bash
Symptoms: Low-health abilities never used
Check:
1. emergency_health_threshold set correctly per enemy
2. is_emergency flag set on ability resources
3. Health component reporting correct values
```

---

## ✅ Final Validation Checklist

- [ ] All 5+ enemy types spawn and move correctly
- [ ] Each enemy uses appropriate abilities for their type
- [ ] Emergency abilities trigger at low health
- [ ] Cooldown system prevents ability spam
- [ ] Custom Wizard AI behaves differently from others
- [ ] No parser errors or runtime exceptions
- [ ] Frame rate stable with multiple enemies
- [ ] Old attack systems completely removed
- [ ] Code clean and well-documented

---

## 🚀 Future Enhancements

Once basic system is working:

### **Phase 2 Improvements**
- Per-enemy movement patterns (wizard kiting, goblin rushing)
- Visual effects for ability activation
- Sound effects for different ability types
- Damage numbers integration

### **Phase 3 Expansions**
- New ability types (debuffs, shields, summons)
- Environmental abilities (using obstacles)
- Combo abilities (chain different abilities)
- Dynamic difficulty scaling

---

## 📝 Notes

- **Test incrementally** - Fix issues as they arise
- **Keep backups** - Don't delete old systems until new one proven
- **Document issues** - Note any edge cases discovered
- **Performance focus** - Ensure system scales with enemy count

**Estimated Time: 75 minutes**

---

## 🎉 Completion

After successful testing and cleanup:

1. **System Complete**: Abilities-only enemy system fully functional
2. **Performance Optimized**: Stable with multiple enemies
3. **Codebase Clean**: Old redundant systems removed
4. **Documentation Updated**: All changes documented
5. **Ready for Enhancement**: Foundation for future improvements

**Total Implementation Time: ~3.5 hours**