# BasicUsageExample.gd - Example of how to use the spatial collision system
# This demonstrates basic integration and usage patterns

extends Node

# Example of creating enemies with spatial collision integration
func create_enemy_with_spatial_collision(enemy_type: String, position: Vector2) -> Node2D:
	"""Create an enemy with full spatial collision integration"""
	
	# Load enemy scene
	var enemy_scene_path = "res://scenes/enemies/" + enemy_type.capitalize() + ".tscn"
	if not ResourceLoader.exists(enemy_scene_path):
		enemy_scene_path = "res://scenes/Enemy.tscn"
	
	var enemy_scene = load(enemy_scene_path)
	var enemy = enemy_scene.instantiate()
	
	# Set position and type
	enemy.global_position = position
	enemy.enemy_type = enemy_type
	
	# Add to scene
	get_tree().current_scene.add_child(enemy)
	
	# The enemy will automatically register with spatial grid in its _ready() function
	# if the integration has been properly implemented
	
	return enemy

# Example of manually managing spatial grid
func manual_spatial_grid_example():
	"""Example of manually working with spatial grid"""
	
	# Create a custom entity
	var custom_entity = CharacterBody2D.new()
	custom_entity.global_position = Vector2(100, 100)
	get_tree().current_scene.add_child(custom_entity)
	
	# Register with spatial grid
	SpatialGrid.register_entity(custom_entity, 1.5, 25.0)  # mass=1.5, radius=25
	
	# Query nearby entities
	var nearby = SpatialGrid.get_nearby_entities(Vector2(100, 100), 50.0)
	print("Found ", nearby.size(), " entities within 50 pixels")
	
	# Update position (if entity moves significantly)
	var old_pos = custom_entity.global_position
	custom_entity.global_position = Vector2(200, 200)
	SpatialGrid.update_entity_position(custom_entity, old_pos, custom_entity.global_position)
	
	# Cleanup when done
	SpatialGrid.unregister_entity(custom_entity)
	custom_entity.queue_free()

# Example of using LOD system
func lod_system_example():
	"""Example of working with LOD system"""
	
	# Get LOD statistics
	var stats = EnemyLODManager.get_lod_statistics()
	print("Performance budget: ", stats.performance_budget)
	print("Current FPS: ", stats.current_fps)
	
	# Force LOD level for specific entity (for testing)
	var enemy = get_tree().get_first_node_in_group("enemies")
	if enemy:
		EnemyLODManager.force_lod_level(enemy, EnemyLODManager.LODLevel.SIMPLIFIED)
		print("Forced enemy to simplified LOD")

# Example of mass-based collision
func mass_collision_example():
	"""Example of setting up mass-based collision"""
	
	# Create two entities with different masses
	var heavy_entity = CharacterBody2D.new()
	var light_entity = CharacterBody2D.new()
	
	heavy_entity.global_position = Vector2(100, 100)
	light_entity.global_position = Vector2(120, 100)  # 20px apart
	
	get_tree().current_scene.add_child(heavy_entity)
	get_tree().current_scene.add_child(light_entity)
	
	# Add mass collision components
	var heavy_collision = MassBasedCollision.new()
	var light_collision = MassBasedCollision.new()
	
	heavy_entity.add_child(heavy_collision)
	light_entity.add_child(light_collision)
	
	# Configure masses
	heavy_collision.set_mass(2.0)  # Heavy entity
	light_collision.set_mass(0.5)  # Light entity
	
	# Set collision radii
	heavy_collision.set_collision_radius(30.0)
	light_collision.set_collision_radius(15.0)
	
	# Connect collision signals
	heavy_collision.collision_occurred.connect(_on_heavy_collision)
	light_collision.collision_occurred.connect(_on_light_collision)
	
	print("Created mass collision example - heavy will push light entity")

func _on_heavy_collision(other_entity: Node2D, force: Vector2):
	"""Handle collision for heavy entity"""
	print("Heavy entity collided with ", other_entity.name, " force: ", force.length())

