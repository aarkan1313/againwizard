# Phase5AutoInstaller.gd
# Purpose: Automated installer for Phase 5 enhancement system
# Godot Version: 4.4.1 compatible
# Usage: Run in Godot editor or via script to automatically install Phase 5

extends RefCounted
class_name Phase5AutoInstaller

# Installation paths
const PROJECT_PATH = "C:/FFS/godot/Game10"
const INSTALL_SOURCE_PATH = "C:/FFS/install/phase 5 install"
const SCRIPTS_PATH = PROJECT_PATH + "/scripts/world"

# Installation status
var installation_log: Array[String] = []
var errors: Array[String] = []
var warnings: Array[String] = []

signal installation_step(step_name: String, progress: float)
signal installation_complete(success: bool, log: Array[String])
signal installation_error(error_message: String)

# ============================================================================
# MAIN INSTALLATION ENTRY POINT
# ============================================================================

static func install_phase5_automatically() -> Dictionary:
	"""Main entry point for automatic Phase 5 installation"""
	var installer = Phase5AutoInstaller.new()
	return installer._perform_installation()

func _perform_installation() -> Dictionary:
	"""Perform complete Phase 5 installation with error handling"""
	print("🚀 Starting Phase 5 automatic installation...")
	installation_log.append("Phase 5 Installation Started: " + Time.get_datetime_string_from_system())
	
	var result = {
		"success": false,
		"installed_files": [],
		"modifications": [],
		"errors": [],
		"warnings": [],
		"next_steps": []
	}
	
	try:
		# Step 1: Pre-installation checks
		installation_step.emit("Pre-installation validation", 0.1)
		if not _validate_installation_requirements():
			result.errors = errors
			return result
		
		# Step 2: Backup existing files
		installation_step.emit("Creating backups", 0.2)
		if not _create_backups():
			result.errors = errors
			return result
		
		# Step 3: Copy Phase 5 files
		installation_step.emit("Installing Phase 5 files", 0.4)
		var installed_files = _install_phase5_files()
		result.installed_files = installed_files
		
		# Step 4: Detect and modify ChunkVisualManager
		installation_step.emit("Integrating with ChunkVisualManager", 0.6)
		var modifications = _integrate_with_chunk_visual_manager()
		result.modifications = modifications
		
		# Step 5: Create configuration files
		installation_step.emit("Creating configuration", 0.8)
		_create_configuration_files()
		
		# Step 6: Final validation
		installation_step.emit("Final validation", 0.9)
		if _validate_installation():
			result.success = true
			result.next_steps = _get_next_steps()
			print("✅ Phase 5 installation completed successfully!")
		else:
			result.errors = errors
			print("❌ Phase 5 installation validation failed")
		
		installation_step.emit("Complete", 1.0)
		
	except error:
		errors.append("Critical installation error: " + str(error))
		result.errors = errors
		print("💥 Phase 5 installation failed: ", error)
	
	result.errors = errors
	result.warnings = warnings
	installation_complete.emit(result.success, installation_log)
	
	return result

# ============================================================================
# PRE-INSTALLATION VALIDATION
# ============================================================================

func _validate_installation_requirements() -> bool:
	"""Validate all requirements before installation"""
	var validation_passed = true
	
	# Check if project directory exists
	if not DirAccess.dir_exists_absolute(PROJECT_PATH):
		errors.append("Project directory not found: " + PROJECT_PATH)
		validation_passed = false
	
	# Check if source files exist
	if not DirAccess.dir_exists_absolute(INSTALL_SOURCE_PATH):
		errors.append("Installation source not found: " + INSTALL_SOURCE_PATH)
		validation_passed = false
	
	# Check for required source files
	var required_files = [
		"OptimizedPhase5Visualizer.gd",
		"Phase5IntegrationLayer.gd", 
		"PerformanceMonitor.gd"
	]
	
	for file in required_files:
		if not FileAccess.file_exists(INSTALL_SOURCE_PATH + "/" + file):
			errors.append("Required source file missing: " + file)
			validation_passed = false
	
	# Check if scripts/world directory exists
	if not DirAccess.dir_exists_absolute(SCRIPTS_PATH):
		warnings.append("Scripts/world directory doesn't exist, will create it")
		var dir = DirAccess.open(PROJECT_PATH)
		if dir:
			dir.make_dir_recursive("scripts/world")
			installation_log.append("Created scripts/world directory")
	
	# Check for HeavyChunkLoader and other dependencies
	if not FileAccess.file_exists(SCRIPTS_PATH + "/HeavyChunkLoader.gd"):
		errors.append("HeavyChunkLoader.gd not found - Phase 5 requires this dependency")
		validation_passed = false
	
	# Check for MagicalNoiseGenerator
	if not FileAccess.file_exists(SCRIPTS_PATH + "/MagicalNoiseGenerator.gd"):
		errors.append("MagicalNoiseGenerator.gd not found - Phase 5 requires this dependency")
		validation_passed = false
	
	# Check for SimpleBiomeVisualizer
	if not FileAccess.file_exists(SCRIPTS_PATH + "/SimpleBiomeVisualizer.gd"):
		warnings.append("SimpleBiomeVisualizer.gd not found - fallback functionality will be limited")
	
	installation_log.append("Pre-installation validation: " + ("PASSED" if validation_passed else "FAILED"))
	return validation_passed

