# Projectile Physics System

## Overview

The FFS Wizard RPG implements a comprehensive projectile physics system that handles both player spells and enemy projectiles with sophisticated collision detection, visual effects, and performance optimizations. The system emphasizes visual clarity, predictable behavior, and seamless integration with the game's combat mechanics.

## Core Projectile Architecture

### Projectile Collision Layers

**Collision System Design**:
```gdscript
# Layer definitions for projectile systems
const COLLISION_LAYERS = {
    PLAYER: 1,           # Player CharacterBody2D
    ENEMIES: 2,          # Enemy CharacterBody2D  
    PLAYER_SPELLS: 4,    # Player projectiles
    ENEMY_SPELLS: 8,     # Enemy projectiles
    WORLD: 16            # Static world geometry
}

# Mask definitions (what each type detects)
const COLLISION_MASKS = {
    PLAYER_SPELLS: ENEMIES | WORLD,     # Hit enemies and world
    ENEMY_SPELLS: PLAYER | WORLD        # Hit player and world
}
```

**Collision Matrix**:
| Projectile Type | Layer | Detects | Purpose |
|----------------|-------|---------|---------|
| Player Spells | 4 | Enemies (2) + World (16) | Damage enemies, blocked by walls |
| Enemy Spells | 8 | Player (1) + World (16) | Damage player, blocked by walls |

**Note**: Layer values correspond directly to collision_layer property in code (Layer 4 = collision_layer = 4)

## Player Projectile System

### SpellProjectile.gd - Player Spell Physics

**File Path**: `res://scripts/SpellProjectile.gd`  
**Class Type**: Area2D  
**Purpose**: Player-fired spell projectiles with comprehensive visual and physics systems

#### Core Physics Properties

```gdscript
class_name SpellProjectile extends Area2D

# Physics properties
var direction: Vector2 = Vector2.RIGHT
var speed: float = 300.0
var max_range: float = 600.0
var distance_traveled: float = 0.0

# Spell configuration
var spell_data: SpellData
var damage: float = 25.0
var pierce_count: int = 0
var homing_enabled: bool = false
var homing_target: Node2D
```

#### Movement and Physics Processing

**Core Movement System**:
```gdscript
func _physics_process(delta: float):
    # Handle homing behavior
    if homing_enabled and is_instance_valid(homing_target):
        update_homing_direction(delta)
    
    # Calculate movement vector
    var velocity = direction * speed
    var movement = velocity * delta
    
    # Apply movement
    position += movement
    distance_traveled += movement.length()
    
    # Check range limits
    if distance_traveled >= max_range:
        explode_and_cleanup()
```

**Homing Projectile Mechanics**:
```gdscript
func update_homing_direction(delta: float):
    if not is_instance_valid(homing_target):
        homing_enabled = false
        return
    
    # Calculate direction to target
    var target_direction = (homing_target.global_position - global_position).normalized()
    
    # Lerp current direction toward target
    var homing_strength = spell_data.homing_strength if spell_data else 2.0
    direction = direction.lerp(target_direction, homing_strength * delta)
    direction = direction.normalized()
    
    # Update visual rotation
    rotation = direction.angle()
```

#### Collision Detection System

**Enemy Collision Handling**:
```gdscript
func _on_area_entered(area: Area2D):
    var enemy = area.get_parent()
    
    # Validate enemy target
    if not enemy.has_method("take_damage"):
        return
    
    # Calculate final damage with all modifiers
    var final_damage = calculate_enhanced_damage()
    
    # Apply damage to enemy
    enemy.take_damage(final_damage, spell_data.spell_name if spell_data else "unknown")
    
    # Create impact effects
    create_spell_impact_effect(global_position, enemy)
    
    # Handle piercing mechanics
    if pierce_count > 0:
        handle_pierce_collision(enemy)
    else:
        queue_free()
```

**World Collision Handling**:
```gdscript
func _on_body_entered(body: Node2D):
    # Check if this is world geometry
    if body.collision_layer & COLLISION_LAYERS.WORLD:
        # Create wall impact effect
        create_wall_impact_effect(global_position)
        queue_free()
    
    # Handle other collision types
    elif body == get_player_reference():
        # Should not happen with proper collision setup
        print("Warning: Player spell hit player - check collision configuration")
```

#### Piercing System Implementation

