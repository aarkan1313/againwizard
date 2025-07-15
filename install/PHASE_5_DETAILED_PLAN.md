# PHASE 5: PROCEDURAL MAPS & WORLD GENERATION
## Detailed Implementation Plan (6 Days)

### 🎯 **PHASE OVERVIEW**
Transform static combat into dynamic, procedural environments with elemental zones, destructible terrain, and environmental hazards that enhance combat gameplay.

### 📋 **SUCCESS CRITERIA**
- [ ] 5+ distinct zone types with unique gameplay effects
- [ ] Destructible terrain that affects combat tactics
- [ ] Environmental effects that enhance spell combat
- [ ] Map generation creates varied, interesting layouts
- [ ] Elemental zones provide meaningful gameplay differences
- [ ] Performance remains stable with procedural generation

---

## 📅 **DAY 1: MAP GENERATION FOUNDATION**

### **Morning (3 hours): Core Map Generator**

**Create `scripts/world/MapGenerator.gd`**:
```gdscript
extends Node
class_name MapGenerator

enum ZoneType { 
    PLAINS, FIRE_CAVES, ICE_FIELDS, POISON_SWAMPS, 
    CRYSTAL_CAVERNS, VOLCANIC_CHAMBER 
}

enum RoomType { 
    OPEN_ARENA, CORRIDOR_MAZE, SCATTERED_ISLANDS, 
    CENTRAL_PLATFORM, RING_FORMATION 
}

# Core generation parameters
var map_size: Vector2 = Vector2(1200, 800)
var tile_size: int = 32
var room_count_range: Vector2i = Vector2i(3, 7)
var corridor_width: int = 96

# Zone properties affect gameplay
var zone_effects = {
    ZoneType.PLAINS: {"movement_speed": 1.0, "spell_power": 1.0},
    ZoneType.FIRE_CAVES: {"fire_damage": 1.3, "ice_damage": 0.7, "heat_damage": 2.0},
    ZoneType.ICE_FIELDS: {"ice_damage": 1.3, "fire_damage": 0.7, "movement_speed": 0.8},
    ZoneType.POISON_SWAMPS: {"poison_chance": 0.3, "movement_speed": 0.6, "heal_reduction": 0.5},
    ZoneType.CRYSTAL_CAVERNS: {"spell_power": 1.2, "mana_regen": 1.5, "crystal_resonance": true},
    ZoneType.VOLCANIC_CHAMBER: {"fire_damage": 1.5, "explosion_radius": 1.3, "lava_hazards": true}
}

func generate_map(zone_type: ZoneType, room_type: RoomType, wave_number: int) -> Dictionary:
    var map_data = {
        "zone_type": zone_type,
        "room_type": room_type,
        "rooms": [],
        "walls": [],
        "destructible_objects": [],
        "hazards": [],
        "spawn_points": [],
        "player_spawn": Vector2.ZERO,
        "effects": zone_effects[zone_type]
    }
    
    match room_type:
        RoomType.OPEN_ARENA:
            _generate_open_arena(map_data, wave_number)
        RoomType.CORRIDOR_MAZE:
            _generate_corridor_maze(map_data, wave_number)
        RoomType.SCATTERED_ISLANDS:
            _generate_scattered_islands(map_data, wave_number)
        RoomType.CENTRAL_PLATFORM:
            _generate_central_platform(map_data, wave_number)
        RoomType.RING_FORMATION:
            _generate_ring_formation(map_data, wave_number)
    
    _add_zone_specific_features(map_data, zone_type, wave_number)
    _validate_map_layout(map_data)
    
    return map_data

func _generate_open_arena(map_data: Dictionary, wave: int):
    # Large open space with scattered cover
    var center = map_size / 2
    map_data.player_spawn = center
    
    # Add perimeter walls
    _add_boundary_walls(map_data)
    
    # Scatter destructible cover based on wave
    var cover_count = 5 + (wave / 3)  # More cover in later waves
    for i in cover_count:
        var pos = _random_position_with_clearance(center, 200)
        map_data.destructible_objects.append({
            "position": pos,
            "type": "rock_pile",
            "health": 50,
            "size": Vector2(64, 64)
        })
    
    # Enemy spawn points around perimeter
    _generate_perimeter_spawns(map_data, 8)

# ... additional generation methods
```

**Create `scripts/world/WorldManager.gd`** (Autoload):
```gdscript
extends Node

var current_map_data: Dictionary = {}
var current_zone_type: MapGenerator.ZoneType
var map_generator: MapGenerator
var world_root: Node2D

signal map_generated(map_data: Dictionary)
signal zone_effects_changed(effects: Dictionary)

func _ready():
    map_generator = MapGenerator.new()
    add_child(map_generator)

func generate_new_map(wave_number: int):
    # Vary zone type based on wave or player choice
    current_zone_type = _select_zone_for_wave(wave_number)
    var room_type = _select_room_type_for_wave(wave_number)
    
    current_map_data = map_generator.generate_map(current_zone_type, room_type, wave_number)
    
    # Apply zone effects to game systems
    _apply_zone_effects(current_map_data.effects)
    
    map_generated.emit(current_map_data)
    
    print("🗺️ Generated %s map with %s layout for wave %d" % [
        MapGenerator.ZoneType.keys()[current_zone_type],
        MapGenerator.RoomType.keys()[room_type], 
        wave_number
    ])

func _select_zone_for_wave(wave: int) -> MapGenerator.ZoneType:
    # Early waves: safer zones
    if wave <= 3:
        return [MapGenerator.ZoneType.PLAINS, MapGenerator.ZoneType.CRYSTAL_CAVERNS].pick_random()
    elif wave <= 7:
        return [MapGenerator.ZoneType.FIRE_CAVES, MapGenerator.ZoneType.ICE_FIELDS].pick_random()
    else:
        # Later waves: any zone including dangerous ones
        return MapGenerator.ZoneType.values().pick_random()

func _apply_zone_effects(effects: Dictionary):
    # Modify game systems based on zone
    if effects.has("movement_speed"):
        GameEvents.emit_zone_effect("movement_speed", effects.movement_speed)
    if effects.has("spell_power"):
        GameEvents.emit_zone_effect("spell_power", effects.spell_power)
    # ... other effects
    
    zone_effects_changed.emit(effects)
```

### **Afternoon (2 hours): Map Rendering System**