# ============================================================================
# BACKUP SYSTEM
# ============================================================================

func _create_backups() -> bool:
	"""Create backups of files that will be modified"""
	var backup_dir = PROJECT_PATH + "/backups/phase5_" + Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	
	var dir = DirAccess.open(PROJECT_PATH)
	if not dir:
		errors.append("Cannot access project directory for backup creation")
		return false
	
	dir.make_dir_recursive("backups")
	dir.make_dir_recursive(backup_dir.replace(PROJECT_PATH + "/", ""))
	
	# Backup ChunkVisualManager if it exists
	var chunk_visual_manager_path = SCRIPTS_PATH + "/ChunkVisualManager.gd"
	if FileAccess.file_exists(chunk_visual_manager_path):
		if _copy_file(chunk_visual_manager_path, backup_dir + "/ChunkVisualManager.gd.backup"):
			installation_log.append("Backed up ChunkVisualManager.gd")
		else:
			warnings.append("Failed to backup ChunkVisualManager.gd")
	
	installation_log.append("Backups created in: " + backup_dir)
	return true

# ============================================================================
# FILE INSTALLATION
# ============================================================================

func _install_phase5_files() -> Array[String]:
	"""Install Phase 5 core files"""
	var installed_files: Array[String] = []
	
	var files_to_install = [
		"OptimizedPhase5Visualizer.gd",
		"Phase5IntegrationLayer.gd",
		"PerformanceMonitor.gd"
	]
	
	for file in files_to_install:
		var source_path = INSTALL_SOURCE_PATH + "/" + file
		var dest_path = SCRIPTS_PATH + "/" + file
		
		if _copy_file(source_path, dest_path):
			installed_files.append(dest_path)
			installation_log.append("Installed: " + file)
		else:
			errors.append("Failed to install: " + file)
	
	return installed_files

# ============================================================================
# CHUNKVISUALMANAGER INTEGRATION
# ============================================================================

func _integrate_with_chunk_visual_manager() -> Array[String]:
	"""Automatically integrate with existing ChunkVisualManager"""
	var modifications: Array[String] = []
	var chunk_manager_path = SCRIPTS_PATH + "/ChunkVisualManager.gd"
	
	if not FileAccess.file_exists(chunk_manager_path):
		# Create a minimal ChunkVisualManager if it doesn't exist
		_create_minimal_chunk_visual_manager()
		modifications.append("Created minimal ChunkVisualManager.gd")
		return modifications
	
	# Read existing ChunkVisualManager
	var file = FileAccess.open(chunk_manager_path, FileAccess.READ)
	if not file:
		errors.append("Cannot read ChunkVisualManager.gd for integration")
		return modifications
	
	var content = file.get_as_text()
	file.close()
	
	# Check if Phase 5 is already integrated
	if content.contains("Phase5IntegrationLayer"):
		warnings.append("Phase 5 already appears to be integrated with ChunkVisualManager")
		return modifications
	
	# Auto-integrate Phase 5
	var modified_content = _auto_integrate_phase5(content)
	if modified_content != content:
		# Write modified content
		file = FileAccess.open(chunk_manager_path, FileAccess.WRITE)
		if file:
			file.store_string(modified_content)
			file.close()
			modifications.append("Added Phase 5 integration to ChunkVisualManager.gd")
			installation_log.append("Successfully integrated Phase 5 with ChunkVisualManager")
		else:
			errors.append("Failed to write modified ChunkVisualManager.gd")
	
	return modifications