**Multi-Target Pierce Mechanics**:
```gdscript
var targets_hit: Array[Node] = []
var max_pierce_count: int = 0

func handle_pierce_collision(enemy: Node):
    # Add to hit targets list
    targets_hit.append(enemy)
    
    # Decrement pierce count
    pierce_count -= 1
    
    # Create pierce visual effect
    create_pierce_effect(global_position)
    
    # Check if piercing is exhausted
    if pierce_count <= 0:
        create_final_impact_effect()
        queue_free()
    
    # Continue traveling for more hits
```

**Pierce Damage Falloff**:
```gdscript
func calculate_pierce_damage(hit_count: int) -> float:
    if hit_count == 0:
        return damage  # Full damage for first hit
    
    # Reduce damage by 15% per previous hit
    var damage_reduction = hit_count * 0.15
    var damage_multiplier = max(0.25, 1.0 - damage_reduction)  # Minimum 25% damage
    
    return damage * damage_multiplier
```

### Visual Effects Integration

#### Spell-Specific Visual System

**Dynamic Texture Loading**:
```gdscript
func load_spell_texture(spell_name: String) -> Texture2D:
    # Try to load spell-specific texture
    var texture_path = "res://assets/spells/" + spell_name.to_lower() + ".png"
    
    if ResourceLoader.exists(texture_path):
        return load(texture_path)
    else:
        # Generate procedural texture as fallback
        return generate_spell_texture(spell_name)

func generate_spell_texture(spell_name: String) -> ImageTexture:
    var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
    var spell_color = get_spell_color(spell_name)
    
    # Create circular projectile with gradient
    for x in range(32):
        for y in range(32):
            var center = Vector2(16, 16)
            var distance = Vector2(x, y).distance_to(center)
            
            if distance <= 12:
                var alpha = 1.0 - (distance / 12.0)
                var color = Color(spell_color.r, spell_color.g, spell_color.b, alpha)
                image.set_pixel(x, y, color)
    
    var texture = ImageTexture.new()
    texture.set_image(image)
    return texture
```

**Spell Color Mapping**:
```gdscript
func get_spell_color(spell_name: String) -> Color:
    match spell_name.to_lower():
        "fireball": return Color.ORANGE_RED
        "lightning": return Color.YELLOW
        "ice_shard": return Color.CYAN
        "energy_burst": return Color.MAGENTA
        "arcane_missile": return Color.PURPLE
        "poison_dart": return Color.GREEN
        "wind_blade": return Color.LIGHT_GRAY
        "dark_bolt": return Color.DARK_SLATE_GRAY
        "light_beam": return Color.WHITE
        "heal": return Color.LIGHT_GREEN
        _: return Color.WHITE
```

#### Impact Effect System

**Spell Impact Effects**:
```gdscript
func create_spell_impact_effect(impact_position: Vector2, target: Node = null):
    # Create main impact effect
    var impact_effect = create_impact_particles(impact_position)
    
    # Add spell-specific secondary effects
    create_spell_specific_effect(impact_position, target)
    
    # Screen shake for powerful spells
    if spell_data and spell_data.base_damage > 50:
        GameEvents.emit_screen_shake(spell_data.base_damage * 0.02, 0.2)

func create_impact_particles(position: Vector2) -> GPUParticles2D:
    var particles = GPUParticles2D.new()
    get_tree().current_scene.add_child(particles)
    particles.global_position = position
    
    # Configure particle material
    var material = ParticleProcessMaterial.new()
    material.direction = Vector3(0, -1, 0)
    material.initial_velocity_min = 50.0
    material.initial_velocity_max = 150.0
    material.angular_velocity_min = -180.0
    material.angular_velocity_max = 180.0
    material.gravity = Vector3(0, 98, 0)
    material.scale_min = 0.5
    material.scale_max = 1.5
    
    # Spell-specific color
    if spell_data:
        material.color = spell_data.projectile_color
    
    particles.process_material = material
    particles.amount = 25
    particles.lifetime = 2.0
    particles.emitting = true
    
    # Auto-cleanup
    var cleanup_timer = Timer.new()
    cleanup_timer.wait_time = 3.0
    cleanup_timer.one_shot = true
    cleanup_timer.timeout.connect(particles.queue_free)
    particles.add_child(cleanup_timer)
    cleanup_timer.start()
    
    return particles
```

