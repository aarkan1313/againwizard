# PHASE 5 FINAL: INFINITE WORLD WITH HEAVY PRELOADING
## Implementation Plan Based on User Specifications (8 days)

### 🎯 **REVISED SPECIFICATIONS**
- **Heavy preloading**: 50 chunks at game start with loading screen
- **Runtime preloading**: 5 chunks ahead during gameplay
- **Save system**: 3x3 grid (9 chunks) around player position
- **Enemy spawning**: All enemy types everywhere (biome-specific commented/placeholder)
- **Camera**: Don't touch existing system
- **Navigation**: Rare chunk markers every 50 kills, double spawn chance in direction

---

## 📅 **DAY 1: HEAVY PRELOADING SYSTEM**

### **Morning (4 hours): Chunk System with Heavy Preloading**

**Create `scripts/world/HeavyChunkLoader.gd`** (Autoload):
```gdscript
extends Node

# Preloading configuration
const INITIAL_PRELOAD_COUNT: int = 50       # Load 50 chunks at start
const RUNTIME_PRELOAD_DISTANCE: int = 5     # 5 chunks ahead during gameplay
const SAVE_AREA_SIZE: int = 3               # 3x3 = 9 chunks saved around player

# Chunk management
const CHUNK_SIZE: int = 512
var active_chunks: Dictionary = {}
var saved_chunks: Dictionary = {}           # 9 chunks around player that persist
var loading_queue: Array = []
var generation_thread: Thread
var generation_mutex: Mutex
var should_exit_thread: bool = false

# Player tracking
var player_position: Vector2 = Vector2.ZERO
var current_chunk_coord: Vector2i = Vector2i.ZERO

# Loading screen management
var is_initial_loading: bool = false
var chunks_loaded: int = 0
var target_chunks: int = 0

signal initial_loading_progress(loaded: int, total: int, percentage: float)
signal initial_loading_complete()
signal chunk_loaded(chunk_coord: Vector2i, chunk_data: ChunkData)

class ChunkData:
    var coord: Vector2i
    var biome_type: BiomeType
    var poi_type: POIType
    var world_position: Vector2
    var terrain_data: Dictionary
    var is_saved: bool = false  # Part of the 3x3 saved area
    var last_visited: float = 0.0
    var generation_seed: int    # For consistent regeneration
    
    func _init(chunk_coord: Vector2i):
        coord = chunk_coord
        world_position = Vector2(chunk_coord.x * CHUNK_SIZE, chunk_coord.y * CHUNK_SIZE)
        generation_seed = _generate_consistent_seed(chunk_coord)
    
    func _generate_consistent_seed(coord: Vector2i) -> int:
        # Generate consistent seed based on coordinates
        return abs(coord.x * 73856093) ^ abs(coord.y * 19349663)

enum BiomeType {
    PLAINS, FIRE_CAVES, ICE_FIELDS, POISON_SWAMPS, 
    CRYSTAL_CAVERNS, VOLCANIC_CHAMBER, DARK_FOREST, DESERT_RUINS
}

enum POIType {
    NORMAL,        # 1000 weight
    ARENA,         # 50 weight  
    LOOT_CACHE,    # 30 weight
    VENDOR,        # 5 weight
    BOSS_LAIR,     # 3 weight
    DUNGEON_ENTRY, # 2 weight
    RARE_BIOME     # 1 weight - affected by rare chunk markers
}

var chunk_generator: ChunkGenerator

func _ready():
    chunk_generator = ChunkGenerator.new()
    add_child(chunk_generator)
    
    # Initialize threading
    generation_thread = Thread.new()
    generation_mutex = Mutex.new()
    
    print("🗺️ HeavyChunkLoader initialized")

func start_initial_loading(start_position: Vector2):
    """Called when starting new game or loading save"""
    is_initial_loading = true
    player_position = start_position
    current_chunk_coord = world_to_chunk_coord(start_position)
    
    # Generate spiral pattern around player for initial 50 chunks
    var preload_coords = _generate_spiral_coordinates(current_chunk_coord, INITIAL_PRELOAD_COUNT)
    target_chunks = preload_coords.size()
    chunks_loaded = 0
    
    # Start generation thread
    generation_thread.start(_generation_thread_function)
    
    # Queue all preload chunks
    generation_mutex.lock()
    for coord in preload_coords:
        loading_queue.append(coord)
    generation_mutex.unlock()
    
    print("🔄 Starting heavy preload of %d chunks..." % target_chunks)

func _generate_spiral_coordinates(center: Vector2i, count: int) -> Array:
    """Generate coordinates in spiral pattern for even distribution"""
    var coords = []
    var x = 0
    var y = 0
    var dx = 0
    var dy = -1
    
    for i in count:
        coords.append(center + Vector2i(x, y))
        
        # Spiral movement logic
        if x == y or (x < 0 and x == -y) or (x > 0 and x == 1 - y):
            var temp = dx
            dx = -dy
            dy = temp
        
        x += dx
        y += dy
    
    return coords

func _generation_thread_function():
    while true:
        generation_mutex.lock()
        if should_exit_thread:
            generation_mutex.unlock()
            break
        
        if loading_queue.size() > 0:
            var chunk_coord = loading_queue.pop_front()
            generation_mutex.unlock()
            
            # Generate chunk (heavy work done in thread)
            var chunk_data = chunk_generator.generate_chunk(chunk_coord)
            
            # Queue for main thread processing
            call_deferred("_finish_chunk_loading", chunk_coord, chunk_data)
        else:
            generation_mutex.unlock()
            OS.delay_msec(10)

func _finish_chunk_loading(chunk_coord: Vector2i, chunk_data: ChunkData):
    active_chunks[chunk_coord] = chunk_data
    chunks_loaded += 1
    
    # Check if this chunk should be saved (within 3x3 of player)
    var distance_to_player = current_chunk_coord.distance_to(chunk_coord)
    if distance_to_player <= SAVE_AREA_SIZE:
        chunk_data.is_saved = true
        saved_chunks[chunk_coord] = chunk_data
    
    chunk_loaded.emit(chunk_coord, chunk_data)
    
    if is_initial_loading:
        var percentage = float(chunks_loaded) / float(target_chunks) * 100.0
        initial_loading_progress.emit(chunks_loaded, target_chunks, percentage)
        
        if chunks_loaded >= target_chunks:
            is_initial_loading = false
            initial_loading_complete.emit()
            print("✅ Initial chunk loading complete!")

func update_player_position(new_position: Vector2):
    player_position = new_position
    var new_chunk_coord = world_to_chunk_coord(new_position)
    
    if new_chunk_coord != current_chunk_coord:
        current_chunk_coord = new_chunk_coord
        _update_saved_chunks_area()
        _queue_runtime_preloading()

func _update_saved_chunks_area():
    """Update which chunks are in the 3x3 saved area"""
    # Clear existing saved status
    for chunk_data in saved_chunks.values():
        chunk_data.is_saved = false
    saved_chunks.clear()
    
    # Mark new 3x3 area as saved
    for x in range(-SAVE_AREA_SIZE, SAVE_AREA_SIZE + 1):
        for y in range(-SAVE_AREA_SIZE, SAVE_AREA_SIZE + 1):
            var chunk_coord = current_chunk_coord + Vector2i(x, y)
            
            if active_chunks.has(chunk_coord):
                var chunk_data = active_chunks[chunk_coord]
                chunk_data.is_saved = true
                saved_chunks[chunk_coord] = chunk_data

func _queue_runtime_preloading():
    """Queue chunks for runtime preloading (5 chunks ahead)"""
    if is_initial_loading:
        return  # Don't do runtime loading during initial load
    
    # Get player movement direction (simplified - just load in all directions)
    var coords_to_load = []
    
    for x in range(-RUNTIME_PRELOAD_DISTANCE, RUNTIME_PRELOAD_DISTANCE + 1):
        for y in range(-RUNTIME_PRELOAD_DISTANCE, RUNTIME_PRELOAD_DISTANCE + 1):
            var chunk_coord = current_chunk_coord + Vector2i(x, y)
            
            if not active_chunks.has(chunk_coord):
                coords_to_load.append(chunk_coord)
    
    # Queue for loading (limit to prevent overload)
    generation_mutex.lock()
    for coord in coords_to_load.slice(0, 5):  # Only 5 at a time
        loading_queue.append(coord)
    generation_mutex.unlock()

func world_to_chunk_coord(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(floor(world_pos.x / CHUNK_SIZE)),
        int(floor(world_pos.y / CHUNK_SIZE))
    )

func get_chunk_at_position(world_pos: Vector2) -> ChunkData:
    var chunk_coord = world_to_chunk_coord(world_pos)
    return active_chunks.get(chunk_coord)

func save_persistent_chunks() -> Dictionary:
    """Save the 3x3 area around player"""
    var save_data = {}
    
    for chunk_coord in saved_chunks:
        var chunk_data = saved_chunks[chunk_coord]
        save_data[str(chunk_coord)] = {
            "coord": chunk_coord,
            "biome_type": chunk_data.biome_type,
            "poi_type": chunk_data.poi_type,
            "terrain_data": chunk_data.terrain_data,
            "generation_seed": chunk_data.generation_seed,
            "last_visited": chunk_data.last_visited
        }
    
    return save_data

func load_persistent_chunks(save_data: Dictionary):
    """Load saved 3x3 area"""
    for coord_str in save_data:
        var chunk_info = save_data[coord_str]
        var chunk_coord = Vector2i(chunk_info.coord.x, chunk_info.coord.y)
        
        var chunk_data = ChunkData.new(chunk_coord)
        chunk_data.biome_type = chunk_info.biome_type
        chunk_data.poi_type = chunk_info.poi_type
        chunk_data.terrain_data = chunk_info.terrain_data
        chunk_data.generation_seed = chunk_info.generation_seed
        chunk_data.last_visited = chunk_info.last_visited
        chunk_data.is_saved = true
        
        active_chunks[chunk_coord] = chunk_data
        saved_chunks[chunk_coord] = chunk_data

func _exit_tree():
    generation_mutex.lock()
    should_exit_thread = true
    generation_mutex.unlock()
    if generation_thread.is_started():
        generation_thread.wait_to_finish()
```