func _auto_integrate_phase5(content: String) -> String:
	"""Automatically integrate Phase 5 into existing ChunkVisualManager code"""
	var lines = content.split("\n")
	var modified_lines: Array[String] = []
	var integration_added = false
	var ready_method_found = false
	
	for i in range(lines.size()):
		var line = lines[i]
		modified_lines.append(line)
		
		# Add Phase 5 variables after class declaration
		if line.contains("extends") and line.contains("Node") and not integration_added:
			modified_lines.append("")
			modified_lines.append("# Phase 5 Enhanced Rendering Integration")
			modified_lines.append("var phase5_integration: Phase5IntegrationLayer")
			modified_lines.append("var phase5_enhancement_enabled: bool = false")
			integration_added = true
		
		# Add Phase 5 initialization in _ready method
		if line.contains("func _ready():"):
			ready_method_found = true
			# Look for end of _ready method and add Phase 5 init
			var j = i + 1
			while j < lines.size() and not lines[j].strip_edges().begins_with("func "):
				modified_lines.append(lines[j])
				j += 1
			
			# Add Phase 5 initialization before next function
			modified_lines.append("")
			modified_lines.append("\t# Initialize Phase 5 integration")
			modified_lines.append("\t_initialize_phase5_integration()")
			modified_lines.append("")
			
			# Skip lines we already processed
			i = j - 1
	
	# Add Phase 5 integration methods at the end
	if integration_added:
		modified_lines.append("")
		modified_lines.append("# ============================================================================")
		modified_lines.append("# PHASE 5 INTEGRATION METHODS")
		modified_lines.append("# ============================================================================")
		modified_lines.append("")
		modified_lines.append("func _initialize_phase5_integration():")
		modified_lines.append("\t\"\"\"Initialize Phase 5 integration layer\"\"\"")
		modified_lines.append("\tphase5_integration = Phase5IntegrationLayer.new()")
		modified_lines.append("\tadd_child(phase5_integration)")
		modified_lines.append("\tprint(\"🚀 Phase 5 integration layer initialized\")")
		modified_lines.append("")
		modified_lines.append("func enable_phase5_enhancement():")
		modified_lines.append("\t\"\"\"Enable Phase 5 enhanced rendering\"\"\"")
		modified_lines.append("\tphase5_enhancement_enabled = true")
		modified_lines.append("\tif phase5_integration:")
		modified_lines.append("\t\tphase5_integration.enable_phase5_enhancement()")
		modified_lines.append("\tprint(\"✅ Phase 5 enhancement ENABLED\")")
		modified_lines.append("")
		modified_lines.append("func disable_phase5_enhancement():")
		modified_lines.append("\t\"\"\"Disable Phase 5 enhanced rendering\"\"\"")
		modified_lines.append("\tphase5_enhancement_enabled = false")
		modified_lines.append("\tif phase5_integration:")
		modified_lines.append("\t\tphase5_integration.disable_phase5_enhancement()")
		modified_lines.append("\tprint(\"❌ Phase 5 enhancement DISABLED\")")
	
	return "\n".join(modified_lines)

