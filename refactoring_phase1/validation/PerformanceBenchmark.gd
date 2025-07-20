# PerformanceBenchmark.gd
# Performance benchmarking script for Phase 1 object pooling implementation
# Measures before/after performance to validate improvements

extends Node
class_name PerformanceBenchmark

# ========================================
# BENCHMARK CONFIGURATION
# ========================================
@export var benchmark_iterations: int = 1000
@export var warmup_iterations: int = 100
@export var memory_monitoring: bool = true

# Benchmark results storage
var benchmark_results: Dictionary = {}

# ========================================
# PERFORMANCE METRICS
# ========================================
func benchmark_direct_instantiation() -> Dictionary:
	print("📊 Benchmarking direct instantiation (old method)...")
	
	var projectile_scene = preload("res://scenes/combat/SpellProjectile.tscn")
	var enemy_scene = preload("res://scenes/enemies/Goblin.tscn")
	
	# Warmup
	_warmup_direct_instantiation(projectile_scene, enemy_scene)
	
	var start_memory = OS.get_static_memory_usage()
	var start_time = Time.get_unix_time_from_system()
	
	# Benchmark projectile creation
	var projectile_times: Array[float] = []
	for i in range(benchmark_iterations):
		var proj_start = Time.get_unix_time_from_system()
		var projectile = projectile_scene.instantiate()
		add_child(projectile)
		projectile.queue_free()
		projectile_times.append(Time.get_unix_time_from_system() - proj_start)
	
	# Benchmark enemy creation
	var enemy_times: Array[float] = []
	for i in range(benchmark_iterations):
		var enemy_start = Time.get_unix_time_from_system()
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.queue_free()
		enemy_times.append(Time.get_unix_time_from_system() - enemy_start)
	
	var end_time = Time.get_unix_time_from_system()
	var end_memory = OS.get_static_memory_usage()
	
	# Force garbage collection
	GDScript.garbage_collect()
	await get_tree().process_frame
	var post_gc_memory = OS.get_static_memory_usage()
	
	return {
		"method": "direct_instantiation",
		"total_time": end_time - start_time,
		"projectile_avg_time": _calculate_average(projectile_times),
		"enemy_avg_time": _calculate_average(enemy_times),
		"memory_delta": end_memory - start_memory,
		"post_gc_memory": post_gc_memory,
		"iterations": benchmark_iterations
	}

func benchmark_pooled_instantiation() -> Dictionary:
	print("📊 Benchmarking pooled instantiation (new method)...")
	
	# Setup pools
	var projectile_pool = ProjectilePool.new()
	var enemy_pool = EnemyPool.new()
	
	projectile_pool.pool_scene = preload("res://scenes/combat/SpellProjectile.tscn")
	enemy_pool.pool_scene = preload("res://scenes/enemies/Goblin.tscn")
	
	add_child(projectile_pool)
	add_child(enemy_pool)
	
	# Warmup
	_warmup_pooled_instantiation(projectile_pool, enemy_pool)
	
	var start_memory = OS.get_static_memory_usage()
	var start_time = Time.get_unix_time_from_system()
	
	# Benchmark projectile creation from pool
	var projectile_times: Array[float] = []
	for i in range(benchmark_iterations):
		var proj_start = Time.get_unix_time_from_system()
		var projectile = projectile_pool.get_object()
		projectile_pool.return_object(projectile)
		projectile_times.append(Time.get_unix_time_from_system() - proj_start)
	
	# Benchmark enemy creation from pool
	var enemy_times: Array[float] = []
	for i in range(benchmark_iterations):
		var enemy_start = Time.get_unix_time_from_system()
		var enemy = enemy_pool.get_object()
		enemy_pool.return_object(enemy)
		enemy_times.append(Time.get_unix_time_from_system() - enemy_start)
	
	var end_time = Time.get_unix_time_from_system()
	var end_memory = OS.get_static_memory_usage()
	
	# Get pool statistics
	var projectile_stats = projectile_pool.get_pool_stats()
	var enemy_stats = enemy_pool.get_pool_stats()
	
	return {
		"method": "pooled_instantiation",
		"total_time": end_time - start_time,
		"projectile_avg_time": _calculate_average(projectile_times),
		"enemy_avg_time": _calculate_average(enemy_times),
		"memory_delta": end_memory - start_memory,
		"iterations": benchmark_iterations,
		"projectile_pool_stats": projectile_stats,
		"enemy_pool_stats": enemy_stats
	}

