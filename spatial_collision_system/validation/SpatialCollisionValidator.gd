# SpatialCollisionValidator.gd - Validation and testing system for spatial collision
# Ensures proper installation and functionality of the spatial collision system

extends Node
class_name SpatialCollisionValidator

# Test results
var test_results: Array = []
var validation_passed: bool = false
var performance_metrics: Dictionary = {}

signal validation_completed(success: bool, results: Array)
signal test_completed(test_name: String, passed: bool, details: String)

func _ready():
	print("🧪 Spatial Collision Validator initialized")

func run_full_validation() -> bool:
	"""Run comprehensive validation of spatial collision system"""
	print("\n🔍 Starting Spatial Collision System Validation...")
	test_results.clear()
	
	# Core system tests
	test_autoload_availability()
	test_spatial_grid_functionality()
	test_lod_manager_functionality()
	test_collision_optimizer_functionality()
	test_mass_collision_component()
	
	# Integration tests
	test_enemy_integration()
	test_player_integration()
	test_performance_benchmarks()
	
	# Configuration tests
	test_game_config_integration()
	
	# Generate final report
	validation_passed = generate_validation_report()
	validation_completed.emit(validation_passed, test_results)
	
	return validation_passed

func test_autoload_availability() -> bool:
	"""Test if all required autoloads are available"""
	var test_name = "Autoload Availability"
	var autoloads = ["SpatialGrid", "EnemyLODManager", "CollisionOptimizer"]
	var missing_autoloads = []
	
	for autoload_name in autoloads:
		var autoload = get_node_or_null("/root/" + autoload_name)
		if not autoload:
			missing_autoloads.append(autoload_name)
	
	var passed = missing_autoloads.is_empty()
	var details = "All autoloads available" if passed else "Missing: " + str(missing_autoloads)
	
	add_test_result(test_name, passed, details)
	return passed

func test_spatial_grid_functionality() -> bool:
	"""Test basic spatial grid operations"""
	var test_name = "Spatial Grid Functionality"
	var passed = true
	var details = ""
	
	if not SpatialGrid:
		add_test_result(test_name, false, "SpatialGrid not available")
		return false
	
	try:
		# Test grid key calculation
		var pos = Vector2(150, 250)
		var grid_key = SpatialGrid.get_grid_key(pos)
		if grid_key != Vector2i(1, 2):  # Assuming 100px grid size
			passed = false
			details += "Grid key calculation failed. "
		
		# Test entity registration
		var test_entity = Node2D.new()
		test_entity.global_position = Vector2(100, 100)
		get_tree().current_scene.add_child(test_entity)
		
		var registered = SpatialGrid.register_entity(test_entity, 1.0, 20.0)
		if not registered:
			passed = false
			details += "Entity registration failed. "
		
		# Test nearby entity query
		var nearby = SpatialGrid.get_nearby_entities(Vector2(100, 100), 50.0)
		if test_entity not in nearby:
			passed = false
			details += "Nearby entity query failed. "
		
		# Test entity unregistration
		var unregistered = SpatialGrid.unregister_entity(test_entity)
		if not unregistered:
			passed = false
			details += "Entity unregistration failed. "
		
		# Cleanup
		test_entity.queue_free()
		
		if passed:
			details = "All spatial grid operations successful"
	
	except:
		passed = false
		details = "Exception during spatial grid testing"
	
	add_test_result(test_name, passed, details)
	return passed

func test_lod_manager_functionality() -> bool:
	"""Test LOD manager operations"""
	var test_name = "LOD Manager Functionality"
	var passed = true
	var details = ""
	
	if not EnemyLODManager:
		add_test_result(test_name, false, "EnemyLODManager not available")
		return false
	
	try:
		# Test LOD statistics
		var stats = EnemyLODManager.get_lod_statistics()
		if not stats.has("performance_budget"):
			passed = false
			details += "LOD statistics incomplete. "
		
		# Test LOD level assignment
		var test_entity = Node2D.new()
		get_tree().current_scene.add_child(test_entity)
		
		EnemyLODManager.force_lod_level(test_entity, EnemyLODManager.LODLevel.SIMPLIFIED)
		var lod_level = EnemyLODManager.get_entity_lod_level(test_entity)
		
		if lod_level != EnemyLODManager.LODLevel.SIMPLIFIED:
			passed = false
			details += "LOD level assignment failed. "
		
		# Cleanup
		test_entity.queue_free()
		
		if passed:
			details = "LOD manager operations successful"
	
	except:
		passed = false
		details = "Exception during LOD manager testing"
	
	add_test_result(test_name, passed, details)
	return passed

