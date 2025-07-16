# Phase 5.5.5: Smart Loading System

## Overview
**Goal**: Implement intelligent chunk loading that predicts player movement and spreads generation load across multiple frames for smooth performance.

**Timeline**: 2-3 days  
**Dependencies**: Phase 5.5.4 (advanced terrain) must be complete  
**Priority**: High (user wants "smart loading to spread the load")

---

## Technical Approach

### **Current System Issues:**
- Chunks generate immediately when needed (causes frame drops)
- No prediction of player movement direction
- Loading screen doesn't pre-load efficiently
- Equal priority for all chunks regardless of distance/direction

### **New System Features:**
- Directional movement prediction
- Priority-based chunk generation queue
- Frame-spread generation to avoid hitches
- Intelligent pre-loading during loading screens
- Distance-based quality adjustment

---

## Implementation Steps

### **Step 1: Movement Prediction System**

**Create new file**: `scripts/world/MovementPredictor.gd`

```gdscript
extends RefCounted
class_name MovementPredictor

var movement_history: Array[Vector2] = []
var max_history_size: int = 10
var prediction_distance: float = 3.0  # Chunks ahead to predict

func update_player_position(new_position: Vector2):
    """Update player position and maintain movement history"""
    movement_history.append(new_position)
    
    if movement_history.size() > max_history_size:
        movement_history.pop_front()

func get_predicted_direction() -> Vector2:
    """Calculate predicted movement direction"""
    if movement_history.size() < 2:
        return Vector2.ZERO
    
    var total_direction = Vector2.ZERO
    var weight_sum = 0.0
    
    # Weight recent movements more heavily
    for i in range(1, movement_history.size()):
        var direction = movement_history[i] - movement_history[i-1]
        var weight = float(i) / float(movement_history.size())  # More recent = higher weight
        
        total_direction += direction * weight
        weight_sum += weight
    
    if weight_sum > 0:
        return total_direction / weight_sum
    return Vector2.ZERO

func get_predicted_chunks(current_chunk: Vector2i, chunk_size: int) -> Array[Vector2i]:
    """Get list of chunks in predicted movement direction"""
    var predicted_chunks: Array[Vector2i] = []
    var direction = get_predicted_direction()
    
    if direction.length() < 10:  # Too slow to predict
        return predicted_chunks
    
    # Convert direction to chunk coordinates
    var chunk_direction = Vector2i(
        sign(direction.x),
        sign(direction.y)
    )
    
    # Generate chunks in predicted direction
    for distance in range(1, int(prediction_distance) + 1):
        var predicted_chunk = current_chunk + chunk_direction * distance
        predicted_chunks.append(predicted_chunk)
        
        # Also add adjacent chunks for wider coverage
        if distance <= 2:
            predicted_chunks.append(predicted_chunk + Vector2i(chunk_direction.y, chunk_direction.x))
            predicted_chunks.append(predicted_chunk + Vector2i(-chunk_direction.y, -chunk_direction.x))
    
    return predicted_chunks
```

### **Step 2: Chunk Generation Queue**

**Create new file**: `scripts/world/ChunkGenerationQueue.gd`

