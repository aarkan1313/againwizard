# Phase5QuickStart.gd
# Purpose: Quick start utilities for Phase 5 enhanced rendering
# Architecture: Simple one-command interface for Phase 5 management
# Compatibility: Godot 4.4.1 - Claude Code executable
# Usage: One-line commands for enable/disable/status

extends RefCounted
class_name Phase5QuickStart

# ============================================================================
# ONE-CLICK PHASE 5 MANAGEMENT
# ============================================================================

static func quick_enable() -> bool:
	"""Enable Phase 5 with optimal settings - ONE COMMAND SETUP"""
	print("🚀 Enabling Phase 5 Enhanced Rendering...")
	
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager:
		print("❌ ChunkVisualManager not found - ensuring installation...")
		var install_result = Phase5AutoInstaller.run_installation()
		if not install_result.success:
			print("❌ Installation failed: ", install_result.errors)
			return false
		
		# Try to find chunk manager again after installation
		chunk_manager = _find_chunk_visual_manager()
		if not chunk_manager:
			print("❌ ChunkVisualManager still not found after installation")
			return false
	
	try:
		# Enable Phase 5
		chunk_manager.enable_phase5_enhancement()
		
		# Apply optimal settings
		if chunk_manager.phase5_integration:
			var settings = Phase5Config.get_default_settings()
			Phase5Config.apply_settings_to_integration(chunk_manager.phase5_integration, settings)
			print("✅ Phase 5 enabled with optimal settings")
			
			# Quick validation
			var validation_result = Phase5TestSuite.quick_validation()
			if validation_result:
				print("✅ Phase 5 validation passed - ready to use!")
				_print_usage_tips()
				return true
			else:
				print("⚠️ Phase 5 enabled but validation had issues")
				return true  # Still return true as it's enabled
		else:
			print("⚠️ Phase 5 enabled but integration layer not available")
			return true
			
	except error:
		print("❌ Error enabling Phase 5: ", error)
		return false

static func quick_disable() -> bool:
	"""Disable Phase 5 and return to original system"""
	print("🔄 Disabling Phase 5 Enhanced Rendering...")
	
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager:
		print("❌ ChunkVisualManager not found")
		return false
	
	try:
		chunk_manager.disable_phase5_enhancement()
		print("✅ Phase 5 disabled - returned to original rendering")
		return true
	except error:
		print("❌ Error disabling Phase 5: ", error)
		return false

static func quick_status() -> Dictionary:
	"""Get quick status of Phase 5 system"""
	var status = {
		"phase5_available": false,
		"phase5_enabled": false,
		"integration_healthy": false,
		"performance_good": false,
		"current_fps": 0.0,
		"current_quality": "UNKNOWN",
		"errors": []
	}
	
	try:
		var chunk_manager = _find_chunk_visual_manager()
		if chunk_manager:
			status.phase5_available = true
			
			if chunk_manager.has_method("is_phase5_enabled"):
				status.phase5_enabled = chunk_manager.is_phase5_enabled()
			
			if chunk_manager.phase5_integration:
				var integration_stats = chunk_manager.phase5_integration.get_integration_stats()
				status.integration_healthy = integration_stats.get("integration_health", "unknown") in ["healthy", "warning"]
				status.current_fps = integration_stats.get("current_fps", 0.0)
				status.current_quality = integration_stats.get("current_quality", "UNKNOWN")
				status.performance_good = status.current_fps >= 45.0
	
	except error:
		status.errors.append(str(error))
	
	return status

static func get_performance_report() -> String:
	"""Get formatted performance report"""
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager:
		return "❌ ChunkVisualManager not found"
	
	if not chunk_manager.phase5_integration:
		return "❌ Phase 5 integration not available"
	
	try:
		return chunk_manager.phase5_integration.get_performance_summary()
	except error:
		return "❌ Error getting performance report: " + str(error)

# ============================================================================
# INSTALLATION AND TESTING SHORTCUTS
# ============================================================================

static func install_and_enable() -> bool:
	"""Complete installation and enablement in one command"""
	print("🎯 Installing and enabling Phase 5...")
	
	# Step 1: Install
	var install_result = Phase5AutoInstaller.run_installation()
	if not install_result.success:
		print("❌ Installation failed")
		return false
	
	# Step 2: Enable
	var enable_result = quick_enable()
	if not enable_result:
		print("❌ Enablement failed")
		return false
	
	print("🎉 Phase 5 installed and enabled successfully!")
	return true