**Spell-Specific Effects**:
```gdscript
func create_spell_specific_effect(position: Vector2, target: Node = null):
    if not spell_data:
        return
    
    match spell_data.spell_name.to_lower():
        "fireball":
            create_fire_explosion(position)
        "ice_shard":
            create_frost_effect(position, target)
        "lightning":
            create_electric_spark(position)
        "poison_dart":
            create_poison_cloud(position)
        "heal":
            create_healing_sparkles(position)

func create_fire_explosion(position: Vector2):
    # Fire ring expansion
    var fire_ring = create_expanding_circle(position, Color.ORANGE_RED, 0.5)
    
    # Heat distortion effect
    create_heat_distortion(position)

func create_frost_effect(position: Vector2, target: Node = null):
    # Ice crystals
    for i in range(5):
        var crystal = create_ice_crystal()
        crystal.global_position = position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
    
    # Freeze target visually
    if target and target.has_method("apply_frost_visual"):
        target.apply_frost_visual(1.0)
```

### Animation System

**Safe Animation Handling**:
```gdscript
func play_projectile_animation():
    if not sprite or not sprite.texture:
        return
    
    # Prevent ERR_INVALID_PARAMETER errors with validation
    var tween = create_tween()
    tween.set_parallel(true)  # Allow multiple simultaneous animations
    
    # Scale pulsing for energy projectiles
    if should_pulse():
        tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.2)
        tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
        tween.set_loops()
    
    # Rotation for spinning projectiles
    if should_rotate():
        tween.tween_property(sprite, "rotation", TAU, 1.0)
        tween.set_loops()

func should_pulse() -> bool:
    if not spell_data:
        return false
    
    return spell_data.spell_name.to_lower() in ["energy_burst", "arcane_missile", "light_beam"]

func should_rotate() -> bool:
    if not spell_data:
        return false
    
    return spell_data.spell_name.to_lower() in ["fireball", "ice_shard", "wind_blade"]
```

## Enemy Projectile System

### EnemyProjectile.gd - Enemy-Fired Projectiles

**File Path**: `res://scripts/enemies/EnemyProjectile.gd`  
**Purpose**: Enemy-fired projectiles with player collision detection and damage type visualization

#### Core Configuration

```gdscript
class_name EnemyProjectile extends Area2D

# Physics properties
var direction: Vector2 = Vector2.RIGHT
var speed: float = 200.0
var damage: float = 15.0
var max_lifetime: float = 10.0
var max_range: float = 800.0

# Collision setup
collision_layer = 8  # Enemy projectiles layer
collision_mask = 1   # Hit player layer

# Visual properties
var damage_type: String = "physical"
var projectile_color: Color = Color.WHITE
```

#### Movement and Lifetime Management

**Core Physics Processing**:
```gdscript
func _physics_process(delta: float):
    # Standard projectile movement
    var velocity = direction * speed
    var movement = velocity * delta
    position += movement
    distance_traveled += movement.length()
    
    # Update lifetime
    max_lifetime -= delta
    
    # Check termination conditions
    if max_lifetime <= 0 or distance_traveled >= max_range:
        create_timeout_effect()
        queue_free()
```

#### Player Collision System

**Player Hit Detection**:
```gdscript
func _on_body_entered(body: Node2D):
    # Check if hit player
    if body == get_player_reference():
        # Apply damage with type
        var player = body as Player
        player.take_damage(damage, damage_type)
        
        # Create impact effect
        create_player_hit_effect(body.global_position)
        
        # Handle piercing
        if pierce_count > 0:
            handle_enemy_projectile_pierce(body)
        else:
            queue_free()

func _on_area_entered(area: Area2D):
    # Check for player damage area
    var parent = area.get_parent()
    if parent == get_player_reference():
        _on_body_entered(parent)
```

#### Damage Type Visualization

**Color-Coded Projectiles**:
```gdscript
func setup_damage_type_visuals(damage_type: String):
    self.damage_type = damage_type
    
    match damage_type.to_lower():
        "fire":
            projectile_color = Color.ORANGE_RED
            create_fire_trail()
        "ice":
            projectile_color = Color.CYAN
            create_frost_particles()
        "lightning":
            projectile_color = Color.YELLOW
            create_electric_crackling()
        "poison":
            projectile_color = Color.GREEN
            create_poison_bubbles()
        "dark":
            projectile_color = Color.PURPLE
            create_shadow_wisps()
        "physical":
            projectile_color = Color.GRAY
        _:
            projectile_color = Color.WHITE
    
    # Apply color to sprite
    if sprite:
        sprite.modulate = projectile_color
```

