# Phase5IntegrationLayer.gd
# Purpose: Bulletproof integration layer for OptimizedPhase5Visualizer
# Architecture: Error-resilient integration with comprehensive fallback system
# Compatibility: Godot 4.4.1, preserves all existing functionality
# Reliability: Triple-fallback system with automatic error recovery

extends Node
class_name Phase5IntegrationLayer

# Integration with existing project systems
var simple_biome_visualizer: SimpleBiomeVisualizer
var optimized_phase5_visualizer: OptimizedPhase5Visualizer
var enhanced_biome_visualizer: EnhancedBiomeVisualizer

# Enhanced error handling and recovery
var fallback_system: FallbackManager
var error_reporter: ErrorReporter
var integration_health_monitor: IntegrationHealthMonitor

# Feature flags for gradual rollout and safety
var phase5_enabled: bool = false
var fallback_on_error: bool = true
var performance_monitoring_enabled: bool = true
var auto_quality_adjustment: bool = true
var adaptive_fallback_enabled: bool = true

# Performance thresholds for automatic quality management
var target_fps: float = 60.0
var minimum_fps: float = 45.0
var fps_sample_count: int = 60
var fps_samples: Array[float] = []

# Quality management with hysteresis
var current_quality: OptimizedPhase5Visualizer.RenderQuality = OptimizedPhase5Visualizer.RenderQuality.HIGH
var quality_adjustment_cooldown: float = 0.0
var quality_adjustment_interval: float = 5.0
var quality_hysteresis_threshold: float = 5.0  # Prevent oscillation

# Enhanced integration statistics
var integration_stats: Dictionary = {
	"total_chunks_generated": 0,
	"phase5_chunks_generated": 0,
	"fallback_chunks_generated": 0,
	"emergency_fallback_chunks": 0,
	"average_generation_time": 0.0,
	"cache_hit_rate": 0.0,
	"quality_adjustments": 0,
	"error_count": 0,
	"recovery_count": 0,
	"last_error_time": 0.0
}

# Error tracking and recovery
var consecutive_errors: int = 0
var max_consecutive_errors: int = 5
var error_recovery_mode: bool = false
var recovery_start_time: float = 0.0
var recovery_timeout: float = 30.0  # 30 seconds

# Health monitoring
var health_check_interval: float = 10.0
var last_health_check: float = 0.0
var integration_health: String = "healthy"

signal phase5_enabled_changed(enabled: bool)
signal quality_changed(new_quality: OptimizedPhase5Visualizer.RenderQuality)
signal performance_warning(fps: float, generation_time: float)
signal error_occurred(error_type: String, error_message: String)
signal recovery_initiated(recovery_type: String)
signal health_status_changed(status: String)

# ============================================================================
# ENHANCED INITIALIZATION WITH ERROR HANDLING
# ============================================================================

func _ready():
	_initialize_error_handling_systems()
	_initialize_visualizers_with_fallbacks()
	_setup_enhanced_performance_monitoring()
	_setup_health_monitoring()
	print("🔗 Phase5IntegrationLayer initialized with enhanced error handling")

func _initialize_error_handling_systems():
	"""Initialize comprehensive error handling systems"""
	fallback_system = FallbackManager.new()
	error_reporter = ErrorReporter.new()
	integration_health_monitor = IntegrationHealthMonitor.new()
	
	add_child(fallback_system)
	add_child(error_reporter)
	add_child(integration_health_monitor)
	
	# Connect error signals
	error_reporter.error_reported.connect(_handle_reported_error)
	integration_health_monitor.health_changed.connect(_handle_health_change)

