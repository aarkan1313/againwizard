# Phase 5.5.6: Simple POI Content

## Overview
**Goal**: Replace empty POI markers with actual structures and content, creating foundation for complex POI system.

**Timeline**: 2-3 days  
**Dependencies**: Phase 5.5.5 (smart loading) must be complete  
**Priority**: Medium (user said "start simple plan for complex")

---

## Technical Approach

### **Current System Issues:**
- POI markers are just colored squares
- No actual content or interaction
- Same appearance regardless of biome
- No structural variety or purpose

### **New System Features:**
- Biome-specific POI structures
- Procedural structure generation
- Foundation for complex POI expansion
- Visual variety and natural placement

---

## Implementation Steps

### **Step 1: POI Structure Templates**

**Create new file**: `scripts/world/POIStructureTemplates.gd`

```gdscript
extends RefCounted
class_name POIStructureTemplates

enum POIType {
    SMALL_ROCK,
    LARGE_ROCK,
    TREE,
    RUINS,
    CRYSTAL_FORMATION,
    LAVA_VENT,
    ICE_SPIRE,
    TOXIC_POOL,
    SAND_DUNE,
    VOLCANIC_ROCK,
    ANCIENT_PILLAR,
    POISON_FLOWER
}

static func get_biome_poi_types(biome_type: int) -> Array[POIType]:
    """Get appropriate POI types for each biome"""
    match biome_type:
        HeavyChunkLoader.BiomeType.PLAINS:
            return [POIType.TREE, POIType.SMALL_ROCK, POIType.LARGE_ROCK]
        HeavyChunkLoader.BiomeType.FIRE_CAVES:
            return [POIType.LAVA_VENT, POIType.VOLCANIC_ROCK, POIType.LARGE_ROCK]
        HeavyChunkLoader.BiomeType.ICE_FIELDS:
            return [POIType.ICE_SPIRE, POIType.LARGE_ROCK, POIType.SMALL_ROCK]
        HeavyChunkLoader.BiomeType.POISON_SWAMPS:
            return [POIType.TOXIC_POOL, POIType.POISON_FLOWER, POIType.TREE]
        HeavyChunkLoader.BiomeType.DARK_FOREST:
            return [POIType.TREE, POIType.LARGE_ROCK, POIType.ANCIENT_PILLAR]
        HeavyChunkLoader.BiomeType.CRYSTAL_CAVERNS:
            return [POIType.CRYSTAL_FORMATION, POIType.LARGE_ROCK, POIType.SMALL_ROCK]
        HeavyChunkLoader.BiomeType.VOLCANIC_CHAMBER:
            return [POIType.VOLCANIC_ROCK, POIType.LAVA_VENT, POIType.LARGE_ROCK]
        HeavyChunkLoader.BiomeType.DESERT_RUINS:
            return [POIType.RUINS, POIType.SAND_DUNE, POIType.ANCIENT_PILLAR]
        _:
            return [POIType.SMALL_ROCK, POIType.LARGE_ROCK]

static func create_poi_structure(poi_type: POIType, size_scale: float = 1.0) -> Node2D:
    """Create a POI structure based on type"""
    var structure = Node2D.new()
    structure.name = "POI_" + POIType.keys()[poi_type]
    
    match poi_type:
        POIType.SMALL_ROCK:
            _create_small_rock(structure, size_scale)
        POIType.LARGE_ROCK:
            _create_large_rock(structure, size_scale)
        POIType.TREE:
            _create_tree(structure, size_scale)
        POIType.RUINS:
            _create_ruins(structure, size_scale)
        POIType.CRYSTAL_FORMATION:
            _create_crystal_formation(structure, size_scale)
        POIType.LAVA_VENT:
            _create_lava_vent(structure, size_scale)
        POIType.ICE_SPIRE:
            _create_ice_spire(structure, size_scale)
        POIType.TOXIC_POOL:
            _create_toxic_pool(structure, size_scale)
        POIType.SAND_DUNE:
            _create_sand_dune(structure, size_scale)
        POIType.VOLCANIC_ROCK:
            _create_volcanic_rock(structure, size_scale)
        POIType.ANCIENT_PILLAR:
            _create_ancient_pillar(structure, size_scale)
        POIType.POISON_FLOWER:
            _create_poison_flower(structure, size_scale)
    
    return structure

# Individual structure creation functions
static func _create_small_rock(parent: Node2D, scale: float):
    var rock = ColorRect.new()
    rock.size = Vector2(8, 6) * scale
    rock.position = Vector2(-4, -3) * scale
    rock.color = Color(0.6, 0.6, 0.6)
    parent.add_child(rock)
    
    # Add some detail
    var detail = ColorRect.new()
    detail.size = Vector2(3, 2) * scale
    detail.position = Vector2(2, 1) * scale
    detail.color = Color(0.5, 0.5, 0.5)
    rock.add_child(detail)

static func _create_large_rock(parent: Node2D, scale: float):
    var rock = ColorRect.new()
    rock.size = Vector2(16, 12) * scale
    rock.position = Vector2(-8, -6) * scale
    rock.color = Color(0.5, 0.5, 0.5)
    parent.add_child(rock)
    
    # Add multiple detail pieces
    for i in range(3):
        var detail = ColorRect.new()
        detail.size = Vector2(4, 3) * scale
        detail.position = Vector2(randi() % 8, randi() % 6) * scale
        detail.color = Color(0.4, 0.4, 0.4)
        rock.add_child(detail)

static func _create_tree(parent: Node2D, scale: float):
    # Tree trunk
    var trunk = ColorRect.new()
    trunk.size = Vector2(4, 12) * scale
    trunk.position = Vector2(-2, -6) * scale
    trunk.color = Color(0.4, 0.25, 0.1)
    parent.add_child(trunk)
    
    # Tree canopy
    var canopy = ColorRect.new()
    canopy.size = Vector2(12, 8) * scale
    canopy.position = Vector2(-6, -14) * scale
    canopy.color = Color(0.2, 0.6, 0.2)
    parent.add_child(canopy)
    
    # Add some leaves detail
    for i in range(2):
        var leaf = ColorRect.new()
        leaf.size = Vector2(3, 3) * scale
        leaf.position = Vector2(randi() % 6 - 3, randi() % 4 - 10) * scale
        leaf.color = Color(0.3, 0.7, 0.3)
        parent.add_child(leaf)

static func _create_ruins(parent: Node2D, scale: float):
    # Base structure
    var base = ColorRect.new()
    base.size = Vector2(20, 6) * scale
    base.position = Vector2(-10, -3) * scale
    base.color = Color(0.7, 0.6, 0.4)
    parent.add_child(base)
    
    # Broken pillars
    for i in range(3):
        var pillar = ColorRect.new()
        pillar.size = Vector2(3, 8 + randi() % 4) * scale
        pillar.position = Vector2(-8 + i * 8, -11) * scale
        pillar.color = Color(0.8, 0.7, 0.5)
        parent.add_child(pillar)

static func _create_crystal_formation(parent: Node2D, scale: float):
    # Main crystal
    var crystal = ColorRect.new()
    crystal.size = Vector2(8, 16) * scale
    crystal.position = Vector2(-4, -8) * scale
    crystal.color = Color(0.8, 0.4, 1.0)
    parent.add_child(crystal)
    
    # Smaller crystals around it
    for i in range(3):
        var small_crystal = ColorRect.new()
        small_crystal.size = Vector2(4, 8) * scale
        small_crystal.position = Vector2(randi() % 16 - 8, randi() % 8 - 4) * scale
        small_crystal.color = Color(0.7, 0.3, 0.9)
        parent.add_child(small_crystal)

static func _create_lava_vent(parent: Node2D, scale: float):
    # Vent opening
    var vent = ColorRect.new()
    vent.size = Vector2(12, 8) * scale
    vent.position = Vector2(-6, -4) * scale
    vent.color = Color(0.3, 0.1, 0.1)
    parent.add_child(vent)
    
    # Lava glow
    var glow = ColorRect.new()
    glow.size = Vector2(8, 4) * scale
    glow.position = Vector2(-4, -2) * scale
    glow.color = Color(1.0, 0.3, 0.0)
    parent.add_child(glow)

static func _create_ice_spire(parent: Node2D, scale: float):
    # Main spire
    var spire = ColorRect.new()
    spire.size = Vector2(6, 20) * scale
    spire.position = Vector2(-3, -10) * scale
    spire.color = Color(0.8, 0.9, 1.0)
    parent.add_child(spire)
    
    # Ice crystals
    for i in range(2):
        var crystal = ColorRect.new()
        crystal.size = Vector2(3, 6) * scale
        crystal.position = Vector2(randi() % 8 - 4, randi() % 12 - 6) * scale
        crystal.color = Color(0.9, 0.95, 1.0)
        parent.add_child(crystal)

static func _create_toxic_pool(parent: Node2D, scale: float):
    # Pool base
    var pool = ColorRect.new()
    pool.size = Vector2(16, 12) * scale
    pool.position = Vector2(-8, -6) * scale
    pool.color = Color(0.2, 0.5, 0.1)
    parent.add_child(pool)
    
    # Toxic bubbles
    for i in range(3):
        var bubble = ColorRect.new()
        bubble.size = Vector2(4, 4) * scale
        bubble.position = Vector2(randi() % 8 - 4, randi() % 8 - 4) * scale
        bubble.color = Color(0.4, 0.7, 0.2)
        parent.add_child(bubble)

static func _create_sand_dune(parent: Node2D, scale: float):
    # Main dune
    var dune = ColorRect.new()
    dune.size = Vector2(24, 10) * scale
    dune.position = Vector2(-12, -5) * scale
    dune.color = Color(0.9, 0.8, 0.6)
    parent.add_child(dune)
    
    # Sand details
    for i in range(2):
        var detail = ColorRect.new()
        detail.size = Vector2(8, 4) * scale
        detail.position = Vector2(randi() % 12 - 6, randi() % 6 - 3) * scale
        detail.color = Color(0.85, 0.75, 0.55)
        parent.add_child(detail)

static func _create_volcanic_rock(parent: Node2D, scale: float):
    # Main rock
    var rock = ColorRect.new()
    rock.size = Vector2(14, 10) * scale
    rock.position = Vector2(-7, -5) * scale
    rock.color = Color(0.3, 0.1, 0.1)
    parent.add_child(rock)
    
    # Lava veins
    for i in range(2):
        var vein = ColorRect.new()
        vein.size = Vector2(6, 2) * scale
        vein.position = Vector2(randi() % 8 - 4, randi() % 6 - 3) * scale
        vein.color = Color(0.8, 0.2, 0.0)
        parent.add_child(vein)

static func _create_ancient_pillar(parent: Node2D, scale: float):
    # Pillar base
    var base = ColorRect.new()
    base.size = Vector2(8, 4) * scale
    base.position = Vector2(-4, -2) * scale
    base.color = Color(0.6, 0.6, 0.6)
    parent.add_child(base)
    
    # Pillar shaft
    var shaft = ColorRect.new()
    shaft.size = Vector2(6, 16) * scale
    shaft.position = Vector2(-3, -18) * scale
    shaft.color = Color(0.7, 0.7, 0.7)
    parent.add_child(shaft)
    
    # Pillar top
    var top = ColorRect.new()
    top.size = Vector2(8, 4) * scale
    top.position = Vector2(-4, -22) * scale
    top.color = Color(0.6, 0.6, 0.6)
    parent.add_child(top)

static func _create_poison_flower(parent: Node2D, scale: float):
    # Stem
    var stem = ColorRect.new()
    stem.size = Vector2(2, 8) * scale
    stem.position = Vector2(-1, -4) * scale
    stem.color = Color(0.1, 0.4, 0.1)
    parent.add_child(stem)
    
    # Flower head
    var flower = ColorRect.new()
    flower.size = Vector2(8, 6) * scale
    flower.position = Vector2(-4, -10) * scale
    flower.color = Color(0.6, 0.1, 0.8)
    parent.add_child(flower)
    
    # Poison glow
    var glow = ColorRect.new()
    glow.size = Vector2(4, 3) * scale
    glow.position = Vector2(-2, -8) * scale
    glow.color = Color(0.8, 0.3, 1.0)
    parent.add_child(glow)
```