# ========================================
# WARMUP FUNCTIONS
# ========================================
func _warmup_direct_instantiation(projectile_scene: PackedScene, enemy_scene: PackedScene):
	print("🔥 Warming up direct instantiation...")
	
	for i in range(warmup_iterations):
		var projectile = projectile_scene.instantiate()
		add_child(projectile)
		projectile.queue_free()
		
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.queue_free()
	
	# Clear any remaining objects
	GDScript.garbage_collect()
	await get_tree().process_frame

func _warmup_pooled_instantiation(projectile_pool: ProjectilePool, enemy_pool: EnemyPool):
	print("🔥 Warming up pooled instantiation...")
	
	for i in range(warmup_iterations):
		var projectile = projectile_pool.get_object()
		projectile_pool.return_object(projectile)
		
		var enemy = enemy_pool.get_object()
		enemy_pool.return_object(enemy)

# ========================================
# COMPREHENSIVE BENCHMARK
# ========================================
func run_comprehensive_benchmark() -> Dictionary:
	print("🚀 Starting comprehensive performance benchmark...")
	print("📋 Configuration: %d iterations, %d warmup" % [benchmark_iterations, warmup_iterations])
	
	# Run benchmarks
	var direct_results = await benchmark_direct_instantiation()
	await get_tree().process_frame  # Allow cleanup
	
	var pooled_results = await benchmark_pooled_instantiation()
	
	# Calculate improvements
	var improvements = _calculate_improvements(direct_results, pooled_results)
	
	var comprehensive_results = {
		"benchmark_time": Time.get_datetime_string_from_system(),
		"configuration": {
			"iterations": benchmark_iterations,
			"warmup": warmup_iterations
		},
		"direct_instantiation": direct_results,
		"pooled_instantiation": pooled_results,
		"improvements": improvements
	}
	
	_print_benchmark_results(comprehensive_results)
	
	return comprehensive_results

func _calculate_improvements(direct: Dictionary, pooled: Dictionary) -> Dictionary:
	var projectile_speedup = direct.projectile_avg_time / pooled.projectile_avg_time if pooled.projectile_avg_time > 0 else 0
	var enemy_speedup = direct.enemy_avg_time / pooled.enemy_avg_time if pooled.enemy_avg_time > 0 else 0
	var total_speedup = direct.total_time / pooled.total_time if pooled.total_time > 0 else 0
	
	var memory_reduction = direct.memory_delta - pooled.memory_delta
	var memory_improvement = (memory_reduction / direct.memory_delta * 100) if direct.memory_delta > 0 else 0
	
	return {
		"projectile_speedup": projectile_speedup,
		"enemy_speedup": enemy_speedup,
		"total_speedup": total_speedup,
		"memory_reduction_bytes": memory_reduction,
		"memory_improvement_percent": memory_improvement,
		"projectile_time_saved_percent": ((direct.projectile_avg_time - pooled.projectile_avg_time) / direct.projectile_avg_time * 100) if direct.projectile_avg_time > 0 else 0,
		"enemy_time_saved_percent": ((direct.enemy_avg_time - pooled.enemy_avg_time) / direct.enemy_avg_time * 100) if direct.enemy_avg_time > 0 else 0
	}