func test_collision_optimizer_functionality() -> bool:
	"""Test collision optimizer operations"""
	var test_name = "Collision Optimizer Functionality"
	var passed = true
	var details = ""
	
	if not CollisionOptimizer:
		add_test_result(test_name, false, "CollisionOptimizer not available")
		return false
	
	try:
		# Test performance report
		var report = CollisionOptimizer.get_performance_report()
		if not report.has("optimization_level"):
			passed = false
			details += "Performance report incomplete. "
		
		# Test optimization level forcing
		CollisionOptimizer.force_optimization_level(1)
		await get_tree().process_frame  # Wait for processing
		
		var debug_info = CollisionOptimizer.get_debug_info()
		if debug_info.optimization_level != 1:
			passed = false
			details += "Optimization level forcing failed. "
		
		# Reset to default
		CollisionOptimizer.force_optimization_level(0)
		
		if passed:
			details = "Collision optimizer operations successful"
	
	except:
		passed = false
		details = "Exception during collision optimizer testing"
	
	add_test_result(test_name, passed, details)
	return passed

func test_mass_collision_component() -> bool:
	"""Test MassBasedCollision component functionality"""
	var test_name = "Mass Collision Component"
	var passed = true
	var details = ""
	
	try:
		# Create test entities
		var parent1 = CharacterBody2D.new()
		var parent2 = CharacterBody2D.new()
		parent1.global_position = Vector2(100, 100)
		parent2.global_position = Vector2(120, 100)  # 20px apart
		
		get_tree().current_scene.add_child(parent1)
		get_tree().current_scene.add_child(parent2)
		
		# Add collision components
		var collision1 = MassBasedCollision.new()
		var collision2 = MassBasedCollision.new()
		
		parent1.add_child(collision1)
		parent2.add_child(collision2)
		
		# Test mass setting
		collision1.set_mass(2.0)
		collision2.set_mass(1.0)
		
		if collision1.mass != 2.0 or collision2.mass != 1.0:
			passed = false
			details += "Mass setting failed. "
		
		# Test collision radius setting
		collision1.set_collision_radius(15.0)
		if collision1.collision_radius != 15.0:
			passed = false
			details += "Collision radius setting failed. "
		
		# Test collision info
		var info = collision1.get_collision_info()
		if not info.has("mass") or not info.has("collision_radius"):
			passed = false
			details += "Collision info incomplete. "
		
		# Cleanup
		parent1.queue_free()
		parent2.queue_free()
		
		if passed:
			details = "Mass collision component operations successful"
	
	except:
		passed = false
		details = "Exception during mass collision component testing"
	
	add_test_result(test_name, passed, details)
	return passed

func test_enemy_integration() -> bool:
	"""Test enemy integration with spatial collision system"""
	var test_name = "Enemy Integration"
	var passed = true
	var details = ""
	
	try:
		# Try to load enemy scene
		var enemy_scene_path = "res://scenes/enemies/Goblin.tscn"
		if not ResourceLoader.exists(enemy_scene_path):
			enemy_scene_path = "res://scenes/Enemy.tscn"
		
		if ResourceLoader.exists(enemy_scene_path):
			var enemy_scene = load(enemy_scene_path)
			var enemy = enemy_scene.instantiate()
			get_tree().current_scene.add_child(enemy)
			
			# Check for required components/methods
			if not enemy.has_method("setup_mass_collision_system"):
				passed = false
				details += "Enemy missing setup_mass_collision_system method. "
			
			if not enemy.has("mass"):
				passed = false
				details += "Enemy missing mass property. "
			
			# Check spatial grid registration
			await get_tree().process_frame  # Wait for _ready
			
			if SpatialGrid.total_entities == 0:
				passed = false
				details += "Enemy not registered with spatial grid. "
			
			# Cleanup
			enemy.queue_free()
		else:
			passed = false
			details = "No enemy scene found for testing"
		
		if passed and details == "":
			details = "Enemy integration successful"
	
	except:
		passed = false
		details = "Exception during enemy integration testing"
	
	add_test_result(test_name, passed, details)
	return passed

