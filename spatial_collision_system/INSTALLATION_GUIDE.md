# Spatial Collision System - Installation Guide

## Overview

This guide provides step-by-step instructions to install the spatial collision system in your existing Godot project. The system is designed to be drop-in compatible with zero breaking changes.

## Prerequisites

- Godot 4.4.1 or later
- Existing project with Enemy.gd and Player.gd systems
- Basic understanding of Godot autoloads and scene structure

## Installation Steps

### Step 1: Add Autoloads to project.godot

Add these autoloads to your `project.godot` file in the `[autoload]` section:

```ini
[autoload]
# Add these new autoloads (existing autoloads remain unchanged)
SpatialGrid="*res://spatial_collision_system/autoloads/SpatialGrid.gd"
EnemyLODManager="*res://spatial_collision_system/autoloads/EnemyLODManager.gd"
CollisionOptimizer="*res://spatial_collision_system/optimization/CollisionOptimizer.gd"
```

**Important**: Add these AFTER your existing autoloads to maintain dependency order.

### Step 2: Copy System Files

Copy the entire `spatial_collision_system/` folder to your project root:

```
your_project/
├── spatial_collision_system/
│   ├── autoloads/
│   │   ├── SpatialGrid.gd
│   │   └── EnemyLODManager.gd
│   ├── components/
│   │   └── MassBasedCollision.gd
│   ├── optimization/
│   │   └── CollisionOptimizer.gd
│   ├── integration/
│   ├── validation/
│   └── examples/
└── ... (your existing project files)
```

### Step 3: Update GameConfig (Optional but Recommended)

Add these configuration options to your `GameConfig.gd`:

```gdscript
# Add to GameConfig.gd
func get_spatial_grid_size() -> float:
    return 100.0  # Adjustable based on performance

func get_max_entities_per_cell() -> int:
    return 20

func get_separation_distance() -> float:
    return 40.0

func get_separation_force_strength() -> float:
    return 20.0

func get_collision_force_multiplier() -> float:
    return 100.0

func get_max_full_physics_enemies() -> int:
    return 50

func get_max_simplified_enemies() -> int:
    return 150

func get_target_fps() -> float:
    return 60.0
```

### Step 4: Update Enemy.gd

Apply the changes from `integration/Enemy_Enhanced.gd` to your existing `Enemy.gd`:

#### 4.1: Add Variables (after line 43)
```gdscript
# Enhanced collision system
var mass_collision_component: MassBasedCollision
var spatial_grid_registered: bool = false
var last_spatial_position: Vector2 = Vector2.ZERO
```

#### 4.2: Update _ready() Function (after existing setup)
```gdscript
func _ready():
    # ... existing _ready() code ...
    
    # Setup enhanced collision system
    setup_mass_collision_system()
    register_with_spatial_grid()
```

#### 4.3: Add New Functions
Copy these functions from `integration/Enemy_Enhanced.gd`:
- `setup_mass_collision_system()`
- `register_with_spatial_grid()`
- `update_spatial_grid_position()`
- `_on_mass_collision_occurred()`

#### 4.4: Update _physics_process() (add after line 163)
```gdscript
func _physics_process(delta):
    if is_dead:
        return
    
    # Update spatial grid position if moved significantly
    update_spatial_grid_position()
    
    # ... rest of existing _physics_process code ...
```

#### 4.5: Update die() Function (add cleanup)
```gdscript
func die():
    if is_dead:
        return
    
    is_dead = true
    
    # Unregister from spatial grid
    if spatial_grid_registered and SpatialGrid:
        SpatialGrid.unregister_entity(self)
        spatial_grid_registered = false
    
    # ... rest of existing die() code ...
```

### Step 5: Update EnemyAIController.gd

Apply changes from `integration/EnemyAIController_Enhanced.gd`:

#### 5.1: Replace apply_separation_force() Function
Replace the existing function (around line 428-444) with the enhanced version that uses spatial grid.

#### 5.2: Add LOD Integration
Add the LOD integration functions to handle performance scaling.

### Step 6: Update Player.gd (Optional - for Player-Enemy Mass Collision)

If you want player-enemy mass-based collision, apply changes from `integration/Player_Enhanced.gd`:

#### 6.1: Add Variables
```gdscript
# Enhanced collision system
var mass_collision_component: MassBasedCollision
var player_mass: float = 1.5
var collision_immunity_active: bool = false
```

