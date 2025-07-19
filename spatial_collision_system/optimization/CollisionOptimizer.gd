# CollisionOptimizer.gd - Performance monitoring and auto-tuning for collision system
# Automatically adjusts collision parameters based on performance metrics
# Integrates with PerformanceMonitor and GameConfig for optimal performance

extends Node

# Performance targets
@export var target_fps: float = 60.0
@export var min_acceptable_fps: float = 45.0
@export var performance_check_interval: float = 2.0  # Check every 2 seconds

# Optimization parameters
var collision_check_interval_min: float = 0.016  # ~60 FPS
var collision_check_interval_max: float = 0.1    # ~10 FPS
var cache_update_interval_min: float = 0.05      # Fast updates
var cache_update_interval_max: float = 0.2       # Slow updates

# System references
var spatial_grid: Node = null
var lod_manager: Node = null
var game_config: Node = null
var performance_monitor: Node = null

# Performance tracking
var current_fps: float = 60.0
var fps_history: Array = []
var fps_history_size: int = 10
var last_performance_check: float = 0.0

# Optimization state
var optimization_level: int = 0  # 0=none, 1=light, 2=medium, 3=aggressive
var adjustments_made: int = 0
var last_optimization_time: float = 0.0

# Performance statistics
var stats: Dictionary = {
	"fps_avg": 60.0,
	"fps_min": 60.0,
	"collision_checks_per_second": 0,
	"entities_processed": 0,
	"optimization_adjustments": 0,
	"performance_warnings": 0
}

signal performance_optimized(level: int, changes: Dictionary)
signal performance_warning(message: String, severity: int)

func _ready():
	setup_system_integration()
	set_process(true)
	last_performance_check = Time.get_ticks_msec() * 0.001

func setup_system_integration():
	"""Connect to existing game systems"""
	spatial_grid = get_node_or_null("/root/SpatialGrid")
	lod_manager = get_node_or_null("/root/EnemyLODManager")
	game_config = get_node_or_null("/root/GameConfig")
	performance_monitor = get_node_or_null("/root/PerformanceMonitor")
	
	# Connect to performance monitoring if available
	if performance_monitor and performance_monitor.has_signal("fps_updated"):
		performance_monitor.fps_updated.connect(_on_fps_updated)
	
	# Connect to spatial grid warnings
	if spatial_grid and spatial_grid.has_signal("performance_warning"):
		spatial_grid.performance_warning.connect(_on_spatial_grid_warning)

func _process(delta):
	"""Monitor performance and trigger optimizations"""
	current_fps = 1.0 / max(delta, 0.001)
	update_fps_history(current_fps)
	
	var current_time = Time.get_ticks_msec() * 0.001
	if current_time - last_performance_check > performance_check_interval:
		analyze_performance()
		last_performance_check = current_time

func update_fps_history(fps: float):
	"""Track FPS history for analysis"""
	fps_history.append(fps)
	if fps_history.size() > fps_history_size:
		fps_history.pop_front()
	
	# Update stats
	if fps_history.size() > 0:
		stats.fps_avg = fps_history.reduce(func(a, b): return a + b) / fps_history.size()
		stats.fps_min = fps_history.min()

func analyze_performance():
	"""Analyze current performance and trigger optimizations"""
	var avg_fps = stats.fps_avg
	var min_fps = stats.fps_min
	
	# Determine if optimization is needed
	var new_optimization_level = 0
	
	if avg_fps < min_acceptable_fps or min_fps < min_acceptable_fps * 0.8:
		new_optimization_level = 3  # Aggressive optimization
		performance_warning.emit("Poor performance detected: " + str(avg_fps) + " FPS", 3)
	elif avg_fps < target_fps * 0.85:
		new_optimization_level = 2  # Medium optimization
		performance_warning.emit("Performance below target: " + str(avg_fps) + " FPS", 2)
	elif avg_fps < target_fps * 0.95:
		new_optimization_level = 1  # Light optimization
	else:
		new_optimization_level = 0  # No optimization needed
	
	# Apply optimizations if level changed
	if new_optimization_level != optimization_level:
		apply_optimization_level(new_optimization_level)
		optimization_level = new_optimization_level

