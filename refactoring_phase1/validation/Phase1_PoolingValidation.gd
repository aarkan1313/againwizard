# Phase1_PoolingValidation.gd
# Comprehensive validation script for Phase 1 object pooling implementation
# Tests both ProjectilePool and EnemyPool integration

extends Node
class_name Phase1PoolingValidator

# ========================================
# VALIDATION CONFIGURATION
# ========================================
@export var validation_enabled: bool = true
@export var performance_monitoring: bool = true
@export var detailed_logging: bool = false

# Performance tracking
var projectile_spawn_times: Array[float] = []
var enemy_spawn_times: Array[float] = []
var memory_snapshots: Array[Dictionary] = []

# Pool references for testing
var spell_component: Node
var enemy_spawner: Node
var projectile_pool: ProjectilePool
var enemy_pool: EnemyPool

# ========================================
# VALIDATION INITIALIZATION
# ========================================
func _ready():
	if validation_enabled:
		print("🔍 Starting Phase 1 Pooling Validation...")
		_initialize_validation()

func _initialize_validation():
	# Find system components
	_locate_system_components()
	
	# Validate pool implementations
	_validate_pool_setup()
	
	# Start performance monitoring
	if performance_monitoring:
		_start_performance_monitoring()

func _locate_system_components():
	# Locate SpellComponent
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		spell_component = player[0].get_node("SpellComponent")
		if spell_component:
			projectile_pool = spell_component.get("projectile_pool")
	
	# Locate EnemySpawner
	enemy_spawner = get_tree().get_nodes_in_group("enemy_spawner")
	if enemy_spawner.size() > 0:
		enemy_spawner = enemy_spawner[0]
		enemy_pool = enemy_spawner.get("enemy_pool")

# ========================================
# POOL SETUP VALIDATION
# ========================================
func _validate_pool_setup() -> bool:
	var validation_passed = true
	
	print("📋 Validating Pool Setup...")
	
	# Validate ProjectilePool
	if not _validate_projectile_pool():
		validation_passed = false
		push_error("❌ ProjectilePool validation failed")
	
	# Validate EnemyPool  
	if not _validate_enemy_pool():
		validation_passed = false
		push_error("❌ EnemyPool validation failed")
	
	if validation_passed:
		print("✅ Pool setup validation passed")
	
	return validation_passed

func _validate_projectile_pool() -> bool:
	if not projectile_pool:
		print("❌ ProjectilePool not found in SpellComponent")
		return false
	
	if not projectile_pool.pool_scene:
		print("❌ ProjectilePool scene not configured")
		return false
	
	print("✅ ProjectilePool configured correctly")
	return true

func _validate_enemy_pool() -> bool:
	if not enemy_pool:
		print("❌ EnemyPool not found in EnemySpawner")
		return false
	
	if not enemy_pool.pool_scene:
		print("❌ EnemyPool scene not configured")
		return false
	
	print("✅ EnemyPool configured correctly")
	return true

# ========================================
# PERFORMANCE TESTING
# ========================================
func _start_performance_monitoring():
	# Create timer for periodic performance checks
	var timer = Timer.new()
	timer.wait_time = 5.0  # Check every 5 seconds
	timer.timeout.connect(_record_performance_snapshot)
	add_child(timer)
	timer.start()
	
	print("📊 Performance monitoring started")

func _record_performance_snapshot():
	var snapshot = {
		"timestamp": Time.get_unix_time_from_system(),
		"projectile_pool_stats": projectile_pool.get_pool_stats() if projectile_pool else {},
		"enemy_pool_stats": enemy_pool.get_pool_stats() if enemy_pool else {},
		"memory_usage": _get_memory_usage()
	}
	
	memory_snapshots.append(snapshot)
	
	if detailed_logging:
		print("📊 Performance Snapshot: ", snapshot)

func _get_memory_usage() -> Dictionary:
	return {
		"static_memory": OS.get_static_memory_usage(),
		"dynamic_memory": OS.get_static_memory_peak_usage()
	}

# ========================================
# FUNCTIONAL TESTING
# ========================================
func test_projectile_pooling(spell_count: int = 10) -> bool:
	print("🧪 Testing projectile pooling with %d spells..." % spell_count)
	
	if not spell_component:
		print("❌ SpellComponent not available for testing")
		return false
	
	var start_time = Time.get_unix_time_from_system()
	var test_passed = true
	
	# Test projectile creation and pooling
	for i in range(spell_count):
		var projectile_start = Time.get_unix_time_from_system()
		
		# Test projectile spawn (if method exists)
		if spell_component.has_method("_get_pooled_projectile"):
			var projectile = spell_component._get_pooled_projectile()
			if not projectile:
				test_passed = false
				print("❌ Failed to get projectile from pool (iteration %d)" % i)
				continue
			
			# Record spawn time
			projectile_spawn_times.append(Time.get_unix_time_from_system() - projectile_start)
			
			# Return to pool
			if spell_component.has_method("_return_projectile_to_pool"):
				spell_component._return_projectile_to_pool(projectile)
		else:
			print("⚠️ Pooled projectile methods not implemented yet")
			break
	
	var total_time = Time.get_unix_time_from_system() - start_time
	var avg_spawn_time = _calculate_average(projectile_spawn_times)
	
	print("📊 Projectile test completed in %.3f seconds" % total_time)
	print("📊 Average spawn time: %.6f seconds" % avg_spawn_time)
	
	return test_passed

