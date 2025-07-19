# Core Map Generation System

## Overview
This document contains the essential code for generating the infinite world map with biomes, chunks, and terrain.

## Core Components

### 1. UnifiedWorldManager.gd - Main World Controller
**Purpose**: Manages chunk loading/unloading and world state
**Key Functions**:
- `initialize_world()` - Sets up world system
- `_generate_chunk()` - Creates individual chunks
- `_world_to_chunk()` - Position conversion
- `get_chunk_at_position()` - Retrieves chunk data

```gdscript
# Core chunk management
const CHUNK_SIZE = 2048
const ACTIVE_RADIUS = 4  # 9x9 grid around player

class ChunkData:
    var coord: Vector2i
    var biome_type: int
    var world_position: Vector2
    var generation_seed: int
    
    func _determine_biome(coord: Vector2i, seed: int) -> int:
        var noise_gen = FastNoiseLite.new()
        noise_gen.seed = seed
        noise_gen.frequency = 0.1
        var biome_noise = noise_gen.get_noise_2d(coord.x * 0.5, coord.y * 0.5)
        
        if biome_noise < -0.75: return 2  # ICE_FIELDS
        elif biome_noise < -0.5: return 6  # DARK_FOREST
        elif biome_noise < -0.25: return 3  # POISON_SWAMPS
        elif biome_noise < 0.0: return 0  # PLAINS
        elif biome_noise < 0.25: return 7  # DESERT_RUINS
        elif biome_noise < 0.5: return 1  # FIRE_CAVES
        elif biome_noise < 0.75: return 5  # VOLCANIC_CHAMBER
        else: return 4  # CRYSTAL_CAVERNS

func _generate_chunk(coord: Vector2i):
    var chunk_data = ChunkData.new(coord, world_seed)
    active_chunks[coord] = chunk_data
    
    var chunk_visual = chunk_renderer.create_chunk_visual_with_poi(coord, chunk_data.poi_type)
    chunk_visual.position = chunk_data.world_position
    add_child(chunk_visual)
    chunk_visuals[coord] = chunk_visual
```

### 2. SimpleChunkRenderer.gd - Visual Generation
**Purpose**: Creates the visual appearance of chunks with biome blending
**Key Functions**:
- `create_chunk_visual_with_poi()` - Main chunk creation
- `_get_biome_influences()` - Calculates biome blending
- `_blend_biome_colors()` - Smooth color transitions
- `_create_gradient_background()` - Seamless chunk backgrounds

