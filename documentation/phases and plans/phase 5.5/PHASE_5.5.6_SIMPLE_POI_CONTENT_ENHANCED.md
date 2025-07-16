# Phase 5.5.6: Simple POI Content - ENHANCED VISUAL SYSTEMS

## Overview
**Goal**: Create visually stunning, biome-integrated POI structures with maximum procedural detail
**Timeline**: 4-5 days (enhanced from 2-3 days)
**Dependencies**: Phase 5.5.5 (enhanced smart loading) must be complete
**Priority**: High - Visual content that makes the world feel alive

## ENHANCED VISION: PRODUCTION-QUALITY POI SYSTEM
**Focus**: Each POI should look hand-crafted while being fully procedural
**Key Innovation**: Multi-part structures with environmental integration
**Visual Target**: Rival commercial 2D game POI quality

## Current State Analysis
- SimpleChunkRenderer has basic POI placement system
- POIs are simple colored rectangles with minimal variety
- No biome-specific content or visual integration
- No animated elements or environmental effects
- Massive potential for visual enhancement

---

## Implementation Plan

### **Day 1-2: Advanced POI Structure System**

#### 1. Enhanced POI Architecture
**Create new file**: `scripts/world/POIStructureSystem.gd`

```gdscript
extends RefCounted
class_name POIStructureSystem

enum POIType {
    CRYSTAL_FORMATION,      # Ice Fields - Crystalline structures
    LAVA_VENT,             # Fire Caves - Volcanic features
    ANCIENT_RUINS,         # Wastelands - Mysterious structures
    MYSTICAL_GROVE,        # Enchanted Forest - Magical trees
    TOXIC_POOL,            # Poison Swamps - Bubbling hazards
    WINDSWEPT_MONUMENT,    # Windy Peaks - Stone formations
    FERTILE_OASIS,         # Plains - Life-giving springs
    VOID_TEAR              # Void Regions - Reality distortions
}

class POIStructure:
    var type: POIType
    var scale: float
    var primary_color: Color
    var accent_color: Color
    var animation_speed: float
    var complexity_level: int
    var environmental_effects: Array[String]
    
    func _init(poi_type: POIType, base_scale: float):
        type = poi_type
        scale = base_scale * (0.8 + randf() * 0.4)  # 80%-120% size variation
        complexity_level = 1 + randi() % 3  # 1-3 complexity levels
        animation_speed = 0.5 + randf() * 1.5  # Variable animation speed
        _generate_colors()
        _determine_effects()
    
    func _generate_colors():
        """Generate biome-appropriate colors"""
        match type:
            POIType.CRYSTAL_FORMATION:
                primary_color = Color(0.7, 0.9, 1.0, 0.9)  # Ice blue
                accent_color = Color(0.9, 0.95, 1.0, 0.7)  # Light blue
            POIType.LAVA_VENT:
                primary_color = Color(1.0, 0.3, 0.0, 1.0)  # Lava red
                accent_color = Color(1.0, 0.7, 0.0, 0.9)   # Orange glow
            POIType.ANCIENT_RUINS:
                primary_color = Color(0.6, 0.5, 0.4, 1.0)  # Weathered stone
                accent_color = Color(0.3, 0.6, 0.8, 0.5)   # Mysterious blue
            POIType.MYSTICAL_GROVE:
                primary_color = Color(0.2, 0.8, 0.3, 1.0)  # Vibrant green
                accent_color = Color(0.9, 0.9, 0.5, 0.8)   # Golden glow
            POIType.TOXIC_POOL:
                primary_color = Color(0.5, 0.8, 0.2, 1.0)  # Sickly green
                accent_color = Color(0.8, 0.9, 0.3, 0.6)   # Toxic yellow
            POIType.WINDSWEPT_MONUMENT:
                primary_color = Color(0.7, 0.7, 0.6, 1.0)  # Weathered gray
                accent_color = Color(0.5, 0.7, 0.9, 0.4)   # Sky blue
            POIType.FERTILE_OASIS:
                primary_color = Color(0.3, 0.7, 0.9, 0.8)  # Clear water
                accent_color = Color(0.4, 0.8, 0.3, 1.0)   # Lush green
            POIType.VOID_TEAR:
                primary_color = Color(0.1, 0.0, 0.2, 0.9)  # Dark purple
                accent_color = Color(0.6, 0.2, 0.8, 0.7)   # Void purple

func create_poi_structure(poi_type: POIType, world_position: Vector2, scale: float, biome_influences: Dictionary) -> Node2D:
    """Create a complete POI structure with all visual elements"""
    var structure = POIStructure.new(poi_type, scale)
    var poi_node = Node2D.new()
    poi_node.position = world_position
    
    # Create base structure
    var base_structure = _create_base_structure(structure)
    poi_node.add_child(base_structure)
    
    # Add detail layers
    var detail_layer = _create_detail_layer(structure, biome_influences)
    poi_node.add_child(detail_layer)
    
    # Add animated elements
    var animation_layer = _create_animation_layer(structure)
    poi_node.add_child(animation_layer)
    
    # Add environmental integration
    var environment_layer = _create_environment_layer(structure, biome_influences)
    poi_node.add_child(environment_layer)
    
    # Add particle effects
    var particle_layer = _create_particle_layer(structure)
    poi_node.add_child(particle_layer)
    
    return poi_node

func _create_base_structure(structure: POIStructure) -> Node2D:
    """Create the main structural elements"""
    var base = Node2D.new()
    
    match structure.type:
        POIType.CRYSTAL_FORMATION:
            return _create_crystal_formation(structure)
        POIType.LAVA_VENT:
            return _create_lava_vent(structure)
        POIType.ANCIENT_RUINS:
            return _create_ancient_ruins(structure)
        POIType.MYSTICAL_GROVE:
            return _create_mystical_grove(structure)
        POIType.TOXIC_POOL:
            return _create_toxic_pool(structure)
        POIType.WINDSWEPT_MONUMENT:
            return _create_windswept_monument(structure)
        POIType.FERTILE_OASIS:
            return _create_fertile_oasis(structure)
        POIType.VOID_TEAR:
            return _create_void_tear(structure)
    
    return base

func _create_crystal_formation(structure: POIStructure) -> Node2D:
    """Create detailed crystal formation"""
    var formation = Node2D.new()
    var crystal_count = 5 + structure.complexity_level * 2
    
    # Create main crystal cluster
    for i in range(crystal_count):
        var crystal = Node2D.new()
        
        # Crystal shape (elongated diamond)
        var crystal_shape = Polygon2D.new()
        var crystal_height = 20 + randf() * 30
        var crystal_width = crystal_height * 0.4
        
        crystal_shape.polygon = PackedVector2Array([
            Vector2(0, -crystal_height),           # Top point
            Vector2(crystal_width, -crystal_height * 0.3),  # Upper right
            Vector2(crystal_width * 0.8, crystal_height * 0.2),  # Lower right
            Vector2(0, crystal_height * 0.4),      # Bottom point
            Vector2(-crystal_width * 0.8, crystal_height * 0.2), # Lower left
            Vector2(-crystal_width, -crystal_height * 0.3)  # Upper left
        ])
        
        # Crystal coloring with gradient effect
        var crystal_color = structure.primary_color
        crystal_color.a = 0.8 + randf() * 0.2
        crystal_shape.color = crystal_color
        
        # Add inner glow
        var glow = crystal_shape.duplicate()
        glow.scale = Vector2(0.7, 0.7)
        glow.color = structure.accent_color
        glow.z_index = 1
        
        crystal.add_child(crystal_shape)
        crystal.add_child(glow)
        
        # Position crystals in cluster
        var angle = (i * PI * 2) / crystal_count + randf() * 0.5
        var distance = randf() * 15 * structure.scale
        crystal.position = Vector2(cos(angle), sin(angle)) * distance
        crystal.rotation = randf() * PI * 2
        crystal.scale = Vector2(structure.scale * (0.7 + randf() * 0.6), structure.scale * (0.7 + randf() * 0.6))
        
        formation.add_child(crystal)
    
    # Add crystal debris around base
    _add_crystal_debris(formation, structure)
    
    return formation

func _create_lava_vent(structure: POIStructure) -> Node2D:
    """Create detailed lava vent with flowing lava"""
    var vent = Node2D.new()
    
    # Main vent opening (irregular circle)
    var vent_opening = Polygon2D.new()
    var vent_radius = 25 * structure.scale
    var points = []
    
    for i in range(16):
        var angle = (i * PI * 2) / 16
        var radius_variation = vent_radius * (0.8 + randf() * 0.4)
        var point = Vector2(cos(angle), sin(angle)) * radius_variation
        points.append(point)
    
    vent_opening.polygon = PackedVector2Array(points)
    vent_opening.color = Color(0.1, 0.05, 0.0, 1.0)  # Dark interior
    vent.add_child(vent_opening)
    
    # Lava pool inside
    var lava_pool = vent_opening.duplicate()
    lava_pool.scale = Vector2(0.8, 0.8)
    lava_pool.color = structure.primary_color
    lava_pool.z_index = 1
    vent.add_child(lava_pool)
    
    # Lava flow streams
    for i in range(3 + structure.complexity_level):
        var flow = _create_lava_flow(structure, vent_radius)
        var flow_angle = randf() * PI * 2
        flow.position = Vector2(cos(flow_angle), sin(flow_angle)) * vent_radius
        flow.rotation = flow_angle + PI/2
        vent.add_child(flow)
    
    # Rock rim around vent
    _add_volcanic_rim(vent, structure, vent_radius)
    
    return vent

func _create_lava_flow(structure: POIStructure, start_radius: float) -> Node2D:
    """Create a flowing lava stream"""
    var flow = Node2D.new()
    var flow_length = 40 + randf() * 60
    var flow_width = 8 + randf() * 6
    
    # Create flowing lava shape
    var flow_shape = Polygon2D.new()
    var flow_points = []
    
    # Generate curved flow path
    for i in range(10):
        var distance = (i * flow_length) / 9
        var width_factor = 1.0 - (i * 0.1)  # Taper toward end
        var curve_offset = sin(i * 0.5) * 5  # Slight curve
        
        flow_points.append(Vector2(-flow_width * width_factor, distance) + Vector2(curve_offset, 0))
        flow_points.append(Vector2(flow_width * width_factor, distance) + Vector2(curve_offset, 0))
    
    flow_shape.polygon = PackedVector2Array(flow_points)
    flow_shape.color = structure.primary_color
    flow.add_child(flow_shape)
    
    # Add inner glow
    var glow = flow_shape.duplicate()
    glow.scale = Vector2(0.6, 0.6)
    glow.color = structure.accent_color
    glow.z_index = 1
    flow.add_child(glow)
    
    return flow

func _create_ancient_ruins(structure: POIStructure) -> Node2D:
    """Create mysterious ancient ruins"""
    var ruins = Node2D.new()
    
    # Main structure - broken pillar or wall
    var main_structure = _create_stone_pillar(structure)
    ruins.add_child(main_structure)
    
    # Scattered stone blocks
    for i in range(3 + structure.complexity_level):
        var stone_block = _create_stone_block(structure)
        var angle = randf() * PI * 2
        var distance = 20 + randf() * 40
        stone_block.position = Vector2(cos(angle), sin(angle)) * distance
        stone_block.rotation = randf() * PI * 2
        ruins.add_child(stone_block)
    
    # Mysterious glowing runes
    _add_glowing_runes(ruins, structure)
    
    return ruins

func _create_mystical_grove(structure: POIStructure) -> Node2D:
    """Create magical tree grove"""
    var grove = Node2D.new()
    
    # Central magical tree
    var central_tree = _create_magical_tree(structure, 1.5)
    grove.add_child(central_tree)
    
    # Surrounding smaller trees
    for i in range(2 + structure.complexity_level):
        var tree = _create_magical_tree(structure, 0.6 + randf() * 0.4)
        var angle = (i * PI * 2) / (2 + structure.complexity_level)
        var distance = 30 + randf() * 20
        tree.position = Vector2(cos(angle), sin(angle)) * distance
        grove.add_child(tree)
    
    # Magical undergrowth
    _add_magical_undergrowth(grove, structure)
    
    return grove
```