**Trail Effect Creation**:
```gdscript
func create_fire_trail():
    var trail = Line2D.new()
    add_child(trail)
    trail.default_color = Color.ORANGE_RED
    trail.width = 3.0
    trail.gradient = create_fire_gradient()
    
    # Update trail in process
    trail_line = trail

func create_frost_particles():
    var particles = GPUParticles2D.new()
    add_child(particles)
    
    var material = ParticleProcessMaterial.new()
    material.emission_count = 5
    material.color = Color.CYAN
    material.initial_velocity_min = 10.0
    material.initial_velocity_max = 30.0
    
    particles.process_material = material
    particles.emitting = true
```

### Piercing Projectile Mechanics

#### Multi-Hit System

**Pierce Implementation for Enemy Projectiles**:
```gdscript
var targets_hit: Array[Node] = []
var max_pierce_count: int = 0
var current_pierce_count: int = 0

func handle_enemy_projectile_pierce(target: Node):
    # Track hit targets to prevent double-hits
    targets_hit.append(target)
    current_pierce_count += 1
    
    # Create pierce visual feedback
    create_pierce_flash(global_position)
    
    # Check if piercing exhausted
    if current_pierce_count >= max_pierce_count:
        create_final_pierce_effect()
        queue_free()
    
    # Continue traveling for additional hits
```

**Pierce Damage Scaling**:
```gdscript
func calculate_pierce_damage_for_hit(hit_index: int) -> float:
    # Enemy projectiles maintain full damage through all pierces
    # (Different from player projectiles which have falloff)
    return damage
```

## Area of Effect Projectiles

### Explosion Mechanics

**AoE Projectile Implementation**:
```gdscript
func create_explosion_on_impact(impact_position: Vector2):
    var explosion_radius = spell_data.explosion_radius if spell_data else 100.0
    
    # Create explosion area for damage detection
    var explosion_area = Area2D.new()
    var explosion_shape = CircleShape2D.new()
    explosion_shape.radius = explosion_radius
    
    var collision_shape = CollisionShape2D.new()
    collision_shape.shape = explosion_shape
    explosion_area.add_child(collision_shape)
    
    # Set collision properties
    explosion_area.collision_layer = 0  # Don't exist on any layer
    explosion_area.collision_mask = COLLISION_LAYERS.ENEMIES  # Detect enemies
    
    # Add to scene temporarily
    get_tree().current_scene.add_child(explosion_area)
    explosion_area.global_position = impact_position
    
    # Wait one frame for physics update
    await get_tree().process_frame
    
    # Apply damage to all enemies in explosion
    var enemies_in_explosion = explosion_area.get_overlapping_areas()
    for enemy_area in enemies_in_explosion:
        var enemy = enemy_area.get_parent()
        if enemy.has_method("take_damage"):
            var distance_to_center = enemy.global_position.distance_to(impact_position)
            var damage_falloff = calculate_explosion_falloff(distance_to_center, explosion_radius)
            var final_damage = damage * damage_falloff
            
            enemy.take_damage(final_damage, "explosion")
    
    # Clean up explosion area
    explosion_area.queue_free()
    
    # Create visual explosion effect
    create_explosion_visual_effect(impact_position, explosion_radius)
```

**Damage Falloff Calculation**:
```gdscript
func calculate_explosion_falloff(distance: float, max_radius: float) -> float:
    if distance >= max_radius:
        return 0.0
    
    # Linear falloff from center to edge
    var falloff_factor = 1.0 - (distance / max_radius)
    
    # Minimum 30% damage at edge, 100% at center
    return 0.3 + (falloff_factor * 0.7)
```

## Performance Optimizations

### Object Pooling System

**Projectile Pool Management**:
```gdscript
# Singleton projectile pool manager
class_name ProjectilePool extends Node

var available_spell_projectiles: Array[SpellProjectile] = []
var available_enemy_projectiles: Array[EnemyProjectile] = []
var active_projectiles: Array[Area2D] = []

func get_spell_projectile() -> SpellProjectile:
    if available_spell_projectiles.is_empty():
        var projectile = preload("res://scenes/SpellProjectile.tscn").instantiate()
        return projectile
    
    var projectile = available_spell_projectiles.pop_back()
    projectile.reset_state()
    return projectile

func return_spell_projectile(projectile: SpellProjectile):
    # Clean up projectile state
    projectile.reset_visual_effects()
    projectile.disconnect_all_signals()
    
    # Remove from scene
    if projectile.get_parent():
        projectile.get_parent().remove_child(projectile)
    
    # Return to pool
    active_projectiles.erase(projectile)
    available_spell_projectiles.append(projectile)
```

### Collision Optimization

