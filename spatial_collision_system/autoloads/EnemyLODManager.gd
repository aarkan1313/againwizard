# EnemyLODManager.gd - Level of Detail system for massive enemy scaling
# Manages performance by adjusting enemy behavior complexity based on distance and performance
# Integrates with SpatialGrid and PlayerTracker for optimal performance scaling

extends Node

# LOD configuration - tunable for performance
var lod_distances: Array[float] = [200.0, 500.0, 1000.0]  # Distance thresholds
var max_full_physics_enemies: int = 50  # Max enemies with full physics
var max_simplified_enemies: int = 150   # Max enemies with simplified physics
var performance_target_fps: float = 60.0  # Target FPS for auto-scaling

# Current performance state
var current_fps: float = 60.0
var performance_budget: float = 1.0  # 1.0 = full performance, 0.5 = half performance available
var last_performance_check: float = 0.0
var performance_check_interval: float = 1.0  # Check every second

# LOD levels
enum LODLevel {
	FULL,        # Full physics, AI, and collision
	SIMPLIFIED,  # Reduced physics, basic AI, basic collision
	MINIMAL,     # Movement only, no collision
	DISABLED     # No updates except position
}

# System references
var spatial_grid: Node = null
var player_tracker: Node = null
var game_config: Node = null
var performance_monitor: Node = null

# Entity tracking by LOD level
var entities_by_lod: Dictionary = {
	LODLevel.FULL: [],
	LODLevel.SIMPLIFIED: [],
	LODLevel.MINIMAL: [],
	LODLevel.DISABLED: []
}

# Performance statistics
var lod_stats: Dictionary = {
	"entities_upgraded": 0,
	"entities_downgraded": 0,
	"performance_adjustments": 0
}

signal lod_changed(entity: Node2D, old_level: int, new_level: int)
signal performance_scaled(new_budget: float)

func _ready():
	setup_system_integration()
	load_configuration()
	set_process(true)

func setup_system_integration():
	"""Connect to existing game systems"""
	spatial_grid = get_node_or_null("/root/SpatialGrid")
	player_tracker = get_node_or_null("/root/PlayerTracker")
	game_config = get_node_or_null("/root/GameConfig")
	performance_monitor = get_node_or_null("/root/PerformanceMonitor")
	
	if spatial_grid:
		spatial_grid.entity_registered.connect(_on_entity_registered)
		spatial_grid.entity_unregistered.connect(_on_entity_unregistered)

func load_configuration():
	"""Load LOD configuration from GameConfig"""
	if game_config:
		lod_distances[0] = game_config.get("lod_full_distance", 200.0)
		lod_distances[1] = game_config.get("lod_simplified_distance", 500.0)
		lod_distances[2] = game_config.get("lod_minimal_distance", 1000.0)
		max_full_physics_enemies = game_config.get("max_full_physics_enemies", 50)
		max_simplified_enemies = game_config.get("max_simplified_enemies", 150)
		performance_target_fps = game_config.get("target_fps", 60.0)
	
	print("✅ EnemyLODManager initialized - Full: ", max_full_physics_enemies, " Simplified: ", max_simplified_enemies)

func _process(delta):
	"""Update LOD system every frame"""
	update_performance_tracking(delta)
	
	# Performance-based LOD updates (less frequent)
	var current_time = Time.get_ticks_msec() * 0.001
	if current_time - last_performance_check > performance_check_interval:
		update_lod_system()
		last_performance_check = current_time

func update_performance_tracking(delta):
	"""Track current performance"""
	current_fps = 1.0 / max(delta, 0.001)  # Avoid division by zero
	
	# Calculate performance budget (how much performance headroom we have)
	if performance_target_fps > 0:
		performance_budget = min(current_fps / performance_target_fps, 1.0)
	else:
		performance_budget = 1.0

func update_lod_system():
	"""Main LOD update logic - distance and performance based"""
	if not player_tracker or not spatial_grid:
		return
	
	var player_pos = player_tracker.get_player_position()
	if player_pos == Vector2.ZERO:
		return
	
	# Get all registered entities from spatial grid
	var all_entities = []
	for lod_level in entities_by_lod:
		all_entities.append_array(entities_by_lod[lod_level])
	
	# Add newly registered entities
	var spatial_entities = spatial_grid.registered_entities.keys()
	for entity in spatial_entities:
		if entity.is_in_group("enemies") and not entity in all_entities:
			all_entities.append(entity)
	
	# Calculate distances and sort by priority
	var entity_priorities = []
	for entity in all_entities:
		if not is_instance_valid(entity):
			continue
		
		var distance = player_pos.distance_to(entity.global_position)
		var priority = calculate_entity_priority(entity, distance)
		entity_priorities.append({
			"entity": entity,
			"distance": distance,
			"priority": priority
		})
	
	# Sort by priority (higher priority = closer, more important)
	entity_priorities.sort_custom(func(a, b): return a.priority > b.priority)
	
	# Assign LOD levels based on performance budget and distance
	assign_lod_levels(entity_priorities)