```gdscript
extends RefCounted
class_name ChunkGenerationQueue

enum Priority {
    CRITICAL,    # Player is very close
    HIGH,        # In predicted direction
    MEDIUM,      # Within active radius
    LOW          # Distant but needed
}

var generation_queue: Array[Dictionary] = []
var max_chunks_per_frame: int = 2
var current_frame_count: int = 0

func add_chunk_request(chunk_coord: Vector2i, priority: Priority, distance: float):
    """Add chunk generation request to queue"""
    var request = {
        "coord": chunk_coord,
        "priority": priority,
        "distance": distance,
        "timestamp": Time.get_ticks_msec()
    }
    
    generation_queue.append(request)
    _sort_queue()

func _sort_queue():
    """Sort queue by priority and distance"""
    generation_queue.sort_custom(func(a, b):
        if a.priority != b.priority:
            return a.priority < b.priority  # Lower enum value = higher priority
        return a.distance < b.distance  # Closer = higher priority
    )

func get_next_chunk_batch() -> Array[Vector2i]:
    """Get next batch of chunks to generate this frame"""
    var batch: Array[Vector2i] = []
    var processed = 0
    
    while processed < max_chunks_per_frame and generation_queue.size() > 0:
        var request = generation_queue.pop_front()
        batch.append(request.coord)
        processed += 1
    
    return batch

func has_pending_chunks() -> bool:
    """Check if there are chunks waiting to be generated"""
    return generation_queue.size() > 0

func clear_old_requests():
    """Remove old requests that are no longer relevant"""
    var current_time = Time.get_ticks_msec()
    var max_age = 5000  # 5 seconds
    
    generation_queue = generation_queue.filter(func(request):
        return current_time - request.timestamp < max_age
    )

func set_generation_rate(chunks_per_frame: int):
    """Adjust generation rate based on performance"""
    max_chunks_per_frame = chunks_per_frame
```

### **Step 3: Enhanced UnifiedWorldManager**

**Update `scripts/world/UnifiedWorldManager.gd`:**

```gdscript
# Add new components
var movement_predictor: MovementPredictor
var generation_queue: ChunkGenerationQueue
var last_player_position: Vector2
var performance_monitor: Dictionary = {
    "avg_generation_time": 0.0,
    "frame_drops": 0,
    "adaptive_rate": 2
}

func _ready():
    # Initialize new systems
    movement_predictor = MovementPredictor.new()
    generation_queue = ChunkGenerationQueue.new()
    
    # Existing initialization...
    _setup_unified_world_system()

func _process(delta):
    # Update movement prediction
    if player:
        var current_position = player.global_position
        movement_predictor.update_player_position(current_position)
        last_player_position = current_position
    
    # Process chunk generation queue
    _process_chunk_generation_queue()
    
    # Update performance metrics
    _update_performance_metrics()
    
    # Clean up old requests
    generation_queue.clear_old_requests()

func _process_chunk_generation_queue():
    """Process chunks from generation queue"""
    var batch = generation_queue.get_next_chunk_batch()
    
    for chunk_coord in batch:
        var start_time = Time.get_ticks_msec()
        
        # Generate chunk if not already exists
        if not chunk_coord in active_chunks:
            _generate_chunk_smart(chunk_coord)
        
        # Track generation time for performance monitoring
        var generation_time = Time.get_ticks_msec() - start_time
        _update_generation_metrics(generation_time)

func _generate_chunk_smart(chunk_coord: Vector2i):
    """Generate chunk with smart loading optimizations"""
    var start_time = Time.get_ticks_msec()
    
    # Check if we should use simplified generation for distant chunks
    var player_chunk_coord = get_player_chunk_coord()
    var distance = (chunk_coord - player_chunk_coord).length()
    
    var chunk_visual: Node2D
    if distance > 3:  # Distant chunks get simplified generation
        chunk_visual = chunk_renderer.create_simplified_chunk_visual(chunk_coord)
    else:
        chunk_visual = chunk_renderer.create_chunk_visual(chunk_coord)
    
    # Set position and add to scene
    chunk_visual.position = Vector2(chunk_coord.x * CHUNK_SIZE, chunk_coord.y * CHUNK_SIZE)
    chunk_visual.z_index = CHUNK_Z_INDEX
    add_child(chunk_visual)
    
    # Store in active chunks
    active_chunks[chunk_coord] = chunk_visual
    
    var generation_time = Time.get_ticks_msec() - start_time
    if generation_time > 30:  # Log slow generations
        print("Smart chunk generated in ", generation_time, "ms at ", chunk_coord)
```

### **Step 4: Intelligent Chunk Prioritization**

**Enhanced chunk loading with priorities:**