#### 2. Biome-Specific POI Integration
**Create new file**: `scripts/world/BiomePOIIntegration.gd`

```gdscript
extends RefCounted
class_name BiomePOIIntegration

func integrate_poi_with_terrain(poi_node: Node2D, world_position: Vector2, biome_influences: Dictionary, terrain_chunk: Node2D):
    """Integrate POI naturally with surrounding terrain"""
    
    # Analyze dominant biome
    var dominant_biome = _get_dominant_biome(biome_influences)
    
    # Add terrain-specific integration
    _add_terrain_modification(poi_node, world_position, dominant_biome)
    _add_environmental_shadows(poi_node, world_position, terrain_chunk)
    _add_biome_specific_details(poi_node, biome_influences)
    _add_natural_placement_effects(poi_node, world_position, terrain_chunk)

func _add_terrain_modification(poi_node: Node2D, world_position: Vector2, dominant_biome: int):
    """Modify terrain around POI for natural integration"""
    var terrain_effects = Node2D.new()
    terrain_effects.name = "TerrainEffects"
    poi_node.add_child(terrain_effects)
    
    match dominant_biome:
        BiomeType.ICE_FIELDS:
            _add_ice_accumulation(terrain_effects, world_position)
        BiomeType.FIRE_CAVES:
            _add_heat_distortion(terrain_effects, world_position)
        BiomeType.POISON_SWAMPS:
            _add_toxic_seepage(terrain_effects, world_position)
        BiomeType.PLAINS:
            _add_grass_growth(terrain_effects, world_position)
        BiomeType.ENCHANTED_FOREST:
            _add_magical_moss(terrain_effects, world_position)
        BiomeType.WASTELANDS:
            _add_erosion_effects(terrain_effects, world_position)

func _add_ice_accumulation(terrain_effects: Node2D, world_position: Vector2):
    """Add ice buildup around ice-field POIs"""
    var ice_patches = []
    
    for i in range(5):
        var ice_patch = Polygon2D.new()
        var patch_size = 15 + randf() * 10
        var angle = randf() * PI * 2
        var distance = 35 + randf() * 25
        
        # Create irregular ice patch
        var points = []
        for j in range(8):
            var point_angle = (j * PI * 2) / 8
            var point_distance = patch_size * (0.7 + randf() * 0.6)
            points.append(Vector2(cos(point_angle), sin(point_angle)) * point_distance)
        
        ice_patch.polygon = PackedVector2Array(points)
        ice_patch.color = Color(0.8, 0.9, 1.0, 0.6)
        ice_patch.position = Vector2(cos(angle), sin(angle)) * distance
        
        terrain_effects.add_child(ice_patch)

func _add_environmental_shadows(poi_node: Node2D, world_position: Vector2, terrain_chunk: Node2D):
    """Add realistic shadows cast by POI"""
    var shadow_layer = Node2D.new()
    shadow_layer.name = "Shadows"
    shadow_layer.z_index = -1
    poi_node.add_child(shadow_layer)
    
    # Simulate sun direction
    var sun_direction = Vector2(0.7, 0.3).normalized()
    var shadow_offset = sun_direction * 20
    var shadow_color = Color(0.0, 0.0, 0.0, 0.3)
    
    # Create shadow shapes based on POI structure
    for child in poi_node.get_children():
        if child.name == "Shadows":
            continue
        
        var shadow = _create_shadow_for_node(child, shadow_offset, shadow_color)
        if shadow:
            shadow_layer.add_child(shadow)

func _create_shadow_for_node(node: Node2D, offset: Vector2, color: Color) -> Node2D:
    """Create shadow for a specific node"""
    if not node.has_method("duplicate"):
        return null
    
    var shadow = node.duplicate()
    shadow.position = node.position + offset
    shadow.modulate = color
    shadow.z_index = -1
    
    # Make shadow slightly larger and skewed
    shadow.scale = shadow.scale * 1.1
    shadow.skew = 0.1
    
    return shadow
```