static func validate_and_fix() -> bool:
	"""Validate installation and attempt to fix issues"""
	print("🔧 Validating Phase 5 and fixing issues...")
	
	# Run validation
	var test_result = Phase5TestSuite.quick_validation()
	if test_result:
		print("✅ Phase 5 validation passed - no issues found")
		return true
	
	# Attempt fixes
	print("🔧 Issues found - attempting automatic fixes...")
	
	# Fix 1: Reinstall
	var install_result = Phase5AutoInstaller.run_installation()
	if install_result.success:
		print("✅ Reinstallation completed")
		
		# Test again
		test_result = Phase5TestSuite.quick_validation()
		if test_result:
			print("✅ Issues resolved - Phase 5 working correctly")
			return true
	
	print("❌ Could not automatically fix all issues")
	print("💡 Try manual troubleshooting or check installation guide")
	return false

# ============================================================================
# QUALITY AND PERFORMANCE SHORTCUTS
# ============================================================================

static func set_quality(quality_name: String) -> bool:
	"""Set Phase 5 quality level by name"""
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager or not chunk_manager.phase5_integration:
		print("❌ Phase 5 not available")
		return false
	
	var quality_map = {
		"EMERGENCY": OptimizedPhase5Visualizer.RenderQuality.EMERGENCY,
		"LOW": OptimizedPhase5Visualizer.RenderQuality.LOW,
		"MEDIUM": OptimizedPhase5Visualizer.RenderQuality.MEDIUM,
		"HIGH": OptimizedPhase5Visualizer.RenderQuality.HIGH,
		"ULTRA": OptimizedPhase5Visualizer.RenderQuality.ULTRA
	}
	
	if not quality_map.has(quality_name.to_upper()):
		print("❌ Invalid quality: ", quality_name, " (Use: EMERGENCY, LOW, MEDIUM, HIGH, ULTRA)")
		return false
	
	try:
		chunk_manager.phase5_integration.set_render_quality(quality_map[quality_name.to_upper()])
		print("✅ Quality set to: ", quality_name.to_upper())
		return true
	except error:
		print("❌ Error setting quality: ", error)
		return false

static func auto_quality(enabled: bool) -> bool:
	"""Enable/disable automatic quality adjustment"""
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager or not chunk_manager.phase5_integration:
		print("❌ Phase 5 not available")
		return false
	
	try:
		chunk_manager.phase5_integration.set_auto_quality_adjustment(enabled)
		print("✅ Auto quality adjustment: ", "ENABLED" if enabled else "DISABLED")
		return true
	except error:
		print("❌ Error setting auto quality: ", error)
		return false

static func get_quality_recommendation() -> String:
	"""Get intelligent quality recommendation"""
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager or not chunk_manager.phase5_integration:
		return "Phase 5 not available"
	
	try:
		var performance_monitor = chunk_manager.phase5_integration.performance_monitor
		if performance_monitor and performance_monitor.has_method("get_recommended_quality"):
			return performance_monitor.get_recommended_quality()
		else:
			# Fallback to basic recommendation
			var current_fps = Engine.get_frames_per_second()
			if current_fps >= 75:
				return "ULTRA"
			elif current_fps >= 60:
				return "HIGH"
			elif current_fps >= 45:
				return "MEDIUM"
			elif current_fps >= 30:
				return "LOW"
			else:
				return "EMERGENCY"
	except error:
		return "Error getting recommendation: " + str(error)

# ============================================================================
# DEBUG AND DEVELOPMENT HELPERS
# ============================================================================

static func enable_debug() -> bool:
	"""Enable debug mode for development"""
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager or not chunk_manager.phase5_integration:
		print("❌ Phase 5 not available")
		return false
	
	try:
		chunk_manager.phase5_integration.set_debug_mode(true)
		print("✅ Debug mode enabled")
		return true
	except error:
		print("❌ Error enabling debug: ", error)
		return false

static func disable_debug() -> bool:
	"""Disable debug mode"""
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager or not chunk_manager.phase5_integration:
		print("❌ Phase 5 not available")
		return false
	
	try:
		chunk_manager.phase5_integration.set_debug_mode(false)
		print("✅ Debug mode disabled")
		return true
	except error:
		print("❌ Error disabling debug: ", error)
		return false

