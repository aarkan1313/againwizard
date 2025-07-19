# SpatialGrid.gd - High-performance spatial partitioning system for 1000+ enemies
# Provides O(1) average case collision queries using grid-based spatial partitioning
# Integrates with PlayerTracker and GameConfig for optimal performance

extends Node

# Grid configuration - tunable via GameConfig
var grid_size: float = 100.0  # Size of each grid cell in pixels
var max_entities_per_cell: int = 20  # Performance threshold per cell

# Core data structures
var entity_grid: Dictionary = {}  # Vector2i -> Array[Entity]
var entity_positions: Dictionary = {}  # Entity -> Vector2i (last known grid position)
var registered_entities: Dictionary = {}  # Entity -> EntityData (metadata)

# Performance tracking
var total_entities: int = 0
var active_cells: int = 0
var query_count: int = 0
var last_performance_check: float = 0.0

# Integration with existing systems
var player_tracker: Node = null
var game_config: Node = null
var game_events: Node = null

signal entity_registered(entity: Node2D)
signal entity_unregistered(entity: Node2D)
signal performance_warning(message: String)

class EntityData:
	var entity: Node2D
	var mass: float
	var collision_radius: float
	var lod_level: int  # 0=full physics, 1=simplified, 2=disabled
	var last_update_time: float
	
	func _init(e: Node2D, m: float = 1.0, r: float = 20.0):
		entity = e
		mass = m
		collision_radius = r
		lod_level = 0
		last_update_time = 0.0

func _ready():
	# Initialize system and connect to existing singletons
	setup_system_integration()
	load_configuration()
	
	# Performance monitoring
	set_process(true)
	last_performance_check = Time.get_ticks_msec() * 0.001

func setup_system_integration():
	"""Connect to existing game systems"""
	# Get references to existing singletons
	player_tracker = get_node_or_null("/root/PlayerTracker")
	game_config = get_node_or_null("/root/GameConfig")
	game_events = get_node_or_null("/root/GameEvents")
	
	# Connect to game events if available
	if game_events and game_events.has_signal("enemy_spawned"):
		game_events.enemy_spawned.connect(_on_enemy_spawned)
	if game_events and game_events.has_signal("enemy_died"):
		game_events.enemy_died.connect(_on_enemy_died)

func load_configuration():
	"""Load configuration from GameConfig"""
	if game_config:
		grid_size = game_config.get("spatial_grid_size", 100.0)
		max_entities_per_cell = game_config.get("max_entities_per_cell", 20)
	
	print("✅ SpatialGrid initialized - Grid size: ", grid_size, "px")

func _process(delta):
	"""Performance monitoring and auto-optimization"""
	var current_time = Time.get_ticks_msec() * 0.001
	
	# Check performance every 2 seconds
	if current_time - last_performance_check > 2.0:
		check_performance()
		last_performance_check = current_time

func get_grid_key(position: Vector2) -> Vector2i:
	"""Convert world position to grid coordinates - OPTIMIZED"""
	return Vector2i(
		int(position.x / grid_size),
		int(position.y / grid_size)
	)

func register_entity(entity: Node2D, mass: float = 1.0, collision_radius: float = 20.0) -> bool:
	"""Register entity in spatial grid"""
	if not is_instance_valid(entity):
		return false
	
	# Avoid duplicate registration
	if registered_entities.has(entity):
		return true
	
	# Create entity data
	var entity_data = EntityData.new(entity, mass, collision_radius)
	registered_entities[entity] = entity_data
	
	# Add to grid
	update_entity_position(entity, Vector2.ZERO, entity.global_position)
	
	total_entities += 1
	entity_registered.emit(entity)
	
	return true

func unregister_entity(entity: Node2D) -> bool:
	"""Remove entity from spatial grid"""
	if not registered_entities.has(entity):
		return false
	
	# Remove from grid
	var old_key = entity_positions.get(entity, Vector2i.ZERO)
	if entity_grid.has(old_key):
		entity_grid[old_key].erase(entity)
		if entity_grid[old_key].is_empty():
			entity_grid.erase(old_key)
			active_cells -= 1
	
	# Clean up tracking
	registered_entities.erase(entity)
	entity_positions.erase(entity)
	
	total_entities -= 1
	entity_unregistered.emit(entity)
	
	return true

func update_entity_position(entity: Node2D, old_pos: Vector2, new_pos: Vector2):
	"""Update entity position in spatial grid - PERFORMANCE CRITICAL"""
	if not registered_entities.has(entity):
		return
	
	var old_key = get_grid_key(old_pos)
	var new_key = get_grid_key(new_pos)
	
	# Only update if grid cell changed
	if old_key != new_key:
		# Remove from old cell
		if entity_grid.has(old_key):
			entity_grid[old_key].erase(entity)
			if entity_grid[old_key].is_empty():
				entity_grid.erase(old_key)
				active_cells -= 1
		
		# Add to new cell
		if not entity_grid.has(new_key):
			entity_grid[new_key] = []
			active_cells += 1
		entity_grid[new_key].append(entity)
		
		# Update tracking
		entity_positions[entity] = new_key
		
		# Check for overcrowding
		if entity_grid[new_key].size() > max_entities_per_cell:
			performance_warning.emit("Grid cell overcrowded: " + str(new_key))