func _on_light_collision(other_entity: Node2D, force: Vector2):
	"""Handle collision for light entity"""
	print("Light entity was pushed by ", other_entity.name, " force: ", force.length())

# Example of performance monitoring
func performance_monitoring_example():
	"""Example of monitoring collision system performance"""
	
	# Get spatial grid performance info
	var grid_info = SpatialGrid.get_debug_info()
	print("Spatial Grid Stats:")
	print("  Total entities: ", grid_info.total_entities)
	print("  Active cells: ", grid_info.active_cells)
	print("  Average entities per cell: ", grid_info.get("avg_entities_per_cell", 0))
	
	# Get LOD performance info
	var lod_info = EnemyLODManager.get_lod_statistics()
	print("LOD System Stats:")
	print("  Performance budget: ", lod_info.performance_budget)
	print("  Entities by LOD: ", lod_info.entities_by_lod)
	
	# Get collision optimizer info
	var optimizer_info = CollisionOptimizer.get_performance_report()
	print("Collision Optimizer Stats:")
	print("  Optimization level: ", optimizer_info.optimization_level)
	print("  Performance health: ", optimizer_info.performance_health)

# Example of configuration tuning
func configuration_example():
	"""Example of tuning system configuration"""
	
	# Configure spatial grid
	if GameConfig:
		# Adjust grid size based on performance
		if Engine.get_frames_per_second() < 45:
			GameConfig.set("spatial_grid_size", 150.0)  # Larger cells for better performance
		else:
			GameConfig.set("spatial_grid_size", 80.0)   # Smaller cells for better accuracy
		
		# Adjust LOD limits based on entity count
		var entity_count = SpatialGrid.total_entities if SpatialGrid else 0
		if entity_count > 100:
			GameConfig.set("max_full_physics_enemies", 30)
			GameConfig.set("max_simplified_enemies", 80)
		else:
			GameConfig.set("max_full_physics_enemies", 50)
			GameConfig.set("max_simplified_enemies", 150)

# Example of enemy separation with spatial grid
func spatial_separation_example(enemy: Node2D):
	"""Example of implementing enemy separation using spatial grid"""
	
	if not SpatialGrid or not is_instance_valid(enemy):
		return
	
	var separation_distance = 40.0
	var separation_force = Vector2.ZERO
	
	# Get nearby enemies efficiently
	var nearby_enemies = SpatialGrid.get_nearby_enemies(enemy.global_position, separation_distance)
	
	for other_enemy in nearby_enemies:
		if other_enemy == enemy or not is_instance_valid(other_enemy):
			continue
		
		var distance = enemy.global_position.distance_to(other_enemy.global_position)
		if distance < separation_distance and distance > 0:
			# Calculate separation with mass consideration
			var enemy_mass = enemy.mass if enemy.has("mass") else 1.0
			var other_mass = other_enemy.mass if other_enemy.has("mass") else 1.0
			var mass_ratio = other_mass / (enemy_mass + other_mass)
			
			var away_direction = (enemy.global_position - other_enemy.global_position).normalized()
			var force_strength = (separation_distance - distance) / separation_distance
			
			separation_force += away_direction * force_strength * 20.0 * mass_ratio
	
	# Apply separation force
	if separation_force.length() > 0 and enemy.has("velocity"):
		enemy.velocity += separation_force / enemy.mass

