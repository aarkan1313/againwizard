# Phase 5.5.4: Advanced Procedural Terrain

## Overview
**Goal**: Replace simple ColorRect backgrounds with high-quality procedural terrain generation using custom drawing and noise-based patterns.

**Timeline**: 3-4 days  
**Dependencies**: Phase 5.5.3 (biome transitions) must be complete  
**Priority**: High (user wants "best possible procedural system")

---

## Technical Approach

### **Current System Limitations:**
- Simple solid ColorRect backgrounds
- Basic terrain variation (small colored rectangles)
- No texture detail or visual depth
- Artificial, flat appearance

### **New System Features:**
- Custom `_draw()` function for procedural terrain
- Noise-based terrain patterns and textures
- Biome-specific terrain characteristics
- Height-based shading and detail layers
- Procedural texture generation

---

## Implementation Steps

### **Step 1: Custom Terrain Node**

**Create new file**: `scripts/world/ProceduralTerrainChunk.gd`

```gdscript
extends Node2D
class_name ProceduralTerrainChunk

var chunk_coord: Vector2i
var chunk_size: int
var biome_influences: Dictionary
var noise: FastNoiseLite
var detail_noise: FastNoiseLite

func _init(coord: Vector2i, size: int, influences: Dictionary, noise_gen: FastNoiseLite):
    chunk_coord = coord
    chunk_size = size
    biome_influences = influences
    noise = noise_gen
    
    # Secondary noise for detail
    detail_noise = FastNoiseLite.new()
    detail_noise.seed = noise.seed + 1000
    detail_noise.frequency = 0.4
    detail_noise.noise_type = FastNoiseLite.TYPE_PERLIN

func _draw():
    # Generate procedural terrain texture
    _draw_procedural_terrain()
    
    # Add detail layers
    _draw_terrain_details()
    
    # Add biome-specific features
    _draw_biome_features()
```

### **Step 2: Procedural Terrain Generation**

**Core terrain drawing function:**
```gdscript
func _draw_procedural_terrain():
    """Draw base terrain using noise patterns"""
    var pixel_size = 4  # 4x4 pixel chunks for performance
    var width_steps = chunk_size / pixel_size
    var height_steps = chunk_size / pixel_size
    
    for x in range(width_steps):
        for y in range(height_steps):
            var world_x = chunk_coord.x * chunk_size + x * pixel_size
            var world_y = chunk_coord.y * chunk_size + y * pixel_size
            
            # Get terrain height/type from noise
            var terrain_noise = noise.get_noise_2d(world_x * 0.01, world_y * 0.01)
            var detail_noise_val = detail_noise.get_noise_2d(world_x * 0.05, world_y * 0.05)
            
            # Calculate base color from biome influences
            var base_color = _get_local_biome_color(x, y)
            
            # Modify color based on terrain height
            var terrain_color = _apply_terrain_shading(base_color, terrain_noise, detail_noise_val)
            
            # Draw terrain pixel
            var rect = Rect2(Vector2(x * pixel_size, y * pixel_size), Vector2(pixel_size, pixel_size))
            draw_rect(rect, terrain_color)
```

### **Step 3: Biome-Specific Terrain Patterns**

**Pattern generation per biome:**
```gdscript
func _get_biome_terrain_pattern(biome_type: int, noise_val: float, detail_val: float) -> Dictionary:
    """Generate biome-specific terrain patterns"""
    var pattern = {"color_mod": 1.0, "roughness": 0.0, "features": []}
    
    match biome_type:
        HeavyChunkLoader.BiomeType.PLAINS:
            pattern.color_mod = 0.9 + detail_val * 0.2
            pattern.roughness = 0.1
            if noise_val > 0.3:
                pattern.features.append("grass_patch")
        
        HeavyChunkLoader.BiomeType.FIRE_CAVES:
            pattern.color_mod = 0.8 + abs(noise_val) * 0.4
            pattern.roughness = 0.5
            if noise_val > 0.4:
                pattern.features.append("lava_crack")
        
        HeavyChunkLoader.BiomeType.ICE_FIELDS:
            pattern.color_mod = 0.95 + detail_val * 0.1
            pattern.roughness = 0.05
            if noise_val > 0.2:
                pattern.features.append("ice_crystal")
        
        HeavyChunkLoader.BiomeType.POISON_SWAMPS:
            pattern.color_mod = 0.7 + abs(noise_val) * 0.3
            pattern.roughness = 0.3
            if noise_val < -0.3:
                pattern.features.append("poison_pool")
        
        HeavyChunkLoader.BiomeType.DARK_FOREST:
            pattern.color_mod = 0.6 + detail_val * 0.2
            pattern.roughness = 0.4
            if noise_val > 0.3:
                pattern.features.append("tree_shadow")
        
        HeavyChunkLoader.BiomeType.CRYSTAL_CAVERNS:
            pattern.color_mod = 0.8 + abs(noise_val) * 0.4
            pattern.roughness = 0.2
            if noise_val > 0.4:
                pattern.features.append("crystal_vein")
        
        HeavyChunkLoader.BiomeType.VOLCANIC_CHAMBER:
            pattern.color_mod = 0.5 + abs(noise_val) * 0.5
            pattern.roughness = 0.6
            if noise_val > 0.3:
                pattern.features.append("volcanic_rock")
        
        HeavyChunkLoader.BiomeType.DESERT_RUINS:
            pattern.color_mod = 0.85 + detail_val * 0.3
            pattern.roughness = 0.25
            if noise_val > 0.2:
                pattern.features.append("sand_dune")
    
    return pattern
```