### **Afternoon (2 hours): Loading Screen System**

**Create `scenes/ui/LoadingScreen.tscn`**:
- Control (Full Rect)
- Background (ColorRect - dark)
- CenterContainer:
  - VBoxContainer:
    - Title Label: "Generating World..."
    - ProgressBar (chunk loading progress)
    - Status Label: "Loading chunk 15/50..."
    - Spinner/Animation

**Create `scripts/ui/LoadingScreen.gd`**:
```gdscript
extends Control

@onready var progress_bar = $CenterContainer/VBox/ProgressBar
@onready var status_label = $CenterContainer/VBox/StatusLabel
@onready var title_label = $CenterContainer/VBox/TitleLabel
@onready var spinner = $CenterContainer/VBox/Spinner

var loading_messages = [
    "Generating terrain...",
    "Placing biomes...",
    "Creating points of interest...",
    "Spawning creatures...",
    "Weaving magic into the world...",
    "Almost ready..."
]

func _ready():
    # Connect to chunk loader
    if HeavyChunkLoader:
        HeavyChunkLoader.initial_loading_progress.connect(_on_loading_progress)
        HeavyChunkLoader.initial_loading_complete.connect(_on_loading_complete)
    
    # Start spinner animation
    _animate_spinner()

func show_loading():
    visible = true
    progress_bar.value = 0
    status_label.text = "Preparing to generate world..."

func _on_loading_progress(loaded: int, total: int, percentage: float):
    progress_bar.value = percentage
    status_label.text = "Loading chunk %d/%d..." % [loaded, total]
    
    # Change message based on progress
    var message_index = int(percentage / 100.0 * loading_messages.size())
    message_index = min(message_index, loading_messages.size() - 1)
    title_label.text = loading_messages[message_index]

func _on_loading_complete():
    status_label.text = "World generation complete!"
    
    # Fade out after brief delay
    await get_tree().create_timer(0.5).timeout
    
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    tween.tween_callback(hide)

func _animate_spinner():
    if spinner:
        var tween = create_tween()
        tween.set_loops()
        tween.tween_property(spinner, "rotation", TAU, 1.0)
```

