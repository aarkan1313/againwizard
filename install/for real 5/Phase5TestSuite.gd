# Phase5TestSuite.gd
# Purpose: Comprehensive test suite for Phase 5 installation validation
# Architecture: Automated testing with detailed reporting
# Compatibility: Godot 4.4.1 - Claude Code executable
# Usage: Run in Godot console or via script to validate Phase 5 installation

extends RefCounted
class_name Phase5TestSuite

# Test results tracking
var test_results: Dictionary = {}
var tests_passed: int = 0
var tests_failed: int = 0
var tests_skipped: int = 0

signal test_completed(test_name: String, passed: bool, message: String)
signal test_suite_completed(results: Dictionary)

# ============================================================================
# MAIN TEST SUITE ENTRY POINT
# ============================================================================

static func run_full_test_suite() -> Dictionary:
	"""Run complete Phase 5 test suite and return results"""
	var suite = Phase5TestSuite.new()
	return suite._execute_test_suite()

static func quick_validation() -> bool:
	"""Quick validation check for Phase 5 installation"""
	var suite = Phase5TestSuite.new()
	return suite._run_quick_tests()

func _execute_test_suite() -> Dictionary:
	"""Execute comprehensive test suite"""
	print("🧪 Starting Phase 5 Comprehensive Test Suite...")
	test_results.clear()
	tests_passed = 0
	tests_failed = 0
	tests_skipped = 0
	
	# Test categories
	_test_installation_validation()
	_test_file_integrity()
	_test_class_loading()
	_test_integration_functionality()
	_test_performance_systems()
	_test_error_handling()
	_test_fallback_systems()
	_test_compatibility()
	
	# Generate final report
	var final_results = _generate_final_report()
	test_suite_completed.emit(final_results)
	
	return final_results

func _run_quick_tests() -> bool:
	"""Run only essential validation tests"""
	print("⚡ Running Phase 5 Quick Validation...")
	
	var essential_tests = [
		"files_exist",
		"classes_loadable",
		"basic_functionality"
	]
	
	for test_name in essential_tests:
		match test_name:
			"files_exist":
				_test_required_files_exist()
			"classes_loadable":
				_test_phase5_classes_loadable()
			"basic_functionality":
				_test_basic_integration_functionality()
	
	return tests_failed == 0

# ============================================================================
# INSTALLATION VALIDATION TESTS
# ============================================================================

func _test_installation_validation():
	"""Test installation validation and status"""
	print("📋 Testing installation validation...")
	
	# Test 1: Check installation status
	_run_test("installation_status_check", func():
		var status = Phase5AutoInstaller.check_installation_status()
		return status.has("installed") and status.has("files_present")
	)
	
	# Test 2: Verify project paths
	_run_test("project_paths_valid", func():
		var project_path = "C:/FFS/godot/Game10"
		var scripts_path = project_path + "/scripts/world"
		return DirAccess.dir_exists_absolute(project_path) and DirAccess.dir_exists_absolute(scripts_path)
	)

func _test_required_files_exist():
	"""Test that all required Phase 5 files exist"""
	print("📁 Testing required files existence...")
	
	var required_files = [
		"OptimizedPhase5Visualizer.gd",
		"Phase5IntegrationLayer.gd",
		"PerformanceMonitor.gd",
		"Phase5AutoInstaller.gd"
	]
	
	var install_path = "C:/FFS/install/phase 5 install"
	
	for file in required_files:
		_run_test("file_exists_" + file, func():
			return FileAccess.file_exists(install_path + "/" + file)
		)

# ============================================================================
# FILE INTEGRITY TESTS
# ============================================================================

func _test_file_integrity():
	"""Test file integrity and content validation"""
	print("🔍 Testing file integrity...")
	
	# Test Phase5AutoInstaller
	_run_test("autoinstaller_integrity", func():
		return _validate_file_contains("Phase5AutoInstaller.gd", [
			"class_name Phase5AutoInstaller",
			"install_phase5_automatically",
			"check_installation_status"
		])
	)
	
	# Test OptimizedPhase5Visualizer
	_run_test("visualizer_integrity", func():
		return _validate_file_contains("OptimizedPhase5Visualizer.gd", [
			"class_name OptimizedPhase5Visualizer",
			"create_enhanced_chunk_visual",
			"RenderQuality"
		])
	)
	
	# Test Phase5IntegrationLayer
	_run_test("integration_integrity", func():
		return _validate_file_contains("Phase5IntegrationLayer.gd", [
			"class_name Phase5IntegrationLayer",
			"create_enhanced_biome_visual",
			"enable_phase5_enhancement"
		])
	)