### **Step 2: Enhanced POI Generation System**

**Update `scripts/world/SimpleChunkRenderer.gd`:**

```gdscript
func _add_enhanced_poi(chunk_node: Node2D, chunk_coord: Vector2i, influences: Dictionary):
    """Add enhanced POI with actual structures"""
    # Get dominant biome for POI selection
    var dominant_biome = _get_dominant_biome(influences)
    
    # Get appropriate POI types for this biome
    var poi_types = POIStructureTemplates.get_biome_poi_types(dominant_biome)
    
    # Select random POI type
    var selected_poi = poi_types[randi() % poi_types.size()]
    
    # Create structure
    var size_scale = 0.8 + randf() * 0.4  # 0.8 to 1.2 scale
    var poi_structure = POIStructureTemplates.create_poi_structure(selected_poi, size_scale)
    
    # Position randomly within chunk (avoid edges)
    var margin = 32
    var poi_position = Vector2(
        margin + randi() % (CHUNK_SIZE - margin * 2),
        margin + randi() % (CHUNK_SIZE - margin * 2)
    )
    poi_structure.position = poi_position
    
    # Add to chunk
    chunk_node.add_child(poi_structure)
    
    # Add debug label (optional)
    if show_debug_borders:
        _add_poi_debug_label(poi_structure, selected_poi)

func _get_dominant_biome(influences: Dictionary) -> int:
    """Get the most influential biome"""
    var max_influence = 0.0
    var dominant_biome = HeavyChunkLoader.BiomeType.PLAINS
    
    for biome_type in influences:
        if influences[biome_type] > max_influence:
            max_influence = influences[biome_type]
            dominant_biome = biome_type
    
    return dominant_biome

func _add_poi_debug_label(poi_structure: Node2D, poi_type: POIStructureTemplates.POIType):
    """Add debug label for POI identification"""
    var label = Label.new()
    label.text = POIStructureTemplates.POIType.keys()[poi_type]
    label.position = Vector2(0, -30)
    label.scale = Vector2(0.4, 0.4)
    label.modulate = Color(1, 1, 1, 0.7)
    poi_structure.add_child(label)
```