**Create `scripts/world/MapRenderer.gd`**:
```gdscript
extends Node2D
class_name MapRenderer

var tilemap: TileMap
var destructible_layer: Node2D
var hazard_layer: Node2D
var effect_layer: Node2D

var wall_texture: Texture2D
var floor_textures: Dictionary = {}
var destructible_textures: Dictionary = {}

func _ready():
    _setup_layers()
    _load_procedural_textures()
    
    # Connect to world manager
    if WorldManager:
        WorldManager.map_generated.connect(_on_map_generated)

func _setup_layers():
    # Base tilemap for floors and walls
    tilemap = TileMap.new()
    tilemap.tile_set = preload("res://data/procedural_tileset.tres")
    add_child(tilemap)
    
    # Layer for destructible objects
    destructible_layer = Node2D.new()
    destructible_layer.name = "DestructibleLayer"
    add_child(destructible_layer)
    
    # Layer for environmental hazards
    hazard_layer = Node2D.new()
    hazard_layer.name = "HazardLayer"
    add_child(hazard_layer)
    
    # Layer for visual effects
    effect_layer = Node2D.new()
    effect_layer.name = "EffectLayer"
    add_child(effect_layer)

func _on_map_generated(map_data: Dictionary):
    _clear_previous_map()
    _render_zone_background(map_data.zone_type)
    _render_walls(map_data.walls)
    _render_destructible_objects(map_data.destructible_objects)
    _render_hazards(map_data.hazards)
    _apply_zone_visual_effects(map_data.zone_type)

func _load_procedural_textures():
    # Generate textures for different zone types
    floor_textures[MapGenerator.ZoneType.PLAINS] = _generate_grass_texture()
    floor_textures[MapGenerator.ZoneType.FIRE_CAVES] = _generate_lava_texture()
    floor_textures[MapGenerator.ZoneType.ICE_FIELDS] = _generate_ice_texture()
    # ... etc
    
func _generate_grass_texture() -> ImageTexture:
    # Procedural grass texture generation
    var image = Image.create(32, 32, false, Image.FORMAT_RGB8)
    # ... procedural generation logic
    var texture = ImageTexture.new()
    texture.set_image(image)
    return texture

# ... additional rendering methods
```

---

## 📅 **DAY 2: ELEMENTAL ZONE SYSTEMS**

### **Morning (3 hours): Zone Effect Implementation**

**Enhance `GameEvents.gd` with zone events**:
```gdscript
# Add to GameEvents.gd
signal zone_effect_applied(effect_type: String, value: float)
signal environmental_damage(damage: float, type: String)
signal zone_changed(old_zone: String, new_zone: String)

func emit_zone_effect(effect_type: String, value: float):
    zone_effect_applied.emit(effect_type, value)
    UnifiedDebugSystem.log_info(UnifiedDebugSystem.LogCategory.GENERAL, 
        "Zone effect applied: %s = %.2f" % [effect_type, value], "ZoneSystem")

func emit_environmental_damage(damage: float, type: String):
    environmental_damage.emit(damage, type)
    UnifiedDebugSystem.log_debug(UnifiedDebugSystem.LogCategory.COMBAT,
        "Environmental damage: %.1f %s" % [damage, type], "Environment")
```

**Create `scripts/world/ZoneEffectManager.gd`**:
```gdscript
extends Node
class_name ZoneEffectManager

var active_effects: Dictionary = {}
var effect_timers: Dictionary = {}
var zone_particles: Dictionary = {}

signal effect_started(effect_name: String)
signal effect_ended(effect_name: String)

func _ready():
    # Connect to zone changes
    if WorldManager:
        WorldManager.zone_effects_changed.connect(_on_zone_effects_changed)
    
    # Connect to environmental events
    if GameEvents:
        GameEvents.zone_effect_applied.connect(_apply_zone_effect)

func _on_zone_effects_changed(effects: Dictionary):
    _clear_all_effects()
    
    for effect_type in effects:
        var value = effects[effect_type]
        _apply_zone_effect(effect_type, value)

func _apply_zone_effect(effect_type: String, value):
    match effect_type:
        "movement_speed":
            _modify_player_movement(value)
        "spell_power":
            _modify_spell_power(value)
        "fire_damage":
            _modify_elemental_damage("fire", value)
        "ice_damage":
            _modify_elemental_damage("ice", value)
        "poison_chance":
            _apply_poison_environment(value)
        "mana_regen":
            _modify_mana_regeneration(value)
        "heat_damage":
            _start_heat_damage_over_time(value)
        "lava_hazards":
            _activate_lava_hazards()
        "crystal_resonance":
            _activate_crystal_resonance()

func _modify_player_movement(multiplier: float):
    var player = GameManager.get_player()
    if player and player.has_method("set_movement_modifier"):
        player.set_movement_modifier(multiplier)
        active_effects["movement_speed"] = multiplier

func _modify_spell_power(multiplier: float):
    # Apply to spell component
    var player = GameManager.get_player()
    if player and player.has_node("SpellComponent"):
        var spell_comp = player.get_node("SpellComponent")
        if spell_comp.has_method("set_power_modifier"):
            spell_comp.set_power_modifier(multiplier)
            active_effects["spell_power"] = multiplier

func _start_heat_damage_over_time(damage_per_second: float):
    if effect_timers.has("heat_damage"):
        effect_timers["heat_damage"].queue_free()
    
    var timer = Timer.new()
    timer.wait_time = 1.0  # Every second
    timer.timeout.connect(func(): _deal_environmental_damage(damage_per_second, "heat"))
    add_child(timer)
    timer.start()
    effect_timers["heat_damage"] = timer

func _deal_environmental_damage(damage: float, type: String):
    var player = GameManager.get_player()
    if player and player.has_method("take_environmental_damage"):
        player.take_environmental_damage(damage, type)
        GameEvents.emit_environmental_damage(damage, type)

# ... additional effect methods
```

### **Afternoon (2 hours): Visual Zone Effects**

**Create `scripts/world/ZoneVisualEffects.gd`**:
```gdscript
extends Node2D
class_name ZoneVisualEffects

var particle_systems: Dictionary = {}
var ambient_effects: Dictionary = {}
var zone_lighting: Dictionary = {}

func _ready():
    if WorldManager:
        WorldManager.zone_effects_changed.connect(_apply_visual_effects)

func _apply_visual_effects(zone_type: MapGenerator.ZoneType):
    _clear_previous_effects()
    
    match zone_type:
        MapGenerator.ZoneType.FIRE_CAVES:
            _create_fire_ambiance()
        MapGenerator.ZoneType.ICE_FIELDS:
            _create_ice_ambiance()
        MapGenerator.ZoneType.POISON_SWAMPS:
            _create_poison_ambiance()
        MapGenerator.ZoneType.CRYSTAL_CAVERNS:
            _create_crystal_ambiance()
        MapGenerator.ZoneType.VOLCANIC_CHAMBER:
            _create_volcanic_ambiance()

func _create_fire_ambiance():
    # Floating fire particles
    var fire_particles = _create_particle_system("fire_ambient")
    fire_particles.amount = 50
    fire_particles.emission_rect_extents = Vector2(600, 400)
    fire_particles.gravity = Vector2(0, -20)
    # ... configure fire particle properties
    
    # Orange lighting overlay
    var lighting = ColorRect.new()
    lighting.color = Color(1.0, 0.6, 0.2, 0.1)
    lighting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(lighting)
    zone_lighting["fire"] = lighting

func _create_ice_ambiance():
    # Falling snow particles
    var snow_particles = _create_particle_system("snow_ambient")
    snow_particles.amount = 30
    snow_particles.gravity = Vector2(0, 50)
    # ... configure snow properties
    
    # Blue lighting overlay
    var lighting = ColorRect.new()
    lighting.color = Color(0.4, 0.7, 1.0, 0.08)
    lighting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(lighting)
    zone_lighting["ice"] = lighting

func _create_particle_system(name: String) -> GPUParticles2D:
    var particles = GPUParticles2D.new()
    particles.name = name
    add_child(particles)
    particle_systems[name] = particles
    return particles

# ... additional visual effect methods
```