func calculate_entity_priority(entity: Node2D, distance: float) -> float:
	"""Calculate entity priority for LOD assignment"""
	var base_priority = 1.0 / max(distance, 1.0)  # Closer = higher priority
	
	# Boost priority for certain enemy types
	if entity.has_method("get") and entity.has("enemy_type"):
		match entity.enemy_type:
			"golem":
				base_priority *= 1.5  # Bosses get higher priority
			"wizard":
				base_priority *= 1.3  # Special enemies get priority
	
	# Boost priority for enemies in combat
	if entity.has_method("get_distance_to_player"):
		var combat_distance = entity.get_distance_to_player()
		if combat_distance < 150.0:  # In combat range
			base_priority *= 2.0
	
	return base_priority

func assign_lod_levels(entity_priorities: Array):
	"""Assign LOD levels based on priority and performance budget"""
	# Clear current assignments
	for lod_level in entities_by_lod:
		entities_by_lod[lod_level].clear()
	
	# Performance-adjusted limits
	var full_limit = int(max_full_physics_enemies * performance_budget)
	var simplified_limit = int(max_simplified_enemies * performance_budget)
	
	var full_count = 0
	var simplified_count = 0
	
	for item in entity_priorities:
		var entity = item.entity
		var distance = item.distance
		
		if not is_instance_valid(entity):
			continue
		
		var new_lod = determine_lod_level(distance, full_count, simplified_count, full_limit, simplified_limit)
		var old_lod = get_entity_lod_level(entity)
		
		# Apply LOD level
		set_entity_lod_level(entity, new_lod)
		entities_by_lod[new_lod].append(entity)
		
		# Update counters
		match new_lod:
			LODLevel.FULL:
				full_count += 1
			LODLevel.SIMPLIFIED:
				simplified_count += 1
		
		# Emit signal if LOD changed
		if old_lod != new_lod:
			lod_changed.emit(entity, old_lod, new_lod)
			track_lod_change(old_lod, new_lod)

func determine_lod_level(distance: float, full_count: int, simplified_count: int, full_limit: int, simplified_limit: int) -> LODLevel:
	"""Determine appropriate LOD level for entity"""
	# Force minimal/disabled for very distant entities
	if distance > lod_distances[2]:
		return LODLevel.DISABLED
	elif distance > lod_distances[1]:
		return LODLevel.MINIMAL
	
	# Within simplified range
	elif distance > lod_distances[0]:
		if simplified_count < simplified_limit:
			return LODLevel.SIMPLIFIED
		else:
			return LODLevel.MINIMAL
	
	# Within full physics range
	else:
		if full_count < full_limit:
			return LODLevel.FULL
		elif simplified_count < simplified_limit:
			return LODLevel.SIMPLIFIED
		else:
			return LODLevel.MINIMAL

func set_entity_lod_level(entity: Node2D, lod_level: LODLevel):
	"""Apply LOD settings to entity"""
	if not is_instance_valid(entity):
		return
	
	# Update spatial grid LOD level
	if spatial_grid:
		spatial_grid.set_entity_lod_level(entity, lod_level)
	
	# Apply LOD-specific settings to entity
	match lod_level:
		LODLevel.FULL:
			apply_full_lod(entity)
		LODLevel.SIMPLIFIED:
			apply_simplified_lod(entity)
		LODLevel.MINIMAL:
			apply_minimal_lod(entity)
		LODLevel.DISABLED:
			apply_disabled_lod(entity)

func apply_full_lod(entity: Node2D):
	"""Apply full physics and AI"""
	if entity.has_method("set_physics_process"):
		entity.set_physics_process(true)
	
	# Enable full collision
	if entity.has("collision_layer"):
		entity.collision_layer = 2
		entity.collision_mask = 5
	
	# Enable AI
	var ai_controller = entity.get_node_or_null("EnemyAIController")
	if ai_controller and ai_controller.has_method("set_enabled"):
		ai_controller.set_enabled(true)
	
	# Enable separation force
	if ai_controller and ai_controller.has_method("set_separation_enabled"):
		ai_controller.set_separation_enabled(true)