func test_player_integration() -> bool:
	"""Test player integration with spatial collision system"""
	var test_name = "Player Integration"
	var passed = true
	var details = ""
	
	try:
		# Try to load player scene
		var player_scene_path = "res://scenes/gameplay/Player.tscn"
		if ResourceLoader.exists(player_scene_path):
			var player_scene = load(player_scene_path)
			var player = player_scene.instantiate()
			get_tree().current_scene.add_child(player)
			
			# Check for optional enhanced collision methods
			var has_mass_collision = player.has_method("setup_mass_collision_system")
			
			if has_mass_collision:
				details = "Player has enhanced collision integration"
			else:
				details = "Player using basic collision (enhancement optional)"
			
			# Cleanup
			player.queue_free()
		else:
			passed = false
			details = "No player scene found for testing"
	
	except:
		passed = false
		details = "Exception during player integration testing"
	
	add_test_result(test_name, passed, details)
	return passed

func test_performance_benchmarks() -> bool:
	"""Test performance with multiple entities"""
	var test_name = "Performance Benchmarks"
	var passed = true
	var details = ""
	
	try:
		var start_time = Time.get_ticks_msec()
		var test_entities = []
		
		# Create 100 test entities
		for i in range(100):
			var entity = CharacterBody2D.new()
			entity.global_position = Vector2(randf() * 1000, randf() * 1000)
			get_tree().current_scene.add_child(entity)
			
			# Add to spatial grid
			if SpatialGrid:
				SpatialGrid.register_entity(entity, randf() * 2.0, 20.0)
			
			test_entities.append(entity)
		
		# Test spatial queries
		var query_start = Time.get_ticks_msec()
		for i in range(10):
			var query_pos = Vector2(randf() * 1000, randf() * 1000)
			var nearby = SpatialGrid.get_nearby_entities(query_pos, 100.0)
		var query_time = Time.get_ticks_msec() - query_start
		
		# Cleanup
		for entity in test_entities:
			SpatialGrid.unregister_entity(entity)
			entity.queue_free()
		
		var total_time = Time.get_ticks_msec() - start_time
		
		# Performance thresholds
		if total_time > 1000:  # More than 1 second
			passed = false
			details = "Performance too slow: " + str(total_time) + "ms"
		elif query_time > 100:  # Query time too high
			passed = false
			details = "Query performance poor: " + str(query_time) + "ms for 10 queries"
		else:
			details = "Performance acceptable: " + str(total_time) + "ms total, " + str(query_time) + "ms queries"
		
		# Store metrics
		performance_metrics["entity_creation_time"] = total_time
		performance_metrics["query_time"] = query_time
		performance_metrics["entities_tested"] = 100
	
	except:
		passed = false
		details = "Exception during performance testing"
	
	add_test_result(test_name, passed, details)
	return passed

func test_game_config_integration() -> bool:
	"""Test GameConfig integration"""
	var test_name = "GameConfig Integration"
	var passed = true
	var details = ""
	
	if GameConfig:
		try:
			# Test spatial grid configuration
			var grid_size = GameConfig.get("spatial_grid_size", 100.0)
			var max_entities = GameConfig.get("max_entities_per_cell", 20)
			
			if grid_size <= 0 or max_entities <= 0:
				passed = false
				details += "Invalid configuration values. "
			
			# Test LOD configuration
			var max_full = GameConfig.get("max_full_physics_enemies", 50)
			var max_simplified = GameConfig.get("max_simplified_enemies", 150)
			
			if max_full <= 0 or max_simplified <= 0:
				passed = false
				details += "Invalid LOD configuration. "
			
			if passed:
				details = "GameConfig integration successful"
		
		except:
			passed = false
			details = "Exception accessing GameConfig"
	else:
		passed = false
		details = "GameConfig not available"
	
	add_test_result(test_name, passed, details)
	return passed