### **Step 3: Multiple POI Support**

**Enhanced POI placement system:**

```gdscript
func _add_multiple_pois(chunk_node: Node2D, chunk_coord: Vector2i, influences: Dictionary):
    """Add multiple POIs to a chunk based on biome"""
    var poi_count = _calculate_poi_count(influences)
    
    for i in range(poi_count):
        # Vary POI chance based on biome
        var poi_chance = _get_biome_poi_chance(influences)
        
        if randf() < poi_chance:
            _add_enhanced_poi(chunk_node, chunk_coord, influences)

func _calculate_poi_count(influences: Dictionary) -> int:
    """Calculate number of POIs based on biome influences"""
    var base_count = 1
    
    # Some biomes have more POIs
    for biome_type in influences:
        var influence = influences[biome_type]
        match biome_type:
            HeavyChunkLoader.BiomeType.CRYSTAL_CAVERNS:
                base_count += int(influence * 2)  # More crystals
            HeavyChunkLoader.BiomeType.DESERT_RUINS:
                base_count += int(influence * 1.5)  # More ruins
            HeavyChunkLoader.BiomeType.DARK_FOREST:
                base_count += int(influence * 1.2)  # More trees
    
    return min(base_count, 3)  # Cap at 3 POIs per chunk

func _get_biome_poi_chance(influences: Dictionary) -> float:
    """Get POI spawn chance based on biome influences"""
    var base_chance = 0.05  # 5% base chance
    
    for biome_type in influences:
        var influence = influences[biome_type]
        match biome_type:
            HeavyChunkLoader.BiomeType.CRYSTAL_CAVERNS:
                base_chance += influence * 0.1  # 10% more likely
            HeavyChunkLoader.BiomeType.DESERT_RUINS:
                base_chance += influence * 0.08  # 8% more likely
            HeavyChunkLoader.BiomeType.POISON_SWAMPS:
                base_chance += influence * 0.06  # 6% more likely
    
    return min(base_chance, 0.2)  # Cap at 20% chance
```

