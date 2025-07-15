# Phase5Config.gd
# Purpose: Configuration management for Phase 5 enhanced rendering
# Architecture: Centralized settings with hardware-specific optimizations
# Compatibility: Godot 4.4.1 - Claude Code executable
# Usage: Settings management and hardware optimization

extends RefCounted
class_name Phase5Config

# Default settings optimized for Godot 4.4.1
const DEFAULT_SETTINGS = {
	"render_quality": "HIGH",
	"auto_quality_adjustment": true,
	"performance_monitoring": true,
	"fallback_on_error": true,
	"debug_mode": false,
	"max_cache_size": 50,
	"target_fps": 60.0,
	"minimum_fps": 45.0,
	"memory_pressure_threshold": 100,  # MB
	"enable_thread_safety": true,
	"adaptive_quality_enabled": true,
	"distance_based_lod": true
}

# Hardware-specific preset configurations
const HARDWARE_PRESETS = {
	"ultra": {
		"render_quality": "ULTRA",
		"max_cache_size": 100,
		"target_fps": 75.0,
		"minimum_fps": 60.0,
		"memory_pressure_threshold": 200
	},
	"high": {
		"render_quality": "HIGH",
		"max_cache_size": 75,
		"target_fps": 60.0,
		"minimum_fps": 45.0,
		"memory_pressure_threshold": 150
	},
	"medium": {
		"render_quality": "MEDIUM",
		"max_cache_size": 50,
		"target_fps": 50.0,
		"minimum_fps": 35.0,
		"memory_pressure_threshold": 100
	},
	"low": {
		"render_quality": "LOW",
		"max_cache_size": 25,
		"target_fps": 40.0,
		"minimum_fps": 25.0,
		"memory_pressure_threshold": 75
	},
	"mobile": {
		"render_quality": "LOW",
		"max_cache_size": 15,
		"target_fps": 30.0,
		"minimum_fps": 20.0,
		"memory_pressure_threshold": 50,
		"auto_quality_adjustment": true,
		"adaptive_quality_enabled": true
	}
}

# ============================================================================
# CONFIGURATION MANAGEMENT
# ============================================================================

static func get_default_settings() -> Dictionary:
	"""Get default configuration settings"""
	return DEFAULT_SETTINGS.duplicate()

static func get_hardware_preset(hardware_class: String) -> Dictionary:
	"""Get hardware-specific preset configuration"""
	var preset = HARDWARE_PRESETS.get(hardware_class.to_lower(), HARDWARE_PRESETS.medium)
	var settings = DEFAULT_SETTINGS.duplicate()
	
	# Merge preset with defaults
	for key in preset.keys():
		settings[key] = preset[key]
	
	return settings

static func get_optimal_settings_for_system() -> Dictionary:
	"""Get optimal settings based on current system capabilities"""
	var settings = DEFAULT_SETTINGS.duplicate()
	
	# Detect system capabilities
	var system_class = _detect_hardware_class()
	var hardware_preset = get_hardware_preset(system_class)
	
	# Merge hardware preset
	for key in hardware_preset.keys():
		settings[key] = hardware_preset[key]
	
	# Additional system-specific optimizations
	settings = _apply_system_optimizations(settings)
	
	return settings

static func _detect_hardware_class() -> String:
	"""Detect hardware class based on system capabilities"""
	var renderer_info = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TYPE_VIDEO)
	var memory_info = OS.get_static_memory_usage_by_type()
	
	# Calculate total memory
	var total_memory = 0
	for memory_type in memory_info.values():
		total_memory += memory_type
	total_memory = total_memory / (1024 * 1024)  # Convert to MB
	
	# Simple hardware classification based on available data
	var current_fps = Engine.get_frames_per_second()
	
	if total_memory > 8000 and current_fps >= 60:  # 8GB+ RAM, good performance
		return "ultra"
	elif total_memory > 4000 and current_fps >= 45:  # 4GB+ RAM, decent performance
		return "high"
	elif total_memory > 2000 and current_fps >= 30:  # 2GB+ RAM, moderate performance
		return "medium"
	elif total_memory > 1000:  # 1GB+ RAM
		return "low"
	else:
		return "mobile"