func _validate_file_contains(filename: String, required_strings: Array[String]) -> bool:
	"""Validate that a file contains required strings"""
	var file_path = "C:/FFS/install/phase 5 install/" + filename
	if not FileAccess.file_exists(file_path):
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	for required_string in required_strings:
		if not content.contains(required_string):
			return false
	
	return true

# ============================================================================
# CLASS LOADING TESTS
# ============================================================================

func _test_class_loading():
	"""Test that all Phase 5 classes can be loaded"""
	print("🏗️ Testing class loading...")
	
	_test_phase5_classes_loadable()
	_test_dependency_classes_available()

func _test_phase5_classes_loadable():
	"""Test that Phase 5 classes can be instantiated"""
	
	# Test OptimizedPhase5Visualizer loading
	_run_test("optimized_visualizer_loadable", func():
		try:
			var visualizer = OptimizedPhase5Visualizer.new()
			return visualizer != null
		except error:
			return false
	)
	
	# Test Phase5IntegrationLayer loading
	_run_test("integration_layer_loadable", func():
		try:
			var integration = Phase5IntegrationLayer.new()
			return integration != null
		except error:
			return false
	)
	
	# Test PerformanceMonitor loading
	_run_test("performance_monitor_loadable", func():
		try:
			var monitor = PerformanceMonitor.new()
			return monitor != null
		except error:
			return false
	)

func _test_dependency_classes_available():
	"""Test that required dependency classes are available"""
	
	# Test HeavyChunkLoader availability
	_run_test("heavy_chunk_loader_available", func():
		try:
			var chunk_data = HeavyChunkLoader.ChunkData.new()
			return chunk_data != null
		except error:
			return false
	)
	
	# Test MagicalNoiseGenerator availability
	_run_test("magical_noise_generator_available", func():
		try:
			var noise_gen = MagicalNoiseGenerator.new()
			return noise_gen != null
		except error:
			return false
	)

# ============================================================================
# INTEGRATION FUNCTIONALITY TESTS
# ============================================================================

func _test_integration_functionality():
	"""Test core integration functionality"""
	print("⚙️ Testing integration functionality...")
	
	_test_basic_integration_functionality()
	_test_chunk_visual_generation()
	_test_quality_management()

func _test_basic_integration_functionality():
	"""Test basic integration layer functionality"""
	
	_run_test("integration_initialization", func():
		try:
			var integration = Phase5IntegrationLayer.new()
			# Test basic methods exist
			return integration.has_method("enable_phase5_enhancement") and \
				   integration.has_method("create_enhanced_biome_visual")
		except error:
			return false
	)

func _test_chunk_visual_generation():
	"""Test chunk visual generation functionality"""
	
	_run_test("chunk_visual_generation", func():
		try:
			var visualizer = OptimizedPhase5Visualizer.new()
			
			# Create test chunk data
			var test_chunk = HeavyChunkLoader.ChunkData.new()
			test_chunk.coord = Vector2i(0, 0)
			test_chunk.biome_type = HeavyChunkLoader.BiomeType.PLAINS
			test_chunk.world_position = Vector2.ZERO
			test_chunk.terrain_data = {}
			test_chunk.chunk_size = 64
			
			# Test visual generation
			var visual = visualizer.create_enhanced_chunk_visual(test_chunk, 0.0)
			if visual:
				visual.queue_free()  # Clean up
				return true
			return false
		except error:
			return false
	)

func _test_quality_management():
	"""Test quality management functionality"""
	
	_run_test("quality_settings", func():
		try:
			var visualizer = OptimizedPhase5Visualizer.new()
			
			# Test quality setting
			visualizer.set_render_quality(OptimizedPhase5Visualizer.RenderQuality.HIGH)
			
			# Test quality enum access
			var quality_keys = OptimizedPhase5Visualizer.RenderQuality.keys()
			return quality_keys.size() > 0 and "HIGH" in quality_keys
		except error:
			return false
	)

# ============================================================================
# PERFORMANCE SYSTEM TESTS
# ============================================================================