func apply_optimization_level(level: int):
	"""Apply performance optimizations based on level"""
	var changes = {}
	
	match level:
		0:  # No optimization - restore defaults
			changes = restore_default_settings()
		1:  # Light optimization
			changes = apply_light_optimization()
		2:  # Medium optimization
			changes = apply_medium_optimization()
		3:  # Aggressive optimization
			changes = apply_aggressive_optimization()
	
	adjustments_made += 1
	stats.optimization_adjustments = adjustments_made
	last_optimization_time = Time.get_ticks_msec() * 0.001
	
	performance_optimized.emit(level, changes)
	
	print("🔧 Collision optimization level ", level, " applied: ", changes)

func restore_default_settings() -> Dictionary:
	"""Restore default performance settings"""
	var changes = {}
	
	# Reset collision check intervals
	if spatial_grid:
		update_collision_components_timing(collision_check_interval_min, cache_update_interval_min)
		changes["collision_timing"] = "restored_default"
	
	# Reset LOD settings
	if lod_manager and game_config:
		game_config.set("max_full_physics_enemies", 50)
		game_config.set("max_simplified_enemies", 150)
		changes["lod_limits"] = "restored_default"
	
	return changes

func apply_light_optimization() -> Dictionary:
	"""Apply light performance optimizations"""
	var changes = {}
	
	# Slightly reduce collision check frequency
	var collision_interval = lerp(collision_check_interval_min, collision_check_interval_max, 0.2)
	var cache_interval = lerp(cache_update_interval_min, cache_update_interval_max, 0.2)
	update_collision_components_timing(collision_interval, cache_interval)
	changes["collision_frequency"] = "reduced_20%"
	
	# Slightly reduce LOD limits
	if lod_manager and game_config:
		game_config.set("max_full_physics_enemies", 40)
		game_config.set("max_simplified_enemies", 120)
		changes["lod_limits"] = "reduced_20%"
	
	return changes

func apply_medium_optimization() -> Dictionary:
	"""Apply medium performance optimizations"""
	var changes = {}
	
	# Moderately reduce collision check frequency
	var collision_interval = lerp(collision_check_interval_min, collision_check_interval_max, 0.5)
	var cache_interval = lerp(cache_update_interval_min, cache_update_interval_max, 0.4)
	update_collision_components_timing(collision_interval, cache_interval)
	changes["collision_frequency"] = "reduced_50%"
	
	# Reduce LOD limits
	if lod_manager and game_config:
		game_config.set("max_full_physics_enemies", 30)
		game_config.set("max_simplified_enemies", 80)
		changes["lod_limits"] = "reduced_40%"
	
	# Reduce spatial grid cell size for better performance
	if spatial_grid and game_config:
		game_config.set("spatial_grid_size", 150.0)  # Larger cells = fewer cells
		changes["grid_optimization"] = "larger_cells"
	
	return changes

func apply_aggressive_optimization() -> Dictionary:
	"""Apply aggressive performance optimizations"""
	var changes = {}
	
	# Significantly reduce collision check frequency
	var collision_interval = lerp(collision_check_interval_min, collision_check_interval_max, 0.8)
	var cache_interval = lerp(cache_update_interval_min, cache_update_interval_max, 0.7)
	update_collision_components_timing(collision_interval, cache_interval)
	changes["collision_frequency"] = "reduced_80%"
	
	# Aggressive LOD reduction
	if lod_manager and game_config:
		game_config.set("max_full_physics_enemies", 20)
		game_config.set("max_simplified_enemies", 50)
		changes["lod_limits"] = "reduced_60%"
	
	# Optimize spatial grid for maximum performance
	if spatial_grid and game_config:
		game_config.set("spatial_grid_size", 200.0)  # Much larger cells
		game_config.set("max_entities_per_cell", 30)  # Allow more entities per cell
		changes["grid_optimization"] = "maximum_performance"
	
	# Reduce collision force calculations
	if game_config:
		game_config.set("collision_force_multiplier", 50.0)  # Lighter calculations
		changes["collision_calculations"] = "simplified"
	
	return changes