# Example of creating a stress test
func stress_test_example(entity_count: int = 500):
	"""Example of stress testing the spatial collision system"""
	
	print("Starting stress test with ", entity_count, " entities...")
	
	var start_time = Time.get_ticks_msec()
	var entities = []
	
	# Create many entities
	for i in range(entity_count):
		var entity = CharacterBody2D.new()
		entity.global_position = Vector2(
			randf_range(-1000, 1000),
			randf_range(-1000, 1000)
		)
		
		get_tree().current_scene.add_child(entity)
		
		# Register with spatial grid
		var mass = randf_range(0.5, 2.0)
		var radius = randf_range(15.0, 30.0)
		SpatialGrid.register_entity(entity, mass, radius)
		
		entities.append(entity)
	
	var creation_time = Time.get_ticks_msec() - start_time
	print("Entity creation took: ", creation_time, "ms")
	
	# Test spatial queries
	var query_start = Time.get_ticks_msec()
	var total_found = 0
	
	for i in range(100):  # 100 queries
		var query_pos = Vector2(
			randf_range(-1000, 1000),
			randf_range(-1000, 1000)
		)
		var nearby = SpatialGrid.get_nearby_entities(query_pos, 100.0)
		total_found += nearby.size()
	
	var query_time = Time.get_ticks_msec() - query_start
	print("100 spatial queries took: ", query_time, "ms")
	print("Average entities found per query: ", total_found / 100.0)
	
	# Monitor performance for a few seconds
	var monitor_start = Time.get_ticks_msec()
	var frame_count = 0
	var min_fps = 999.0
	var max_fps = 0.0
	
	while Time.get_ticks_msec() - monitor_start < 5000:  # 5 seconds
		await get_tree().process_frame
		frame_count += 1
		
		var current_fps = Engine.get_frames_per_second()
		min_fps = min(min_fps, current_fps)
		max_fps = max(max_fps, current_fps)
	
	var avg_fps = frame_count / 5.0
	print("Performance over 5 seconds:")
	print("  Average FPS: ", avg_fps)
	print("  Min FPS: ", min_fps)
	print("  Max FPS: ", max_fps)
	
	# Cleanup
	for entity in entities:
		SpatialGrid.unregister_entity(entity)
		entity.queue_free()
	
	print("Stress test completed")

# Example of debugging collision issues
func debug_collision_example():
	"""Example of debugging collision system issues"""
	
	print("=== Collision System Debug Report ===")
	
	# Check system availability
	print("System Availability:")
	print("  SpatialGrid: ", "✅" if SpatialGrid else "❌")
	print("  EnemyLODManager: ", "✅" if EnemyLODManager else "❌")
	print("  CollisionOptimizer: ", "✅" if CollisionOptimizer else "❌")
	print("  GameConfig: ", "✅" if GameConfig else "❌")
	
	# Check entity counts
	if SpatialGrid:
		var grid_stats = SpatialGrid.get_debug_info()
		print("Spatial Grid Status:")
		print("  Total entities: ", grid_stats.total_entities)
		print("  Active cells: ", grid_stats.active_cells)
		print("  Query count: ", grid_stats.query_count)
	
	# Check LOD distribution
	if EnemyLODManager:
		var lod_counts = EnemyLODManager.get_entity_counts_by_lod()
		print("LOD Distribution:")
		for lod_level in lod_counts:
			print("  ", lod_level, ": ", lod_counts[lod_level])
	
	# Check performance
	if CollisionOptimizer:
		var perf_report = CollisionOptimizer.get_performance_report()
		print("Performance Status:")
		print("  Health: ", perf_report.performance_health)
		print("  Optimization level: ", perf_report.optimization_level)
		print("  Recommendations: ", perf_report.recommendations)
	
	print("=== End Debug Report ===")

# Usage examples for different scenarios
func _ready():
	"""Example of how to use these functions"""
	
	# Wait a moment for systems to initialize
	await get_tree().create_timer(1.0).timeout
	
	# Run basic examples
	print("Running spatial collision system examples...")
	
	# Example 1: Create some enemies
	create_enemy_with_spatial_collision("goblin", Vector2(100, 100))
	create_enemy_with_spatial_collision("orc", Vector2(200, 100))
	
	# Example 2: Monitor performance
	performance_monitoring_example()
	
	# Example 3: Test LOD system
	lod_system_example()
	
	# Example 4: Debug system
	debug_collision_example()
	
	print("Examples completed - check console output")