# Part 3: Enemy.gd Refactor
**Abilities-Only Enemy System Implementation**

---

## 🎯 Overview

Simplify Enemy.gd to remove all complex attack logic and replace with the new abilities-only system using AbilityManager.

---

## 📁 File Location
`scripts/Enemy.gd`

---

## 🛠️ Implementation

### **Step 1: Remove Old Attack Systems**

Remove or comment out these sections in Enemy.gd:

```gdscript
# REMOVE/COMMENT OUT:
# - All basic attack logic (lines ~261-280)
# - EnemyAttackComponent references
# - EnemyAttackPattern state machine logic
# - Telegraph system calls
# - Manual damage dealing code
```

### **Step 2: Add AbilityManager Integration**

Add these variables and setup:

```gdscript
# scripts/Enemy.gd - ADD to existing class (keep all current variables)

# EXISTING VARIABLES (keep all from lines 8-49):
# @export var enemy_data: EnemyData
# var enemy_type: String = "goblin" 
# var health: float = 100.0
# var max_health: float = 100.0
# var speed: float = 150.0
# var enemy_abilities: EnemyAbilities
# var health_component: HealthComponent
# etc.

# NEW: AbilityManager reference (add these)
var ability_manager: AbilityManager
var player_node: Node2D

# Helper function to check if alive (use existing is_dead)
func is_alive() -> bool:
    return not is_dead

func _ready():
    setup_ability_manager()
    find_player()
    # ... keep existing setup code

func setup_ability_manager():
    # Create appropriate manager based on enemy type
    match enemy_type:
        "wizard":
            ability_manager = WizardAbilityManager.new()
            ability_manager.emergency_health_threshold = 0.35  # Panics early
        "goblin":
            ability_manager = AbilityManager.new()
            ability_manager.emergency_health_threshold = 0.30  # Panics early
        "orc":
            ability_manager = AbilityManager.new()
            ability_manager.emergency_health_threshold = 0.20  # Tough
        "skeleton":
            ability_manager = AbilityManager.new()
            ability_manager.emergency_health_threshold = 0.25  # Balanced
        "golem":
            ability_manager = AbilityManager.new()
            ability_manager.emergency_health_threshold = 0.15  # Very tough
        _:
            ability_manager = AbilityManager.new()
            ability_manager.emergency_health_threshold = 0.25  # Default
    
    add_child(ability_manager)
    ability_manager.abilities_component = enemy_abilities  # Use existing field
    # Handle health component - check if it exists or use direct health
    if health_component:
        ability_manager.health_component = health_component
    else:
        # Create a simple health wrapper if no component exists
        ability_manager.health_component = _create_health_wrapper()

func find_player():
    # Existing player finding logic or:
    player_node = get_tree().get_first_node_in_group("player")
```

### **Step 3: Simplify Physics Process**

Replace complex movement/attack logic with simple approach:

```gdscript
func _physics_process(delta):
    if not player_node or is_dead:  # Use existing is_dead variable
        return
    
    # NEW: Simple abilities-only combat
    if ability_manager:
        ability_manager.evaluate_and_execute(player_node, global_position)
    
    # Simple movement logic (keep existing movement if it works, or replace)
    handle_movement()
    
    # Apply movement (already exists in current Enemy.gd)
    move_and_slide()

func handle_movement():
    var distance_to_player = global_position.distance_to(player_node.global_position)
    
    # Basic movement toward player (use existing speed variable)
    if distance_to_player > 60:
        var direction = (player_node.global_position - global_position).normalized()
        velocity = direction * speed  # Use existing speed variable
    else:
        velocity = Vector2.ZERO
    
    # TODO: Per-enemy movement patterns can be added later
    # - Wizard: Kite away if too close
    # - Goblin: Rush in aggressively  
    # - Skeleton: Maintain medium range
```

### **Step 4: Remove Old Method Calls**

Remove or replace these old system calls:

```gdscript
# REMOVE these calls from existing code:
# - attack_component.execute_attack()
# - attack_pattern.update_state()
# - telegraph_system.show_telegraph()
# - Any manual damage dealing

# REPLACE with:
# - ability_manager.evaluate_and_execute() (already added above)
```

### **Step 5: Keep Essential Systems**

Preserve these important existing systems:

```gdscript
# KEEP these existing methods (already exist in Enemy.gd):
# - take_damage() method (if exists)
# - die() method (if exists) 
# - Health-related signals and connections
# - All existing @onready var declarations
# - All existing functions and logic

# ADD this health wrapper if no HealthComponent exists:
func _create_health_wrapper():
    var wrapper = Node.new()
    wrapper.name = "HealthWrapper"
    wrapper.set_script(preload("res://scripts/components/HealthComponent.gd"))
    wrapper.current_health = health
    wrapper.max_health = max_health
    return wrapper

# ADD helper method for AbilityManager health access:
func get_health_percent() -> float:
    if health_component and health_component.has_method("get_health_percent"):
        return health_component.get_health_percent()
    else:
        return health / max_health if max_health > 0 else 0.0
```

---

## 🔧 Integration Notes

### **Required EnemyAbilities Methods**

Ensure EnemyAbilities.gd has these methods:

```gdscript
func get_available_abilities() -> Array[AbilityData]:
    # Return abilities that exist and aren't on cooldown
    pass

func use_ability(ability_name: String, target: Node2D) -> bool:
    # Execute the named ability
    pass
```

### **Component Dependencies**

Verify these components exist and are properly connected:
- HealthComponent (existing)
- EnemyAbilities (existing) 
- MovementComponent (if used)

---

## ✅ Validation

After refactoring:

1. **No Parser Errors**: Enemy.gd loads without issues
2. **Scene Compatibility**: Enemy scenes still work
3. **Component Access**: AbilityManager can access abilities and health
4. **Basic Functionality**: Enemies can move and respond to player

---

## 🚀 Next Steps

- Part 4: Configure individual enemy scenes
- Part 5: Create ability resources for each enemy type
- Part 6: Test and cleanup old systems

---

## 📝 Notes

- **Preserve existing functionality** - Don't break current working systems
- **Gradual transition** - Can comment out old code instead of deleting
- **Per-enemy customization** - Emergency thresholds and manager types
- **Simple movement** - Can be enhanced later per enemy type

**Estimated Time: 30 minutes**