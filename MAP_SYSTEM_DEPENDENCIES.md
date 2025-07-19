# MAP SYSTEM DEPENDENCIES ANALYSIS

## Overview
This document tracks ALL references to the current map/world generation system to ensure safe replacement with a new system.

## Current Map System Files
- `scripts/world/UnifiedWorldManager.gd` - Core world system
- `scripts/world/SimpleChunkRenderer.gd` - Visual rendering system

## Dependencies Found

### 1. Save/Load Systems
**RunData.gd** - **CRITICAL DEPENDENCY**
- Lines 23-25: `world_seed`, `current_chunk_position`, `explored_chunks`
- Lines 29, 35-36, 39-40, 46: Multiple chunk-coordinate based data structures
- Methods dependent on chunks:
  - `add_magical_structure(chunk_coord)` - Links POIs to chunks
  - `set_l_system_seed(chunk_coord)` - Per-chunk generation seeds
  - `save_magical_terrain_modification(chunk_coord)` - Terrain changes
  - `set_biome_evolution_level(chunk_coord)` - Biome progression
  - `get_magical_structures_in_chunk(chunk_coord)`
  - `get_l_system_seed_for_chunk(chunk_coord)`

**SaveManager.gd** - **MODERATE DEPENDENCY**
- Lines 342-344: Saves world_seed from GameManager
- References to "world_generator" group (line 346)

**GameManager.gd** - **CRITICAL DEPENDENCY** 
- Lines 26-30: Chunk system state management
- Lines 47-49: Chunk loading signals  
- Lines 66-70: UnifiedWorldManager integration
- Lines 189-216: World initialization methods
- Lines 217-257: Chunk system update loop
- Lines 272-286: Chunk query API methods
- Lines 439-461: Biome detection for spell interactions

### 2. Enemy Spawning Systems  
**EnemySpawner.gd** - **CRITICAL DEPENDENCY**
- Lines 376, 391, 405, 496, 501: References to UnifiedWorldManager
- Methods using world system:
  - `_get_chunk_spawn_position()` - Gets spawn positions from chunk data
  - `_get_chunk_preferred_enemy_type()` - Gets biome-appropriate enemy types  
  - `get_enemy_spawn_position()` - API method used by spawner
  - `get_preferred_enemy_type()` - API method for biome-based enemies
  - `is_chunk_spawning_available()` - Checks if chunk system is active
- Uses group "unified_world" to find world manager
- **Fallback system**: Has `chunk_spawn_fallback` for old random spawning if chunks unavailable

### 3. Debug/UI Systems
**ChunkDebugUI.gd** - **CRITICAL DEPENDENCY**
- Line 19: `var unified_world_manager: UnifiedWorldManager`
- Lines 66, 70-73: Looks for UnifiedWorldManager at specific node path
- Lines 117-134: Displays world system info (chunks, seed, player position)
- Lines 154-204: All debug buttons call UnifiedWorldManager methods:
  - `toggle_debug_borders()`, `toggle_transition_indicators()`
  - `toggle_enhanced_terrain()`, `toggle_shader_enhancement()`

**UnifiedDebugSystem.gd** - **UNKNOWN DEPENDENCY** (needs checking)

**ChunkLoadingScreen.gd** - **LIKELY DEPENDENCY** (needs checking)

### 4. Core Scene Integration
**Main.gd** - **CRITICAL DEPENDENCY**
- Line 8: `@onready var unified_world_manager: UnifiedWorldManager`
- Lines 15-16: Sets player reference for chunk system
- Lines 199-231: Chunk loading screen management
- Lines 285-300: UnifiedWorldManager initialization checks
- Lines 302-308: ChunkDebugUI setup

**ChunkLoadingScreen.gd** - **CRITICAL DEPENDENCY** 
- Line 4: Direct dependency on UnifiedWorldManager
- Lines 47-53: Connects to GameManager chunk loading signals
- Lines 89-92: Queries world manager for chunk count display
- Lines 223-228: Emergency fallback using `force_complete_generation()`

### 5. API Dependencies & Method Calls
**Required UnifiedWorldManager API:**
- `initialize_world(spawn_position)` - Core initialization
- `get_world_info()` - Status queries  
- `world_to_chunk_coord(position)` - Position conversion
- `get_chunks_in_radius(position, radius)` - Area queries
- `get_chunk_at_position(position)` - Chunk data access
- `get_enemy_spawn_position(position)` - Enemy spawning
- `get_preferred_enemy_type(position)` - Biome-based enemies
- `is_chunk_spawning_available()` - System status
- `force_complete_generation()` - Emergency completion
- `cleanup()` - Shutdown
- `update_seed(seed)` - Seed management
- `update_player_position(position)` - Position tracking

**Required SimpleChunkRenderer API:**
- `create_chunk_visual_with_poi(coord, poi_type)` - Visual creation
- `get_cache_stats()` - Performance monitoring

## Search Keywords Used
- UnifiedWorldManager
- SimpleChunkRenderer
- HeavyChunkLoader (legacy)
- ChunkData
- BiomeType
- POIType
- chunk_coord
- biome_type
- poi_type
- world_seed
- get_chunk_at_position
- get_chunks_in_radius
- world_to_chunk_coord

## Replacement Strategy
**For dropping in a new map generation system, you MUST:**

1. **Maintain API Compatibility**: New system must implement ALL the UnifiedWorldManager API methods listed above
2. **Use Same Node Groups**: Place new world manager in "unified_world" group  
3. **Preserve Save Data**: Handle world_seed, chunk coordinates, and all chunk-based save data
4. **Signal Compatibility**: Emit same signals (world_initialized, chunk_generated, etc.)
5. **Debug Integration**: Support debug methods called by ChunkDebugUI
6. **Scene Structure**: Replace UnifiedWorldManager node in Main scene without breaking @onready references

**Migration Steps:**
1. Create new world system with UnifiedWorldManager-compatible API
2. Test save/load compatibility with existing RunData structure
3. Verify EnemySpawner integration works with fallback system
4. Update ChunkDebugUI to work with new system
5. Test loading screen integration
6. Replace node in Main.tscn and update any @onready references

## Files Checked
✅ **Core Systems (11 files):**
- GameManager.gd, Main.gd, EnemySpawner.gd
- RunData.gd, SaveManager.gd, MetaSaveManager.gd, RunSaveManager.gd
- ChunkLoadingScreen.gd, ChunkDebugUI.gd
- UnifiedWorldManager.gd, SimpleChunkRenderer.gd

✅ **Search Coverage:**
- All /scripts directories scanned
- All files containing "UnifiedWorldManager", "SimpleChunkRenderer", "chunk", "biome", "poi" keywords analyzed
- Node group references ("unified_world") documented
- API method calls catalogued

**Result**: Found 11 files with direct dependencies, 2 core files to replace, extensive API compatibility required.

---
*Analysis in progress...*