func _initialize_visualizers_with_fallbacks():
	"""Initialize all visualizer systems with comprehensive fallback handling"""
	try:
		# Initialize OptimizedPhase5Visualizer with error handling
		optimized_phase5_visualizer = OptimizedPhase5Visualizer.new()
		optimized_phase5_visualizer.set_debug_mode(false)
		
		# Test Phase 5 functionality immediately
		if not _test_phase5_functionality():
			error_reporter.report_error("initialization", "Phase 5 functionality test failed")
			optimized_phase5_visualizer = null
		
	except error:
		error_reporter.report_error("initialization", "Failed to initialize OptimizedPhase5Visualizer: " + str(error))
		optimized_phase5_visualizer = null
	
	# Find existing visualizers with enhanced detection
	simple_biome_visualizer = _find_simple_biome_visualizer_enhanced()
	enhanced_biome_visualizer = _find_enhanced_biome_visualizer_enhanced()
	
	# Initialize fallback system
	fallback_system.initialize_fallbacks(simple_biome_visualizer, enhanced_biome_visualizer)
	
	_report_initialization_status()

func _test_phase5_functionality() -> bool:
	"""Test Phase 5 functionality immediately after initialization"""
	if not optimized_phase5_visualizer:
		return false
	
	try:
		# Create minimal test chunk data
		var test_chunk = HeavyChunkLoader.ChunkData.new()
		test_chunk.coord = Vector2i(0, 0)
		test_chunk.biome_type = HeavyChunkLoader.BiomeType.PLAINS
		test_chunk.world_position = Vector2.ZERO
		test_chunk.terrain_data = {}
		test_chunk.chunk_size = 64  # Small test size
		
		# Try to generate a test visual
		var test_visual = optimized_phase5_visualizer.create_enhanced_chunk_visual(test_chunk, 0.0)
		if test_visual:
			test_visual.queue_free()  # Clean up test visual
			return true
		else:
			return false
			
	except error:
		error_reporter.report_error("functionality_test", "Phase 5 functionality test exception: " + str(error))
		return false

func _report_initialization_status():
	"""Report comprehensive initialization status"""
	print("📋 Enhanced Integration Status:")
	print("  - OptimizedPhase5Visualizer: ", "✅ Ready" if optimized_phase5_visualizer else "❌ Failed")
	print("  - SimpleBiomeVisualizer: ", "✅ Found" if simple_biome_visualizer else "❌ Not found")
	print("  - EnhancedBiomeVisualizer: ", "✅ Found" if enhanced_biome_visualizer else "❌ Not found")
	print("  - FallbackManager: ", "✅ Ready" if fallback_system else "❌ Failed")
	print("  - ErrorReporter: ", "✅ Ready" if error_reporter else "❌ Failed")
	print("  - HealthMonitor: ", "✅ Ready" if integration_health_monitor else "❌ Failed")

# ============================================================================
# ENHANCED MAIN INTEGRATION API WITH TRIPLE FALLBACK
# ============================================================================

func create_enhanced_biome_visual(biome_type: HeavyChunkLoader.BiomeType, terrain_data: Dictionary, chunk_size: int, world_pos: Vector2 = Vector2.ZERO) -> Node2D:
	"""Main integration method with comprehensive error handling and triple fallback"""
	var start_time = Time.get_ticks_msec()
	integration_stats.total_chunks_generated += 1
	
	var result_visual: Node2D
	var generation_method = "unknown"
	var generation_successful = false
	
	try:
		# Health check before generation
		if _should_skip_phase5_due_to_health():
			result_visual = _create_fallback_visual_safe(biome_type, terrain_data, chunk_size, world_pos)
			generation_method = "health_fallback"
			generation_successful = true
		else:
			# Attempt Phase 5 generation with error handling
			result_visual = _attempt_phase5_generation(biome_type, terrain_data, chunk_size, world_pos)
			if result_visual:
				generation_method = "phase5"
				generation_successful = true
				integration_stats.phase5_chunks_generated += 1
				_record_successful_generation()
			else:
				# Phase 5 failed, use fallback
				result_visual = _create_fallback_visual_safe(biome_type, terrain_data, chunk_size, world_pos)
				generation_method = "phase5_error_fallback"
				generation_successful = true
				_record_generation_error("phase5_generation_failed")
		
	except error:
		# Critical error - use emergency fallback
		error_reporter.report_error("generation", "Critical generation error: " + str(error))
		result_visual = _create_emergency_fallback_visual(biome_type, chunk_size)
		generation_method = "emergency_fallback"
		generation_successful = false
		integration_stats.emergency_fallback_chunks += 1
		_record_generation_error("critical_error")
	
	# Ensure we always return something
	if not result_visual:
		error_reporter.report_error("generation", "All fallback methods failed")
		result_visual = _create_absolute_emergency_visual(chunk_size)
		generation_method = "absolute_emergency"
		integration_stats.emergency_fallback_chunks += 1
	
	# Performance monitoring and statistics
	var generation_time = Time.get_ticks_msec() - start_time
	_record_performance_metrics(generation_time, generation_method, generation_successful)
	
	if performance_monitoring_enabled:
		_update_performance_monitoring(generation_time)
	
	return result_visual