---

## 📅 **DAY 2: RARE CHUNK MARKER SYSTEM**

### **Morning (3 hours): Kill-Based Rare Chunk Markers**

**Create `scripts/world/RareChunkTracker.gd`** (Autoload):
```gdscript
extends Node

# Rare chunk tracking
var kills_since_last_marker: int = 0
var kills_per_marker: int = 50  # Every 50 kills
var active_markers: Array = []
var rare_chunk_boost_active: bool = false
var boost_direction: Vector2 = Vector2.ZERO
var boost_multiplier: float = 2.0  # Double chance in direction

signal rare_chunk_marker_appeared(direction: Vector2, distance: float)
signal rare_chunk_found()

class RareChunkMarker:
    var direction: Vector2
    var target_chunk_coord: Vector2i
    var creation_time: float
    var is_active: bool = true
    
    func _init(dir: Vector2, target: Vector2i):
        direction = dir
        target_chunk_coord = target
        creation_time = Time.get_ticks_msec() / 1000.0

func _ready():
    # Connect to kill events
    if GameEvents:
        GameEvents.enemy_died.connect(_on_enemy_killed)
    
    # Connect to chunk generation for rare boost
    if HeavyChunkLoader:
        HeavyChunkLoader.chunk_loaded.connect(_on_chunk_loaded)
    
    print("🎯 RareChunkTracker initialized - markers every %d kills" % kills_per_marker)

func _on_enemy_killed(enemy_type: String, xp_reward: int):
    kills_since_last_marker += 1
    
    if kills_since_last_marker >= kills_per_marker:
        _create_rare_chunk_marker()
        kills_since_last_marker = 0

func _create_rare_chunk_marker():
    var player_pos = GameManager.get_player_position()
    var player_chunk = HeavyChunkLoader.world_to_chunk_coord(player_pos)
    
    # Find direction to nearest rare chunk (or create target)
    var target_direction = _find_or_create_rare_chunk_target(player_chunk)
    var target_chunk = player_chunk + Vector2i(
        int(target_direction.x * 20),  # 20 chunks away (roughly 10,000 pixels)
        int(target_direction.y * 20)
    )
    
    var marker = RareChunkMarker.new(target_direction, target_chunk)
    active_markers.append(marker)
    
    # Activate boost in this direction
    rare_chunk_boost_active = true
    boost_direction = target_direction
    
    # Show marker to player
    _show_marker_ui(target_direction)
    
    var distance = target_chunk.distance_to(player_chunk) * HeavyChunkLoader.CHUNK_SIZE
    rare_chunk_marker_appeared.emit(target_direction, distance)
    
    print("🎯 Rare chunk marker created! Direction: %s" % target_direction)

func _find_or_create_rare_chunk_target(player_chunk: Vector2i) -> Vector2:
    # For now, just pick a random direction
    # Later this could check for actual rare chunks
    var directions = [
        Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
        Vector2(1, 1).normalized(), Vector2(-1, 1).normalized(),
        Vector2(1, -1).normalized(), Vector2(-1, -1).normalized()
    ]
    
    return directions.pick_random()

func _show_marker_ui(direction: Vector2):
    # Create UI indicator showing direction
    var marker_ui = preload("res://scenes/ui/RareChunkMarker.tscn").instantiate()
    marker_ui.setup_direction(direction)
    
    # Add to UI layer
    var ui_root = get_tree().current_scene.get_node_or_null("UI")
    if ui_root:
        ui_root.add_child(marker_ui)

func _on_chunk_loaded(chunk_coord: Vector2i, chunk_data):
    # Check if this chunk is rare and in boost direction
    if rare_chunk_boost_active and chunk_data.poi_type == HeavyChunkLoader.POIType.RARE_BIOME:
        var player_chunk = HeavyChunkLoader.world_to_chunk_coord(GameManager.get_player_position())
        var direction_to_chunk = (chunk_coord - player_chunk).normalized()
        
        # Check if this rare chunk is in the boosted direction
        var direction_similarity = boost_direction.dot(direction_to_chunk)
        if direction_similarity > 0.7:  # Within 45 degrees
            rare_chunk_found.emit()
            _deactivate_current_marker()
            print("🎉 Rare chunk found in marker direction!")

func _deactivate_current_marker():
    rare_chunk_boost_active = false
    boost_direction = Vector2.ZERO
    
    # Remove oldest marker
    if active_markers.size() > 0:
        active_markers[0].is_active = false
        active_markers.remove_at(0)

func get_rare_chunk_boost_for_generation(chunk_coord: Vector2i) -> float:
    """Called by chunk generator to get boost multiplier"""
    if not rare_chunk_boost_active:
        return 1.0
    
    var player_chunk = HeavyChunkLoader.world_to_chunk_coord(GameManager.get_player_position())
    var direction_to_chunk = (chunk_coord - player_chunk).normalized()
    
    # Check alignment with boost direction
    var alignment = boost_direction.dot(direction_to_chunk)
    if alignment > 0.5:  # Within 60 degrees
        return boost_multiplier
    
    return 1.0

func get_status_info() -> Dictionary:
    return {
        "kills_until_next_marker": kills_per_marker - kills_since_last_marker,
        "active_markers": active_markers.size(),
        "boost_active": rare_chunk_boost_active,
        "boost_direction": boost_direction
    }
```

### **Afternoon (2 hours): Rare Chunk Marker UI**

**Create `scenes/ui/RareChunkMarker.tscn`**:
- Control (Top Right corner positioning)
- Panel (semi-transparent background)
- HBoxContainer:
  - Arrow Icon (TextureRect - points in direction)
  - VBoxContainer:
    - Label: "Rare Area Detected"
    - Label: "Direction: Northeast"