static func _apply_system_optimizations(settings: Dictionary) -> Dictionary:
	"""Apply system-specific optimizations"""
	var optimized = settings.duplicate()
	
	# Platform-specific optimizations
	var platform = OS.get_name()
	match platform:
		"Windows":
			# Windows optimizations
			optimized["enable_thread_safety"] = true
		"Linux":
			# Linux optimizations
			optimized["enable_thread_safety"] = true
		"macOS":
			# macOS optimizations
			optimized["max_cache_size"] = min(optimized["max_cache_size"], 40)
		"Android", "iOS":
			# Mobile optimizations
			optimized["render_quality"] = "LOW"
			optimized["max_cache_size"] = 15
			optimized["memory_pressure_threshold"] = 50
			optimized["auto_quality_adjustment"] = true
		"Web":
			# Web/HTML5 optimizations
			optimized["render_quality"] = "MEDIUM"
			optimized["max_cache_size"] = 20
			optimized["enable_thread_safety"] = false  # Web doesn't support threading
	
	return optimized

# ============================================================================
# SETTINGS APPLICATION
# ============================================================================

static func apply_settings_to_integration(integration: Phase5IntegrationLayer, settings: Dictionary):
	"""Apply configuration settings to Phase 5 integration layer"""
	if not integration:
		push_error("Phase5Config: Integration layer is null")
		return
	
	try:
		# Apply quality setting
		if settings.has("render_quality"):
			var quality_name = settings["render_quality"]
			var quality_enum = _get_quality_enum_from_name(quality_name)
			if quality_enum != null:
				integration.set_render_quality(quality_enum)
		
		# Apply auto quality adjustment
		if settings.has("auto_quality_adjustment"):
			integration.set_auto_quality_adjustment(settings["auto_quality_adjustment"])
		
		# Apply performance monitoring
		if settings.has("performance_monitoring"):
			integration.set_performance_monitoring(settings["performance_monitoring"])
		
		# Apply fallback setting
		if settings.has("fallback_on_error"):
			integration.set_fallback_on_error(settings["fallback_on_error"])
		
		# Apply debug mode
		if settings.has("debug_mode"):
			integration.set_debug_mode(settings["debug_mode"])
		
		# Apply performance targets
		if settings.has("target_fps") or settings.has("minimum_fps"):
			var target_fps = settings.get("target_fps", 60.0)
			var minimum_fps = settings.get("minimum_fps", 45.0)
			integration.target_fps = target_fps
			integration.minimum_fps = minimum_fps
			
			if integration.performance_monitor:
				integration.performance_monitor.set_performance_targets(target_fps, minimum_fps, 3.0)
		
		print("✅ Phase5Config: Settings applied successfully")
		
	except error:
		push_error("Phase5Config: Error applying settings - " + str(error))

static func apply_settings_to_visualizer(visualizer: OptimizedPhase5Visualizer, settings: Dictionary):
	"""Apply configuration settings to Phase 5 visualizer"""
	if not visualizer:
		push_error("Phase5Config: Visualizer is null")
		return
	
	try:
		# Apply quality setting
		if settings.has("render_quality"):
			var quality_name = settings["render_quality"]
			var quality_enum = _get_quality_enum_from_name(quality_name)
			if quality_enum != null:
				visualizer.set_render_quality(quality_enum)
		
		# Apply cache size
		if settings.has("max_cache_size"):
			visualizer.max_cache_size = settings["max_cache_size"]
		
		# Apply debug mode
		if settings.has("debug_mode"):
			visualizer.set_debug_mode(settings["debug_mode"])
		
		# Apply memory pressure threshold
		if settings.has("memory_pressure_threshold"):
			var threshold_mb = settings["memory_pressure_threshold"]
			visualizer.memory_pressure_threshold = threshold_mb * 1024 * 1024  # Convert to bytes
		
		print("✅ Phase5Config: Visualizer settings applied successfully")
		
	except error:
		push_error("Phase5Config: Error applying visualizer settings - " + str(error))