---

## 📅 **DAY 3: DESTRUCTIBLE TERRAIN**

### **Morning (3 hours): Destructible Object System**

**Create `scripts/world/DestructibleObject.gd`**:
```gdscript
extends StaticBody2D
class_name DestructibleObject

@export var max_health: float = 100.0
@export var object_type: String = "rock_pile"
@export var drop_chance: float = 0.3
@export var debris_count: int = 5

var current_health: float
var is_destroyed: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: ProgressBar = $HealthBar

signal destroyed(object: DestructibleObject)
signal damaged(damage: float, health_remaining: float)

func _ready():
    collision_layer = 16  # Layer 5 for destructible objects
    collision_mask = 0    # Don't detect anything
    current_health = max_health
    
    # Hide health bar initially
    health_bar.visible = false
    health_bar.max_value = max_health
    health_bar.value = current_health
    
    # Generate procedural texture based on type
    _generate_texture_for_type()
    
    add_to_group("destructible_objects")

func _generate_texture_for_type():
    match object_type:
        "rock_pile":
            sprite.texture = _generate_rock_texture()
        "ice_wall":
            sprite.texture = _generate_ice_texture()
        "crystal_formation":
            sprite.texture = _generate_crystal_texture()
        "dead_tree":
            sprite.texture = _generate_tree_texture()

func take_damage(damage: float, damage_type: String = "physical") -> bool:
    if is_destroyed:
        return false
    
    # Some objects have resistances
    var actual_damage = _calculate_actual_damage(damage, damage_type)
    
    current_health -= actual_damage
    current_health = max(0, current_health)
    
    # Show health bar when damaged
    health_bar.visible = true
    health_bar.value = current_health
    
    # Visual damage feedback
    _show_damage_effect(actual_damage)
    
    damaged.emit(actual_damage, current_health)
    
    if current_health <= 0:
        _destroy_object()
        return true
    
    return false

func _calculate_actual_damage(damage: float, type: String) -> float:
    match object_type:
        "ice_wall":
            if type == "fire":
                return damage * 2.0  # Fire melts ice quickly
            elif type == "ice":
                return damage * 0.5  # Ice resists ice
        "crystal_formation":
            if type == "lightning":
                return damage * 1.5  # Lightning shatters crystal
        _:
            return damage

func _destroy_object():
    if is_destroyed:
        return
    
    is_destroyed = true
    
    # Create debris particles
    _create_destruction_effect()
    
    # Possibly drop items
    if randf() < drop_chance:
        _drop_loot()
    
    # Remove collision so projectiles pass through
    collision_shape.disabled = true
    
    # Fade out and remove
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    tween.tween_callback(queue_free)
    
    destroyed.emit(self)

func _create_destruction_effect():
    # Create debris particles
    for i in debris_count:
        var debris = _create_debris_piece()
        get_parent().add_child(debris)

func _create_debris_piece() -> RigidBody2D:
    var debris = RigidBody2D.new()
    var debris_sprite = Sprite2D.new()
    var debris_collision = CollisionShape2D.new()
    
    # Small piece of the original texture
    debris_sprite.texture = sprite.texture
    debris_sprite.scale = Vector2(0.3, 0.3)
    
    # Random shape for collision
    var shape = RectangleShape2D.new()
    shape.size = Vector2(8, 8)
    debris_collision.shape = shape
    
    debris.add_child(debris_sprite)
    debris.add_child(debris_collision)
    
    # Random position around destruction point
    debris.global_position = global_position + Vector2(
        randf_range(-32, 32),
        randf_range(-32, 32)
    )
    
    # Random velocity
    debris.linear_velocity = Vector2(
        randf_range(-200, 200),
        randf_range(-300, -100)
    )
    debris.angular_velocity = randf_range(-10, 10)
    
    # Auto-cleanup after a few seconds
    var cleanup_timer = Timer.new()
    cleanup_timer.wait_time = 3.0
    cleanup_timer.one_shot = true
    cleanup_timer.timeout.connect(debris.queue_free)
    debris.add_child(cleanup_timer)
    cleanup_timer.start()
    
    return debris

func _drop_loot():
    # Simple loot drop - expand in Phase 6
    var loot = preload("res://scenes/items/XPOrb.tscn").instantiate()
    loot.global_position = global_position
    get_parent().add_child(loot)

# ... texture generation methods
```

### **Afternoon (2 hours): Terrain Modification System**

**Create `scripts/world/TerrainModifier.gd`**:
```gdscript
extends Node
class_name TerrainModifier

var destructible_objects: Array[DestructibleObject] = []
var terrain_grid: Array = []  # 2D grid tracking terrain state
var grid_size: Vector2i
var cell_size: int = 32

signal terrain_modified(position: Vector2, radius: float)
signal path_created(start: Vector2, end: Vector2)

func _ready():
    # Connect to spell projectile impacts
    if GameEvents:
        GameEvents.spell_cast.connect(_on_spell_cast)

func initialize_terrain(map_data: Dictionary):
    # Set up terrain grid based on map size
    grid_size = Vector2i(map_data.map_size.x / cell_size, map_data.map_size.y / cell_size)
    terrain_grid = []
    
    for x in grid_size.x:
        terrain_grid.append([])
        for y in grid_size.y:
            terrain_grid[x].append({"passable": true, "object": null})
    
    # Register all destructible objects
    destructible_objects.clear()
    for obj_data in map_data.destructible_objects:
        _register_destructible_object(obj_data)

func modify_terrain_at_position(position: Vector2, radius: float, damage: float, damage_type: String = "explosion"):
    var affected_objects = _find_objects_in_radius(position, radius)
    
    for obj in affected_objects:
        if obj.has_method("take_damage"):
            var distance = position.distance_to(obj.global_position)
            var distance_factor = 1.0 - (distance / radius)
            var actual_damage = damage * distance_factor
            
            obj.take_damage(actual_damage, damage_type)
    
    terrain_modified.emit(position, radius)

func create_path_through_terrain(start: Vector2, end: Vector2, width: float):
    # Create a clear path by removing obstacles
    var direction = (end - start).normalized()
    var distance = start.distance_to(end)
    var steps = int(distance / cell_size)
    
    for i in steps:
        var current_pos = start + direction * (i * cell_size)
        var objects_in_path = _find_objects_in_radius(current_pos, width / 2)
        
        for obj in objects_in_path:
            if obj.has_method("take_damage"):
                obj.take_damage(999999, "terrain_modification")  # Instant destroy
    
    path_created.emit(start, end)

func _find_objects_in_radius(position: Vector2, radius: float) -> Array:
    var found_objects = []
    
    for obj in destructible_objects:
        if not is_instance_valid(obj) or obj.is_destroyed:
            continue
            
        var distance = position.distance_to(obj.global_position)
        if distance <= radius:
            found_objects.append(obj)
    
    return found_objects

func _register_destructible_object(obj_data: Dictionary):
    # This would be called when objects are spawned
    # Implementation depends on how objects are created in MapRenderer
    pass

func _on_spell_cast(spell_name: String, damage: float):
    # Some spells modify terrain
    match spell_name:
        "Fireball":
            # Fireball creates small explosion
            pass  # Handled by projectile impact
        "Earth_Slam":
            # Hypothetical earth spell that creates cracks
            pass
        "Lightning_Strike":
            # Lightning might shatter crystal formations
            pass

# Integration with spell projectiles
func handle_projectile_impact(position: Vector2, spell_data, damage: float):
    var explosion_radius = spell_data.get("explosion_radius", 50.0)
    var damage_type = spell_data.get("element_type", "physical")
    
    modify_terrain_at_position(position, explosion_radius, damage * 0.5, damage_type)
```