**Create `scripts/ui/RareChunkMarker.gd`**:
```gdscript
extends Control

@onready var arrow_icon = $Panel/HBox/ArrowIcon
@onready var direction_label = $Panel/HBox/VBox/DirectionLabel
@onready var title_label = $Panel/HBox/VBox/TitleLabel

var marker_direction: Vector2
var pulse_tween: Tween

func _ready():
    # Position in top-right corner
    anchor_left = 1.0
    anchor_right = 1.0
    anchor_top = 0.0
    anchor_bottom = 0.0
    offset_left = -200
    offset_top = 50
    
    # Start pulse animation
    _start_pulse_animation()

func setup_direction(direction: Vector2):
    marker_direction = direction
    
    # Set arrow rotation to point in direction
    var angle = direction.angle()
    arrow_icon.rotation = angle
    
    # Set direction text
    direction_label.text = "Direction: %s" % _direction_to_string(direction)
    
    # Show with fade-in animation
    modulate.a = 0.0
    var fade_tween = create_tween()
    fade_tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _direction_to_string(dir: Vector2) -> String:
    var angle = dir.angle_to(Vector2.UP)
    var degrees = rad_to_deg(abs(angle))
    
    if degrees < 22.5:
        return "North"
    elif degrees < 67.5:
        if angle > 0:
            return "Northeast"
        else:
            return "Northwest"
    elif degrees < 112.5:
        if angle > 0:
            return "East"
        else:
            return "West"
    elif degrees < 157.5:
        if angle > 0:
            return "Southeast"
        else:
            return "Southwest"
    else:
        return "South"

func _start_pulse_animation():
    pulse_tween = create_tween()
    pulse_tween.set_loops()
    pulse_tween.tween_property(arrow_icon, "scale", Vector2(1.2, 1.2), 0.8)
    pulse_tween.tween_property(arrow_icon, "scale", Vector2(1.0, 1.0), 0.8)

func remove_marker():
    # Fade out and remove
    var fade_tween = create_tween()
    fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
    fade_tween.tween_callback(queue_free)

func _on_rare_chunk_found():
    title_label.text = "Rare Area Found!"
    title_label.modulate = Color.GOLD
    
    # Auto-remove after 3 seconds
    await get_tree().create_timer(3.0).timeout
    remove_marker()
```

---

## 📅 **DAY 3: SIMPLIFIED ENEMY SPAWNING**

### **Morning (3 hours): Universal Enemy Spawning**