func _create_minimal_chunk_visual_manager():
	"""Create a minimal ChunkVisualManager if none exists"""
	var minimal_content = """# ChunkVisualManager.gd
# Auto-generated minimal ChunkVisualManager for Phase 5 integration
# Godot Version: 4.4.1

extends Node
class_name ChunkVisualManager

# Phase 5 Enhanced Rendering Integration
var phase5_integration: Phase5IntegrationLayer
var phase5_enhancement_enabled: bool = false

func _ready():
	print("🎨 ChunkVisualManager initialized")
	
	# Initialize Phase 5 integration
	_initialize_phase5_integration()

func create_chunk_visual(biome_type: HeavyChunkLoader.BiomeType, terrain_data: Dictionary, chunk_size: int, world_pos: Vector2 = Vector2.ZERO) -> Node2D:
	\"\"\"Create visual representation for chunk with Phase 5 enhancement\"\"\"
	
	# Try Phase 5 enhanced rendering first
	if phase5_enhancement_enabled and phase5_integration:
		var enhanced_visual = phase5_integration.create_enhanced_biome_visual(
			biome_type, terrain_data, chunk_size, world_pos
		)
		if enhanced_visual:
			return enhanced_visual
	
	# Fallback to basic visual
	return _create_basic_visual(biome_type, chunk_size)

func _create_basic_visual(biome_type: HeavyChunkLoader.BiomeType, chunk_size: int) -> Node2D:
	\"\"\"Create basic fallback visual\"\"\"
	var visual_node = Node2D.new()
	var background = ColorRect.new()
	background.size = Vector2(chunk_size, chunk_size)
	background.color = Color.GRAY  # Basic fallback color
	visual_node.add_child(background)
	return visual_node

# ============================================================================
# PHASE 5 INTEGRATION METHODS
# ============================================================================

func _initialize_phase5_integration():
	\"\"\"Initialize Phase 5 integration layer\"\"\"
	phase5_integration = Phase5IntegrationLayer.new()
	add_child(phase5_integration)
	print("🚀 Phase 5 integration layer initialized")

func enable_phase5_enhancement():
	\"\"\"Enable Phase 5 enhanced rendering\"\"\"
	phase5_enhancement_enabled = true
	if phase5_integration:
		phase5_integration.enable_phase5_enhancement()
	print("✅ Phase 5 enhancement ENABLED")

func disable_phase5_enhancement():
	\"\"\"Disable Phase 5 enhanced rendering\"\"\"
	phase5_enhancement_enabled = false
	if phase5_integration:
		phase5_integration.disable_phase5_enhancement()
	print("❌ Phase 5 enhancement DISABLED")
"""
	
	var file = FileAccess.open(SCRIPTS_PATH + "/ChunkVisualManager.gd", FileAccess.WRITE)
	if file:
		file.store_string(minimal_content)
		file.close()
		installation_log.append("Created minimal ChunkVisualManager.gd")
	else:
		errors.append("Failed to create minimal ChunkVisualManager.gd")

# ============================================================================
# CONFIGURATION FILES
# ============================================================================

func _create_configuration_files():
	"""Create Phase 5 configuration files"""
	_create_phase5_config()
	_create_quick_start_script()

func _create_phase5_config():
	"""Create Phase 5 configuration file"""
	var config_content = """# Phase5Config.gd
# Configuration settings for Phase 5 enhanced rendering
# Auto-generated by Phase5AutoInstaller

extends RefCounted
class_name Phase5Config

# Default settings optimized for Godot 4.4.1
const DEFAULT_SETTINGS = {
	\"render_quality\": \"HIGH\",
	\"auto_quality_adjustment\": true,
	\"performance_monitoring\": true,
	\"fallback_on_error\": true,
	\"debug_mode\": false,
	\"max_cache_size\": 50,
	\"target_fps\": 60.0,
	\"minimum_fps\": 45.0
}

static func get_default_settings() -> Dictionary:
	return DEFAULT_SETTINGS.duplicate()

static func apply_settings_to_integration(integration: Phase5IntegrationLayer, settings: Dictionary):
	\"\"\"Apply settings to Phase 5 integration layer\"\"\"
	if settings.has(\"render_quality\"):
		var quality_enum = OptimizedPhase5Visualizer.RenderQuality.get(settings.render_quality)
		if quality_enum != null:
			integration.set_render_quality(quality_enum)
	
	if settings.has(\"auto_quality_adjustment\"):
		integration.set_auto_quality_adjustment(settings.auto_quality_adjustment)
	
	if settings.has(\"performance_monitoring\"):
		integration.set_performance_monitoring(settings.performance_monitoring)
	
	if settings.has(\"fallback_on_error\"):
		integration.set_fallback_on_error(settings.fallback_on_error)
	
	if settings.has(\"debug_mode\"):
		integration.set_debug_mode(settings.debug_mode)
"""
	
	var file = FileAccess.open(SCRIPTS_PATH + "/Phase5Config.gd", FileAccess.WRITE)
	if file:
		file.store_string(config_content)
		file.close()
		installation_log.append("Created Phase5Config.gd")