**Spatial Partitioning for Projectiles**:
```gdscript
# Group projectiles by screen regions for efficient collision checking
var projectile_spatial_grid: Dictionary = {}
const GRID_CELL_SIZE: float = 200.0

func update_projectile_spatial_grid():
    projectile_spatial_grid.clear()
    
    for projectile in active_projectiles:
        if not is_instance_valid(projectile):
            continue
        
        var grid_pos = Vector2(
            int(projectile.global_position.x / GRID_CELL_SIZE),
            int(projectile.global_position.y / GRID_CELL_SIZE)
        )
        
        if not projectile_spatial_grid.has(grid_pos):
            projectile_spatial_grid[grid_pos] = []
        
        projectile_spatial_grid[grid_pos].append(projectile)
```

### Memory Management

**Automatic Cleanup System**:
```gdscript
# In main projectile manager
var projectile_cleanup_timer: float = 0.0
const CLEANUP_INTERVAL: float = 2.0

func _process(delta):
    projectile_cleanup_timer -= delta
    
    if projectile_cleanup_timer <= 0:
        cleanup_invalid_projectiles()
        projectile_cleanup_timer = CLEANUP_INTERVAL

func cleanup_invalid_projectiles():
    # Remove invalid projectiles from tracking
    for i in range(active_projectiles.size() - 1, -1, -1):
        var projectile = active_projectiles[i]
        
        if not is_instance_valid(projectile):
            active_projectiles.remove_at(i)
        elif projectile.should_be_cleaned_up():
            projectile.queue_free()
            active_projectiles.remove_at(i)
```

### Visual Effect Optimization

**Effect Batching**:
```gdscript
# Batch similar effects to reduce draw calls
var pending_impact_effects: Array = []
var effect_batch_timer: float = 0.0

func create_batched_impact_effect(position: Vector2, effect_type: String):
    pending_impact_effects.append({
        "position": position,
        "type": effect_type,
        "timestamp": Time.get_time_dict_from_system()
    })
    
    if effect_batch_timer <= 0:
        effect_batch_timer = 0.016  # Next frame
        call_deferred("process_batched_effects")

func process_batched_effects():
    # Group effects by type and create single batched effect
    var effects_by_type = {}
    
    for effect_data in pending_impact_effects:
        var effect_type = effect_data.type
        if not effects_by_type.has(effect_type):
            effects_by_type[effect_type] = []
        effects_by_type[effect_type].append(effect_data)
    
    # Create batched effects
    for effect_type in effects_by_type:
        create_multi_position_effect(effect_type, effects_by_type[effect_type])
    
    pending_impact_effects.clear()
```

## Advanced Projectile Features

### Predictive Targeting

**Lead Target Calculation**:
```gdscript
func calculate_intercept_direction(target: Node2D, projectile_speed: float) -> Vector2:
    if not target.has_method("get_velocity"):
        # Fallback to direct targeting
        return (target.global_position - global_position).normalized()
    
    var target_velocity = target.get_velocity()
    var relative_position = target.global_position - global_position
    
    # Calculate intercept time
    var a = target_velocity.dot(target_velocity) - projectile_speed * projectile_speed
    var b = 2 * relative_position.dot(target_velocity)
    var c = relative_position.dot(relative_position)
    
    var discriminant = b * b - 4 * a * c
    if discriminant < 0:
        # No solution, use direct targeting
        return relative_position.normalized()
    
    var t1 = (-b - sqrt(discriminant)) / (2 * a)
    var t2 = (-b + sqrt(discriminant)) / (2 * a)
    
    var intercept_time = t1 if t1 > 0 else t2
    if intercept_time <= 0:
        return relative_position.normalized()
    
    # Calculate intercept position
    var intercept_position = target.global_position + target_velocity * intercept_time
    return (intercept_position - global_position).normalized()
```

### Gravity-Affected Projectiles

**Ballistic Trajectory System**:
```gdscript
func _physics_process(delta: float):
    # Apply gravity if enabled
    if affected_by_gravity:
        velocity.y += gravity_strength * delta
    
    # Apply velocity
    position += velocity * delta
    distance_traveled += velocity.length() * delta
    
    # Update direction for visual rotation
    if velocity.length() > 0:
        direction = velocity.normalized()
        rotation = direction.angle()
```

The projectile physics system provides a robust foundation for diverse spell and combat mechanics while maintaining excellent performance through optimization techniques like object pooling, spatial partitioning, and effect batching. The system's modular design allows for easy expansion with new projectile types and behaviors while ensuring consistent visual quality and reliable collision detection.