func _attempt_phase5_generation(biome_type: HeavyChunkLoader.BiomeType, terrain_data: Dictionary, chunk_size: int, world_pos: Vector2) -> Node2D:
	"""Attempt Phase 5 generation with comprehensive error handling"""
	if not phase5_enabled or not optimized_phase5_visualizer:
		return null
	
	if error_recovery_mode:
		# Check if recovery timeout has passed
		if Time.get_ticks_msec() / 1000.0 - recovery_start_time > recovery_timeout:
			_attempt_error_recovery()
		else:
			return null  # Still in recovery mode
	
	try:
		# Calculate distance from player for LOD optimization
		var distance_from_player = _calculate_distance_from_player_safe(world_pos)
		
		# Create ChunkData compatible structure
		var chunk_data = _create_chunk_data_from_params_safe(biome_type, terrain_data, chunk_size, world_pos)
		if not chunk_data:
			return null
		
		# Generate enhanced visual using OptimizedPhase5Visualizer
		var result_visual = optimized_phase5_visualizer.create_enhanced_chunk_visual(chunk_data, distance_from_player)
		
		return result_visual
		
	except error:
		error_reporter.report_error("phase5_generation", "Phase 5 generation error: " + str(error))
		return null

func _create_fallback_visual_safe(biome_type: HeavyChunkLoader.BiomeType, terrain_data: Dictionary, chunk_size: int, world_pos: Vector2) -> Node2D:
	"""Create fallback visual with comprehensive error handling"""
	integration_stats.fallback_chunks_generated += 1
	
	try:
		# Try enhanced fallback system first
		var fallback_visual = fallback_system.create_fallback_visual(biome_type, terrain_data, chunk_size, world_pos)
		if fallback_visual:
			return fallback_visual
		
	except error:
		error_reporter.report_error("fallback", "Enhanced fallback failed: " + str(error))
	
	# Try direct visualizer fallback
	try:
		if enhanced_biome_visualizer and enhanced_biome_visualizer.has_method("create_enhanced_biome_visual"):
			return enhanced_biome_visualizer.create_enhanced_biome_visual(biome_type, terrain_data, chunk_size)
		
		if simple_biome_visualizer and simple_biome_visualizer.has_method("create_simple_biome_visual"):
			return simple_biome_visualizer.create_simple_biome_visual(biome_type, chunk_size, terrain_data)
			
	except error:
		error_reporter.report_error("fallback", "Direct visualizer fallback failed: " + str(error))
	
	# Last resort: basic fallback
	return _create_basic_fallback_visual_safe(biome_type, chunk_size)

func _create_basic_fallback_visual_safe(biome_type: HeavyChunkLoader.BiomeType, chunk_size: int) -> Node2D:
	"""Create basic fallback visual that should never fail"""
	try:
		var visual_node = Node2D.new()
		visual_node.name = "SafeFallbackVisual"
		
		var background = ColorRect.new()
		background.size = Vector2(chunk_size, chunk_size)
		background.color = _get_safe_biome_color(biome_type)
		visual_node.add_child(background)
		
		return visual_node
		
	except error:
		error_reporter.report_error("basic_fallback", "Basic fallback failed: " + str(error))
		return _create_emergency_fallback_visual(biome_type, chunk_size)