func apply_simplified_lod(entity: Node2D):
	"""Apply simplified physics and AI"""
	if entity.has_method("set_physics_process"):
		entity.set_physics_process(true)
	
	# Simplified collision - only with player
	if entity.has("collision_layer"):
		entity.collision_layer = 2
		entity.collision_mask = 1  # Only player
	
	# Basic AI
	var ai_controller = entity.get_node_or_null("EnemyAIController")
	if ai_controller and ai_controller.has_method("set_enabled"):
		ai_controller.set_enabled(true)
	
	# Disable separation force for performance
	if ai_controller and ai_controller.has_method("set_separation_enabled"):
		ai_controller.set_separation_enabled(false)

func apply_minimal_lod(entity: Node2D):
	"""Apply minimal processing - movement only"""
	if entity.has_method("set_physics_process"):
		entity.set_physics_process(true)
	
	# No collision
	if entity.has("collision_layer"):
		entity.collision_layer = 0
		entity.collision_mask = 0
	
	# Minimal AI - basic movement only
	var ai_controller = entity.get_node_or_null("EnemyAIController")
	if ai_controller and ai_controller.has_method("set_enabled"):
		ai_controller.set_enabled(true)
	if ai_controller and ai_controller.has_method("set_separation_enabled"):
		ai_controller.set_separation_enabled(false)

func apply_disabled_lod(entity: Node2D):
	"""Disable most processing"""
	if entity.has_method("set_physics_process"):
		entity.set_physics_process(false)
	
	# No collision
	if entity.has("collision_layer"):
		entity.collision_layer = 0
		entity.collision_mask = 0
	
	# Disable AI
	var ai_controller = entity.get_node_or_null("EnemyAIController")
	if ai_controller and ai_controller.has_method("set_enabled"):
		ai_controller.set_enabled(false)

func get_entity_lod_level(entity: Node2D) -> LODLevel:
	"""Get current LOD level for entity"""
	for lod_level in entities_by_lod:
		if entity in entities_by_lod[lod_level]:
			return lod_level
	return LODLevel.FULL  # Default

func track_lod_change(old_lod: LODLevel, new_lod: LODLevel):
	"""Track LOD changes for statistics"""
	if new_lod > old_lod:
		lod_stats.entities_downgraded += 1
	elif new_lod < old_lod:
		lod_stats.entities_upgraded += 1

func get_lod_statistics() -> Dictionary:
	"""Get LOD system statistics"""
	var stats = lod_stats.duplicate()
	stats.performance_budget = performance_budget
	stats.current_fps = current_fps
	stats.entities_by_lod = {}
	
	for lod_level in entities_by_lod:
		stats.entities_by_lod[LODLevel.keys()[lod_level]] = entities_by_lod[lod_level].size()
	
	return stats

func force_lod_level(entity: Node2D, lod_level: LODLevel):
	"""Force specific LOD level for entity (debug/testing)"""
	if not is_instance_valid(entity):
		return
	
	var old_lod = get_entity_lod_level(entity)
	
	# Remove from current LOD list
	for lod in entities_by_lod:
		entities_by_lod[lod].erase(entity)
	
	# Add to new LOD list
	entities_by_lod[lod_level].append(entity)
	set_entity_lod_level(entity, lod_level)
	
	lod_changed.emit(entity, old_lod, lod_level)

# Event handlers
func _on_entity_registered(entity: Node2D):
	"""Handle new entity registration"""
	if entity.is_in_group("enemies"):
		entities_by_lod[LODLevel.FULL].append(entity)

func _on_entity_unregistered(entity: Node2D):
	"""Handle entity removal"""
	for lod_level in entities_by_lod:
		entities_by_lod[lod_level].erase(entity)

# Debug and monitoring
func get_debug_info() -> Dictionary:
	"""Get debug information"""
	return {
		"performance_budget": performance_budget,
		"current_fps": current_fps,
		"lod_distances": lod_distances,
		"entities_by_lod": get_entity_counts_by_lod(),
		"performance_stats": lod_stats
	}

func get_entity_counts_by_lod() -> Dictionary:
	"""Get entity count for each LOD level"""
	var counts = {}
	for lod_level in entities_by_lod:
		counts[LODLevel.keys()[lod_level]] = entities_by_lod[lod_level].size()
	return counts