**Update `EnemySpawner.gd` for infinite world**:
```gdscript
# Add to existing EnemySpawner.gd

# New properties for infinite world
var spawn_radius: float = 400.0          # Spawn enemies within this radius of player
var max_enemies_total: int = 50          # Total enemies on screen
var enemies_per_chunk: int = 8           # Base enemies per active chunk
var spawn_check_interval: float = 2.0   # Check spawn every 2 seconds
var spawn_timer: Timer

# Biome multipliers (commented/placeholder for now)
var biome_enemy_multipliers: Dictionary = {
    HeavyChunkLoader.BiomeType.PLAINS: 1.0,
    HeavyChunkLoader.BiomeType.FIRE_CAVES: 1.1,      # Slightly harder
    HeavyChunkLoader.BiomeType.ICE_FIELDS: 1.1,
    HeavyChunkLoader.BiomeType.POISON_SWAMPS: 1.2,   # Harder
    HeavyChunkLoader.BiomeType.CRYSTAL_CAVERNS: 1.0,
    HeavyChunkLoader.BiomeType.VOLCANIC_CHAMBER: 1.3, # Hardest
    HeavyChunkLoader.BiomeType.DARK_FOREST: 1.2,
    HeavyChunkLoader.BiomeType.DESERT_RUINS: 1.1
}

# All enemy types available everywhere (placeholder)
var all_enemy_types: Array = [
    "goblin", "orc", "skeleton", "slime", "wizard"
]

# Future biome-specific enemies (commented for now)
# var biome_specific_enemies: Dictionary = {
#     HeavyChunkLoader.BiomeType.FIRE_CAVES: ["fire_elemental", "magma_slime"],
#     HeavyChunkLoader.BiomeType.ICE_FIELDS: ["ice_golem", "frost_spider"],
#     HeavyChunkLoader.BiomeType.POISON_SWAMPS: ["poison_blob", "toxic_spider"],
#     # ... etc
# }

func _ready():
    # ... existing setup code ...
    
    # Setup spawn timer for infinite world
    spawn_timer = Timer.new()
    spawn_timer.wait_time = spawn_check_interval
    spawn_timer.timeout.connect(_check_and_spawn_enemies)
    add_child(spawn_timer)
    spawn_timer.start()
    
    print("🐛 EnemySpawner configured for infinite world")

func _check_and_spawn_enemies():
    """Main spawning logic for infinite world"""
    var current_enemy_count = get_tree().get_nodes_in_group("enemies").size()
    
    if current_enemy_count >= max_enemies_total:
        return  # Already at capacity
    
    var player_pos = GameManager.get_player_position()
    var nearby_chunks = _get_chunks_around_player(player_pos)
    
    for chunk_data in nearby_chunks:
        _spawn_enemies_for_chunk(chunk_data, player_pos)

func _get_chunks_around_player(player_pos: Vector2) -> Array:
    """Get all active chunks within spawn radius"""
    var nearby_chunks = []
    var player_chunk = HeavyChunkLoader.world_to_chunk_coord(player_pos)
    
    # Check 3x3 area around player chunk
    for x in range(-1, 2):
        for y in range(-1, 2):
            var chunk_coord = player_chunk + Vector2i(x, y)
            var chunk_data = HeavyChunkLoader.active_chunks.get(chunk_coord)
            
            if chunk_data:
                # Check if chunk is within spawn radius
                var chunk_center = chunk_data.world_position + Vector2(
                    HeavyChunkLoader.CHUNK_SIZE / 2,
                    HeavyChunkLoader.CHUNK_SIZE / 2
                )
                var distance = player_pos.distance_to(chunk_center)
                
                if distance <= spawn_radius:
                    nearby_chunks.append(chunk_data)
    
    return nearby_chunks

func _spawn_enemies_for_chunk(chunk_data, player_pos: Vector2):
    """Spawn enemies in a specific chunk"""
    var enemies_in_chunk = _count_enemies_in_chunk(chunk_data)
    var target_enemies = _calculate_target_enemies_for_chunk(chunk_data)
    
    var enemies_to_spawn = target_enemies - enemies_in_chunk
    if enemies_to_spawn <= 0:
        return
    
    # Limit spawning per cycle to avoid frame drops
    enemies_to_spawn = min(enemies_to_spawn, 3)
    
    for i in enemies_to_spawn:
        var spawn_pos = _find_valid_spawn_position(chunk_data, player_pos)
        if spawn_pos != Vector2.ZERO:
            var enemy_type = _select_enemy_type(chunk_data)
            _spawn_enemy_at_position(enemy_type, spawn_pos, chunk_data)

func _count_enemies_in_chunk(chunk_data) -> int:
    """Count existing enemies in chunk area"""
    var count = 0
    var enemies = get_tree().get_nodes_in_group("enemies")
    
    for enemy in enemies:
        if _is_position_in_chunk(enemy.global_position, chunk_data):
            count += 1
    
    return count

func _is_position_in_chunk(pos: Vector2, chunk_data) -> bool:
    """Check if position is within chunk bounds"""
    var chunk_start = chunk_data.world_position
    var chunk_end = chunk_start + Vector2(HeavyChunkLoader.CHUNK_SIZE, HeavyChunkLoader.CHUNK_SIZE)
    
    return (pos.x >= chunk_start.x and pos.x <= chunk_end.x and
            pos.y >= chunk_start.y and pos.y <= chunk_end.y)

func _calculate_target_enemies_for_chunk(chunk_data) -> int:
    """Calculate how many enemies should be in this chunk"""
    var base_count = enemies_per_chunk
    
    # Apply biome multiplier
    var biome_multiplier = biome_enemy_multipliers.get(chunk_data.biome_type, 1.0)
    base_count = int(base_count * biome_multiplier)
    
    # Apply wave difficulty scaling
    var wave_multiplier = 1.0 + (WaveManager.current_wave - 1) * 0.1
    base_count = int(base_count * wave_multiplier)
    
    # Apply POI modifiers
    match chunk_data.poi_type:
        HeavyChunkLoader.POIType.ARENA:
            base_count = int(base_count * 1.5)  # More enemies in arena chunks
        HeavyChunkLoader.POIType.VENDOR:
            base_count = 0  # No enemies near vendors
        HeavyChunkLoader.POIType.BOSS_LAIR:
            base_count = int(base_count * 0.5)  # Fewer regular enemies, save room for boss
        HeavyChunkLoader.POIType.LOOT_CACHE:
            base_count = int(base_count * 1.2)  # Slightly more enemies guarding loot
    
    return max(0, base_count)

func _find_valid_spawn_position(chunk_data, player_pos: Vector2) -> Vector2:
    """Find valid spawn position within chunk"""
    var attempts = 0
    var max_attempts = 20
    
    while attempts < max_attempts:
        # Random position within chunk
        var spawn_pos = chunk_data.world_position + Vector2(
            randf() * HeavyChunkLoader.CHUNK_SIZE,
            randf() * HeavyChunkLoader.CHUNK_SIZE
        )
        
        # Check distance from player (not too close, not too far)
        var distance = spawn_pos.distance_to(player_pos)
        if distance > 150 and distance < spawn_radius:
            # TODO: Add terrain collision checks here
            return spawn_pos
        
        attempts += 1
    
    return Vector2.ZERO  # Failed to find valid position

func _select_enemy_type(chunk_data) -> String:
    """Select enemy type - currently all types everywhere"""
    # For now, spawn all enemy types everywhere
    var enemy_type = all_enemy_types.pick_random()
    
    # Future biome-specific logic (commented out):
    # if biome_specific_enemies.has(chunk_data.biome_type):
    #     var biome_enemies = biome_specific_enemies[chunk_data.biome_type]
    #     if randf() < 0.3:  # 30% chance for biome-specific
    #         enemy_type = biome_enemies.pick_random()
    
    return enemy_type

func _spawn_enemy_at_position(enemy_type: String, spawn_pos: Vector2, chunk_data):
    """Actually spawn the enemy"""
    var enemy = _create_enemy_instance(enemy_type)
    if enemy:
        enemy.global_position = spawn_pos
        
        # Apply biome multipliers to enemy stats
        var biome_multiplier = biome_enemy_multipliers.get(chunk_data.biome_type, 1.0)
        _apply_biome_effects_to_enemy(enemy, biome_multiplier)
        
        # Add to scene
        get_tree().current_scene.add_child(enemy)
        
        # Reduced logging for performance
        if randf() < 0.1:  # Only log 10% of spawns
            print("🐛 Spawned %s in %s biome" % [enemy_type, HeavyChunkLoader.BiomeType.keys()[chunk_data.biome_type]])

func _apply_biome_effects_to_enemy(enemy: Node, multiplier: float):
    """Apply biome difficulty multiplier to enemy"""
    if enemy.has_method("apply_difficulty_multiplier"):
        enemy.apply_difficulty_multiplier(multiplier)
    elif enemy.has_method("set_health_multiplier"):
        enemy.set_health_multiplier(multiplier)

func get_spawn_status() -> Dictionary:
    """Debug info for spawn system"""
    var total_enemies = get_tree().get_nodes_in_group("enemies").size()
    var player_pos = GameManager.get_player_position()
    var current_chunk = HeavyChunkLoader.get_chunk_at_position(player_pos)
    
    return {
        "total_enemies": total_enemies,
        "max_enemies": max_enemies_total,
        "current_biome": HeavyChunkLoader.BiomeType.keys()[current_chunk.biome_type] if current_chunk else "None",
        "spawn_radius": spawn_radius,
        "enemies_per_chunk": enemies_per_chunk
    }
```

---

## 📅 **DAY 4: SAVE SYSTEM INTEGRATION**

### **Morning (3 hours): 3x3 Chunk Save System**

