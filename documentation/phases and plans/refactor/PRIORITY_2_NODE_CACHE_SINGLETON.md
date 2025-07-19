# Priority 2: NodeCache Singleton Implementation

## Overview
**Problem**: 325 tree queries across 77 files causing performance overhead  
**Goal**: Centralized node caching system reducing tree queries by 80%  
**Timeline**: 4 hours over 1 day  
**Risk Level**: Low (performance optimization with fallback)

## Current Performance Issues

### Tree Query Analysis
```bash
# Count of get_tree().get_first_node_in_group() calls:
grep -r "get_tree().get_first_node_in_group" scripts/ | wc -l
# Result: 325 calls across 77 files

# Most common patterns:
get_tree().get_first_node_in_group("player")           # 89 instances
get_tree().get_first_node_in_group("unified_world")    # 67 instances  
get_tree().get_first_node_in_group("players")          # 43 instances
get_tree().get_first_node_in_group("enemy_spawner")    # 28 instances
get_tree().get_first_node_in_group("world_manager")    # 21 instances
```

### Performance Impact
- **Tree traversal is O(n)** where n = number of nodes
- **Called every frame** in many systems
- **Repeated lookups** for same nodes
- **Cache misses** cause expensive tree walks

### Problem Examples
```gdscript
# EnemyAIController.gd - called every AI update
func _update_ai():
    var player = get_tree().get_first_node_in_group("players")  # Expensive!
    if player:
        _chase_player(player)

# GameManager.gd - called every frame
func _process(delta):
    var world_manager = get_tree().get_first_node_in_group("unified_world")  # Expensive!
    if world_manager:
        _update_chunk_system()
```

## Solution Architecture

### NodeCache Singleton Design
```
NodeCache (Singleton)
├── Cached Nodes (Dictionary)
├── Cache Timestamps (Dictionary) 
├── Cache Duration Settings
├── Automatic Cache Invalidation
└── Fallback to Tree Queries
```

### Cache Strategy
- **Time-based invalidation**: Cache entries expire after configurable duration
- **Event-based invalidation**: Cache invalidated when nodes are added/removed
- **Fallback mechanism**: Falls back to tree query if cache miss
- **Group-based caching**: Cache by node group for efficiency

## Implementation Plan