---

## 📅 **DAY 4: ENVIRONMENTAL HAZARDS**

### **Morning (3 hours): Hazard System Implementation**

**Create `scripts/world/EnvironmentalHazard.gd`**:
```gdscript
extends Area2D
class_name EnvironmentalHazard

enum HazardType { 
    LAVA_POOL, POISON_GAS, ICE_SPIKES, LIGHTNING_FIELD, 
    CRYSTAL_RESONANCE, FIRE_GEYSER, ACID_PUDDLE 
}

@export var hazard_type: HazardType
@export var damage_per_second: float = 10.0
@export var effect_duration: float = -1.0  # -1 = permanent
@export var trigger_delay: float = 0.0
@export var warning_duration: float = 1.0

var is_active: bool = false
var affected_entities: Array = []
var warning_phase: bool = false

@onready var visual_effect: Node2D = $VisualEffect
@onready var warning_effect: Node2D = $WarningEffect
@onready var damage_timer: Timer = $DamageTimer
@onready var effect_timer: Timer = $EffectTimer
@onready var trigger_timer: Timer = $TriggerTimer

signal hazard_triggered()
signal entity_entered_hazard(entity: Node)
signal entity_exited_hazard(entity: Node)
signal hazard_expired()

func _ready():
    collision_layer = 32  # Layer 6 for hazards
    collision_mask = 3    # Detect players (1) and enemies (2)
    
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    
    # Setup timers
    damage_timer.wait_time = 1.0  # Damage every second
    damage_timer.timeout.connect(_deal_damage_to_affected)
    
    if effect_duration > 0:
        effect_timer.wait_time = effect_duration
        effect_timer.one_shot = true
        effect_timer.timeout.connect(_expire_hazard)
    
    if trigger_delay > 0:
        trigger_timer.wait_time = trigger_delay
        trigger_timer.one_shot = true
        trigger_timer.timeout.connect(_trigger_hazard)
        _start_warning_phase()
    else:
        _trigger_hazard()

func _start_warning_phase():
    warning_phase = true
    warning_effect.visible = true
    visual_effect.visible = false
    
    # Warning animation
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(warning_effect, "modulate:a", 0.3, 0.2)
    tween.tween_property(warning_effect, "modulate:a", 1.0, 0.2)
    
    trigger_timer.start()

func _trigger_hazard():
    warning_phase = false
    is_active = true
    
    warning_effect.visible = false
    visual_effect.visible = true
    
    _apply_visual_effects()
    
    if damage_per_second > 0:
        damage_timer.start()
    
    if effect_duration > 0:
        effect_timer.start()
    
    hazard_triggered.emit()

func _apply_visual_effects():
    match hazard_type:
        HazardType.LAVA_POOL:
            _create_lava_effect()
        HazardType.POISON_GAS:
            _create_poison_effect()
        HazardType.ICE_SPIKES:
            _create_ice_spikes_effect()
        HazardType.LIGHTNING_FIELD:
            _create_lightning_effect()
        HazardType.FIRE_GEYSER:
            _create_fire_geyser_effect()

func _create_lava_effect():
    var particles = GPUParticles2D.new()
    particles.amount = 50
    # Configure lava bubble particles
    visual_effect.add_child(particles)
    
    # Orange glow
    var glow = ColorRect.new()
    glow.color = Color(1.0, 0.4, 0.0, 0.6)
    glow.size = Vector2(100, 100)
    glow.position = -glow.size / 2
    visual_effect.add_child(glow)

func _create_poison_effect():
    var particles = GPUParticles2D.new()
    particles.amount = 30
    # Configure poison gas particles
    visual_effect.add_child(particles)

func _on_body_entered(body: Node):
    if not is_active or warning_phase:
        return
    
    if body.is_in_group("players") or body.is_in_group("enemies"):
        affected_entities.append(body)
        entity_entered_hazard.emit(body)
        _apply_entry_effect(body)

func _on_body_exited(body: Node):
    if body in affected_entities:
        affected_entities.erase(body)
        entity_exited_hazard.emit(body)
        _remove_entry_effect(body)

func _deal_damage_to_affected():
    for entity in affected_entities:
        if not is_instance_valid(entity):
            continue
        
        _apply_hazard_damage(entity)

func _apply_hazard_damage(entity: Node):
    match hazard_type:
        HazardType.LAVA_POOL:
            _deal_fire_damage(entity, damage_per_second)
        HazardType.POISON_GAS:
            _deal_poison_damage(entity, damage_per_second)
        HazardType.ICE_SPIKES:
            _deal_ice_damage(entity, damage_per_second)
        HazardType.LIGHTNING_FIELD:
            _deal_lightning_damage(entity, damage_per_second)

func _deal_fire_damage(entity: Node, damage: float):
    if entity.has_method("take_environmental_damage"):
        entity.take_environmental_damage(damage, "fire")
    elif entity.has_method("take_damage"):
        entity.take_damage(damage)

func _deal_poison_damage(entity: Node, damage: float):
    # Poison damage over time effect
    if entity.has_method("apply_status_effect"):
        entity.apply_status_effect("poison", damage, 3.0)
    elif entity.has_method("take_environmental_damage"):
        entity.take_environmental_damage(damage, "poison")

func _apply_entry_effect(entity: Node):
    match hazard_type:
        HazardType.ICE_SPIKES:
            # Slow movement when on ice
            if entity.has_method("set_movement_modifier"):
                entity.set_movement_modifier(0.5)
        HazardType.LIGHTNING_FIELD:
            # Disrupt spellcasting
            if entity.has_method("set_casting_modifier"):
                entity.set_casting_modifier(1.5)  # 50% slower casting

func _remove_entry_effect(entity: Node):
    # Remove movement/casting modifiers
    if entity.has_method("reset_movement_modifier"):
        entity.reset_movement_modifier()
    if entity.has_method("reset_casting_modifier"):
        entity.reset_casting_modifier()

func _expire_hazard():
    is_active = false
    
    # Remove effects from all affected entities
    for entity in affected_entities:
        _remove_entry_effect(entity)
    
    affected_entities.clear()
    damage_timer.stop()
    
    # Fade out
    var tween = create_tween()
    tween.tween_property(visual_effect, "modulate:a", 0.0, 1.0)
    tween.tween_callback(queue_free)
    
    hazard_expired.emit()

# Static factory methods for creating hazards
static func create_lava_pool(position: Vector2, radius: float = 50.0) -> EnvironmentalHazard:
    var hazard = preload("res://scenes/world/EnvironmentalHazard.tscn").instantiate()
    hazard.hazard_type = HazardType.LAVA_POOL
    hazard.damage_per_second = 15.0
    hazard.global_position = position
    # Set collision shape size based on radius
    return hazard

static func create_poison_gas(position: Vector2, duration: float = 10.0) -> EnvironmentalHazard:
    var hazard = preload("res://scenes/world/EnvironmentalHazard.tscn").instantiate()
    hazard.hazard_type = HazardType.POISON_GAS
    hazard.damage_per_second = 8.0
    hazard.effect_duration = duration
    hazard.global_position = position
    return hazard

static func create_fire_geyser(position: Vector2, delay: float = 2.0) -> EnvironmentalHazard:
    var hazard = preload("res://scenes/world/EnvironmentalHazard.tscn").instantiate()
    hazard.hazard_type = HazardType.FIRE_GEYSER
    hazard.damage_per_second = 25.0
    hazard.trigger_delay = delay
    hazard.warning_duration = 1.5
    hazard.effect_duration = 3.0
    hazard.global_position = position
    return hazard
```