static func _get_quality_enum_from_name(quality_name: String):
	"""Convert quality name to enum value"""
	match quality_name.to_upper():
		"EMERGENCY":
			return OptimizedPhase5Visualizer.RenderQuality.EMERGENCY
		"LOW":
			return OptimizedPhase5Visualizer.RenderQuality.LOW
		"MEDIUM":
			return OptimizedPhase5Visualizer.RenderQuality.MEDIUM
		"HIGH":
			return OptimizedPhase5Visualizer.RenderQuality.HIGH
		"ULTRA":
			return OptimizedPhase5Visualizer.RenderQuality.ULTRA
		_:
			push_warning("Phase5Config: Unknown quality name: " + quality_name)
			return OptimizedPhase5Visualizer.RenderQuality.HIGH

# ============================================================================
# CONFIGURATION PROFILES
# ============================================================================

static func create_performance_profile() -> Dictionary:
	"""Create performance-focused configuration profile"""
	var settings = DEFAULT_SETTINGS.duplicate()
	
	settings["render_quality"] = "MEDIUM"
	settings["auto_quality_adjustment"] = true
	settings["max_cache_size"] = 75
	settings["target_fps"] = 60.0
	settings["minimum_fps"] = 45.0
	settings["adaptive_quality_enabled"] = true
	settings["distance_based_lod"] = true
	
	return settings

static func create_quality_profile() -> Dictionary:
	"""Create quality-focused configuration profile"""
	var settings = DEFAULT_SETTINGS.duplicate()
	
	settings["render_quality"] = "ULTRA"
	settings["auto_quality_adjustment"] = false
	settings["max_cache_size"] = 100
	settings["target_fps"] = 45.0
	settings["minimum_fps"] = 30.0
	settings["memory_pressure_threshold"] = 200
	
	return settings

static func create_balanced_profile() -> Dictionary:
	"""Create balanced configuration profile"""
	var settings = DEFAULT_SETTINGS.duplicate()
	
	settings["render_quality"] = "HIGH"
	settings["auto_quality_adjustment"] = true
	settings["max_cache_size"] = 60
	settings["target_fps"] = 55.0
	settings["minimum_fps"] = 40.0
	settings["adaptive_quality_enabled"] = true
	
	return settings

static func create_development_profile() -> Dictionary:
	"""Create development-focused configuration profile"""
	var settings = DEFAULT_SETTINGS.duplicate()
	
	settings["render_quality"] = "MEDIUM"
	settings["debug_mode"] = true
	settings["performance_monitoring"] = true
	settings["fallback_on_error"] = true
	settings["auto_quality_adjustment"] = true
	settings["max_cache_size"] = 30  # Smaller cache for faster iteration
	
	return settings

# ============================================================================
# CONFIGURATION VALIDATION
# ============================================================================

static func validate_settings(settings: Dictionary) -> Dictionary:
	"""Validate configuration settings and return validation result"""
	var validation = {
		"valid": true,
		"errors": [],
		"warnings": [],
		"corrected_settings": settings.duplicate()
	}
	
	# Validate render quality
	if settings.has("render_quality"):
		var quality = settings["render_quality"]
		if not quality in ["EMERGENCY", "LOW", "MEDIUM", "HIGH", "ULTRA"]:
			validation.errors.append("Invalid render_quality: " + str(quality))
			validation.valid = false
	
	# Validate numeric ranges
	var numeric_validations = [
		{"key": "target_fps", "min": 15.0, "max": 120.0, "default": 60.0},
		{"key": "minimum_fps", "min": 10.0, "max": 100.0, "default": 45.0},
		{"key": "max_cache_size", "min": 5, "max": 200, "default": 50},
		{"key": "memory_pressure_threshold", "min": 25, "max": 500, "default": 100}
	]
	
	for validation_rule in numeric_validations:
		var key = validation_rule.key
		if settings.has(key):
			var value = settings[key]
			if value < validation_rule.min or value > validation_rule.max:
				validation.warnings.append(key + " value " + str(value) + " is outside recommended range [" + str(validation_rule.min) + ", " + str(validation_rule.max) + "]")
				validation.corrected_settings[key] = validation_rule.default
	
	# Validate minimum_fps <= target_fps
	if settings.has("target_fps") and settings.has("minimum_fps"):
		if settings["minimum_fps"] > settings["target_fps"]:
			validation.errors.append("minimum_fps cannot be greater than target_fps")
			validation.valid = false
	
	return validation