### Step 1: Create NodeCache Singleton (1 hour)
```gdscript
# Create new file: scripts/core/NodeCache.gd
class_name NodeCache
extends Node

# Centralized node caching system to reduce expensive tree queries
# Replaces get_tree().get_first_node_in_group() calls with cached lookups

signal cache_invalidated(group_name: String)
signal cache_updated(group_name: String, node: Node)

# Cache storage
var cached_nodes: Dictionary = {}           # group_name -> Node
var cache_timestamps: Dictionary = {}       # group_name -> timestamp
var cache_hit_counts: Dictionary = {}       # group_name -> hit_count
var cache_miss_counts: Dictionary = {}      # group_name -> miss_count

# Cache configuration
const DEFAULT_CACHE_DURATION: float = 2.0  # Cache for 2 seconds
const MAX_CACHE_SIZE: int = 100            # Prevent memory bloat
var custom_cache_durations: Dictionary = {
    "players": 5.0,           # Player rarely changes
    "unified_world": 10.0,    # World manager very stable
    "enemy_spawner": 5.0,     # Spawner rarely changes
    "world_manager": 10.0     # Stable singleton
}

func _ready():
    name = "NodeCache"
    # Connect to tree changes for cache invalidation
    get_tree().node_added.connect(_on_node_added)
    get_tree().node_removed.connect(_on_node_removed)
    
    # Periodic cache cleanup
    var cleanup_timer = Timer.new()
    cleanup_timer.wait_time = 5.0
    cleanup_timer.timeout.connect(_cleanup_expired_cache)
    cleanup_timer.autostart = true
    add_child(cleanup_timer)
    
    print("🗄️ NodeCache singleton initialized")

func get_cached_node(group_name: String) -> Node:
    """Main API: Get node from cache or tree query with caching"""
    
    # Check cache first
    if _is_cache_valid(group_name):
        _record_cache_hit(group_name)
        return cached_nodes[group_name]
    
    # Cache miss - query tree
    _record_cache_miss(group_name)
    var node = get_tree().get_first_node_in_group(group_name)
    
    # Cache the result (even if null)
    _cache_node(group_name, node)
    
    return node

func get_cached_nodes(group_name: String) -> Array[Node]:
    """Get all nodes in group (not cached - use sparingly)"""
    # This is for cases where you need all nodes, not just first
    # Don't cache this as it's more complex and less commonly used
    return get_tree().get_nodes_in_group(group_name)

func _is_cache_valid(group_name: String) -> bool:
    """Check if cached entry is still valid"""
    if not cached_nodes.has(group_name):
        return false
    
    if not cache_timestamps.has(group_name):
        return false
    
    var node = cached_nodes[group_name]
    
    # Check if node still exists and is valid
    if node != null and not is_instance_valid(node):
        _invalidate_cache_entry(group_name)
        return false
    
    # Check timestamp
    var cache_duration = custom_cache_durations.get(group_name, DEFAULT_CACHE_DURATION)
    var age = Time.get_time_dict_from_system()["unix"] - cache_timestamps[group_name]
    
    if age > cache_duration:
        _invalidate_cache_entry(group_name)
        return false
    
    return true

func _cache_node(group_name: String, node: Node):
    """Cache a node reference with timestamp"""
    
    # Respect cache size limit
    if cached_nodes.size() >= MAX_CACHE_SIZE:
        _cleanup_oldest_entries()
    
    cached_nodes[group_name] = node
    cache_timestamps[group_name] = Time.get_time_dict_from_system()["unix"]
    
    cache_updated.emit(group_name, node)

func _invalidate_cache_entry(group_name: String):
    """Invalidate a specific cache entry"""
    cached_nodes.erase(group_name)
    cache_timestamps.erase(group_name)
    cache_invalidated.emit(group_name)

func invalidate_cache(group_name: String = ""):
    """Public API: Manually invalidate cache"""
    if group_name.is_empty():
        # Invalidate all cache
        cached_nodes.clear()
        cache_timestamps.clear()
        print("🗄️ NodeCache: All cache invalidated")
    else:
        _invalidate_cache_entry(group_name)
        print("🗄️ NodeCache: Invalidated cache for group: ", group_name)

func _on_node_added(node: Node):
    """Handle node added to tree"""
    # Check if this node affects any cached groups
    var groups = node.get_groups()
    for group in groups:
        if cached_nodes.has(group):
            _invalidate_cache_entry(group)

func _on_node_removed(node: Node):
    """Handle node removed from tree"""
    # Check if any cached nodes are this node
    var groups_to_invalidate = []
    for group_name in cached_nodes.keys():
        if cached_nodes[group_name] == node:
            groups_to_invalidate.append(group_name)
    
    for group_name in groups_to_invalidate:
        _invalidate_cache_entry(group_name)

func _cleanup_expired_cache():
    """Periodic cleanup of expired cache entries"""
    var current_time = Time.get_time_dict_from_system()["unix"]
    var expired_groups = []
    
    for group_name in cache_timestamps.keys():
        var cache_duration = custom_cache_durations.get(group_name, DEFAULT_CACHE_DURATION)
        var age = current_time - cache_timestamps[group_name]
        
        if age > cache_duration:
            expired_groups.append(group_name)
    
    for group_name in expired_groups:
        _invalidate_cache_entry(group_name)
    
    if expired_groups.size() > 0:
        print("🗄️ NodeCache: Cleaned up ", expired_groups.size(), " expired entries")

func _cleanup_oldest_entries():
    """Remove oldest cache entries when limit reached"""
    var oldest_group = ""
    var oldest_time = Time.get_time_dict_from_system()["unix"]
    
    for group_name in cache_timestamps.keys():
        if cache_timestamps[group_name] < oldest_time:
            oldest_time = cache_timestamps[group_name]
            oldest_group = group_name
    
    if not oldest_group.is_empty():
        _invalidate_cache_entry(oldest_group)

func _record_cache_hit(group_name: String):
    """Record cache hit for performance metrics"""
    cache_hit_counts[group_name] = cache_hit_counts.get(group_name, 0) + 1

func _record_cache_miss(group_name: String):
    """Record cache miss for performance metrics"""
    cache_miss_counts[group_name] = cache_miss_counts.get(group_name, 0) + 1

func get_performance_stats() -> Dictionary:
    """Get cache performance statistics"""
    var total_hits = 0
    var total_misses = 0
    
    for count in cache_hit_counts.values():
        total_hits += count
    
    for count in cache_miss_counts.values():
        total_misses += count
    
    var hit_rate = float(total_hits) / float(total_hits + total_misses) if (total_hits + total_misses) > 0 else 0.0
    
    return {
        "total_hits": total_hits,
        "total_misses": total_misses,
        "hit_rate": hit_rate,
        "cache_size": cached_nodes.size(),
        "detailed_hits": cache_hit_counts.duplicate(),
        "detailed_misses": cache_miss_counts.duplicate()
    }

func print_performance_stats():
    """Debug: Print cache performance statistics"""
    var stats = get_performance_stats()
    print("🗄️ NodeCache Performance:")
    print("  Total Hits: ", stats.total_hits)
    print("  Total Misses: ", stats.total_misses)
    print("  Hit Rate: ", "%.1f%%" % (stats.hit_rate * 100))
    print("  Cache Size: ", stats.cache_size)
```