### **Step 4: POI Interaction Foundation**

**Prepare for future interaction system:**

```gdscript
# Add to POI structures
func _add_interaction_area(poi_structure: Node2D, poi_type: POIStructureTemplates.POIType):
    """Add interaction area for future functionality"""
    var area = Area2D.new()
    area.name = "InteractionArea"
    
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 24
    collision.shape = shape
    
    area.add_child(collision)
    poi_structure.add_child(area)
    
    # Store POI type for future reference
    poi_structure.set_meta("poi_type", poi_type)
    poi_structure.set_meta("interaction_enabled", true)
```

---

## Integration with Existing Systems

### **Update `create_chunk_visual()` function:**

```gdscript
func create_chunk_visual(chunk_coord: Vector2i) -> Node2D:
    """Create chunk with enhanced POI system"""
    var start_time = Time.get_ticks_msec()
    
    var chunk_node = Node2D.new()
    chunk_node.name = "Chunk_" + str(chunk_coord.x) + "_" + str(chunk_coord.y)
    
    # Get biome influences
    var influences = _get_biome_influences(chunk_coord)
    
    # Create terrain (from Phase 5.5.4)
    var terrain_chunk = ProceduralTerrainChunk.new(chunk_coord, CHUNK_SIZE, influences, noise)
    chunk_node.add_child(terrain_chunk)
    
    # Add enhanced POI system
    _add_multiple_pois(chunk_node, chunk_coord, influences)
    
    # Debug borders
    if show_debug_borders:
        _add_debug_border(chunk_node)
    
    var generation_time = Time.get_ticks_msec() - start_time
    if generation_time > 30:  # Increased threshold for POI generation
        print("POI chunk generated in ", generation_time, "ms at ", chunk_coord)
    
    return chunk_node
```