#### 6.2: Setup Mass Collision
Add the setup function and connect it in `_ready()` or `connect_signals()`.

### Step 7: Test Installation

#### 7.1: Run Validation Script
```gdscript
# Add to a test scene and run
var validator = preload("res://spatial_collision_system/validation/SpatialCollisionValidator.gd").new()
validator.run_full_validation()
```

#### 7.2: Check Debug Output
Look for these messages in the console:
```
✅ SpatialGrid initialized - Grid size: 100px
✅ EnemyLODManager initialized - Full: 50 Simplified: 150
✅ CollisionOptimizer ready for performance monitoring
```

#### 7.3: Test with Enemies
- Spawn 10-20 enemies
- Verify they move and separate normally
- Check performance in debug menu

## Configuration and Tuning

### Performance Tuning

Adjust these values in GameConfig based on your performance targets:

```gdscript
# For high-end systems (1000+ enemies)
spatial_grid_size = 80.0
max_full_physics_enemies = 100
max_simplified_enemies = 300

# For low-end systems (100-200 enemies)
spatial_grid_size = 150.0
max_full_physics_enemies = 25
max_simplified_enemies = 75
```

### Mass Configuration

Set enemy masses in your enemy data files or in the enhanced Enemy.gd:

```gdscript
"goblin": mass = 0.5
"skeleton": mass = 0.7
"orc": mass = 1.0
"wizard": mass = 0.8
"elemental": mass = 1.2
"golem": mass = 2.0
"slime": mass = 0.3
```

## Monitoring and Debug

### Debug Information

Access debug info through:
```gdscript
# Spatial grid stats
print(SpatialGrid.get_debug_info())

# LOD system stats
print(EnemyLODManager.get_lod_statistics())

# Performance stats
print(CollisionOptimizer.get_performance_report())
```

### Performance Monitoring

The system includes automatic performance monitoring:
- Tracks FPS and entity counts
- Auto-adjusts LOD levels based on performance
- Provides optimization recommendations

### Debug Menu Integration

Add to your existing debug menu:
```gdscript
# Add collision system debug panel
func add_collision_debug_panel():
    var panel = VBoxContainer.new()
    
    # Add spatial grid info
    var grid_label = Label.new()
    grid_label.text = "Spatial Grid: " + str(SpatialGrid.total_entities) + " entities"
    panel.add_child(grid_label)
    
    # Add LOD info
    var lod_stats = EnemyLODManager.get_entity_counts_by_lod()
    for lod_level in lod_stats:
        var lod_label = Label.new()
        lod_label.text = lod_level + ": " + str(lod_stats[lod_level])
        panel.add_child(lod_label)
```

## Troubleshooting

### Common Issues

**1. Parser Errors after Installation**
- Check autoload order in project.godot
- Ensure all files are copied correctly
- Verify Godot version compatibility

**2. Performance Degradation**
- Check CollisionOptimizer debug output
- Reduce max_full_physics_enemies
- Increase spatial_grid_size

**3. Enemies Not Separating**
- Verify SpatialGrid registration: `SpatialGrid.total_entities > 0`
- Check enemy LOD levels: `EnemyLODManager.get_entity_lod_level(enemy)`
- Ensure separation_enabled = true

**4. Player Walks Through Enemies**
- This is intentional for performance
- Enable Player_Enhanced.gd integration for mass-based collision
- Or adjust collision masks manually

### Performance Optimization

**If experiencing low FPS:**
1. Check CollisionOptimizer recommendations
2. Reduce entity counts in GameConfig
3. Increase spatial grid cell size
4. Disable collision for distant enemies

**If entities are jittery:**
1. Reduce collision_check_interval
2. Increase friction values
3. Reduce collision force multipliers

## Rollback Plan

To rollback the installation:

1. Remove autoloads from project.godot
2. Delete spatial_collision_system/ folder
3. Restore original Enemy.gd and EnemyAIController.gd from backup
4. Remove any added GameConfig functions

## Next Steps

After successful installation:

1. Monitor performance with debug tools
2. Tune parameters for your specific game
3. Experiment with enemy mass values
4. Consider implementing player mass collision
5. Add visual effects for collision feedback

## Support

If you encounter issues:
1. Check the validation script output
2. Review debug information
3. Compare with the example files
4. Ensure all dependencies are properly configured

The system is designed to be robust and backward-compatible, so most issues are related to configuration rather than core functionality.