### Step 2: Add to Autoloads (5 minutes)
```ini
# project.godot - add NodeCache before other systems that use it
[autoload]
UnifiedDebugSystem="*res://scripts/debug/UnifiedDebugSystem.gd"
NodeCache="*res://scripts/core/NodeCache.gd"              # ADD THIS
CollisionValidator="*res://scripts/CollisionValidator.gd"
GameEvents="*res://scripts/GameEvents.gd"
...
```

### Step 3: Update High-Impact Files (2 hours)
Replace tree queries in most frequently called locations:

#### GameManager.gd
```gdscript
# OLD:
func _update_chunk_system():
    var unified_world = get_tree().get_first_node_in_group("unified_world")
    if not unified_world:
        return

# NEW:
func _update_chunk_system():
    var unified_world = NodeCache.get_cached_node("unified_world")
    if not unified_world:
        return
```

#### EnemyAIController.gd
```gdscript
# OLD:
func _update_ai():
    var player = get_tree().get_first_node_in_group("players")
    if not player:
        return

# NEW:
func _update_ai():
    var player = NodeCache.get_cached_node("players")
    if not player:
        return
```

#### EnemySpawner.gd
```gdscript
# OLD:
func _spawn_enemy():
    var world_manager = get_tree().get_first_node_in_group("unified_world")
    if world_manager:
        # spawn logic

# NEW:
func _spawn_enemy():
    var world_manager = NodeCache.get_cached_node("unified_world")
    if world_manager:
        # spawn logic
```

### Step 4: Create Migration Helper Script (30 minutes)
```gdscript
# tools/migrate_to_node_cache.gd
# Helper script to identify and update tree query patterns

static func find_tree_queries() -> Array:
    """Find all tree query patterns in codebase"""
    var patterns = []
    # This would be implemented as an editor tool
    # to help identify files that need updating
    return patterns

static func suggest_replacements(file_path: String) -> Array:
    """Suggest NodeCache replacements for a file"""
    # Analysis tool to help with migration
    var suggestions = []
    return suggestions
```