### **Afternoon (2 hours): Hazard Integration with Map Generation**

**Enhance `MapGenerator.gd` with hazard placement**:
```gdscript
# Add to MapGenerator.gd

func _add_zone_specific_features(map_data: Dictionary, zone_type: ZoneType, wave: int):
    match zone_type:
        ZoneType.FIRE_CAVES:
            _add_lava_hazards(map_data, wave)
        ZoneType.ICE_FIELDS:
            _add_ice_hazards(map_data, wave)
        ZoneType.POISON_SWAMPS:
            _add_poison_hazards(map_data, wave)
        ZoneType.VOLCANIC_CHAMBER:
            _add_volcanic_hazards(map_data, wave)

func _add_lava_hazards(map_data: Dictionary, wave: int):
    var hazard_count = 2 + (wave / 4)  # More hazards in later waves
    
    for i in hazard_count:
        var position = _random_position_with_clearance(map_data.player_spawn, 150)
        map_data.hazards.append({
            "type": "lava_pool",
            "position": position,
            "radius": randf_range(40, 70),
            "damage": 12.0 + (wave * 1.5)
        })

func _add_volcanic_hazards(map_data: Dictionary, wave: int):
    # Mix of permanent lava pools and fire geysers
    _add_lava_hazards(map_data, wave)
    
    var geyser_count = 1 + (wave / 5)
    for i in geyser_count:
        var position = _random_position_with_clearance(map_data.player_spawn, 200)
        map_data.hazards.append({
            "type": "fire_geyser", 
            "position": position,
            "damage": 20.0 + (wave * 2.0),
            "trigger_delay": randf_range(3.0, 8.0),
            "duration": 4.0
        })

func _add_ice_hazards(map_data: Dictionary, wave: int):
    var spike_count = 3 + (wave / 3)
    
    for i in spike_count:
        var position = _random_position_with_clearance(map_data.player_spawn, 120)
        map_data.hazards.append({
            "type": "ice_spikes",
            "position": position,
            "damage": 8.0 + wave,
            "slow_effect": 0.6 - (wave * 0.02)  # Stronger slow in later waves
        })

func _add_poison_hazards(map_data: Dictionary, wave: int):
    var gas_count = 2 + (wave / 4)
    
    for i in gas_count:
        var position = _random_position_with_clearance(map_data.player_spawn, 180)
        map_data.hazards.append({
            "type": "poison_gas",
            "position": position,
            "damage": 6.0 + (wave * 0.8),
            "duration": 15.0 + wave  # Longer lasting in later waves
        })
```

---

## 📅 **DAY 5: INTEGRATION & ENVIRONMENTAL INTERACTIONS**

### **Morning (3 hours): Spell-Environment Interactions**

**Enhance `SpellProjectile.gd` for environmental interaction**:
```gdscript
# Add to SpellProjectile.gd

func _on_body_entered(body: Node):
    if not is_instance_valid(body):
        return
    
    if body.is_in_group("enemies"):
        _hit_enemy(body)
    elif body.collision_layer == 4:  # Environment layer
        _hit_environment()
    elif body.is_in_group("destructible_objects"):
        _hit_destructible_object(body)
    else:
        print("🔍 Projectile hit unhandled body type: " + body.name + " on layer " + str(body.collision_layer))

func _hit_destructible_object(object: Node):
    if object.has_method("take_damage"):
        var damage_to_terrain = damage * 0.5  # Reduced damage to environment
        var element_type = spell_data.get("element_type", "physical") if spell_data else "physical"
        
        object.take_damage(damage_to_terrain, element_type)
        
        # Create enhanced impact effect based on spell type
        _create_environmental_impact_effect(object.global_position, element_type)
    
    _destroy_projectile()

func _create_environmental_impact_effect(position: Vector2, element_type: String):
    match element_type:
        "fire":
            _create_fire_explosion(position)
            # Fire spells might ignite flammable objects
            _try_ignite_nearby_objects(position, 80.0)
        "ice":
            _create_ice_shatter(position)
            # Ice spells might freeze water or slow nearby enemies
            _try_freeze_nearby_objects(position, 60.0)
        "lightning":
            _create_lightning_burst(position)
            # Lightning might chain to nearby metal objects
            _try_chain_lightning(position, 100.0)
        "poison":
            _create_poison_cloud(position)
            # Poison might create lingering gas cloud
            _create_poison_gas_hazard(position)
        _:
            _create_generic_impact(position)

func _try_ignite_nearby_objects(position: Vector2, radius: float):
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    var circle_shape = CircleShape2D.new()
    circle_shape.radius = radius
    query.shape = circle_shape
    query.transform.origin = position
    query.collision_mask = 16  # Destructible objects layer
    
    var nearby_objects = space_state.intersect_shape(query)
    for collision in nearby_objects:
        var object = collision.collider
        if object.has_method("ignite"):
            object.ignite()

func _create_fire_explosion(position: Vector2):
    # Create fire explosion particle effect
    var explosion = preload("res://scenes/effects/FireExplosion.tscn").instantiate()
    get_parent().add_child(explosion)
    explosion.global_position = position
    
    # Screen shake for big explosions
    if spell_data and spell_data.spell_name == "Fireball":
        GameEvents.emit_screen_shake(0.3, 1.5)

func _create_poison_gas_hazard(position: Vector2):
    # Create temporary poison gas hazard
    var gas_hazard = EnvironmentalHazard.create_poison_gas(position, 8.0)
    get_parent().add_child(gas_hazard)
```