```gdscript
func _update_chunk_loading():
    """Update chunk loading with smart prioritization"""
    var player_chunk_coord = get_player_chunk_coord()
    var predicted_chunks = movement_predictor.get_predicted_chunks(player_chunk_coord, CHUNK_SIZE)
    
    # Get all chunks that should be loaded
    var needed_chunks = get_chunks_around_position(player_chunk_coord, ACTIVE_RADIUS)
    
    # Prioritize chunks
    for chunk_coord in needed_chunks:
        if chunk_coord in active_chunks:
            continue  # Already loaded
        
        var distance = (chunk_coord - player_chunk_coord).length()
        var priority: ChunkGenerationQueue.Priority
        
        # Determine priority
        if distance <= 1:
            priority = ChunkGenerationQueue.Priority.CRITICAL
        elif chunk_coord in predicted_chunks:
            priority = ChunkGenerationQueue.Priority.HIGH
        elif distance <= 2:
            priority = ChunkGenerationQueue.Priority.MEDIUM
        else:
            priority = ChunkGenerationQueue.Priority.LOW
        
        # Add to generation queue
        generation_queue.add_chunk_request(chunk_coord, priority, distance)
    
    # Unload distant chunks
    _unload_distant_chunks(player_chunk_coord)

func _unload_distant_chunks(player_chunk_coord: Vector2i):
    """Unload chunks that are too far away"""
    var chunks_to_unload = []
    
    for chunk_coord in active_chunks:
        var distance = (chunk_coord - player_chunk_coord).length()
        if distance > ACTIVE_RADIUS + 1:  # Buffer zone
            chunks_to_unload.append(chunk_coord)
    
    for chunk_coord in chunks_to_unload:
        _unload_chunk(chunk_coord)
```

### **Step 5: Performance Monitoring and Adaptation**

**Adaptive performance system:**

```gdscript
func _update_performance_metrics():
    """Monitor performance and adjust generation rate"""
    var current_fps = Engine.get_frames_per_second()
    
    # Detect frame drops
    if current_fps < 55:  # Below 55 FPS considered a drop
        performance_monitor.frame_drops += 1
        
        # Reduce generation rate if frequent drops
        if performance_monitor.frame_drops > 5:
            generation_queue.set_generation_rate(max(1, generation_queue.max_chunks_per_frame - 1))
            performance_monitor.frame_drops = 0
            print("Reduced chunk generation rate to ", generation_queue.max_chunks_per_frame)
    
    # Increase rate if performance is good
    elif current_fps > 58 and generation_queue.max_chunks_per_frame < 3:
        generation_queue.set_generation_rate(generation_queue.max_chunks_per_frame + 1)
        print("Increased chunk generation rate to ", generation_queue.max_chunks_per_frame)

func _update_generation_metrics(generation_time: float):
    """Update average generation time metrics"""
    var alpha = 0.1  # Smoothing factor
    performance_monitor.avg_generation_time = (
        performance_monitor.avg_generation_time * (1.0 - alpha) + 
        generation_time * alpha
    )
```

---

## Loading Screen Optimization

### **Enhanced Loading Screen System:**

**Create new file**: `scripts/world/LoadingScreenOptimizer.gd`