```gdscript
# Biome colors
var biome_colors = {
    0: Color(0.4, 0.8, 0.2, 1.0),  # PLAINS - bright grass green
    1: Color(1.0, 0.3, 0.1, 1.0),  # FIRE_CAVES - bright red-orange
    2: Color(0.6, 0.9, 1.0, 1.0),  # ICE_FIELDS - bright icy blue
    3: Color(0.8, 0.6, 0.8, 1.0),  # POISON_SWAMPS - purple-pink
    4: Color(0.9, 0.7, 1.0, 1.0),  # CRYSTAL_CAVERNS - bright purple
    5: Color(0.9, 0.5, 0.1, 1.0),  # VOLCANIC_CHAMBER - bright orange
    6: Color(0.2, 0.5, 0.2, 1.0),  # DARK_FOREST - dark green
    7: Color(1.0, 0.8, 0.4, 1.0)   # DESERT_RUINS - bright sandy yellow
}

# Enhanced biome blending - samples 17 points around chunk
func _get_biome_influences(chunk_coord: Vector2i) -> Dictionary:
    var influences = {}
    var sample_points = [
        Vector2i(0, 0),      # Center
        Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1),    # Adjacent
        Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1),  # Diagonal
        Vector2i(-2, 0), Vector2i(2, 0), Vector2i(0, -2), Vector2i(0, 2),    # Far cardinal
        Vector2i(-2, -2), Vector2i(2, -2), Vector2i(-2, 2), Vector2i(2, 2)   # Far diagonal
    ]
    
    for point in sample_points:
        var sample_coord = chunk_coord + point
        var biome_noise = noise.get_noise_2d(sample_coord.x * BIOME_SCALE, sample_coord.y * BIOME_SCALE)
        var biome_type = _calculate_biome_type(biome_noise)
        
        var distance = point.length()
        var weight = 1.0 / (1.0 + distance * 0.3)
        weight *= exp(-distance * distance * 0.1)  # Gaussian falloff
        
        if biome_type in influences:
            influences[biome_type] += weight
        else:
            influences[biome_type] = weight
    
    return influences

# HSV color blending for natural transitions
func _blend_biome_colors(influences: Dictionary) -> Color:
    var final_color = Color.BLACK
    var total_weight = 0.0
    
    for biome_type in influences:
        var weight = influences[biome_type]
        var biome_color = biome_colors.get(biome_type, Color.GRAY)
        var smooth_weight = _smooth_step(weight)
        var hsv_color = _rgb_to_hsv(biome_color)
        final_color += _hsv_to_rgb(hsv_color) * smooth_weight
        total_weight += smooth_weight
    
    if total_weight > 0:
        final_color /= total_weight
    
    return _enhance_color_transition(final_color, influences)

# Smooth chunk backgrounds with 4x4 gradient
func _create_gradient_background(chunk_node: Node2D, chunk_coord: Vector2i):
    var grid_size = 4
    var tile_size = CHUNK_SIZE / grid_size
    
    for gx in range(grid_size):
        for gy in range(grid_size):
            var tile_pos = Vector2(gx * tile_size, gy * tile_size)
            var world_pos = Vector2(chunk_coord.x * CHUNK_SIZE, chunk_coord.y * CHUNK_SIZE) + tile_pos
            var sample_coord = _world_to_chunk_coord(world_pos + Vector2(tile_size/2, tile_size/2))
            var influences = _get_biome_influences(sample_coord)
            var tile_color = _blend_biome_colors(influences)
            tile_color = _add_enhanced_color_variation(sample_coord, tile_color)
            
            var tile = ColorRect.new()
            tile.size = Vector2(tile_size, tile_size)
            tile.position = tile_pos
            tile.color = tile_color
            chunk_node.add_child(tile)
```

### 3. Biome-Specific Decorations
**Purpose**: Adds unique visual elements to each biome
```gdscript
# Poisson disk sampling for natural decoration placement
func _generate_poisson_disk_decorations(chunk_coord: Vector2i, biome_type: int) -> Array:
    var decorations = []
    var min_distance = _get_biome_decoration_density(biome_type)
    var rng = RandomNumberGenerator.new()
    rng.seed = chunk_coord.x * 1000 + chunk_coord.y
    
    # Generate decorations using Poisson disk sampling
    var seed_pos = Vector2(rng.randf() * CHUNK_SIZE, rng.randf() * CHUNK_SIZE)
    decorations.append({"position": seed_pos, "type": "patch"})
    
    # Continue sampling until max decorations or no valid positions
    while decorations.size() < 50:
        # Sample around existing decorations
        var current = decorations[rng.randi() % decorations.size()].position
        var found = false
        
        for attempt in range(30):
            var angle = rng.randf() * TAU
            var distance = min_distance + rng.randf() * min_distance
            var candidate = current + Vector2.from_angle(angle) * distance
            
            if _is_valid_decoration_position(candidate, decorations, min_distance):
                decorations.append({"position": candidate, "type": "patch"})
                found = true
                break
        
        if not found:
            break
    
    return decorations

# Biome-specific decoration types
func _get_decoration_type_for_biome(biome_type: int) -> String:
    match biome_type:
        0: return "grass_patches"      # PLAINS
        1: return "lava_cracks"        # FIRE_CAVES
        2: return "ice_shards"         # ICE_FIELDS
        3: return "poison_bubbles"     # POISON_SWAMPS
        4: return "crystal_formations" # CRYSTAL_CAVERNS
        5: return "lava_cracks"        # VOLCANIC_CHAMBER
        6: return "tree_stumps"        # DARK_FOREST
        7: return "rune_stones"        # DESERT_RUINS
        _: return "basic"
```