func get_nearby_entities(position: Vector2, radius: float, filter_group: String = "") -> Array:
	"""Get entities within radius using spatial grid - O(1) average case"""
	query_count += 1
	var result = []
	var grid_key = get_grid_key(position)
	var grid_radius = int(ceil(radius / grid_size))
	var radius_sq = radius * radius
	
	# Check surrounding grid cells
	for x in range(grid_key.x - grid_radius, grid_key.x + grid_radius + 1):
		for y in range(grid_key.y - grid_radius, grid_key.y + grid_radius + 1):
			var check_key = Vector2i(x, y)
			if entity_grid.has(check_key):
				for entity in entity_grid[check_key]:
					if not is_instance_valid(entity):
						continue
					
					# Filter by group if specified
					if filter_group != "" and not entity.is_in_group(filter_group):
						continue
					
					# Distance check
					var distance_sq = position.distance_squared_to(entity.global_position)
					if distance_sq <= radius_sq:
						result.append(entity)
	
	return result

func get_nearby_enemies(position: Vector2, radius: float) -> Array:
	"""Optimized enemy query for separation system"""
	return get_nearby_entities(position, radius, "enemies")

func get_entities_in_cell(grid_position: Vector2i) -> Array:
	"""Get all entities in specific grid cell"""
	return entity_grid.get(grid_position, [])

func get_entity_data(entity: Node2D) -> EntityData:
	"""Get metadata for registered entity"""
	return registered_entities.get(entity, null)

func set_entity_lod_level(entity: Node2D, lod_level: int):
	"""Set LOD level for entity (0=full, 1=simplified, 2=disabled)"""
	var entity_data = registered_entities.get(entity, null)
	if entity_data:
		entity_data.lod_level = lod_level

func get_entities_by_lod_level(lod_level: int) -> Array:
	"""Get all entities at specific LOD level"""
	var result = []
	for entity_data in registered_entities.values():
		if entity_data.lod_level == lod_level and is_instance_valid(entity_data.entity):
			result.append(entity_data.entity)
	return result

func check_performance():
	"""Monitor performance and emit warnings"""
	var avg_entities_per_cell = float(total_entities) / max(active_cells, 1)
	
	# Performance warnings
	if total_entities > 500:
		if avg_entities_per_cell > max_entities_per_cell:
			performance_warning.emit("High entity density: " + str(avg_entities_per_cell))
	
	if query_count > 1000:  # Reset counter to prevent overflow
		query_count = 0

func get_debug_info() -> Dictionary:
	"""Get debug information for monitoring"""
	return {
		"total_entities": total_entities,
		"active_cells": active_cells,
		"avg_entities_per_cell": float(total_entities) / max(active_cells, 1),
		"query_count": query_count,
		"grid_size": grid_size
	}

func clear_all():
	"""Clear all entities from grid - for scene transitions"""
	entity_grid.clear()
	entity_positions.clear()
	registered_entities.clear()
	total_entities = 0
	active_cells = 0
	query_count = 0

# Event handlers for integration with existing systems
func _on_enemy_spawned(enemy_type: String, enemy: Node2D):
	"""Auto-register enemies when spawned"""
	if is_instance_valid(enemy) and enemy.has_method("get"):
		var mass = enemy.get("mass") if enemy.has("mass") else 1.0
		var collision_radius = 20.0
		
		# Get collision radius from collision shape if available
		var collision_shape = enemy.get_node_or_null("EnemyCollision")
		if collision_shape and collision_shape.shape is CircleShape2D:
			collision_radius = collision_shape.shape.radius
		
		register_entity(enemy, mass, collision_radius)

func _on_enemy_died(enemy_type: String, xp_reward: int):
	"""Auto-unregister enemies when they die"""
	# Note: This needs enemy reference, may need to modify GameEvents signal
	pass

# Utility functions for mass-based collision system
func get_entities_by_mass_range(min_mass: float, max_mass: float) -> Array:
	"""Get entities within mass range"""
	var result = []
	for entity_data in registered_entities.values():
		if entity_data.mass >= min_mass and entity_data.mass <= max_mass:
			if is_instance_valid(entity_data.entity):
				result.append(entity_data.entity)
	return result

func calculate_collision_force(entity1: Node2D, entity2: Node2D, collision_normal: Vector2) -> Vector2:
	"""Calculate mass-based collision force"""
	var data1 = registered_entities.get(entity1, null)
	var data2 = registered_entities.get(entity2, null)
	
	if not data1 or not data2:
		return Vector2.ZERO
	
	var mass_ratio = data2.mass / (data1.mass + data2.mass)
	var base_force = 100.0  # Configurable via GameConfig
	
	if game_config:
		base_force = game_config.get("collision_force_strength", 100.0)
	
	return collision_normal * base_force * mass_ratio