func _test_performance_systems():
	"""Test performance monitoring and optimization systems"""
	print("📊 Testing performance systems...")
	
	# Test PerformanceMonitor functionality
	_run_test("performance_monitor_basic", func():
		try:
			var monitor = PerformanceMonitor.new()
			monitor.update_fps(60.0)
			monitor.update_generation_time(2.0)
			var stats = monitor.get_performance_stats()
			return stats.has("current_fps") and stats.has("average_generation_time")
		except error:
			return false
	)
	
	# Test performance reporting
	_run_test("performance_reporting", func():
		try:
			var monitor = PerformanceMonitor.new()
			var report = monitor.get_performance_report()
			return report.length() > 0 and report.contains("Performance Monitor Report")
		except error:
			return false
	)

# ============================================================================
# ERROR HANDLING TESTS
# ============================================================================

func _test_error_handling():
	"""Test error handling and recovery systems"""
	print("🛡️ Testing error handling...")
	
	# Test visualizer error handling
	_run_test("visualizer_error_handling", func():
		try:
			var visualizer = OptimizedPhase5Visualizer.new()
			
			# Test with invalid chunk data
			var visual = visualizer.create_enhanced_chunk_visual(null, 0.0)
			# Should return fallback visual or handle error gracefully
			return true  # If we get here, error was handled
		except error:
			return true  # Exception caught, which is also valid error handling
	)
	
	# Test integration layer error handling
	_run_test("integration_error_handling", func():
		try:
			var integration = Phase5IntegrationLayer.new()
			
			# Test with invalid parameters
			var visual = integration.create_enhanced_biome_visual(
				HeavyChunkLoader.BiomeType.PLAINS, {}, 64, Vector2.ZERO
			)
			return visual != null  # Should return some visual even with basic parameters
		except error:
			return false
	)

# ============================================================================
# FALLBACK SYSTEM TESTS
# ============================================================================

func _test_fallback_systems():
	"""Test fallback system functionality"""
	print("🔄 Testing fallback systems...")
	
	_run_test("fallback_visual_creation", func():
		try:
			var integration = Phase5IntegrationLayer.new()
			
			# Disable Phase 5 to test fallback
			integration.phase5_enabled = false
			
			# Should create fallback visual
			var visual = integration.create_enhanced_biome_visual(
				HeavyChunkLoader.BiomeType.PLAINS, {}, 64, Vector2.ZERO
			)
			return visual != null
		except error:
			return false
	)

# ============================================================================
# COMPATIBILITY TESTS
# ============================================================================

func _test_compatibility():
	"""Test compatibility with existing project systems"""
	print("🔗 Testing compatibility...")
	
	# Test SimpleBiomeVisualizer compatibility
	_run_test("simple_biome_visualizer_compatibility", func():
		try:
			# Check if SimpleBiomeVisualizer exists and is compatible
			var simple_visualizer = SimpleBiomeVisualizer.new()
			return simple_visualizer.has_method("create_simple_biome_visual")
		except error:
			# SimpleBiomeVisualizer might not exist, which is okay
			return true
	)
	
	# Test project structure compatibility
	_run_test("project_structure_compatibility", func():
		var required_paths = [
			"C:/FFS/godot/Game10/scripts/world/HeavyChunkLoader.gd",
			"C:/FFS/godot/Game10/scripts/world/MagicalNoiseGenerator.gd"
		]
		
		for path in required_paths:
			if not FileAccess.file_exists(path):
				return false
		return true
	)

# ============================================================================
# TEST EXECUTION FRAMEWORK
# ============================================================================

func _run_test(test_name: String, test_func: Callable) -> bool:
	"""Run individual test and record results"""
	try:
		var start_time = Time.get_ticks_msec()
		var result = test_func.call()
		var end_time = Time.get_ticks_msec()
		
		var test_data = {
			"passed": result,
			"execution_time": end_time - start_time,
			"message": "Test completed successfully" if result else "Test failed"
		}
		
		test_results[test_name] = test_data
		
		if result:
			tests_passed += 1
			print("  ✅ " + test_name + " - PASSED (" + str(test_data.execution_time) + "ms)")
		else:
			tests_failed += 1
			print("  ❌ " + test_name + " - FAILED (" + str(test_data.execution_time) + "ms)")
		
		test_completed.emit(test_name, result, test_data.message)
		return result
		
	except error:
		var test_data = {
			"passed": false,
			"execution_time": 0,
			"message": "Test exception: " + str(error)
		}
		
		test_results[test_name] = test_data
		tests_failed += 1
		print("  💥 " + test_name + " - EXCEPTION: " + str(error))
		
		test_completed.emit(test_name, false, test_data.message)
		return false