### **Step 4: Advanced Shading System**

**Height-based shading and lighting:**
```gdscript
func _apply_terrain_shading(base_color: Color, height_noise: float, detail_noise: float) -> Color:
    """Apply realistic shading based on terrain height"""
    var final_color = base_color
    
    # Height-based lighting (simulate sun from top-left)
    var height_factor = (height_noise + 1.0) * 0.5  # Normalize to 0-1
    var light_intensity = 0.8 + height_factor * 0.4
    
    # Detail variations
    var detail_factor = (detail_noise + 1.0) * 0.5
    var detail_intensity = 0.9 + detail_factor * 0.2
    
    # Apply lighting
    final_color = final_color * light_intensity * detail_intensity
    
    # Add subtle color variations
    var color_variance = detail_noise * 0.1
    final_color.r += color_variance
    final_color.g += color_variance * 0.5
    final_color.b += color_variance * 0.3
    
    # Clamp to valid range
    final_color = Color(
        clamp(final_color.r, 0.0, 1.0),
        clamp(final_color.g, 0.0, 1.0),
        clamp(final_color.b, 0.0, 1.0),
        1.0
    )
    
    return final_color
```

### **Step 5: Terrain Detail Features**

**Draw specific terrain features:**
```gdscript
func _draw_terrain_details():
    """Draw detailed terrain features"""
    var feature_density = 0.02  # 2% of pixels get features
    var pixel_size = 4
    var width_steps = chunk_size / pixel_size
    var height_steps = chunk_size / pixel_size
    
    for x in range(width_steps):
        for y in range(height_steps):
            if randf() < feature_density:
                var world_x = chunk_coord.x * chunk_size + x * pixel_size
                var world_y = chunk_coord.y * chunk_size + y * pixel_size
                
                # Get dominant biome for this location
                var local_biome = _get_dominant_local_biome(x, y)
                
                # Draw biome-specific feature
                _draw_terrain_feature(Vector2(x * pixel_size, y * pixel_size), local_biome)

func _draw_terrain_feature(pos: Vector2, biome_type: int):
    """Draw individual terrain features"""
    var feature_size = randi() % 8 + 4
    var feature_color: Color
    
    match biome_type:
        HeavyChunkLoader.BiomeType.PLAINS:
            feature_color = Color(0.2, 0.5, 0.2)  # Dark green grass
        HeavyChunkLoader.BiomeType.FIRE_CAVES:
            feature_color = Color(1.0, 0.3, 0.0)  # Bright orange lava
        HeavyChunkLoader.BiomeType.ICE_FIELDS:
            feature_color = Color(0.9, 0.9, 1.0)  # Bright white ice
        HeavyChunkLoader.BiomeType.POISON_SWAMPS:
            feature_color = Color(0.3, 0.6, 0.1)  # Toxic green
        HeavyChunkLoader.BiomeType.DARK_FOREST:
            feature_color = Color(0.1, 0.3, 0.1)  # Very dark green
        HeavyChunkLoader.BiomeType.CRYSTAL_CAVERNS:
            feature_color = Color(0.8, 0.4, 1.0)  # Bright purple
        HeavyChunkLoader.BiomeType.VOLCANIC_CHAMBER:
            feature_color = Color(0.4, 0.1, 0.1)  # Dark red rock
        HeavyChunkLoader.BiomeType.DESERT_RUINS:
            feature_color = Color(0.9, 0.8, 0.5)  # Light sand
        _:
            feature_color = Color.GRAY
    
    # Draw feature as small circle or rectangle
    if randf() < 0.5:
        draw_circle(pos + Vector2(feature_size/2, feature_size/2), feature_size/2, feature_color)
    else:
        draw_rect(Rect2(pos, Vector2(feature_size, feature_size)), feature_color)
```