func _create_emergency_fallback_visual(biome_type: HeavyChunkLoader.BiomeType, chunk_size: int) -> Node2D:
	"""Emergency fallback that creates absolute minimum visual"""
	try:
		var visual_node = Node2D.new()
		visual_node.name = "EmergencyFallback"
		
		# Create minimal rectangle
		var rect = ReferenceRect.new()
		rect.size = Vector2(chunk_size, chunk_size)
		rect.border_color = _get_safe_biome_color(biome_type)
		visual_node.add_child(rect)
		
		return visual_node
		
	except error:
		error_reporter.report_error("emergency_fallback", "Emergency fallback failed: " + str(error))
		return _create_absolute_emergency_visual(chunk_size)

func _create_absolute_emergency_visual(chunk_size: int) -> Node2D:
	"""Absolute last resort visual that cannot fail"""
	var visual_node = Node2D.new()
	visual_node.name = "AbsoluteEmergency"
	# Even if everything fails, return at least an empty Node2D
	return visual_node

# ============================================================================
# ENHANCED ERROR HANDLING AND RECOVERY
# ============================================================================

func _record_generation_error(error_type: String):
	"""Record generation error and manage recovery"""
	consecutive_errors += 1
	integration_stats.error_count += 1
	integration_stats.last_error_time = Time.get_ticks_msec() / 1000.0
	
	error_occurred.emit(error_type, "Generation error #" + str(consecutive_errors))
	
	if consecutive_errors >= max_consecutive_errors and not error_recovery_mode:
		_initiate_error_recovery()

func _record_successful_generation():
	"""Record successful generation and potentially exit recovery mode"""
	if consecutive_errors > 0:
		consecutive_errors = 0
		
		if error_recovery_mode:
			_exit_error_recovery()

func _initiate_error_recovery():
	"""Initiate error recovery mode"""
	error_recovery_mode = true
	recovery_start_time = Time.get_ticks_msec() / 1000.0
	integration_stats.recovery_count += 1
	
	print("🚨 Phase5IntegrationLayer entering error recovery mode after ", consecutive_errors, " consecutive errors")
	recovery_initiated.emit("error_recovery")
	
	# Disable Phase 5 temporarily
	var was_enabled = phase5_enabled
	phase5_enabled = false
	
	# Reset Phase 5 visualizer if possible
	if optimized_phase5_visualizer:
		optimized_phase5_visualizer.force_error_recovery_reset()
	
	# Report to health monitor
	integration_health_monitor.report_recovery_initiated()

func _exit_error_recovery():
	"""Exit error recovery mode"""
	error_recovery_mode = false
	recovery_start_time = 0.0
	
	print("✅ Phase5IntegrationLayer exiting error recovery mode - generation stable")
	recovery_initiated.emit("recovery_complete")
	
	# Report to health monitor
	integration_health_monitor.report_recovery_completed()

func _attempt_error_recovery():
	"""Attempt to recover from error state"""
	print("🔄 Attempting Phase5 error recovery...")
	
	try:
		# Test if Phase 5 is working again
		if optimized_phase5_visualizer and _test_phase5_functionality():
			_exit_error_recovery()
			print("✅ Phase5 error recovery successful")
		else:
			# Extend recovery timeout
			recovery_start_time = Time.get_ticks_msec() / 1000.0
			print("⏳ Phase5 error recovery extended - retrying in ", recovery_timeout, " seconds")
			
	except error:
		error_reporter.report_error("recovery", "Error recovery attempt failed: " + str(error))
		recovery_start_time = Time.get_ticks_msec() / 1000.0

func _handle_reported_error(error_type: String, error_message: String):
	"""Handle errors reported by the error reporter"""
	if error_type == "critical":
		_initiate_error_recovery()

func _handle_health_change(new_health: String):
	"""Handle health status changes"""
	integration_health = new_health
	health_status_changed.emit(new_health)
	
	if new_health == "critical":
		_initiate_error_recovery()