# ============================================================================
# QUICK CONFIGURATION HELPERS
# ============================================================================

static func quick_apply_performance_settings(integration: Phase5IntegrationLayer):
	"""Quickly apply performance-optimized settings"""
	var settings = create_performance_profile()
	apply_settings_to_integration(integration, settings)

static func quick_apply_quality_settings(integration: Phase5IntegrationLayer):
	"""Quickly apply quality-optimized settings"""
	var settings = create_quality_profile()
	apply_settings_to_integration(integration, settings)

static func quick_apply_balanced_settings(integration: Phase5IntegrationLayer):
	"""Quickly apply balanced settings"""
	var settings = create_balanced_profile()
	apply_settings_to_integration(integration, settings)

static func quick_apply_auto_detected_settings(integration: Phase5IntegrationLayer):
	"""Quickly apply auto-detected optimal settings"""
	var settings = get_optimal_settings_for_system()
	apply_settings_to_integration(integration, settings)

# ============================================================================
# CONFIGURATION EXPORT/IMPORT
# ============================================================================

static func export_settings_to_string(settings: Dictionary) -> String:
	"""Export settings to JSON string for saving/sharing"""
	return JSON.stringify(settings)

static func import_settings_from_string(json_string: String) -> Dictionary:
	"""Import settings from JSON string"""
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Phase5Config: Failed to parse settings JSON")
		return get_default_settings()
	
	var imported_settings = json.data
	if typeof(imported_settings) != TYPE_DICTIONARY:
		push_error("Phase5Config: Settings JSON is not a dictionary")
		return get_default_settings()
	
	# Validate imported settings
	var validation = validate_settings(imported_settings)
	if not validation.valid:
		push_warning("Phase5Config: Imported settings have errors, using corrected version")
		return validation.corrected_settings
	
	return imported_settings

# ============================================================================
# CLAUDE CODE CONVENIENCE METHODS
# ============================================================================

static func auto_configure_phase5() -> bool:
	"""Automatically configure Phase 5 with optimal settings (Claude Code friendly)"""
	print("🎯 Auto-configuring Phase 5 with optimal settings...")
	
	# Find integration layer
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		print("❌ No scene tree available")
		return false
	
	var chunk_manager = tree.get_first_node_in_group("chunk_visual_manager")
	if not chunk_manager or not chunk_manager.phase5_integration:
		print("❌ Phase 5 integration not found")
		return false
	
	try:
		# Apply optimal settings
		var optimal_settings = get_optimal_settings_for_system()
		apply_settings_to_integration(chunk_manager.phase5_integration, optimal_settings)
		
		if chunk_manager.phase5_integration.optimized_phase5_visualizer:
			apply_settings_to_visualizer(chunk_manager.phase5_integration.optimized_phase5_visualizer, optimal_settings)
		
		print("✅ Phase 5 auto-configured successfully")
		print("📊 Hardware class detected: ", _detect_hardware_class().to_upper())
		print("🎚️ Quality setting: ", optimal_settings.get("render_quality", "HIGH"))
		
		return true
		
	except error:
		print("❌ Error during auto-configuration: ", error)
		return false

static func get_current_config_summary() -> String:
	"""Get summary of current configuration (Claude Code friendly)"""
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return "No scene tree available"
	
	var chunk_manager = tree.get_first_node_in_group("chunk_visual_manager")
	if not chunk_manager or not chunk_manager.phase5_integration:
		return "Phase 5 integration not found"
	
	var integration = chunk_manager.phase5_integration
	var summary = "📋 Current Phase 5 Configuration:\n"
	
	try:
		summary += "  Quality: " + OptimizedPhase5Visualizer.RenderQuality.keys()[integration.current_quality] + "\n"
		summary += "  Auto Quality: " + ("ENABLED" if integration.auto_quality_adjustment else "DISABLED") + "\n"
		summary += "  Performance Monitoring: " + ("ENABLED" if integration.performance_monitoring_enabled else "DISABLED") + "\n"
		summary += "  Target FPS: " + str(integration.target_fps) + "\n"
		summary += "  Hardware Class: " + _detect_hardware_class().to_upper()
	except error:
		summary += "Error reading configuration: " + str(error)
	
	return summary