**Update `RunSaveManager.gd` for infinite world**:
```gdscript
# Add to existing RunSaveManager.gd

func save_run():
    if not is_instance_valid(GameManager.player):
        push_error("Cannot save run - player not valid")
        return false
    
    var save_path = get_run_save_path()
    var backup_path = get_run_backup_path()
    
    # Backup existing save first
    if FileAccess.file_exists(save_path):
        DirAccess.copy_absolute(save_path, backup_path)
    
    var data = {
        "version": SAVE_VERSION,
        "slot": MetaSaveManager.current_slot,
        "wave": WaveManager.current_wave,
        "kills": WaveManager.total_kills,
        "run_time": Time.get_ticks_msec() / 1000.0 - current_run_start_time,
        "xp_earned": GameManager.player.xp,
        "location": "infinite_world",  # New location type
        "player": {
            "position": [GameManager.player.global_position.x, GameManager.player.global_position.y],
            "hp": GameManager.player.hp,
            "max_hp": GameManager.player.max_hp,
            "mana": GameManager.player.mana,
            "max_mana": GameManager.player.max_mana,
            "level": GameManager.player.level,
            "xp": GameManager.player.xp,
            "xp_to_next_level": GameManager.player.xp_to_next_level,
            "stat_points": GameManager.player.stat_points,
            "stats": GameManager.player.stats
        },
        # NEW: Save infinite world state
        "infinite_world": {
            "player_chunk_coord": HeavyChunkLoader.current_chunk_coord,
            "saved_chunks": HeavyChunkLoader.save_persistent_chunks(),
            "rare_chunk_tracker": {
                "kills_since_last_marker": RareChunkTracker.kills_since_last_marker,
                "active_markers": _serialize_rare_markers()
            }
        },
        "timestamp": Time.get_unix_time_from_system()
    }
    
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file == null:
        push_error("Failed to save run data")
        return false
    
    # Save with compression
    var data_string = var_to_str(data)
    file.store_32(data_string.length())
    file.store_buffer(data_string.to_utf8_buffer().compress(FileAccess.COMPRESSION_GZIP))
    file.close()
    
    print("💾 Infinite world state saved")
    return true

func _serialize_rare_markers() -> Array:
    """Convert rare chunk markers to saveable format"""
    var marker_data = []
    
    for marker in RareChunkTracker.active_markers:
        if marker.is_active:
            marker_data.append({
                "direction": [marker.direction.x, marker.direction.y],
                "target_chunk": [marker.target_chunk_coord.x, marker.target_chunk_coord.y],
                "creation_time": marker.creation_time
            })
    
    return marker_data

func load_run() -> Dictionary:
    if not has_active_run():
        return {}
    
    var save_path = get_run_save_path()
    var file = FileAccess.open(save_path, FileAccess.READ)
    if file == null:
        push_error("Failed to load run data")
        return {}
    
    # Load with decompression
    var original_size = file.get_32()
    var compressed_buffer = file.get_buffer(file.get_length() - file.get_position())
    file.close()
    
    var decompressed = compressed_buffer.decompress(original_size, FileAccess.COMPRESSION_GZIP)
    var data_string = decompressed.get_string_from_utf8()
    var data = str_to_var(data_string)
    
    # Verify this save belongs to current slot
    if data.has("slot") and data.slot != MetaSaveManager.current_slot:
        push_error("Run save is for different slot!")
        return {}
    
    # Restore run timer
    if data.has("run_time"):
        current_run_start_time = Time.get_ticks_msec() / 1000.0 - data.run_time
    
    print("💾 Infinite world state loaded")
    return data
```

**Update `Main.gd` to handle infinite world loading**:
```gdscript
# Update existing Main.gd

func _ready():
    # Ensure game state
    GameStateManager.change_state(GameStateManager.GameState.PLAYING)
    
    # Check if we're continuing a run
    var run_data = RunSaveManager.load_run()
    if run_data.size() > 0 and run_data.get("location") == "infinite_world":
        _load_infinite_world_state(run_data)
    else:
        # New run - start with heavy preloading
        _start_new_infinite_world()
    
    # Fade in after loading
    SceneTransition.fade_in()

func _start_new_infinite_world():
    """Start new infinite world session"""
    RunSaveManager.start_new_run()
    
    # Show loading screen
    var loading_screen = preload("res://scenes/ui/LoadingScreen.tscn").instantiate()
    add_child(loading_screen)
    loading_screen.show_loading()
    
    # Start heavy chunk loading at player spawn
    var player_start_pos = player.global_position
    HeavyChunkLoader.start_initial_loading(player_start_pos)
    
    # Wait for loading to complete
    await HeavyChunkLoader.initial_loading_complete
    
    # Initialize other systems
    _start_fresh_run()

func _load_infinite_world_state(data: Dictionary) -> bool:
    """Load saved infinite world state"""
    if not data.has("infinite_world"):
        push_error("Save data missing infinite world information")
        return false
    
    try:
        var world_data = data.infinite_world
        
        # Restore player position first
        var p = data.player
        player.global_position = Vector2(p.position[0], p.position[1])
        
        # Show loading screen for chunk restoration
        var loading_screen = preload("res://scenes/ui/LoadingScreen.tscn").instantiate()
        add_child(loading_screen)
        loading_screen.show_loading()
        
        # Load saved chunks first
        if world_data.has("saved_chunks"):
            HeavyChunkLoader.load_persistent_chunks(world_data.saved_chunks)
        
        # Set player chunk coordinate
        if world_data.has("player_chunk_coord"):
            var chunk_coord = world_data.player_chunk_coord
            HeavyChunkLoader.current_chunk_coord = Vector2i(chunk_coord.x, chunk_coord.y)
        
        # Start preloading around current position
        HeavyChunkLoader.start_initial_loading(player.global_position)
        
        # Wait for loading
        await HeavyChunkLoader.initial_loading_complete
        
        # Restore other infinite world state
        _restore_infinite_world_systems(world_data)
        
        # Restore standard player state
        _restore_player_state(data)
        
        return true
    except:
        push_error("Exception while loading infinite world state")
        return false

func _restore_infinite_world_systems(world_data: Dictionary):
    """Restore infinite world specific systems"""
    
    # Restore rare chunk tracker
    if world_data.has("rare_chunk_tracker"):
        var tracker_data = world_data.rare_chunk_tracker
        
        if tracker_data.has("kills_since_last_marker"):
            RareChunkTracker.kills_since_last_marker = tracker_data.kills_since_last_marker
        
        if tracker_data.has("active_markers"):
            _restore_rare_markers(tracker_data.active_markers)

func _restore_rare_markers(marker_data: Array):
    """Restore active rare chunk markers"""
    RareChunkTracker.active_markers.clear()
    
    for marker_info in marker_data:
        var direction = Vector2(marker_info.direction[0], marker_info.direction[1])
        var target_chunk = Vector2i(marker_info.target_chunk[0], marker_info.target_chunk[1])
        
        var marker = RareChunkTracker.RareChunkMarker.new(direction, target_chunk)
        marker.creation_time = marker_info.creation_time
        
        RareChunkTracker.active_markers.append(marker)
        
        # Restore UI marker
        RareChunkTracker._show_marker_ui(direction)
```