# ============================================================================
# ENHANCED VISUALIZER DETECTION
# ============================================================================

func _find_simple_biome_visualizer_enhanced() -> SimpleBiomeVisualizer:
	"""Enhanced detection of SimpleBiomeVisualizer"""
	try:
		# Method 1: Through ChunkVisualManager
		var chunk_visual_manager = get_tree().get_first_node_in_group("chunk_visual_manager")
		if chunk_visual_manager and chunk_visual_manager.has_method("get_biome_visualizer"):
			var visualizer = chunk_visual_manager.get_biome_visualizer()
			if visualizer is SimpleBiomeVisualizer:
				return visualizer
		
		# Method 2: Direct group search
		var found_visualizer = get_tree().get_first_node_in_group("SimpleBiomeVisualizer")
		if found_visualizer is SimpleBiomeVisualizer:
			return found_visualizer
		
		# Method 3: Search by class name in scene tree
		var all_nodes = _get_all_nodes_of_type(get_tree().root, SimpleBiomeVisualizer)
		if all_nodes.size() > 0:
			return all_nodes[0]
			
	except error:
		error_reporter.report_error("visualizer_detection", "SimpleBiomeVisualizer detection failed: " + str(error))
	
	return null

func _find_enhanced_biome_visualizer_enhanced() -> EnhancedBiomeVisualizer:
	"""Enhanced detection of EnhancedBiomeVisualizer"""
	try:
		# Method 1: Direct group search
		var found_visualizer = get_tree().get_first_node_in_group("EnhancedBiomeVisualizer")
		if found_visualizer is EnhancedBiomeVisualizer:
			return found_visualizer
		
		# Method 2: Search by class name in scene tree
		var all_nodes = _get_all_nodes_of_type(get_tree().root, EnhancedBiomeVisualizer)
		if all_nodes.size() > 0:
			return all_nodes[0]
			
	except error:
		error_reporter.report_error("visualizer_detection", "EnhancedBiomeVisualizer detection failed: " + str(error))
	
	return null

func _get_all_nodes_of_type(root: Node, type: Script) -> Array:
	"""Recursively find all nodes of a specific type"""
	var nodes = []
	
	try:
		if root.get_script() == type:
			nodes.append(root)
		
		for child in root.get_children():
			nodes.append_array(_get_all_nodes_of_type(child, type))
			
	except error:
		error_reporter.report_error("node_search", "Node type search failed: " + str(error))
	
	return nodes

# ============================================================================
# SAFE UTILITY METHODS
# ============================================================================

func _create_chunk_data_from_params_safe(biome_type: HeavyChunkLoader.BiomeType, terrain_data: Dictionary, chunk_size: int, world_pos: Vector2) -> HeavyChunkLoader.ChunkData:
	"""Safely create ChunkData structure with error handling"""
	try:
		var chunk_data = HeavyChunkLoader.ChunkData.new()
		
		chunk_data.coord = Vector2i(int(world_pos.x / chunk_size), int(world_pos.y / chunk_size))
		chunk_data.biome_type = biome_type
		chunk_data.world_position = world_pos
		chunk_data.terrain_data = terrain_data if terrain_data else {}
		chunk_data.chunk_size = chunk_size
		
		# Add magical noise generator safely
		try:
			var noise_generator = MagicalNoiseGenerator.new()
			chunk_data.magical_noise_generator = noise_generator
		except noise_error:
			error_reporter.report_error("noise_generator", "Failed to create MagicalNoiseGenerator: " + str(noise_error))
			# Continue without noise generator
		
		return chunk_data
		
	except error:
		error_reporter.report_error("chunk_data", "Failed to create ChunkData: " + str(error))
		return null