func update_collision_components_timing(collision_interval: float, cache_interval: float):
	"""Update timing parameters for all collision components"""
	# Update all MassBasedCollision components
	var collision_components = get_tree().get_nodes_in_group("mass_collision_components")
	for component in collision_components:
		if component.has("collision_check_interval"):
			component.collision_check_interval = collision_interval
		if component.has("cache_update_interval"):
			component.cache_update_interval = cache_interval

func get_optimization_recommendations() -> Array:
	"""Get recommendations for manual optimization"""
	var recommendations = []
	
	if stats.fps_avg < target_fps * 0.9:
		recommendations.append("Consider reducing max enemy count")
		recommendations.append("Enable LOD system auto-scaling")
	
	if spatial_grid:
		var grid_stats = spatial_grid.get_debug_info()
		if grid_stats.get("avg_entities_per_cell", 0) > 15:
			recommendations.append("Increase spatial grid cell size")
		if grid_stats.get("query_count", 0) > 500:
			recommendations.append("Reduce collision check frequency")
	
	if current_fps < min_acceptable_fps:
		recommendations.append("Enable aggressive optimization mode")
		recommendations.append("Consider disabling collision for distant enemies")
	
	return recommendations

func force_optimization_level(level: int):
	"""Manually force specific optimization level"""
	apply_optimization_level(level)
	optimization_level = level

func get_performance_report() -> Dictionary:
	"""Get comprehensive performance report"""
	var report = stats.duplicate()
	
	report.optimization_level = optimization_level
	report.target_fps = target_fps
	report.performance_health = get_performance_health()
	report.recommendations = get_optimization_recommendations()
	
	if spatial_grid:
		report.spatial_grid_stats = spatial_grid.get_debug_info()
	
	if lod_manager:
		report.lod_stats = lod_manager.get_lod_statistics()
	
	return report

func get_performance_health() -> String:
	"""Get performance health status"""
	if stats.fps_avg >= target_fps * 0.95:
		return "excellent"
	elif stats.fps_avg >= target_fps * 0.85:
		return "good"
	elif stats.fps_avg >= min_acceptable_fps:
		return "acceptable"
	else:
		return "poor"

# Event handlers
func _on_fps_updated(fps: float):
	"""Handle FPS updates from PerformanceMonitor"""
	# Already handled in _process, but could be used for immediate response
	pass

func _on_spatial_grid_warning(message: String):
	"""Handle warnings from spatial grid"""
	stats.performance_warnings += 1
	performance_warning.emit("SpatialGrid: " + message, 2)
	
	# Trigger immediate optimization if needed
	if message.contains("overcrowded"):
		var current_time = Time.get_ticks_msec() * 0.001
		if current_time - last_optimization_time > 5.0:  # Don't optimize too frequently
			apply_optimization_level(min(optimization_level + 1, 3))

# Debug and monitoring
func get_debug_info() -> Dictionary:
	"""Get debug information"""
	return {
		"optimization_level": optimization_level,
		"current_fps": current_fps,
		"fps_history": fps_history,
		"stats": stats,
		"adjustments_made": adjustments_made
	}

func reset_statistics():
	"""Reset performance statistics"""
	stats = {
		"fps_avg": 60.0,
		"fps_min": 60.0,
		"collision_checks_per_second": 0,
		"entities_processed": 0,
		"optimization_adjustments": 0,
		"performance_warnings": 0
	}
	fps_history.clear()
	adjustments_made = 0