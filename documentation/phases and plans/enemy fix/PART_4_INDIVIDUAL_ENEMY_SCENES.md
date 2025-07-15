# Part 4: Individual Enemy Scene Setup
**Abilities-Only Enemy System Implementation**

---

## 🎯 Overview

Configure each individual enemy scene to use the new abilities-only system with appropriate AbilityManager types and emergency thresholds.

---

## 📁 File Locations
- `scenes/enemies/Goblin.tscn`
- `scenes/enemies/Orc.tscn`
- `scenes/enemies/Skeleton.tscn`
- `scenes/enemies/Wizard.tscn`
- `scenes/enemies/Golem.tscn`
- `scenes/enemies/Elemental.tscn`

---

## 🛠️ Implementation

### **Step 1: Goblin.tscn Configuration**

Open Goblin.tscn and configure:

```gdscript
# In Goblin scene root node properties:
enemy_type = "goblin"

# Ensure these child nodes exist:
- EnemyAbilities (Node)
- HealthComponent (Node) 
- CollisionShape2D
- Sprite2D

# EnemyAbilities configuration:
# Will be populated with ability resources in Part 5
```

**Goblin Characteristics:**
- Fast attacker
- Panics early (30% health)
- Uses speed boost to chase player

### **Step 2: Orc.tscn Configuration**

```gdscript
# In Orc scene root node properties:
enemy_type = "orc"

# Orc Characteristics:
- Heavy hitter
- Tough (panics at 20% health)
- Single powerful melee attack
```

### **Step 3: Skeleton.tscn Configuration**

```gdscript
# In Skeleton scene root node properties:
enemy_type = "skeleton"

# Skeleton Characteristics:
- Balanced fighter
- Uses ranged bone projectile
- Moderate panic threshold (25% health)
```

### **Step 4: Wizard.tscn Configuration**

```gdscript
# In Wizard scene root node properties:
enemy_type = "wizard"

# Wizard Characteristics:
- Glass cannon
- Panics very early (35% health)
- Uses custom WizardAbilityManager for advanced AI
- Prefers staying at range
```

### **Step 5: Golem.tscn Configuration**

```gdscript
# In Golem scene root node properties:
enemy_type = "golem"

# Golem Characteristics:
- Tank enemy
- Very tough (panics at 15% health)
- AoE stomp attack
```

### **Step 6: Elemental.tscn Configuration**

```gdscript
# In Elemental scene root node properties:
enemy_type = "elemental"

# Elemental Characteristics:
- Area control
- Moderate toughness (25% health)
- Can be configured with fire/ice/lightning variants later
```

---

## 🎨 Visual Customization

### **Sprite Setup**

Each enemy should have distinct visuals:

```gdscript
# Goblin.tscn - Small, green, fast-looking
Sprite2D:
  texture = res://assets/sprites/goblin2.png
  scale = Vector2(0.8, 0.8)

# Orc.tscn - Large, imposing
Sprite2D:
  texture = res://assets/sprites/orc_cut-removebg-preview.png
  scale = Vector2(1.2, 1.2)

# Skeleton.tscn - Ranged archer appearance
Sprite2D:
  texture = res://assets/sprites/skeleton_archer-removebg-preview.png
  scale = Vector2(1.0, 1.0)

# Wizard.tscn - Magical appearance
Sprite2D:
  texture = res://assets/sprites/evil_wizard_cut-removebg-preview.png
  scale = Vector2(1.0, 1.0)

# Golem.tscn - Large, rocky
Sprite2D:
  texture = res://assets/sprites/golem_cut-removebg-preview.png
  scale = Vector2(1.5, 1.5)
```

### **Collision Shape Customization**

Adjust collision based on enemy size:

```gdscript
# Small enemies (Goblin):
CollisionShape2D:
  shape = CircleShape2D(radius = 18.0)

# Medium enemies (Skeleton, Wizard):
CollisionShape2D:
  shape = CircleShape2D(radius = 22.0)

# Large enemies (Orc, Golem):
CollisionShape2D:
  shape = CircleShape2D(radius = 28.0)
```

---

## 🔧 Component Verification

### **Required Child Nodes**

Each enemy scene needs these components:

```
Enemy (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D  
├── HealthComponent (Node)
├── EnemyAbilities (Node)
└── DamageArea (Area2D) [if using damage detection]
    └── CollisionShape2D
```

### **Script Assignment**

Ensure all enemies use the refactored Enemy.gd:

```gdscript
# Each enemy scene root node:
script = res://scripts/Enemy.gd
```

---

## 🎛️ Per-Enemy Properties

### **Movement Speed Differences**

```gdscript
# Fast enemies:
goblin.movement_speed = 120.0

# Normal enemies:
skeleton.movement_speed = 100.0
wizard.movement_speed = 100.0

# Slow enemies:
orc.movement_speed = 80.0
golem.movement_speed = 60.0
```

### **Health Differences**

```gdscript
# Glass cannons:
wizard.max_health = 80.0

# Balanced:
goblin.max_health = 100.0
skeleton.max_health = 100.0

# Tough:
orc.max_health = 150.0
golem.max_health = 200.0
```

---

## ✅ Validation

For each enemy scene:

1. **Scene Opens**: No errors when opening in Godot
2. **Script Assignment**: Uses refactored Enemy.gd
3. **Component Structure**: Has all required child nodes
4. **Properties Set**: enemy_type matches scene name
5. **Visual Check**: Sprite displays correctly

---

## 🚀 Next Steps

- Part 5: Create ability resources for each enemy type
- Part 6: Test individual enemies and cleanup

---

## 📝 Notes

- **Preserve existing setups** - Don't break current working configurations
- **Consistent structure** - All enemies follow same component pattern
- **Visual identity** - Each enemy type clearly distinguishable
- **Balanced stats** - Movement and health appropriate for enemy role

**Estimated Time: 45 minutes**