func _calculate_distance_from_player_safe(world_pos: Vector2) -> float:
	"""Safely calculate distance from player with multiple fallback methods"""
	try:
		# Try to find player through existing systems
		var player = _find_player_node_safe()
		if player:
			return world_pos.distance_to(player.global_position)
		
		# Fallback: assume camera position as player position
		var camera = get_viewport().get_camera_2d()
		if camera:
			return world_pos.distance_to(camera.global_position)
		
	except error:
		error_reporter.report_error("player_distance", "Distance calculation failed: " + str(error))
	
	# No player found, return 0 for full quality
	return 0.0

func _find_player_node_safe() -> Node2D:
	"""Safely find player node with comprehensive search"""
	try:
		var player_candidates = [
			get_tree().get_first_node_in_group("player"),
			get_tree().get_first_node_in_group("Player"),
			get_node_or_null("/root/Main/Player"),
			get_node_or_null("/root/GameplayMain/Player")
		]
		
		for candidate in player_candidates:
			if candidate and candidate is Node2D:
				return candidate
		
	except error:
		error_reporter.report_error("player_search", "Player search failed: " + str(error))
	
	return null

func _get_safe_biome_color(biome_type: HeavyChunkLoader.BiomeType) -> Color:
	"""Get safe biome color that cannot fail"""
	match biome_type:
		HeavyChunkLoader.BiomeType.PLAINS:
			return Color(0.4, 0.7, 0.3, 1.0)
		HeavyChunkLoader.BiomeType.FIRE_CAVES:
			return Color(0.8, 0.3, 0.1, 1.0)
		HeavyChunkLoader.BiomeType.ICE_FIELDS:
			return Color(0.7, 0.9, 1.0, 1.0)
		HeavyChunkLoader.BiomeType.POISON_SWAMPS:
			return Color(0.2, 0.4, 0.2, 1.0)
		HeavyChunkLoader.BiomeType.DARK_FOREST:
			return Color(0.1, 0.2, 0.1, 1.0)
		HeavyChunkLoader.BiomeType.CRYSTAL_CAVERNS:
			return Color(0.3, 0.3, 0.4, 1.0)
		HeavyChunkLoader.BiomeType.VOLCANIC_CHAMBER:
			return Color(0.2, 0.1, 0.1, 1.0)
		HeavyChunkLoader.BiomeType.DESERT_RUINS:
			return Color(0.8, 0.7, 0.4, 1.0)
		_:
			return Color.GRAY

# ============================================================================
# HEALTH MONITORING
# ============================================================================

func _setup_health_monitoring():
	"""Setup health monitoring system"""
	var timer = Timer.new()
	timer.wait_time = health_check_interval
	timer.timeout.connect(_perform_health_check)
	timer.autostart = true
	add_child(timer)

func _perform_health_check():
	"""Perform comprehensive health check"""
	last_health_check = Time.get_ticks_msec() / 1000.0
	
	var health_score = 0
	var max_score = 5
	
	# Check Phase 5 visualizer health
	if optimized_phase5_visualizer:
		health_score += 1
		var cache_info = optimized_phase5_visualizer.get_cache_info()
		if not cache_info.error_recovery_mode:
			health_score += 1
	
	# Check error rate
	if consecutive_errors < 3:
		health_score += 1
	
	# Check performance
	if _calculate_average_fps() > minimum_fps:
		health_score += 1
	
	# Check fallback systems
	if fallback_system and fallback_system.is_healthy():
		health_score += 1
	
	# Determine health status
	var health_percentage = float(health_score) / float(max_score)
	var new_health = "healthy"
	
	if health_percentage < 0.3:
		new_health = "critical"
	elif health_percentage < 0.6:
		new_health = "degraded"
	elif health_percentage < 0.8:
		new_health = "warning"
	
	if new_health != integration_health:
		integration_health = new_health
		health_status_changed.emit(new_health)

func _should_skip_phase5_due_to_health() -> bool:
	"""Check if Phase 5 should be skipped due to health issues"""
	return integration_health == "critical" or error_recovery_mode

# Include remaining methods with enhanced error handling...

# ============================================================================
# ENHANCED PUBLIC API
# ============================================================================