### 4. Noise-Based Terrain Generation
**Purpose**: Creates natural-looking terrain variations
```gdscript
# Multi-layer noise for realistic terrain
func _get_layered_noise(pos: Vector2) -> float:
    var noise1 = noise.get_noise_2d(pos.x * 0.005, pos.y * 0.005) * 0.5  # Large features
    var noise2 = noise.get_noise_2d(pos.x * 0.01, pos.y * 0.01) * 0.3    # Medium features
    var noise3 = noise.get_noise_2d(pos.x * 0.02, pos.y * 0.02) * 0.2    # Fine details
    return noise1 + noise2 + noise3

# Enhanced color variation with neighbor influence
func _add_enhanced_color_variation(chunk_coord: Vector2i, base_color: Color) -> Color:
    var world_pos = Vector2(chunk_coord.x * CHUNK_SIZE, chunk_coord.y * CHUNK_SIZE)
    var macro_variation = _get_macro_variation(world_pos)
    var micro_variation = _get_micro_variation(world_pos)
    var combined_variation = macro_variation * 0.7 + micro_variation * 0.3
    
    var variation_strength = 0.12
    var smooth_variation = _smooth_step(abs(combined_variation)) * sign(combined_variation)
    
    var result_color = base_color
    if smooth_variation > 0:
        result_color = base_color.lightened(smooth_variation * variation_strength)
    else:
        result_color = base_color.darkened(abs(smooth_variation) * variation_strength)
    
    return _add_neighbor_gradient(chunk_coord, result_color)

# Smooth transitions between chunks
func _add_neighbor_gradient(chunk_coord: Vector2i, base_color: Color) -> Color:
    var neighbor_coords = [
        Vector2i(chunk_coord.x - 1, chunk_coord.y),     # Left
        Vector2i(chunk_coord.x + 1, chunk_coord.y),     # Right
        Vector2i(chunk_coord.x, chunk_coord.y - 1),     # Up
        Vector2i(chunk_coord.x, chunk_coord.y + 1)      # Down
    ]
    
    var gradient_color = base_color
    var total_weight = 1.0
    
    for neighbor_coord in neighbor_coords:
        var neighbor_influences = _get_biome_influences(neighbor_coord)
        var neighbor_color = _blend_biome_colors(neighbor_influences)
        var influence_weight = 0.05  # Subtle influence
        gradient_color += neighbor_color * influence_weight
        total_weight += influence_weight
    
    return gradient_color / total_weight
```

## GPU Shaders (Optional Enhancement)

### Enhanced Terrain Shader
```glsl
shader_type canvas_item;

uniform sampler2D height_noise;
uniform sampler2D detail_noise;
uniform sampler2D micro_noise;
uniform int dominant_biome;
uniform vec2 world_offset;

vec3 get_biome_color(int biome) {
    if (biome == 0) return vec3(0.2, 0.8, 0.2);      // PLAINS
    else if (biome == 1) return vec3(1.0, 0.2, 0.0); // FIRE_CAVES
    else if (biome == 2) return vec3(0.4, 0.8, 1.0); // ICE_FIELDS
    // ... other biomes
}

void fragment() {
    vec2 world_pos = (UV * vec2(textureSize(TEXTURE, 0)) + world_offset) * 0.01;
    
    float height_val = texture(height_noise, world_pos * 0.5).r;
    float detail_val = texture(detail_noise, world_pos * 2.0).r;
    float micro_val = texture(micro_noise, world_pos * 8.0).r;
    
    vec3 base_color = texture(TEXTURE, UV).rgb;
    
    // Height-based lighting
    float lighting = 0.5 + (height_val - 0.5) * 2.0;
    base_color *= clamp(lighting, 0.2, 1.8);
    
    // Detail patterns
    if (detail_val > 0.1) {
        float detail_intensity = (detail_val - 0.1) * 3.0;
        base_color = mix(base_color, base_color * 2.5, clamp(detail_intensity, 0.0, 1.0));
    }
    
    COLOR = vec4(clamp(base_color, 0.0, 1.0), 1.0);
}
```

## Key Features

1. **Infinite World**: Chunks load/unload around player automatically
2. **8 Biome Types**: Each with unique colors and decorations
3. **Smooth Transitions**: 17-point sampling with Gaussian falloff
4. **Performance Optimized**: Caching system for biome calculations
5. **Natural Decoration**: Poisson disk sampling for organic placement
6. **Multi-layer Noise**: Realistic terrain variation at multiple scales

## Configuration
- **Chunk Size**: 2048x2048 pixels
- **Active Radius**: 4 chunks (9x9 grid)
- **Biome Scale**: 0.5 (controls biome region size)
- **Cache Limits**: 10,000 biome entries, 5,000 color entries

This system creates an infinite world with seamless biome transitions and natural-looking terrain variations.