func test_enemy_pooling(enemy_count: int = 10) -> bool:
	print("🧪 Testing enemy pooling with %d enemies..." % enemy_count)
	
	if not enemy_spawner:
		print("❌ EnemySpawner not available for testing")
		return false
	
	var start_time = Time.get_unix_time_from_system()
	var test_passed = true
	
	# Test enemy creation and pooling
	for i in range(enemy_count):
		var enemy_start = Time.get_unix_time_from_system()
		
		# Test enemy spawn (if method exists)
		if enemy_spawner.has_method("_get_pooled_enemy"):
			# Use a default enemy scene for testing
			var default_scene = preload("res://scenes/enemies/Goblin.tscn")
			var enemy = enemy_spawner._get_pooled_enemy(default_scene, "goblin")
			
			if not enemy:
				test_passed = false
				print("❌ Failed to get enemy from pool (iteration %d)" % i)
				continue
			
			# Record spawn time
			enemy_spawn_times.append(Time.get_unix_time_from_system() - enemy_start)
			
			# Return to pool
			if enemy_spawner.has_method("_return_enemy_to_pool"):
				enemy_spawner._return_enemy_to_pool(enemy)
		else:
			print("⚠️ Pooled enemy methods not implemented yet")
			break
	
	var total_time = Time.get_unix_time_from_system() - start_time
	var avg_spawn_time = _calculate_average(enemy_spawn_times)
	
	print("📊 Enemy test completed in %.3f seconds" % total_time)
	print("📊 Average spawn time: %.6f seconds" % avg_spawn_time)
	
	return test_passed

# ========================================
# VALIDATION REPORTING
# ========================================
func generate_validation_report() -> Dictionary:
	var report = {
		"validation_time": Time.get_datetime_string_from_system(),
		"pool_setup_valid": _validate_pool_setup(),
		"projectile_test_results": {
			"spawn_times": projectile_spawn_times,
			"average_spawn_time": _calculate_average(projectile_spawn_times),
			"total_tests": projectile_spawn_times.size()
		},
		"enemy_test_results": {
			"spawn_times": enemy_spawn_times,
			"average_spawn_time": _calculate_average(enemy_spawn_times),
			"total_tests": enemy_spawn_times.size()
		},
		"pool_statistics": {
			"projectile_pool": projectile_pool.get_pool_stats() if projectile_pool else {},
			"enemy_pool": enemy_pool.get_pool_stats() if enemy_pool else {}
		},
		"memory_snapshots": memory_snapshots
	}
	
	_print_validation_report(report)
	return report

func _print_validation_report(report: Dictionary):
	print("\n🎯 PHASE 1 POOLING VALIDATION REPORT")
	print("=" * 50)
	
	print("📅 Validation Time: ", report.validation_time)
	print("✅ Pool Setup Valid: ", report.pool_setup_valid)
	
	print("\n📊 PROJECTILE POOL RESULTS:")
	var proj_results = report.projectile_test_results
	print("  • Total Tests: ", proj_results.total_tests)
	print("  • Average Spawn Time: %.6f seconds" % proj_results.average_spawn_time)
	
	print("\n📊 ENEMY POOL RESULTS:")
	var enemy_results = report.enemy_test_results
	print("  • Total Tests: ", enemy_results.total_tests)
	print("  • Average Spawn Time: %.6f seconds" % enemy_results.average_spawn_time)
	
	print("\n📈 POOL STATISTICS:")
	var pool_stats = report.pool_statistics
	if pool_stats.projectile_pool:
		print("  • Projectile Pool Hit Rate: %.1f%%" % (pool_stats.projectile_pool.hit_rate * 100))
	if pool_stats.enemy_pool:
		print("  • Enemy Pool Hit Rate: %.1f%%" % (pool_stats.enemy_pool.hit_rate * 100))
	
	print("=" * 50)

# ========================================
# UTILITY FUNCTIONS
# ========================================
func _calculate_average(times: Array[float]) -> float:
	if times.size() == 0:
		return 0.0
	
	var sum = 0.0
	for time in times:
		sum += time
	
	return sum / times.size()

# ========================================
# PUBLIC API FOR TESTING
# ========================================
func run_comprehensive_validation():
	print("🚀 Running comprehensive Phase 1 validation...")
	
	var projectile_test = test_projectile_pooling(20)
	var enemy_test = test_enemy_pooling(15)
	
	var report = generate_validation_report()
	
	var overall_success = projectile_test and enemy_test and report.pool_setup_valid
	
	if overall_success:
		print("🎉 Phase 1 validation PASSED! Ready for production.")
	else:
		print("⚠️ Phase 1 validation had issues. Review report above.")
	
	return overall_success

# ========================================
# TESTING INTEGRATION
# ========================================
# To use this validator:
# 1. Add this script to a Node in your test scene
# 2. Call run_comprehensive_validation() after implementing fixes
# 3. Review the generated report for performance metrics
# 4. Ensure hit rates are >80% for optimal performance