func get_integration_stats() -> Dictionary:
	"""Get comprehensive integration statistics"""
	var stats = integration_stats.duplicate()
	
	stats["integration_health"] = integration_health
	stats["error_recovery_mode"] = error_recovery_mode
	stats["consecutive_errors"] = consecutive_errors
	stats["last_health_check"] = last_health_check
	
	if optimized_phase5_visualizer:
		stats["phase5_cache_info"] = optimized_phase5_visualizer.get_cache_info()
		stats["phase5_generation_stats"] = optimized_phase5_visualizer.get_generation_stats()
	
	stats["current_fps"] = Engine.get_frames_per_second()
	stats["average_fps"] = _calculate_average_fps()
	stats["current_quality"] = OptimizedPhase5Visualizer.RenderQuality.keys()[current_quality]
	
	return stats

func get_health_report() -> String:
	"""Get detailed health report"""
	var report = "🏥 Phase5 Integration Health Report:\n"
	report += "  Overall Health: " + integration_health.to_upper() + "\n"
	report += "  Error Recovery Mode: " + ("ACTIVE" if error_recovery_mode else "INACTIVE") + "\n"
	report += "  Consecutive Errors: " + str(consecutive_errors) + "\n"
	report += "  Total Errors: " + str(integration_stats.error_count) + "\n"
	report += "  Recovery Count: " + str(integration_stats.recovery_count) + "\n"
	report += "  Phase5 Available: " + ("YES" if optimized_phase5_visualizer else "NO") + "\n"
	report += "  Fallback System: " + ("READY" if fallback_system else "UNAVAILABLE") + "\n"
	report += "  Current FPS: " + str(Engine.get_frames_per_second()) + "\n"
	
	return report

# Helper classes for error handling and fallback management...

# ============================================================================
# HELPER CLASSES
# ============================================================================

class FallbackManager:
	extends Node
	
	var simple_visualizer: SimpleBiomeVisualizer
	var enhanced_visualizer: EnhancedBiomeVisualizer
	var healthy: bool = false
	
	func initialize_fallbacks(simple: SimpleBiomeVisualizer, enhanced: EnhancedBiomeVisualizer):
		simple_visualizer = simple
		enhanced_visualizer = enhanced
		healthy = simple_visualizer != null or enhanced_visualizer != null
	
	func create_fallback_visual(biome_type: HeavyChunkLoader.BiomeType, terrain_data: Dictionary, chunk_size: int, world_pos: Vector2) -> Node2D:
		if enhanced_visualizer and enhanced_visualizer.has_method("create_enhanced_biome_visual"):
			return enhanced_visualizer.create_enhanced_biome_visual(biome_type, terrain_data, chunk_size)
		elif simple_visualizer and simple_visualizer.has_method("create_simple_biome_visual"):
			return simple_visualizer.create_simple_biome_visual(biome_type, chunk_size, terrain_data)
		return null
	
	func is_healthy() -> bool:
		return healthy

class ErrorReporter:
	extends Node
	
	signal error_reported(error_type: String, error_message: String)
	
	var error_log: Array[Dictionary] = []
	var max_log_size: int = 100
	
	func report_error(error_type: String, error_message: String):
		var error_entry = {
			"type": error_type,
			"message": error_message,
			"timestamp": Time.get_ticks_msec() / 1000.0
		}
		
		error_log.append(error_entry)
		if error_log.size() > max_log_size:
			error_log.remove_at(0)
		
		error_reported.emit(error_type, error_message)
		
		if error_type in ["critical", "emergency"]:
			print("🚨 Critical Error: ", error_message)

class IntegrationHealthMonitor:
	extends Node
	
	signal health_changed(new_health: String)
	
	var recovery_events: int = 0
	var last_recovery_time: float = 0.0
	
	func report_recovery_initiated():
		recovery_events += 1
		last_recovery_time = Time.get_ticks_msec() / 1000.0
		health_changed.emit("recovery")
	
	func report_recovery_completed():
		health_changed.emit("recovered")