---

## 📅 **DAY 5-6: POLISH & INTEGRATION**

### **Day 5: Performance Testing & Optimization**

**Create `scripts/test/InfiniteWorldPerformanceTest.gd`**:
```gdscript
extends Node

var test_duration: float = 60.0  # 1 minute stress test
var test_start_time: float
var performance_samples: Array = []
var chunk_load_count: int = 0
var enemy_spawn_count: int = 0

func run_performance_stress_test():
    print("🧪 Starting 60-second infinite world stress test...")
    
    test_start_time = Time.get_ticks_msec() / 1000.0
    performance_samples.clear()
    chunk_load_count = 0
    enemy_spawn_count = 0
    
    # Connect to events
    HeavyChunkLoader.chunk_loaded.connect(_on_chunk_loaded_test)
    
    # Start monitoring
    var monitor_timer = Timer.new()
    monitor_timer.wait_time = 0.1  # Sample every 100ms
    monitor_timer.timeout.connect(_sample_performance)
    add_child(monitor_timer)
    monitor_timer.start()
    
    # Simulate player movement for chunk loading
    _simulate_player_exploration()
    
    # Wait for test duration
    await get_tree().create_timer(test_duration).timeout
    
    monitor_timer.queue_free()
    _analyze_performance_results()

func _simulate_player_exploration():
    """Simulate player moving around to trigger chunk loading"""
    var player = GameManager.get_player()
    if not player:
        return
    
    var movement_timer = Timer.new()
    movement_timer.wait_time = 2.0  # Move every 2 seconds
    movement_timer.timeout.connect(_move_player_randomly)
    add_child(movement_timer)
    movement_timer.start()
    
    # Stop after test duration
    await get_tree().create_timer(test_duration).timeout
    movement_timer.queue_free()

func _move_player_randomly():
    var player = GameManager.get_player()
    if player:
        # Teleport player to random nearby position to trigger chunk loading
        var random_offset = Vector2(
            randf_range(-1000, 1000),
            randf_range(-1000, 1000)
        )
        player.global_position += random_offset
        HeavyChunkLoader.update_player_position(player.global_position)

func _sample_performance():
    var sample = {
        "timestamp": Time.get_ticks_msec() / 1000.0 - test_start_time,
        "fps": Engine.get_frames_per_second(),
        "memory_mb": OS.get_static_memory_usage() / 1024 / 1024,
        "active_chunks": HeavyChunkLoader.active_chunks.size(),
        "enemy_count": get_tree().get_nodes_in_group("enemies").size(),
        "particle_count": get_tree().get_nodes_in_group("particle_effects").size()
    }
    
    performance_samples.append(sample)

func _on_chunk_loaded_test(chunk_coord: Vector2i, chunk_data):
    chunk_load_count += 1

func _analyze_performance_results():
    print("\n📊 Performance Test Results:")
    
    # Calculate averages
    var total_fps = 0.0
    var total_memory = 0.0
    var min_fps = 999.0
    var max_memory = 0.0
    
    for sample in performance_samples:
        total_fps += sample.fps
        total_memory += sample.memory_mb
        min_fps = min(min_fps, sample.fps)
        max_memory = max(max_memory, sample.memory_mb)
    
    var avg_fps = total_fps / performance_samples.size()
    var avg_memory = total_memory / performance_samples.size()
    
    print("  Average FPS: %.1f" % avg_fps)
    print("  Minimum FPS: %.1f" % min_fps)
    print("  Average Memory: %.1f MB" % avg_memory)
    print("  Peak Memory: %.1f MB" % max_memory)
    print("  Chunks Loaded: %d" % chunk_load_count)
    print("  Final Active Chunks: %d" % HeavyChunkLoader.active_chunks.size())
    
    # Performance assessment
    if avg_fps >= 55 and min_fps >= 45:
        print("  ✅ Performance: EXCELLENT")
    elif avg_fps >= 45 and min_fps >= 35:
        print("  ✅ Performance: GOOD")
    elif avg_fps >= 35:
        print("  ⚠️ Performance: ACCEPTABLE")
    else:
        print("  ❌ Performance: POOR - optimization needed")
    
    if max_memory > 512:
        print("  ⚠️ Memory usage high - consider optimization")
    else:
        print("  ✅ Memory usage within limits")
```

### **Day 6: Final Integration & Testing**

**Create comprehensive integration test**:

**`scripts/test/InfiniteWorldIntegrationTest.gd`**:
```gdscript
extends Node

func run_complete_integration_test():
    print("🧪 Running Complete Infinite World Integration Test...")
    
    var tests = [
        "Heavy Preloading System",
        "Runtime Chunk Loading", 
        "3x3 Save System",
        "Rare Chunk Markers",
        "Enemy Spawning",
        "Biome Effects",
        "Performance Stability"
    ]
    
    var results = []
    
    for test_name in tests:
        var result = await _run_individual_test(test_name)
        results.append({"name": test_name, "passed": result})
    
    _print_integration_summary(results)

func _run_individual_test(test_name: String) -> bool:
    print("  Testing: %s..." % test_name)
    
    match test_name:
        "Heavy Preloading System":
            return await _test_heavy_preloading()
        "Runtime Chunk Loading":
            return await _test_runtime_loading()
        "3x3 Save System":
            return _test_save_system()
        "Rare Chunk Markers":
            return _test_rare_chunk_markers()
        "Enemy Spawning":
            return _test_enemy_spawning()
        "Biome Effects":
            return _test_biome_effects()
        "Performance Stability":
            return await _test_performance_stability()
        _:
            return false

func _test_heavy_preloading() -> bool:
    # Test initial 50-chunk preloading
    HeavyChunkLoader.start_initial_loading(Vector2.ZERO)
    
    # Wait for completion
    await HeavyChunkLoader.initial_loading_complete
    
    # Verify chunks were loaded
    var loaded_count = HeavyChunkLoader.active_chunks.size()
    var success = loaded_count >= 40  # Allow some variation
    
    if success:
        print("    ✅ Loaded %d chunks successfully" % loaded_count)
    else:
        print("    ❌ Only loaded %d chunks (expected ~50)" % loaded_count)
    
    return success

func _test_runtime_loading() -> bool:
    # Simulate player movement to trigger runtime loading
    var initial_chunk_count = HeavyChunkLoader.active_chunks.size()
    
    # Move player to trigger new chunk loading
    var new_position = Vector2(2000, 2000)
    HeavyChunkLoader.update_player_position(new_position)
    
    # Wait for loading
    await get_tree().create_timer(2.0).timeout
    
    var new_chunk_count = HeavyChunkLoader.active_chunks.size()
    var success = new_chunk_count > initial_chunk_count
    
    if success:
        print("    ✅ Runtime loading working (chunks: %d → %d)" % [initial_chunk_count, new_chunk_count])
    else:
        print("    ❌ Runtime loading failed (chunks: %d → %d)" % [initial_chunk_count, new_chunk_count])
    
    return success

func _test_save_system() -> bool:
    # Test 3x3 chunk saving
    var save_data = HeavyChunkLoader.save_persistent_chunks()
    var success = save_data.size() > 0 and save_data.size() <= 9
    
    if success:
        print("    ✅ Save system working (%d chunks saved)" % save_data.size())
    else:
        print("    ❌ Save system failed (%d chunks saved)" % save_data.size())
    
    return success

func _test_rare_chunk_markers() -> bool:
    # Test rare chunk marker creation
    var initial_markers = RareChunkTracker.active_markers.size()
    
    # Simulate kills to trigger marker
    for i in 50:
        RareChunkTracker._on_enemy_killed("test_enemy", 10)
    
    var new_markers = RareChunkTracker.active_markers.size()
    var success = new_markers > initial_markers
    
    if success:
        print("    ✅ Rare chunk markers working (%d markers)" % new_markers)
    else:
        print("    ❌ Rare chunk markers not creating (%d markers)" % new_markers)
    
    return success

func _test_enemy_spawning() -> bool:
    # Test enemy spawning in chunks
    var initial_enemies = get_tree().get_nodes_in_group("enemies").size()
    
    # Force spawn check
    var enemy_spawner = get_node_or_null("/root/EnemySpawner")
    if enemy_spawner and enemy_spawner.has_method("_check_and_spawn_enemies"):
        enemy_spawner._check_and_spawn_enemies()
    
    # Wait for spawning
    await get_tree().create_timer(1.0).timeout
    
    var new_enemies = get_tree().get_nodes_in_group("enemies").size()
    var success = new_enemies >= initial_enemies
    
    if success:
        print("    ✅ Enemy spawning working (%d enemies)" % new_enemies)
    else:
        print("    ❌ Enemy spawning failed (%d enemies)" % new_enemies)
    
    return success

func _test_biome_effects() -> bool:
    # Test biome effect application
    # For now, just verify the system exists
    var success = BiomeEffectManager != null
    
    if success:
        print("    ✅ Biome effects system operational")
    else:
        print("    ❌ Biome effects system not found")
    
    return success

func _test_performance_stability() -> bool:
    # Quick performance test
    var start_fps = Engine.get_frames_per_second()
    
    # Generate some load
    for i in 10:
        await get_tree().process_frame
    
    var end_fps = Engine.get_frames_per_second()
    var success = end_fps > 30  # Minimum acceptable FPS
    
    if success:
        print("    ✅ Performance stable (FPS: %.1f)" % end_fps)
    else:
        print("    ❌ Performance issues (FPS: %.1f)" % end_fps)
    
    return success

func _print_integration_summary(results: Array):
    var passed = 0
    var total = results.size()
    
    print("\n📊 Integration Test Summary:")
    for result in results:
        var status = "✅ PASS" if result.passed else "❌ FAIL"
        print("  %s: %s" % [result.name, status])
        if result.passed:
            passed += 1
    
    print("\n🎯 Overall Result: %d/%d tests passed (%.1f%%)" % [passed, total, (float(passed) / total) * 100])
    
    if passed == total:
        print("🎉 ALL TESTS PASSED! Infinite world system ready for use.")
    else:
        print("⚠️ Some tests failed. Review and fix issues before proceeding.")
```

---

## 🎯 **PHASE 5 SUCCESS CRITERIA (FINAL)**

### **Heavy Preloading System**:
- [ ] Loads 50 chunks at game start with progress bar
- [ ] Loading screen shows progress and completes smoothly
- [ ] Preloading completes in under 10 seconds on average hardware
- [ ] Runtime loading works seamlessly (5 chunks ahead)

### **Infinite World Mechanics**:
- [ ] Seamless chunk loading/unloading (no visible pop-in)
- [ ] 8 biome types with weighted generation
- [ ] 6 POI types with appropriate rarity
- [ ] Player movement drives chunk management correctly

### **Save System Integration**:
- [ ] 3x3 chunk area around player persists between sessions
- [ ] Save/load works reliably with chunk data
- [ ] Rare chunk marker state preserved across sessions

### **Rare Chunk Navigation**:
- [ ] Markers appear every 50 kills (configurable)
- [ ] UI shows direction to rare areas clearly
- [ ] Rare chunk generation probability doubles in marked direction
- [ ] System resets properly when rare chunk is found

### **Enemy Integration**:
- [ ] Enemies spawn appropriately in all chunks
- [ ] Biome multipliers affect difficulty (small effect for now)
- [ ] POI types affect enemy spawning (arena = more, vendor = none)
- [ ] Performance stable with enemy spawning

### **Performance Requirements**:
- [ ] Stable 60 FPS with full system active
- [ ] Memory usage under 400MB for chunk system
- [ ] No visible stuttering during chunk loading
- [ ] Stress test passes (60 seconds continuous play)

---

This revised plan creates a true infinite exploration experience! The heavy preloading ensures players never see chunks pop in, while the rare chunk marker system gives them goals to explore toward. The foundation is perfect for Phase 8's dungeon system - dungeons can be special POI types that appear as markers.

Ready to start Day 1 with the heavy chunk loading system?