---

## Future Expansion Foundation

### **Complex POI System Preparation:**

```gdscript
# POI categories for future expansion
enum POICategory {
    RESOURCE,      # Mineable/harvestable
    STRUCTURE,     # Buildings/ruins
    HAZARD,        # Dangerous areas
    INTERACTIVE,   # NPCs/vendors
    DUNGEON,       # Dungeon entrances
    BOSS,          # Boss arenas
    SPECIAL        # Unique locations
}

# POI rarity system
enum POIRarity {
    COMMON,        # 70% chance
    UNCOMMON,      # 25% chance
    RARE,          # 4% chance
    LEGENDARY      # 1% chance
}

# Foundation for POI content system
class POIContent:
    var poi_type: POIStructureTemplates.POIType
    var category: POICategory
    var rarity: POIRarity
    var loot_table: Array = []
    var interaction_text: String = ""
    var special_effects: Array = []
```

---

## Performance Considerations

### **Optimization Strategies:**
1. **Structure pooling**: Reuse POI structures when possible
2. **LOD for POIs**: Simpler POIs for distant chunks
3. **Batch creation**: Create multiple POIs in single pass
4. **Interaction culling**: Only enable interactions for nearby POIs

### **Performance Targets:**
- **Generation time**: +5ms max per chunk for POI generation
- **Memory usage**: <50MB additional for POI structures
- **Visual quality**: Recognizable, biome-appropriate structures

---

## Testing Strategy

### **Visual Tests:**
- [ ] POI structures look appropriate for each biome
- [ ] Structures have visual variety and detail
- [ ] POI placement looks natural
- [ ] Multiple POIs per chunk work correctly

### **Performance Tests:**
- [ ] POI generation doesn't cause frame drops
- [ ] Memory usage remains reasonable
- [ ] Chunk generation time stays acceptable

### **Functionality Tests:**
- [ ] All biome-specific POI types generate
- [ ] POI placement respects chunk boundaries
- [ ] Debug labels work correctly
- [ ] Integration with terrain system works

---

## Complex POI Planning

### **Phase 6+ Features:**
- **Dungeon POIs**: Multi-room underground areas
- **Vendor POIs**: NPCs with shops and quests
- **Boss POIs**: Large arena-style encounters
- **Resource POIs**: Mineable veins and harvestable areas
- **Interactive POIs**: Puzzles, switches, and mechanisms

### **Technical Requirements:**
- Save/load system for POI states
- Procedural interior generation
- NPC behavior system
- Loot and reward system
- Quest integration

---

## Rollback Plan

If performance or complexity issues occur:
1. Reduce POI structure complexity
2. Limit to 1 POI per chunk
3. Simplify biome-specific variations
4. Fall back to enhanced colored shapes

---

**Note**: This phase creates the foundation for complex POI content while keeping current implementation simple and performant. Future phases will build upon this structure system.