# ========================================
# RESULTS REPORTING
# ========================================
func _print_benchmark_results(results: Dictionary):
	print("\n🎯 PHASE 1 PERFORMANCE BENCHMARK RESULTS")
	print("=" * 60)
	
	print("📅 Benchmark Time: ", results.benchmark_time)
	print("🔧 Iterations: ", results.configuration.iterations)
	print("🔥 Warmup: ", results.configuration.warmup)
	
	print("\n📊 DIRECT INSTANTIATION (OLD METHOD):")
	var direct = results.direct_instantiation
	print("  • Total Time: %.3f seconds" % direct.total_time)
	print("  • Projectile Avg: %.6f seconds" % direct.projectile_avg_time)
	print("  • Enemy Avg: %.6f seconds" % direct.enemy_avg_time)
	print("  • Memory Delta: %d bytes" % direct.memory_delta)
	
	print("\n📊 POOLED INSTANTIATION (NEW METHOD):")
	var pooled = results.pooled_instantiation
	print("  • Total Time: %.3f seconds" % pooled.total_time)
	print("  • Projectile Avg: %.6f seconds" % pooled.projectile_avg_time)
	print("  • Enemy Avg: %.6f seconds" % pooled.enemy_avg_time)
	print("  • Memory Delta: %d bytes" % pooled.memory_delta)
	
	if "projectile_pool_stats" in pooled:
		print("  • Projectile Pool Hit Rate: %.1f%%" % (pooled.projectile_pool_stats.hit_rate * 100))
		print("  • Enemy Pool Hit Rate: %.1f%%" % (pooled.enemy_pool_stats.hit_rate * 100))
	
	print("\n🚀 PERFORMANCE IMPROVEMENTS:")
	var improvements = results.improvements
	print("  • Total Speedup: %.2fx" % improvements.total_speedup)
	print("  • Projectile Speedup: %.2fx (%.1f%% faster)" % [improvements.projectile_speedup, improvements.projectile_time_saved_percent])
	print("  • Enemy Speedup: %.2fx (%.1f%% faster)" % [improvements.enemy_speedup, improvements.enemy_time_saved_percent])
	print("  • Memory Reduction: %d bytes (%.1f%% less)" % [improvements.memory_reduction_bytes, improvements.memory_improvement_percent])
	
	# Performance verdict
	print("\n🎉 PERFORMANCE VERDICT:")
	if improvements.total_speedup >= 2.0:
		print("  🟢 EXCELLENT: >2x performance improvement achieved!")
	elif improvements.total_speedup >= 1.5:
		print("  🟡 GOOD: 1.5-2x performance improvement achieved")
	elif improvements.total_speedup >= 1.2:
		print("  🟠 MODERATE: 1.2-1.5x performance improvement achieved")
	else:
		print("  🔴 MINIMAL: <1.2x improvement - investigate implementation")
	
	print("=" * 60)

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
# MEMORY PROFILING
# ========================================
func profile_memory_usage(duration_seconds: float = 30.0) -> Dictionary:
	print("🧠 Starting memory profiling for %.1f seconds..." % duration_seconds)
	
	var memory_samples: Array[Dictionary] = []
	var start_time = Time.get_unix_time_from_system()
	var sample_interval = 1.0  # Sample every second
	
	while (Time.get_unix_time_from_system() - start_time) < duration_seconds:
		var sample = {
			"timestamp": Time.get_unix_time_from_system() - start_time,
			"static_memory": OS.get_static_memory_usage(),
			"dynamic_peak": OS.get_static_memory_peak_usage()
		}
		memory_samples.append(sample)
		
		await get_tree().create_timer(sample_interval).timeout
	
	return {
		"duration": duration_seconds,
		"samples": memory_samples,
		"sample_count": memory_samples.size()
	}

# ========================================
# INTEGRATION EXAMPLE
# ========================================
# To use this benchmark:
# 1. Add this script to a Node in your test scene
# 2. Call run_comprehensive_benchmark() to compare methods
# 3. Use profile_memory_usage() for extended memory analysis
# 4. Results will show exact performance improvements from pooling