func _create_quick_start_script():
	"""Create quick start script for easy Phase 5 management"""
	var quick_start_content = """# Phase5QuickStart.gd
# Quick start utilities for Phase 5 enhanced rendering
# Auto-generated by Phase5AutoInstaller

extends RefCounted
class_name Phase5QuickStart

# Quick enable Phase 5 with optimal settings
static func quick_enable():
	var chunk_manager = _find_chunk_visual_manager()
	if chunk_manager:
		chunk_manager.enable_phase5_enhancement()
		var settings = Phase5Config.get_default_settings()
		Phase5Config.apply_settings_to_integration(chunk_manager.phase5_integration, settings)
		print("🚀 Phase 5 enabled with optimal settings")
		return true
	else:
		print("❌ ChunkVisualManager not found")
		return false

# Quick disable Phase 5
static func quick_disable():
	var chunk_manager = _find_chunk_visual_manager()
	if chunk_manager:
		chunk_manager.disable_phase5_enhancement()
		print("❌ Phase 5 disabled")
		return true
	else:
		print("❌ ChunkVisualManager not found")
		return false

# Get performance report
static func get_performance_report() -> String:
	var chunk_manager = _find_chunk_visual_manager()
	if chunk_manager and chunk_manager.phase5_integration:
		return chunk_manager.phase5_integration.get_performance_summary()
	else:
		return "Phase 5 not available"

# Find ChunkVisualManager in scene tree
static func _find_chunk_visual_manager():
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("chunk_visual_manager")
	return null
"""
	
	var file = FileAccess.open(SCRIPTS_PATH + "/Phase5QuickStart.gd", FileAccess.WRITE)
	if file:
		file.store_string(quick_start_content)
		file.close()
		installation_log.append("Created Phase5QuickStart.gd")

# ============================================================================
# VALIDATION AND UTILITIES
# ============================================================================

func _validate_installation() -> bool:
	"""Validate that installation completed successfully"""
	var validation_passed = true
	
	# Check if all Phase 5 files exist
	var required_files = [
		"OptimizedPhase5Visualizer.gd",
		"Phase5IntegrationLayer.gd",
		"PerformanceMonitor.gd",
		"Phase5Config.gd",
		"Phase5QuickStart.gd"
	]
	
	for file in required_files:
		if not FileAccess.file_exists(SCRIPTS_PATH + "/" + file):
			errors.append("Validation failed: " + file + " not found after installation")
			validation_passed = false
	
	# Check if ChunkVisualManager was modified/created
	if not FileAccess.file_exists(SCRIPTS_PATH + "/ChunkVisualManager.gd"):
		errors.append("Validation failed: ChunkVisualManager.gd not found")
		validation_passed = false
	
	installation_log.append("Installation validation: " + ("PASSED" if validation_passed else "FAILED"))
	return validation_passed

func _copy_file(source: String, destination: String) -> bool:
	"""Copy file from source to destination with error handling"""
	var source_file = FileAccess.open(source, FileAccess.READ)
	if not source_file:
		errors.append("Cannot read source file: " + source)
		return false
	
	var content = source_file.get_as_text()
	source_file.close()
	
	var dest_file = FileAccess.open(destination, FileAccess.WRITE)
	if not dest_file:
		errors.append("Cannot write destination file: " + destination)
		return false
	
	dest_file.store_string(content)
	dest_file.close()
	return true

func _get_next_steps() -> Array[String]:
	"""Get list of next steps after installation"""
	return [
		"1. Restart Godot editor to reload scripts",
		"2. Run 'Phase5QuickStart.quick_enable()' to enable Phase 5",
		"3. Test chunk generation to verify installation",
		"4. Use 'Phase5QuickStart.get_performance_report()' to monitor performance",
		"5. Adjust quality settings if needed via Phase5Config"
	]

# ============================================================================
# PUBLIC API FOR MANUAL INSTALLATION
# ============================================================================

static func run_installation() -> Dictionary:
	"""Public method to run installation from editor or script"""
	return Phase5AutoInstaller.install_phase5_automatically()

static func check_installation_status() -> Dictionary:
	"""Check if Phase 5 is already installed"""
	var status = {
		"installed": false,
		"files_present": [],
		"files_missing": [],
		"integration_status": "not_integrated"
	}
	
	var scripts_path = "C:/FFS/godot/Game10/scripts/world"
	var required_files = [
		"OptimizedPhase5Visualizer.gd",
		"Phase5IntegrationLayer.gd", 
		"PerformanceMonitor.gd"
	]
	
	for file in required_files:
		if FileAccess.file_exists(scripts_path + "/" + file):
			status.files_present.append(file)
		else:
			status.files_missing.append(file)
	
	status.installed = status.files_missing.is_empty()
	
	# Check integration status
	var chunk_manager_path = scripts_path + "/ChunkVisualManager.gd"
	if FileAccess.file_exists(chunk_manager_path):
		var file = FileAccess.open(chunk_manager_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			if content.contains("Phase5IntegrationLayer"):
				status.integration_status = "integrated"
			else:
				status.integration_status = "not_integrated"
		else:
			status.integration_status = "unknown"
	else:
		status.integration_status = "missing_chunk_manager"
	
	return status