static func clear_cache() -> bool:
	"""Clear Phase 5 cache to free memory"""
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager or not chunk_manager.phase5_integration:
		print("❌ Phase 5 not available")
		return false
	
	try:
		chunk_manager.phase5_integration.cleanup_resources()
		print("✅ Cache cleared")
		return true
	except error:
		print("❌ Error clearing cache: ", error)
		return false

static func get_health_report() -> String:
	"""Get detailed health report"""
	var chunk_manager = _find_chunk_visual_manager()
	if not chunk_manager:
		return "❌ ChunkVisualManager not found"
	
	if not chunk_manager.phase5_integration:
		return "❌ Phase 5 integration not available"
	
	try:
		return chunk_manager.phase5_integration.get_health_report()
	except error:
		return "❌ Error getting health report: " + str(error)

# ============================================================================
# UTILITY METHODS
# ============================================================================

static func _find_chunk_visual_manager():
	"""Find ChunkVisualManager in scene tree"""
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null
	
	# Try multiple methods to find the chunk manager
	var candidates = [
		tree.get_first_node_in_group("chunk_visual_manager"),
		tree.get_first_node_in_group("ChunkVisualManager"),
		tree.get_first_node_in_group("chunk_manager")
	]
	
	for candidate in candidates:
		if candidate and candidate.has_method("enable_phase5_enhancement"):
			return candidate
	
	# Search by name in scene tree
	return _search_for_chunk_manager(tree.root)

static func _search_for_chunk_manager(node: Node):
	"""Recursively search for ChunkVisualManager"""
	if node.name.to_lower().contains("chunk") and node.name.to_lower().contains("visual"):
		if node.has_method("enable_phase5_enhancement"):
			return node
	
	for child in node.get_children():
		var result = _search_for_chunk_manager(child)
		if result:
			return result
	
	return null

static func _print_usage_tips():
	"""Print helpful usage tips"""
	print("")
	print("💡 PHASE 5 QUICK COMMANDS:")
	print("  • Phase5QuickStart.get_performance_report() - Performance stats")
	print("  • Phase5QuickStart.set_quality('HIGH') - Change quality")
	print("  • Phase5QuickStart.auto_quality(true) - Enable auto adjustment")
	print("  • Phase5QuickStart.quick_disable() - Disable if needed")
	print("")

# ============================================================================
# COMPLETE COMMAND REFERENCE
# ============================================================================

static func help() -> void:
	"""Display complete command reference"""
	print("""
🚀 PHASE 5 QUICK START COMMAND REFERENCE

BASIC COMMANDS:
  Phase5QuickStart.quick_enable()              - Enable Phase 5 with optimal settings
  Phase5QuickStart.quick_disable()             - Disable Phase 5, return to original
  Phase5QuickStart.quick_status()              - Get current Phase 5 status
  Phase5QuickStart.install_and_enable()        - Complete setup in one command

QUALITY CONTROL:
  Phase5QuickStart.set_quality('HIGH')         - Set quality (EMERGENCY, LOW, MEDIUM, HIGH, ULTRA)
  Phase5QuickStart.auto_quality(true)          - Enable automatic quality adjustment
  Phase5QuickStart.get_quality_recommendation() - Get AI-recommended quality

MONITORING:
  Phase5QuickStart.get_performance_report()    - Detailed performance statistics
  Phase5QuickStart.get_health_report()         - System health and error status

MAINTENANCE:
  Phase5QuickStart.validate_and_fix()          - Check and fix issues automatically
  Phase5QuickStart.clear_cache()               - Clear cache to free memory
  Phase5QuickStart.enable_debug()              - Enable debug mode for development

TESTING:
  Phase5TestSuite.quick_validation()           - Quick validation check
  Phase5TestSuite.run_full_test_suite()        - Comprehensive testing

INSTALLATION:
  Phase5AutoInstaller.run_installation()       - Automatic installation
  Phase5AutoInstaller.check_installation_status() - Check installation status

🎮 Ready to enhance your magical world! Start with: Phase5QuickStart.quick_enable()
""")

# One-liner for Claude Code convenience
static func enable() -> bool:
	"""Ultra-short alias for quick_enable()"""
	return quick_enable()

static func disable() -> bool:
	"""Ultra-short alias for quick_disable()"""
	return quick_disable()

static func status() -> Dictionary:
	"""Ultra-short alias for quick_status()"""
	return quick_status()