### **Day 3: Animated POI Elements**

#### 3. POI Animation System
**Create new file**: `scripts/world/POIAnimationSystem.gd`

```gdscript
extends RefCounted
class_name POIAnimationSystem

func add_poi_animations(poi_node: Node2D, poi_type: POIStructureSystem.POIType, animation_speed: float):
    """Add appropriate animations to POI based on type"""
    
    match poi_type:
        POIStructureSystem.POIType.CRYSTAL_FORMATION:
            _add_crystal_animations(poi_node, animation_speed)
        POIStructureSystem.POIType.LAVA_VENT:
            _add_lava_animations(poi_node, animation_speed)
        POIStructureSystem.POIType.ANCIENT_RUINS:
            _add_rune_animations(poi_node, animation_speed)
        POIStructureSystem.POIType.MYSTICAL_GROVE:
            _add_magical_animations(poi_node, animation_speed)
        POIStructureSystem.POIType.TOXIC_POOL:
            _add_toxic_animations(poi_node, animation_speed)
        POIStructureSystem.POIType.VOID_TEAR:
            _add_void_animations(poi_node, animation_speed)

func _add_crystal_animations(poi_node: Node2D, speed: float):
    """Add crystalline glow and shimmer effects"""
    var crystals = _find_crystal_nodes(poi_node)
    
    for crystal in crystals:
        # Pulsing glow effect
        var glow_tween = create_tween()
        glow_tween.set_loops()
        glow_tween.tween_property(crystal, "modulate:a", 0.7, 1.0 / speed)
        glow_tween.tween_property(crystal, "modulate:a", 1.0, 1.0 / speed)
        
        # Subtle rotation
        var rotation_tween = create_tween()
        rotation_tween.set_loops()
        rotation_tween.tween_property(crystal, "rotation", crystal.rotation + PI * 2, 20.0 / speed)
        
        # Color shimmer
        var color_tween = create_tween()
        color_tween.set_loops()
        var base_color = crystal.modulate
        var shimmer_color = Color(base_color.r * 1.2, base_color.g * 1.2, base_color.b * 1.2, base_color.a)
        color_tween.tween_property(crystal, "modulate", shimmer_color, 2.0 / speed)
        color_tween.tween_property(crystal, "modulate", base_color, 2.0 / speed)

func _add_lava_animations(poi_node: Node2D, speed: float):
    """Add lava bubbling and flow effects"""
    var lava_elements = _find_lava_nodes(poi_node)
    
    for lava_node in lava_elements:
        # Bubbling effect (scale pulsing)
        var bubble_tween = create_tween()
        bubble_tween.set_loops()
        bubble_tween.tween_property(lava_node, "scale", lava_node.scale * 1.1, 0.5 / speed)
        bubble_tween.tween_property(lava_node, "scale", lava_node.scale, 0.5 / speed)
        
        # Heat glow intensity
        var heat_tween = create_tween()
        heat_tween.set_loops()
        heat_tween.tween_property(lava_node, "modulate:r", 1.2, 0.8 / speed)
        heat_tween.tween_property(lava_node, "modulate:r", 0.8, 0.8 / speed)
        
        # Flowing animation (for lava streams)
        if lava_node.name.contains("Flow"):
            var flow_tween = create_tween()
            flow_tween.set_loops()
            flow_tween.tween_property(lava_node, "position:x", lava_node.position.x + 2, 1.0 / speed)
            flow_tween.tween_property(lava_node, "position:x", lava_node.position.x - 2, 1.0 / speed)

func _add_magical_animations(poi_node: Node2D, speed: float):
    """Add magical sparkle and energy effects"""
    var magical_elements = _find_magical_nodes(poi_node)
    
    for element in magical_elements:
        # Magical energy pulse
        var energy_tween = create_tween()
        energy_tween.set_loops()
        energy_tween.tween_property(element, "modulate:a", 0.6, 1.5 / speed)
        energy_tween.tween_property(element, "modulate:a", 1.0, 1.5 / speed)
        
        # Floating motion
        var float_tween = create_tween()
        float_tween.set_loops()
        float_tween.tween_property(element, "position:y", element.position.y - 5, 2.0 / speed)
        float_tween.tween_property(element, "position:y", element.position.y + 5, 2.0 / speed)
        
        # Sparkle effect
        _add_sparkle_particles(element, speed)

func _add_sparkle_particles(element: Node2D, speed: float):
    """Add sparkle particle effects"""
    var particles = CPUParticles2D.new()
    particles.emission.amount = 20
    particles.emission.lifetime = 2.0
    particles.emission.rate = 10.0
    
    # Sparkle appearance
    particles.emission.initial_velocity_min = 10.0
    particles.emission.initial_velocity_max = 30.0
    particles.emission.angular_velocity_min = -180.0
    particles.emission.angular_velocity_max = 180.0
    
    particles.scale_amount_min = 0.5
    particles.scale_amount_max = 1.0
    particles.scale_amount_curve = _create_sparkle_curve()
    
    particles.color = Color(1.0, 1.0, 0.8, 0.8)
    particles.color_ramp = _create_sparkle_color_ramp()
    
    element.add_child(particles)
    particles.emitting = true

func _create_sparkle_curve() -> Curve:
    """Create curve for sparkle scaling"""
    var curve = Curve.new()
    curve.add_point(0.0, 0.0)
    curve.add_point(0.3, 1.0)
    curve.add_point(1.0, 0.0)
    return curve

func _create_sparkle_color_ramp() -> Gradient:
    """Create color ramp for sparkle effect"""
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(1.0, 1.0, 0.8, 1.0))
    gradient.add_point(0.7, Color(0.9, 0.9, 0.6, 0.8))
    gradient.add_point(1.0, Color(0.8, 0.8, 0.4, 0.0))
    return gradient
```