### Step 5: Performance Testing (30 minutes)
```gdscript
# scripts/tests/test_node_cache_performance.gd
extends Node

func test_cache_performance():
    """Benchmark NodeCache vs direct tree queries"""
    
    var iterations = 1000
    
    # Test direct tree queries
    var start_time = Time.get_ticks_msec()
    for i in range(iterations):
        get_tree().get_first_node_in_group("players")
    var direct_time = Time.get_ticks_msec() - start_time
    
    # Test cached queries
    start_time = Time.get_ticks_msec()
    for i in range(iterations):
        NodeCache.get_cached_node("players")
    var cached_time = Time.get_ticks_msec() - start_time
    
    print("Performance Test Results:")
    print("Direct queries: ", direct_time, "ms")
    print("Cached queries: ", cached_time, "ms")
    print("Performance improvement: ", "%.1fx" % (float(direct_time) / float(cached_time)))
    
    # Verify cache stats
    NodeCache.print_performance_stats()
```

## Migration Strategy

### Phase 1: Core Systems (High Impact)
Update the most frequently called locations first:
- GameManager.gd
- EnemyAIController.gd  
- EnemySpawner.gd
- UnifiedWorldManager.gd
- SaveManager.gd

### Phase 2: UI and Components (Medium Impact)
- PlayerUI.gd
- HealthComponent.gd
- SpellComponent.gd
- Various UI controllers

### Phase 3: Utilities and Debug (Low Impact)
- Debug systems
- Validation scripts
- Helper utilities

### Phase 4: Legacy and Edge Cases
- Rarely called functions
- Test scripts
- Temporary implementations

## Testing Strategy

### Performance Tests
```gdscript
func test_tree_query_reduction():
    # Count tree queries before/after migration
    var before = _count_tree_queries()
    # Apply NodeCache to key files
    var after = _count_tree_queries()
    assert_lt(after, before * 0.2)  # Should reduce by 80%

func test_cache_hit_rate():
    # Cache should have high hit rate for common queries
    NodeCache.get_cached_node("players")  # Prime cache
    await get_tree().process_frame
    
    for i in range(100):
        NodeCache.get_cached_node("players")
    
    var stats = NodeCache.get_performance_stats()
    assert_gt(stats.hit_rate, 0.9)  # Should have >90% hit rate
```

### Functionality Tests
```gdscript
func test_cache_invalidation():
    # Test that cache invalidates when nodes change
    var player = NodeCache.get_cached_node("players")
    player.queue_free()
    await get_tree().process_frame
    
    # Cache should be invalidated
    var cached_player = NodeCache.get_cached_node("players")
    assert_ne(cached_player, player)  # Should be different (null or new player)
```

## Success Criteria

### Performance Goals
- **80% reduction in tree queries** (from 325 to <65)
- **90%+ cache hit rate** for common node groups
- **No measurable performance regression** from caching overhead
- **5-15% overall frame rate improvement** in complex scenes

### Code Quality
- **Consistent NodeCache usage** across codebase
- **Proper fallback handling** when cache misses
- **Clear performance monitoring** and statistics

### Reliability
- **No null reference errors** from cached nodes
- **Proper cache invalidation** when nodes change
- **Memory usage within acceptable bounds**

## Risk Mitigation

### Stale Reference Prevention
- Time-based cache expiration
- Event-based invalidation on node changes
- Validation of cached node instances

### Memory Management
- Cache size limits (100 entries max)
- Periodic cleanup of expired entries
- Monitoring tools for cache statistics

### Fallback Strategy
- Always falls back to tree query on cache miss
- Graceful handling of null cached nodes
- Easy rollback to direct tree queries if issues arise

## Expected Benefits

### Immediate Performance Gains
- **80% reduction in expensive tree traversals**
- **Smoother gameplay** with many enemies (100+ entities)
- **Better frame rate stability** during complex scenes
- **Reduced CPU usage** in core game loop

### Long-term Architecture Benefits
- **Foundation for more sophisticated caching**
- **Better performance profiling capabilities**
- **Cleaner separation** between node location and usage
- **Easier optimization** of node access patterns

This implementation will significantly improve game performance by eliminating the majority of expensive tree queries while maintaining full compatibility with existing code through a simple API replacement pattern.