func add_test_result(test_name: String, passed: bool, details: String):
	"""Add a test result to the results array"""
	var result = {
		"name": test_name,
		"passed": passed,
		"details": details,
		"timestamp": Time.get_ticks_msec()
	}
	
	test_results.append(result)
	test_completed.emit(test_name, passed, details)
	
	var status = "✅" if passed else "❌"
	print(status + " " + test_name + ": " + details)

func generate_validation_report() -> bool:
	"""Generate final validation report"""
	var passed_tests = 0
	var total_tests = test_results.size()
	
	for result in test_results:
		if result.passed:
			passed_tests += 1
	
	var success_rate = float(passed_tests) / total_tests if total_tests > 0 else 0.0
	var overall_passed = success_rate >= 0.8  # 80% pass rate required
	
	print("\n📊 Validation Report:")
	print("=" * 50)
	print("Tests Passed: " + str(passed_tests) + "/" + str(total_tests))
	print("Success Rate: " + str(success_rate * 100) + "%")
	
	if performance_metrics.size() > 0:
		print("\n🎯 Performance Metrics:")
		for metric in performance_metrics:
			print("  " + metric + ": " + str(performance_metrics[metric]))
	
	print("\n📋 Detailed Results:")
	for result in test_results:
		var status = "✅" if result.passed else "❌"
		print("  " + status + " " + result.name + ": " + result.details)
	
	var final_status = "🎉 VALIDATION PASSED" if overall_passed else "⚠️  VALIDATION FAILED"
	print("\n" + final_status)
	
	if not overall_passed:
		print("\n🔧 Recommendations:")
		for result in test_results:
			if not result.passed:
				print("  - Fix: " + result.name + " - " + result.details)
	
	print("=" * 50)
	
	return overall_passed

func run_quick_validation() -> bool:
	"""Run a quick validation check"""
	print("🚀 Quick Validation Check...")
	
	# Check critical components only
	var autoloads_ok = test_autoload_availability()
	var spatial_grid_ok = SpatialGrid != null and SpatialGrid.has_method("register_entity")
	var lod_manager_ok = EnemyLODManager != null and EnemyLODManager.has_method("get_lod_statistics")
	
	var quick_passed = autoloads_ok and spatial_grid_ok and lod_manager_ok
	
	if quick_passed:
		print("✅ Quick validation passed - System ready for use")
	else:
		print("❌ Quick validation failed - Run full validation for details")
	
	return quick_passed

func benchmark_spatial_queries(entity_count: int = 1000, query_count: int = 100) -> Dictionary:
	"""Benchmark spatial query performance"""
	print("🏃 Benchmarking spatial queries...")
	
	var entities = []
	var start_time = Time.get_ticks_msec()
	
	# Create entities
	for i in range(entity_count):
		var entity = Node2D.new()
		entity.global_position = Vector2(randf() * 2000, randf() * 2000)
		get_tree().current_scene.add_child(entity)
		SpatialGrid.register_entity(entity, randf() * 2.0, 20.0)
		entities.append(entity)
	
	var setup_time = Time.get_ticks_msec() - start_time
	
	# Benchmark queries
	var query_start = Time.get_ticks_msec()
	var total_results = 0
	
	for i in range(query_count):
		var query_pos = Vector2(randf() * 2000, randf() * 2000)
		var results = SpatialGrid.get_nearby_entities(query_pos, 100.0)
		total_results += results.size()
	
	var query_time = Time.get_ticks_msec() - query_start
	
	# Cleanup
	for entity in entities:
		SpatialGrid.unregister_entity(entity)
		entity.queue_free()
	
	var benchmark_results = {
		"entity_count": entity_count,
		"query_count": query_count,
		"setup_time_ms": setup_time,
		"query_time_ms": query_time,
		"avg_query_time_ms": float(query_time) / query_count,
		"total_results_found": total_results,
		"avg_results_per_query": float(total_results) / query_count
	}
	
	print("📈 Benchmark Results:")
	for key in benchmark_results:
		print("  " + key + ": " + str(benchmark_results[key]))
	
	return benchmark_results

# Static helper function for integration testing
static func validate_installation() -> bool:
	"""Static function to quickly validate installation"""
	var validator = SpatialCollisionValidator.new()
	var result = validator.run_quick_validation()
	validator.queue_free()
	return result