### **Day 4: Environmental Particle Effects**

#### 4. POI Particle System
**Create new file**: `scripts/world/POIParticleSystem.gd`

```gdscript
extends RefCounted
class_name POIParticleSystem

func add_environmental_particles(poi_node: Node2D, poi_type: POIStructureSystem.POIType, biome_influences: Dictionary):
    """Add environmental particle effects to POI"""
    var particle_layer = Node2D.new()
    particle_layer.name = "ParticleEffects"
    poi_node.add_child(particle_layer)
    
    # Add type-specific particles
    match poi_type:
        POIStructureSystem.POIType.CRYSTAL_FORMATION:
            _add_ice_particles(particle_layer)
        POIStructureSystem.POIType.LAVA_VENT:
            _add_lava_particles(particle_layer)
        POIStructureSystem.POIType.TOXIC_POOL:
            _add_toxic_particles(particle_layer)
        POIStructureSystem.POIType.MYSTICAL_GROVE:
            _add_magical_particles(particle_layer)
        POIStructureSystem.POIType.VOID_TEAR:
            _add_void_particles(particle_layer)
    
    # Add biome-influenced ambient particles
    _add_biome_particles(particle_layer, biome_influences)

func _add_ice_particles(particle_layer: Node2D):
    """Add ice crystal particles"""
    var ice_particles = CPUParticles2D.new()
    ice_particles.emission.amount = 50
    ice_particles.emission.lifetime = 3.0
    ice_particles.emission.rate = 15.0
    
    # Ice particle behavior
    ice_particles.direction = Vector2(0, -1)
    ice_particles.spread = 30.0
    ice_particles.emission.initial_velocity_min = 20.0
    ice_particles.emission.initial_velocity_max = 50.0
    ice_particles.gravity = Vector2(0, 20)
    
    # Ice appearance
    ice_particles.scale_amount_min = 0.3
    ice_particles.scale_amount_max = 0.8
    ice_particles.color = Color(0.8, 0.9, 1.0, 0.7)
    ice_particles.color_ramp = _create_ice_color_ramp()
    
    # Rotation for crystal effect
    ice_particles.emission.angular_velocity_min = -90.0
    ice_particles.emission.angular_velocity_max = 90.0
    
    particle_layer.add_child(ice_particles)
    ice_particles.emitting = true

func _add_lava_particles(particle_layer: Node2D):
    """Add lava ember particles"""
    var lava_particles = CPUParticles2D.new()
    lava_particles.emission.amount = 80
    lava_particles.emission.lifetime = 2.5
    lava_particles.emission.rate = 25.0
    
    # Lava particle behavior
    lava_particles.direction = Vector2(0, -1)
    lava_particles.spread = 45.0
    lava_particles.emission.initial_velocity_min = 30.0
    lava_particles.emission.initial_velocity_max = 80.0
    lava_particles.gravity = Vector2(0, 50)
    
    # Lava appearance
    lava_particles.scale_amount_min = 0.5
    lava_particles.scale_amount_max = 1.2
    lava_particles.color = Color(1.0, 0.3, 0.0, 0.9)
    lava_particles.color_ramp = _create_lava_color_ramp()
    
    # Heat shimmer effect
    lava_particles.emission.angular_velocity_min = -45.0
    lava_particles.emission.angular_velocity_max = 45.0
    
    particle_layer.add_child(lava_particles)
    lava_particles.emitting = true

func _add_toxic_particles(particle_layer: Node2D):
    """Add toxic bubble particles"""
    var toxic_particles = CPUParticles2D.new()
    toxic_particles.emission.amount = 40
    toxic_particles.emission.lifetime = 4.0
    toxic_particles.emission.rate = 12.0
    
    # Toxic particle behavior
    toxic_particles.direction = Vector2(0, -1)
    toxic_particles.spread = 20.0
    toxic_particles.emission.initial_velocity_min = 10.0
    toxic_particles.emission.initial_velocity_max = 30.0
    toxic_particles.gravity = Vector2(0, -15)  # Bubbles float up
    
    # Toxic appearance
    toxic_particles.scale_amount_min = 0.8
    toxic_particles.scale_amount_max = 1.5
    toxic_particles.color = Color(0.5, 0.8, 0.2, 0.6)
    toxic_particles.color_ramp = _create_toxic_color_ramp()
    
    # Bubbling motion
    toxic_particles.emission.angular_velocity_min = -30.0
    toxic_particles.emission.angular_velocity_max = 30.0
    
    particle_layer.add_child(toxic_particles)
    toxic_particles.emitting = true

func _add_magical_particles(particle_layer: Node2D):
    """Add magical sparkle particles"""
    var magic_particles = CPUParticles2D.new()
    magic_particles.emission.amount = 60
    magic_particles.emission.lifetime = 3.5
    magic_particles.emission.rate = 20.0
    
    # Magical particle behavior
    magic_particles.direction = Vector2(0, -1)
    magic_particles.spread = 60.0
    magic_particles.emission.initial_velocity_min = 15.0
    magic_particles.emission.initial_velocity_max = 40.0
    magic_particles.gravity = Vector2(0, -10)  # Magical lift
    
    # Magical appearance
    magic_particles.scale_amount_min = 0.4
    magic_particles.scale_amount_max = 1.0
    magic_particles.color = Color(0.9, 0.9, 0.5, 0.8)
    magic_particles.color_ramp = _create_magic_color_ramp()
    
    # Sparkle rotation
    magic_particles.emission.angular_velocity_min = -180.0
    magic_particles.emission.angular_velocity_max = 180.0
    
    particle_layer.add_child(magic_particles)
    magic_particles.emitting = true

func _create_ice_color_ramp() -> Gradient:
    """Create color ramp for ice particles"""
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(0.9, 0.95, 1.0, 0.8))
    gradient.add_point(0.5, Color(0.8, 0.9, 1.0, 0.6))
    gradient.add_point(1.0, Color(0.7, 0.8, 0.9, 0.0))
    return gradient

func _create_lava_color_ramp() -> Gradient:
    """Create color ramp for lava particles"""
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(1.0, 0.8, 0.0, 1.0))
    gradient.add_point(0.3, Color(1.0, 0.4, 0.0, 0.9))
    gradient.add_point(0.7, Color(0.8, 0.2, 0.0, 0.5))
    gradient.add_point(1.0, Color(0.3, 0.1, 0.0, 0.0))
    return gradient

func _create_toxic_color_ramp() -> Gradient:
    """Create color ramp for toxic particles"""
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(0.6, 0.9, 0.3, 0.7))
    gradient.add_point(0.5, Color(0.5, 0.8, 0.2, 0.5))
    gradient.add_point(1.0, Color(0.3, 0.6, 0.1, 0.0))
    return gradient

func _create_magic_color_ramp() -> Gradient:
    """Create color ramp for magical particles"""
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(1.0, 1.0, 0.8, 0.9))
    gradient.add_point(0.3, Color(0.9, 0.9, 0.6, 0.8))
    gradient.add_point(0.7, Color(0.8, 0.8, 0.4, 0.4))
    gradient.add_point(1.0, Color(0.6, 0.6, 0.2, 0.0))
    return gradient
```