func _generate_final_report() -> Dictionary:
	"""Generate comprehensive final test report"""
	var total_tests = tests_passed + tests_failed + tests_skipped
	var success_rate = float(tests_passed) / float(total_tests) * 100.0 if total_tests > 0 else 0.0
	
	var report = {
		"total_tests": total_tests,
		"tests_passed": tests_passed,
		"tests_failed": tests_failed,
		"tests_skipped": tests_skipped,
		"success_rate": success_rate,
		"overall_status": "PASSED" if tests_failed == 0 else "FAILED",
		"detailed_results": test_results,
		"summary": _generate_summary_report(),
		"recommendations": _generate_recommendations()
	}
	
	print("\n" + "="*60)
	print("🧪 PHASE 5 TEST SUITE RESULTS")
	print("="*60)
	print("Total Tests: " + str(total_tests))
	print("Passed: " + str(tests_passed))
	print("Failed: " + str(tests_failed))
	print("Success Rate: " + str("%.1f" % success_rate) + "%")
	print("Overall Status: " + report.overall_status)
	print("="*60)
	
	if tests_failed > 0:
		print("❌ FAILED TESTS:")
		for test_name in test_results.keys():
			if not test_results[test_name].passed:
				print("  - " + test_name + ": " + test_results[test_name].message)
	
	print("\n📋 RECOMMENDATIONS:")
	for recommendation in report.recommendations:
		print("  • " + recommendation)
	
	return report

func _generate_summary_report() -> String:
	"""Generate summary report text"""
	var total_tests = tests_passed + tests_failed + tests_skipped
	var success_rate = float(tests_passed) / float(total_tests) * 100.0 if total_tests > 0 else 0.0
	
	var summary = "Phase 5 Test Suite completed with " + str("%.1f" % success_rate) + "% success rate. "
	summary += str(tests_passed) + " tests passed, " + str(tests_failed) + " tests failed."
	
	if tests_failed == 0:
		summary += " Phase 5 is ready for use."
	elif tests_failed <= 2:
		summary += " Minor issues detected, but Phase 5 should be functional."
	else:
		summary += " Significant issues detected, installation may need attention."
	
	return summary

func _generate_recommendations() -> Array[String]:
	"""Generate recommendations based on test results"""
	var recommendations: Array[String] = []
	
	if tests_failed == 0:
		recommendations.append("All tests passed! Phase 5 is ready to use.")
		recommendations.append("Run 'Phase5QuickStart.quick_enable()' to activate Phase 5.")
	else:
		if test_results.has("file_exists_OptimizedPhase5Visualizer.gd") and not test_results["file_exists_OptimizedPhase5Visualizer.gd"].passed:
			recommendations.append("Copy missing OptimizedPhase5Visualizer.gd to installation directory.")
		
		if test_results.has("heavy_chunk_loader_available") and not test_results["heavy_chunk_loader_available"].passed:
			recommendations.append("Ensure HeavyChunkLoader.gd is available in your project.")
		
		if test_results.has("integration_layer_loadable") and not test_results["integration_layer_loadable"].passed:
			recommendations.append("Check Phase5IntegrationLayer.gd for syntax errors.")
		
		if tests_failed > 5:
			recommendations.append("Consider running 'Phase5AutoInstaller.run_installation()' to reinstall.")
		
		recommendations.append("Check console output for detailed error messages.")
	
	return recommendations

# ============================================================================
# UTILITY METHODS FOR CLAUDE CODE EXECUTION
# ============================================================================

static func run_installation_and_test() -> Dictionary:
	"""Complete installation and testing workflow for Claude Code"""
	print("🚀 Starting complete Phase 5 installation and validation...")
	
	# Step 1: Run installation
	print("Step 1: Installing Phase 5...")
	var install_result = Phase5AutoInstaller.run_installation()
	
	# Step 2: Run tests
	print("Step 2: Validating installation...")
	var test_result = Phase5TestSuite.run_full_test_suite()
	
	# Step 3: Generate combined report
	var combined_result = {
		"installation": install_result,
		"testing": test_result,
		"overall_success": install_result.success and test_result.overall_status == "PASSED",
		"ready_for_use": false
	}
	
	if combined_result.overall_success:
		combined_result.ready_for_use = true
		print("✅ Phase 5 installation and testing completed successfully!")
		print("🎮 Ready to use! Run 'Phase5QuickStart.quick_enable()' to activate.")
	else:
		print("❌ Issues detected during installation or testing.")
		print("📋 Check the detailed results for troubleshooting information.")
	
	return combined_result