```gdscript
extends RefCounted
class_name LoadingScreenOptimizer

var chunk_manager: UnifiedWorldManager
var target_chunk_count: int = 50
var generation_rate: int = 5  # Chunks per frame during loading

func _init(manager: UnifiedWorldManager):
    chunk_manager = manager

func pre_generate_world(player_position: Vector2) -> bool:
    """Pre-generate chunks during loading screen"""
    var player_chunk_coord = Vector2i(
        int(player_position.x / chunk_manager.CHUNK_SIZE),
        int(player_position.y / chunk_manager.CHUNK_SIZE)
    )
    
    # Generate chunks in expanding spiral pattern
    var generated_this_frame = 0
    var radius = 0
    
    while generated_this_frame < generation_rate and radius < 4:
        var chunks_in_radius = _get_chunks_in_radius(player_chunk_coord, radius)
        
        for chunk_coord in chunks_in_radius:
            if generated_this_frame >= generation_rate:
                break
            
            if not chunk_coord in chunk_manager.active_chunks:
                chunk_manager._generate_chunk_smart(chunk_coord)
                generated_this_frame += 1
        
        radius += 1
    
    # Return true if loading is complete
    return chunk_manager.active_chunks.size() >= target_chunk_count

func _get_chunks_in_radius(center: Vector2i, radius: int) -> Array[Vector2i]:
    """Get chunks at specific radius from center"""
    var chunks: Array[Vector2i] = []
    
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            var chunk_coord = center + Vector2i(x, y)
            var distance = abs(x) + abs(y)  # Manhattan distance
            
            if distance == radius:
                chunks.append(chunk_coord)
    
    return chunks
```

---

## Integration with Game Loop

### **Main.gd Integration:**

```gdscript
# In Main.gd, update loading screen
func _ready():
    # Show loading screen
    loading_screen.show()
    
    # Setup world system
    _setup_unified_world_system()
    
    # Pre-generate world during loading
    var loader = LoadingScreenOptimizer.new(world_manager)
    
    # Generate initial chunks
    while not loader.pre_generate_world(player.global_position):
        await get_tree().process_frame  # Wait one frame
        loading_screen.update_progress(world_manager.active_chunks.size(), loader.target_chunk_count)
    
    # Hide loading screen
    loading_screen.hide()
```

---

## Performance Targets

### **Target Performance:**
- **Generation rate**: 2-3 chunks per frame (adaptive)
- **FPS stability**: Maintain 60 FPS during chunk loading
- **Prediction accuracy**: 70%+ correct direction prediction
- **Loading time**: <3 seconds for initial world
- **Memory usage**: <600MB total

### **Performance Monitoring:**
- Track average generation time
- Monitor frame drops during loading
- Log prediction accuracy
- Measure loading screen efficiency

---

## Advanced Features

### **Chunk Quality Levels:**
```gdscript
enum ChunkQuality {
    LOW,     # Distant chunks - simplified generation
    MEDIUM,  # Normal chunks - standard generation
    HIGH     # Close chunks - full detail generation
}

func get_chunk_quality(distance: float) -> ChunkQuality:
    if distance > 3:
        return ChunkQuality.LOW
    elif distance > 1:
        return ChunkQuality.MEDIUM
    else:
        return ChunkQuality.HIGH
```

### **Dynamic Loading Zones:**
```gdscript
# Adjust loading zones based on player speed
func get_dynamic_loading_radius(player_speed: float) -> int:
    var base_radius = 2
    var speed_factor = clamp(player_speed / 100.0, 0.0, 2.0)
    return base_radius + int(speed_factor)
```

---

## Testing Strategy

### **Performance Tests:**
- [ ] FPS remains stable during chunk loading
- [ ] Generation queue processes efficiently
- [ ] Movement prediction improves loading
- [ ] Loading screen pre-generation works
- [ ] Adaptive rate adjustment functions

### **Functionality Tests:**
- [ ] Chunks load in correct priority order
- [ ] Distant chunks unload properly
- [ ] Prediction system tracks movement
- [ ] Performance monitoring works
- [ ] Integration with existing systems

---

## Rollback Plan

If performance issues occur:
1. Disable movement prediction
2. Reduce generation rate to 1 chunk per frame
3. Simplify priority system
4. Fall back to immediate generation

---

## Future Enhancements

### **Phase 5.5.6 Integration:**
- Priority-based POI generation
- Smart pre-loading of POI content
- Adaptive POI quality based on performance

### **Advanced Features:**
- Machine learning for movement prediction
- Dynamic world streaming
- Network-based chunk sharing
- Background chunk generation

---

**Note**: This system significantly improves performance but adds complexity. Monitor carefully and adjust parameters based on actual performance!