### **Day 5: Quality Integration and Polish**

#### 5. POI Quality Management
**Update `scripts/world/SimpleChunkRenderer.gd`:**

```gdscript
# Add POI quality levels
enum POIQuality {
    BASIC,      # Simple colored shapes
    STANDARD,   # Multi-part structures
    ENHANCED,   # Animated elements
    PREMIUM,    # Full particle effects
    ULTRA       # Maximum detail with all features
}

func create_quality_chunk_visual(chunk_coord: Vector2i, quality: QualityManager.TerrainQuality) -> Node2D:
    """Create chunk with quality-appropriate POI detail"""
    var chunk_node = Node2D.new()
    chunk_node.name = "Chunk_" + str(chunk_coord.x) + "_" + str(chunk_coord.y)
    
    # Generate terrain based on quality
    var terrain_visual = _generate_quality_terrain(chunk_coord, quality)
    chunk_node.add_child(terrain_visual)
    
    # Add POIs with appropriate quality
    var poi_quality = _get_poi_quality_from_terrain_quality(quality)
    _add_quality_pois(chunk_node, chunk_coord, poi_quality)
    
    return chunk_node

func _get_poi_quality_from_terrain_quality(terrain_quality: QualityManager.TerrainQuality) -> POIQuality:
    """Map terrain quality to POI quality"""
    match terrain_quality:
        QualityManager.TerrainQuality.ULTRA_HIGH:
            return POIQuality.ULTRA
        QualityManager.TerrainQuality.HIGH:
            return POIQuality.PREMIUM
        QualityManager.TerrainQuality.MEDIUM:
            return POIQuality.ENHANCED
        QualityManager.TerrainQuality.LOW:
            return POIQuality.STANDARD
        QualityManager.TerrainQuality.PLACEHOLDER:
            return POIQuality.BASIC

func _add_quality_pois(chunk_node: Node2D, chunk_coord: Vector2i, poi_quality: POIQuality):
    """Add POIs with specified quality level"""
    var poi_positions = _get_poi_positions_for_chunk(chunk_coord)
    var poi_system = POIStructureSystem.new()
    
    for poi_data in poi_positions:
        var poi_structure = poi_system.create_quality_poi_structure(
            poi_data.type,
            poi_data.position,
            poi_data.scale,
            poi_data.biome_influences,
            poi_quality
        )
        
        chunk_node.add_child(poi_structure)
```

---

## Performance and Quality Targets

### **POI Performance Targets:**
- **Generation time**: <10ms for ULTRA quality POIs
- **Memory per POI**: <5MB for complex structures
- **Particle count**: <200 active particles per POI
- **Animation overhead**: <1ms per animated POI

### **Visual Quality Targets:**
- **Structure complexity**: 5-15 visual elements per POI
- **Animation smoothness**: 60 FPS for all POI animations
- **Particle quality**: Realistic environmental effects
- **Biome integration**: Natural placement and terrain modification

---

## Benefits of Enhanced POI System

1. **Visual Richness**: Each POI looks unique and hand-crafted
2. **Biome Integration**: POIs feel naturally part of the world
3. **Animated Life**: Moving elements make world feel alive
4. **Environmental Effects**: Realistic particle systems enhance immersion
5. **Quality Scaling**: Appropriate detail level based on distance
6. **Performance Optimization**: Efficient generation and rendering

This enhanced POI system creates a living, breathing world where each structure tells a story and contributes to the overall visual quality of the procedural map.