**Create `scripts/world/EnvironmentalInteraction.gd`**:
```gdscript
extends Node
class_name EnvironmentalInteraction

var active_interactions: Dictionary = {}

signal elemental_reaction(reaction_type: String, position: Vector2)
signal chain_reaction_started(start_pos: Vector2, positions: Array)

func _ready():
    # Connect to spell events
    if GameEvents:
        GameEvents.spell_cast.connect(_on_spell_cast)

func handle_spell_environment_interaction(spell_element: String, position: Vector2, power: float):
    match spell_element:
        "fire":
            _handle_fire_interactions(position, power)
        "ice":
            _handle_ice_interactions(position, power)
        "lightning":
            _handle_lightning_interactions(position, power)
        "poison":
            _handle_poison_interactions(position, power)

func _handle_fire_interactions(position: Vector2, power: float):
    # Fire + Ice = Steam explosion
    if _check_for_ice_nearby(position, 100.0):
        _create_steam_explosion(position, power)
    
    # Fire + Poison = Toxic explosion
    if _check_for_poison_nearby(position, 80.0):
        _create_toxic_explosion(position, power)
    
    # Fire + Flammable objects = Spreading fire
    _ignite_flammable_objects(position, 60.0)

func _handle_ice_interactions(position: Vector2, power: float):
    # Ice + Fire = Steam (handled in fire interactions)
    
    # Ice + Water = Freeze area
    if _check_for_water_nearby(position, 80.0):
        _create_freeze_area(position, power)
    
    # Ice + Lightning = Conductive ice
    if _check_for_lightning_nearby(position, 70.0):
        _create_conductive_ice(position, power)

func _handle_lightning_interactions(position: Vector2, power: float):
    # Lightning + Metal objects = Chain lightning
    var metal_objects = _find_metal_objects_nearby(position, 120.0)
    if metal_objects.size() > 0:
        _create_chain_lightning(position, metal_objects, power)
    
    # Lightning + Water = Electrified area
    if _check_for_water_nearby(position, 100.0):
        _create_electrified_water(position, power)

func _create_steam_explosion(position: Vector2, power: float):
    # Create steam cloud that blinds and damages
    var steam_hazard = EnvironmentalHazard.new()
    steam_hazard.hazard_type = EnvironmentalHazard.HazardType.POISON_GAS  # Reuse gas type
    steam_hazard.damage_per_second = power * 0.3
    steam_hazard.effect_duration = 6.0
    steam_hazard.global_position = position
    
    get_parent().add_child(steam_hazard)
    
    # Visual steam effect
    var steam_particles = preload("res://scenes/effects/SteamCloud.tscn").instantiate()
    get_parent().add_child(steam_particles)
    steam_particles.global_position = position
    
    elemental_reaction.emit("steam_explosion", position)

func _create_chain_lightning(start_pos: Vector2, targets: Array, power: float):
    var current_pos = start_pos
    var chain_positions = [start_pos]
    
    for target in targets:
        if targets.size() > 3:  # Limit chain length
            break
        
        # Create lightning arc visual
        _create_lightning_arc(current_pos, target.global_position)
        
        # Damage target
        if target.has_method("take_damage"):
            target.take_damage(power * 0.7)  # Reduced damage for chained lightning
        
        chain_positions.append(target.global_position)
        current_pos = target.global_position
    
    chain_reaction_started.emit(start_pos, chain_positions)

func _check_for_ice_nearby(position: Vector2, radius: float) -> bool:
    # Check for ice hazards or recent ice spell effects
    return _check_for_element_nearby(position, radius, "ice")

func _check_for_element_nearby(position: Vector2, radius: float, element: String) -> bool:
    # Check recent spell impacts for elemental interactions
    if active_interactions.has(element):
        for interaction_pos in active_interactions[element]:
            if position.distance_to(interaction_pos.position) <= radius:
                if Time.get_ticks_msec() - interaction_pos.timestamp < 3000:  # 3 second window
                    return true
    return false

func register_elemental_impact(element: String, position: Vector2):
    # Register spell impact for potential interactions
    if not active_interactions.has(element):
        active_interactions[element] = []
    
    active_interactions[element].append({
        "position": position,
        "timestamp": Time.get_ticks_msec()
    })
    
    # Clean up old interactions
    _cleanup_old_interactions(element)

func _cleanup_old_interactions(element: String):
    if not active_interactions.has(element):
        return
    
    var current_time = Time.get_ticks_msec()
    active_interactions[element] = active_interactions[element].filter(
        func(interaction): return current_time - interaction.timestamp < 5000
    )
```

### **Afternoon (2 hours): Performance Optimization**

**Create `scripts/world/WorldOptimizer.gd`**:
```gdscript
extends Node
class_name WorldOptimizer

var object_pool: Dictionary = {}
var max_active_particles: int = 100
var max_active_debris: int = 50
var current_particle_count: int = 0
var current_debris_count: int = 0

var performance_budget: Dictionary = {
    "particle_systems": 15,
    "destruction_effects": 8,
    "environmental_hazards": 12,
    "terrain_modifications": 5
}

signal performance_warning(system: String, usage: float)

func _ready():
    # Set up object pools
    _initialize_object_pools()
    
    # Start performance monitoring
    var monitor_timer = Timer.new()
    monitor_timer.wait_time = 2.0
    monitor_timer.timeout.connect(_monitor_performance)
    add_child(monitor_timer)
    monitor_timer.start()

func _initialize_object_pools():
    # Pre-create reusable objects to avoid runtime allocation
    object_pool["debris"] = []
    object_pool["particles"] = []
    object_pool["damage_numbers"] = []
    
    # Pre-allocate debris pieces
    for i in 20:
        var debris = _create_pooled_debris()
        debris.visible = false
        debris.process_mode = Node.PROCESS_MODE_DISABLED
        add_child(debris)
        object_pool["debris"].append(debris)

func get_pooled_debris() -> RigidBody2D:
    if current_debris_count >= max_active_debris:
        return null
    
    for debris in object_pool["debris"]:
        if not debris.visible:
            debris.visible = true
            debris.process_mode = Node.PROCESS_MODE_INHERIT
            current_debris_count += 1
            return debris
    
    # Pool exhausted, create new one if under budget
    if object_pool["debris"].size() < max_active_debris:
        var new_debris = _create_pooled_debris()
        add_child(new_debris)
        object_pool["debris"].append(new_debris)
        current_debris_count += 1
        return new_debris
    
    return null

func return_debris_to_pool(debris: RigidBody2D):
    debris.visible = false
    debris.process_mode = Node.PROCESS_MODE_DISABLED
    debris.linear_velocity = Vector2.ZERO
    debris.angular_velocity = 0.0
    current_debris_count -= 1

func _create_pooled_debris() -> RigidBody2D:
    var debris = RigidBody2D.new()
    var sprite = Sprite2D.new()
    var collision = CollisionShape2D.new()
    
    sprite.texture = preload("res://textures/debris_piece.png")  # Small debris texture
    collision.shape = preload("res://shapes/debris_shape.tres")   # Small rectangle shape
    
    debris.add_child(sprite)
    debris.add_child(collision)
    
    return debris

func _monitor_performance():
    var particle_count = _count_active_particles()
    var hazard_count = _count_active_hazards()
    var destructible_count = _count_active_destructibles()
    
    # Check if we're exceeding performance budgets
    if particle_count > performance_budget.particle_systems:
        performance_warning.emit("particle_systems", float(particle_count) / performance_budget.particle_systems)
        _optimize_particle_systems()
    
    if hazard_count > performance_budget.environmental_hazards:
        performance_warning.emit("environmental_hazards", float(hazard_count) / performance_budget.environmental_hazards)
        _optimize_hazards()

func _count_active_particles() -> int:
    var count = 0
    var particles = get_tree().get_nodes_in_group("particle_effects")
    for particle in particles:
        if particle.visible and particle.emitting:
            count += 1
    return count

func _optimize_particle_systems():
    # Reduce quality of distant particle effects
    var player_pos = GameManager.get_player_position()
    var particles = get_tree().get_nodes_in_group("particle_effects")
    
    for particle in particles:
        var distance = player_pos.distance_to(particle.global_position)
        if distance > 400:  # Far from player
            if particle.has_method("set_quality"):
                particle.set_quality(0.5)  # Reduce particle count

func _optimize_hazards():
    # Disable hazards that are far from player and not immediately threatening
    var player_pos = GameManager.get_player_position()
    var hazards = get_tree().get_nodes_in_group("environmental_hazards")
    
    for hazard in hazards:
        var distance = player_pos.distance_to(hazard.global_position)
        if distance > 500 and not hazard.has_affected_entities():
            hazard.set_optimization_mode(true)  # Reduce update frequency

# Culling system for objects outside view
func cull_invisible_objects():
    var viewport_rect = get_viewport().get_visible_rect()
    var camera = get_viewport().get_camera_2d()
    
    if not camera:
        return
    
    var camera_pos = camera.global_position
    var cull_distance = 800.0  # Cull objects beyond this distance
    
    # Cull destructible objects
    for obj in get_tree().get_nodes_in_group("destructible_objects"):
        var distance = camera_pos.distance_to(obj.global_position)
        if distance > cull_distance:
            obj.visible = false
            obj.process_mode = Node.PROCESS_MODE_DISABLED
        else:
            obj.visible = true
            obj.process_mode = Node.PROCESS_MODE_INHERIT
```