---

## Integration with SimpleChunkRenderer

### **Updated `create_chunk_visual()` function:**
```gdscript
func create_chunk_visual(chunk_coord: Vector2i) -> Node2D:
    """Create chunk with advanced procedural terrain"""
    var start_time = Time.get_ticks_msec()
    
    var chunk_node = Node2D.new()
    chunk_node.name = "Chunk_" + str(chunk_coord.x) + "_" + str(chunk_coord.y)
    
    # Get biome influences
    var influences = _get_biome_influences(chunk_coord)
    
    # Create procedural terrain chunk
    var terrain_chunk = ProceduralTerrainChunk.new(chunk_coord, CHUNK_SIZE, influences, noise)
    chunk_node.add_child(terrain_chunk)
    
    # Add enhanced POI system
    if randf() < 0.05:
        _add_procedural_poi(chunk_node, chunk_coord, influences)
    
    # Debug borders
    if show_debug_borders:
        _add_debug_border(chunk_node)
    
    var generation_time = Time.get_ticks_msec() - start_time
    if generation_time > 20:  # Increased threshold for complex terrain
        print("Procedural terrain generated in ", generation_time, "ms at ", chunk_coord)
    
    return chunk_node
```

---

## Performance Optimization

### **Optimization Strategies:**
1. **Pixel grouping**: 4x4 pixel chunks instead of per-pixel
2. **Noise caching**: Pre-calculate noise values for common coordinates
3. **LOD system**: Simpler terrain for distant chunks
4. **Feature culling**: Reduce detail density based on distance

### **Performance Targets:**
- **Generation time**: <25ms per chunk (complex terrain)
- **Memory usage**: <500MB total
- **Visual quality**: High-detail, realistic terrain
- **FPS**: Stable 60 FPS during gameplay

---

## Advanced Features

### **Texture Atlasing (Future):**
```gdscript
# Pre-generate terrain texture atlas
func _create_terrain_atlas():
    var atlas_size = 512
    var tile_size = 64
    
    # Generate texture tiles for each biome
    for biome in HeavyChunkLoader.BiomeType.values():
        var texture_tile = _generate_biome_texture(biome, tile_size)
        _add_to_atlas(texture_tile, biome)
```

### **Dynamic Weather Effects:**
```gdscript
# Weather modifications to terrain
func _apply_weather_effects(color: Color, weather_type: int) -> Color:
    match weather_type:
        WeatherType.RAIN:
            return color.darkened(0.2)
        WeatherType.SNOW:
            return color.lightened(0.3)
        WeatherType.FOG:
            return color.lerp(Color.GRAY, 0.3)
        _:
            return color
```

---

## Testing Strategy

### **Visual Quality Tests:**
- [ ] Terrain looks natural and detailed
- [ ] Biome-specific patterns are visible
- [ ] Smooth transitions between terrain types
- [ ] No visual artifacts or glitches
- [ ] Performance acceptable during movement

### **Technical Tests:**
- [ ] Custom drawing works correctly
- [ ] Noise patterns generate consistently
- [ ] Memory usage within limits
- [ ] Generation time acceptable
- [ ] Integration with biome transition system

---

## Rollback Plan

If performance issues occur:
1. Reduce pixel detail (8x8 instead of 4x4)
2. Simplify shading calculations
3. Reduce feature density
4. Fall back to enhanced ColorRect system

---

## File Structure

### **New Files:**
- `scripts/world/ProceduralTerrainChunk.gd` - Main terrain generation
- `scripts/world/TerrainPatterns.gd` - Biome-specific patterns
- `scripts/world/TerrainShading.gd` - Lighting and shading utilities

### **Modified Files:**
- `scripts/world/SimpleChunkRenderer.gd` - Integration with new terrain system

---

## Future Enhancements

### **Phase 5.5.5 Integration:**
- Smart loading can pre-generate terrain textures
- Directional loading for terrain detail
- Adaptive quality based on movement speed

### **Advanced Features:**
- Real-time terrain modification
- Player-buildable terrain
- Dynamic erosion effects
- Seasonal terrain changes
- Multi-layer terrain depth

---

**Note**: This phase significantly increases visual quality but also computational complexity. Monitor performance closely during implementation!