---

## 📅 **DAY 6: POLISH & INTEGRATION TESTING**

### **Morning (2 hours): Visual Polish**

**Create enhanced visual effects for zones**:

**Enhanced `ZoneVisualEffects.gd`**:
```gdscript
# Add advanced visual effects

func _create_fire_ambiance():
    # Floating fire particles
    var fire_particles = _create_particle_system("fire_ambient")
    fire_particles.amount = 50
    fire_particles.emission_rect_extents = Vector2(600, 400)
    fire_particles.gravity = Vector2(0, -20)
    fire_particles.scale_amount_min = 0.8
    fire_particles.scale_amount_max = 1.2
    
    # Configure fire particle material
    var material = ParticleProcessMaterial.new()
    material.direction = Vector3(0, -1, 0)
    material.initial_velocity_min = 30.0
    material.initial_velocity_max = 60.0
    material.gravity = Vector3(0, -20, 0)
    material.scale_min = 0.5
    material.scale_max = 1.5
    fire_particles.process_material = material
    
    # Fire texture
    fire_particles.texture = _generate_fire_particle_texture()
    
    # Orange lighting overlay with flickering
    var lighting = ColorRect.new()
    lighting.color = Color(1.0, 0.6, 0.2, 0.1)
    lighting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(lighting)
    zone_lighting["fire"] = lighting
    
    # Animate lighting flicker
    var flicker_tween = create_tween()
    flicker_tween.set_loops()
    flicker_tween.tween_property(lighting, "color:a", 0.05, 0.8)
    flicker_tween.tween_property(lighting, "color:a", 0.15, 0.8)
    
    # Heat shimmer effect
    var shimmer_shader = preload("res://shaders/HeatShimmer.gdshader")
    var shimmer_material = ShaderMaterial.new()
    shimmer_material.shader = shimmer_shader
    lighting.material = shimmer_material

func _generate_fire_particle_texture() -> ImageTexture:
    var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
    
    for x in 16:
        for y in 16:
            var distance_from_center = Vector2(x - 8, y - 8).length()
            var alpha = 1.0 - (distance_from_center / 8.0)
            alpha = clampf(alpha, 0.0, 1.0)
            
            # Fire colors (red to yellow to orange)
            var color: Color
            if alpha > 0.7:
                color = Color.YELLOW
            elif alpha > 0.4:
                color = Color.ORANGE
            else:
                color = Color.RED
            
            color.a = alpha
            image.set_pixel(x, y, color)
    
    var texture = ImageTexture.new()
    texture.set_image(image)
    return texture

func _create_advanced_ice_ambiance():
    # Falling snow with wind
    var snow_particles = _create_particle_system("snow_ambient")
    snow_particles.amount = 80
    snow_particles.gravity = Vector2(5, 50)  # Wind effect
    
    # Ice crystals that sparkle
    var crystal_particles = _create_particle_system("ice_crystals")
    crystal_particles.amount = 20
    crystal_particles.gravity = Vector2(0, 0)
    
    # Blue lighting with cold breath effect
    var lighting = ColorRect.new()
    lighting.color = Color(0.4, 0.7, 1.0, 0.08)
    lighting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(lighting)
    zone_lighting["ice"] = lighting
    
    # Frost overlay on screen edges
    var frost_overlay = preload("res://effects/FrostOverlay.tscn").instantiate()
    add_child(frost_overlay)
```

**Create shader effects for environmental atmosphere**:

**`shaders/HeatShimmer.gdshader`**:
```glsl
shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.1) = 0.02;
uniform float speed : hint_range(0.1, 2.0) = 1.0;

void fragment() {
    vec2 distorted_uv = UV;
    distorted_uv.x += sin(UV.y * 20.0 + TIME * speed) * strength;
    distorted_uv.y += cos(UV.x * 15.0 + TIME * speed * 0.8) * strength * 0.5;
    
    COLOR = texture(TEXTURE, distorted_uv);
}
```

### **Afternoon (3 hours): Integration Testing & Bug Fixes**

**Create comprehensive test suite**:

**`scripts/test/WorldGenerationTests.gd`**:
```gdscript
extends Node
class_name WorldGenerationTests

var test_results: Dictionary = {}

func run_all_tests() -> Dictionary:
    print("🧪 Starting World Generation Test Suite...")
    
    test_results.clear()
    
    # Core generation tests
    test_results["map_generation"] = _test_map_generation()
    test_results["zone_effects"] = _test_zone_effects()
    test_results["destructible_objects"] = _test_destructible_objects()
    test_results["environmental_hazards"] = _test_environmental_hazards()
    test_results["spell_interactions"] = _test_spell_environment_interactions()
    test_results["performance"] = _test_performance_metrics()
    
    _print_test_summary()
    return test_results

func _test_map_generation() -> bool:
    print("  Testing map generation...")
    
    var map_gen = MapGenerator.new()
    
    # Test each zone type
    for zone_type in MapGenerator.ZoneType.values():
        for room_type in MapGenerator.RoomType.values():
            var map_data = map_gen.generate_map(zone_type, room_type, 1)
            
            # Validate map data structure
            if not _validate_map_data(map_data):
                print("    ❌ Failed: Invalid map data for zone %d, room %d" % [zone_type, room_type])
                return false
    
    print("    ✅ Map generation working for all zone/room combinations")
    return true

func _validate_map_data(map_data: Dictionary) -> bool:
    var required_keys = ["zone_type", "room_type", "rooms", "walls", "destructible_objects", "hazards", "spawn_points", "player_spawn", "effects"]
    
    for key in required_keys:
        if not map_data.has(key):
            return false
    
    # Validate player spawn is within map bounds
    if map_data.player_spawn == Vector2.ZERO:
        return false
    
    # Validate spawn points exist
    if map_data.spawn_points.size() == 0:
        return false
    
    return true

func _test_zone_effects() -> bool:
    print("  Testing zone effects...")
    
    var effect_manager = ZoneEffectManager.new()
    add_child(effect_manager)
    
    # Test each zone effect
    var test_effects = {
        "movement_speed": 0.8,
        "spell_power": 1.3,
        "fire_damage": 1.5,
        "ice_damage": 0.7
    }
    
    for effect_type in test_effects:
        var value = test_effects[effect_type]
        effect_manager._apply_zone_effect(effect_type, value)
        
        # Verify effect was applied
        if not effect_manager.active_effects.has(effect_type):
            print("    ❌ Failed: Effect %s not applied" % effect_type)
            effect_manager.queue_free()
            return false
    
    effect_manager.queue_free()
    print("    ✅ Zone effects applying correctly")
    return true

func _test_destructible_objects() -> bool:
    print("  Testing destructible objects...")
    
    # Create test destructible object
    var test_obj = preload("res://scenes/world/DestructibleObject.tscn").instantiate()
    add_child(test_obj)
    test_obj.max_health = 100.0
    test_obj.object_type = "rock_pile"
    
    # Test damage system
    var initial_health = test_obj.current_health
    var damage_dealt = test_obj.take_damage(30.0, "fire")
    
    if test_obj.current_health != initial_health - 30.0:
        print("    ❌ Failed: Damage not applied correctly")
        test_obj.queue_free()
        return false
    
    # Test destruction
    test_obj.take_damage(100.0, "physical")
    if not test_obj.is_destroyed:
        print("    ❌ Failed: Object not destroyed when health reaches 0")
        test_obj.queue_free()
        return false
    
    test_obj.queue_free()
    print("    ✅ Destructible objects working correctly")
    return true

func _test_environmental_hazards() -> bool:
    print("  Testing environmental hazards...")
    
    # Test hazard creation
    var lava_hazard = EnvironmentalHazard.create_lava_pool(Vector2.ZERO, 50.0)
    add_child(lava_hazard)
    
    # Verify hazard properties
    if lava_hazard.hazard_type != EnvironmentalHazard.HazardType.LAVA_POOL:
        print("    ❌ Failed: Hazard type not set correctly")
        lava_hazard.queue_free()
        return false
    
    # Test immediate activation
    if not lava_hazard.is_active:
        print("    ❌ Failed: Hazard not activated immediately")
        lava_hazard.queue_free()
        return false
    
    lava_hazard.queue_free()
    print("    ✅ Environmental hazards working correctly")
    return true

func _test_spell_environment_interactions() -> bool:
    print("  Testing spell-environment interactions...")
    
    var interaction_system = EnvironmentalInteraction.new()
    add_child(interaction_system)
    
    # Test elemental registration
    interaction_system.register_elemental_impact("fire", Vector2(100, 100))
    interaction_system.register_elemental_impact("ice", Vector2(120, 120))
    
    # Verify interactions are tracked
    if not interaction_system.active_interactions.has("fire"):
        print("    ❌ Failed: Fire interaction not registered")
        interaction_system.queue_free()
        return false
    
    interaction_system.queue_free()
    print("    ✅ Spell-environment interactions working correctly")
    return true

func _test_performance_metrics() -> bool:
    print("  Testing performance metrics...")
    
    var optimizer = WorldOptimizer.new()
    add_child(optimizer)
    
    # Test object pooling
    var debris1 = optimizer.get_pooled_debris()
    var debris2 = optimizer.get_pooled_debris()
    
    if not debris1 or not debris2:
        print("    ❌ Failed: Object pooling not working")
        optimizer.queue_free()
        return false
    
    # Test return to pool
    optimizer.return_debris_to_pool(debris1)
    if debris1.visible:
        print("    ❌ Failed: Object not properly returned to pool")
        optimizer.queue_free()
        return false
    
    optimizer.queue_free()
    print("    ✅ Performance optimization working correctly")
    return true

func _print_test_summary():
    print("\n📊 World Generation Test Results:")
    var passed = 0
    var total = test_results.size()
    
    for test_name in test_results:
        var result = test_results[test_name]
        var status = "✅ PASS" if result else "❌ FAIL"
        print("  %s: %s" % [test_name, status])
        if result:
            passed += 1
    
    print("\n🎯 Summary: %d/%d tests passed (%.1f%%)" % [passed, total, (float(passed) / total) * 100])
    
    if passed == total:
        print("🎉 All tests passed! World generation system is ready.")
    else:
        print("⚠️ Some tests failed. Review and fix issues before proceeding.")
```

---

## 🎯 **PHASE 5 SUCCESS CRITERIA CHECKLIST**

### **Core Features**:
- [ ] 5+ distinct zone types (Plains, Fire Caves, Ice Fields, Poison Swamps, Crystal Caverns, Volcanic Chamber)
- [ ] Each zone has unique gameplay effects (movement speed, spell power, elemental damage modifiers)
- [ ] Destructible terrain with visual debris and loot drops
- [ ] Environmental hazards that affect combat (lava pools, poison gas, ice spikes, fire geysers)
- [ ] Spell-environment interactions (fire melts ice, lightning chains through metal)

### **Visual Quality**:
- [ ] Zone-specific visual effects (particle systems, lighting overlays)
- [ ] Destructible object animations and debris
- [ ] Environmental hazard warning and activation effects
- [ ] Smooth transitions between different zone types
- [ ] Performance-optimized particle effects

### **Technical Requirements**:
- [ ] Map generation creates varied, interesting layouts
- [ ] Performance remains stable (60 FPS) with all systems active
- [ ] Object pooling prevents memory leaks
- [ ] Culling system manages off-screen objects
- [ ] All systems integrate cleanly with existing wave mechanics

### **Integration**:
- [ ] Wave system spawns enemies appropriate to zone type
- [ ] Player movement and spells work correctly in all zones
- [ ] Zone effects properly modify existing game systems
- [ ] Save/load system preserves zone state if needed
- [ ] UI displays zone information and effects to player

---

## 🔄 **INTEGRATION WITH EXISTING SYSTEMS**

### **Modified Files**:
- `GameEvents.gd` - Add zone and environmental events
- `Player.gd` - Add environmental damage handling and movement modifiers  
- `SpellProjectile.gd` - Add environmental interaction logic
- `Main.tscn` - Add WorldManager and map rendering nodes
- `WaveManager.gd` - Integrate with zone-based enemy spawning

### **New Autoloads**:
- `WorldManager` - Core world generation coordination
- `ZoneEffectManager` - Handle zone effect application

### **Performance Considerations**:
- Object pooling for debris and particle effects
- Culling system for off-screen objects
- Performance monitoring and automatic optimization
- Configurable quality settings for lower-end hardware

---

This comprehensive plan transforms your static combat into a dynamic, ever-changing battlefield where the environment is as much a part of the strategy as spells and movement. The procedural generation ensures no two sessions feel the same, while the elemental interactions create emergent gameplay opportunities.

Ready to begin Day 1 with the map generation foundation?