# MassBasedCollision.gd - Mass-based collision response component
# Provides realistic physics interactions between entities based on mass
# Integrates with SpatialGrid for efficient collision detection

extends Node
class_name MassBasedCollision

# Mass and collision properties
@export var mass: float = 1.0
@export var collision_radius: float = 20.0
@export var collision_force_multiplier: float = 100.0
@export var friction: float = 0.95  # Velocity decay factor

# Collision response settings
@export var enable_collision_response: bool = true
@export var enable_mass_based_pushing: bool = true
@export var min_collision_force: float = 10.0
@export var max_collision_force: float = 500.0

# Parent entity reference
var parent_entity: Node2D
var spatial_grid: Node = null
var game_config: Node = null

# Performance optimization
var last_collision_check: float = 0.0
var collision_check_interval: float = 0.033  # ~30 FPS collision checks
var cached_nearby_entities: Array = []
var cache_update_timer: float = 0.0
var cache_update_interval: float = 0.1  # Update cache every 0.1s

# Collision state
var collision_forces: Array = []  # Accumulated forces this frame
var is_colliding: bool = false
var collision_count: int = 0

signal collision_occurred(other_entity: Node2D, force: Vector2)
signal mass_changed(new_mass: float)

func _ready():
	# Get parent entity reference
	parent_entity = get_parent()
	if not parent_entity is Node2D:
		push_error("MassBasedCollision must be child of Node2D")
		return
	
	# Connect to game systems
	spatial_grid = get_node_or_null("/root/SpatialGrid")
	game_config = get_node_or_null("/root/GameConfig")
	
	# Load configuration
	load_configuration()
	
	# Register with spatial grid
	if spatial_grid:
		spatial_grid.register_entity(parent_entity, mass, collision_radius)
	
	set_physics_process(true)

func load_configuration():
	"""Load configuration from GameConfig"""
	if game_config:
		collision_force_multiplier = game_config.get("collision_force_multiplier", 100.0)
		collision_check_interval = game_config.get("collision_check_interval", 0.033)
		cache_update_interval = game_config.get("collision_cache_interval", 0.1)
		min_collision_force = game_config.get("min_collision_force", 10.0)
		max_collision_force = game_config.get("max_collision_force", 500.0)

func _physics_process(delta):
	"""Handle collision detection and response"""
	if not enable_collision_response or not is_instance_valid(parent_entity):
		return
	
	# Update collision cache periodically
	cache_update_timer += delta
	if cache_update_timer >= cache_update_interval:
		update_collision_cache()
		cache_update_timer = 0.0
	
	# Perform collision checks at reduced frequency
	last_collision_check += delta
	if last_collision_check >= collision_check_interval:
		perform_collision_checks()
		last_collision_check = 0.0
	
	# Apply accumulated collision forces
	apply_collision_forces(delta)

func update_collision_cache():
	"""Update cache of nearby entities for collision detection"""
	if not spatial_grid:
		return
	
	# Get nearby entities within collision range
	var search_radius = collision_radius * 2.5  # Slightly larger than collision radius
	cached_nearby_entities = spatial_grid.get_nearby_entities(
		parent_entity.global_position, 
		search_radius
	)
	
	# Remove self from cache
	cached_nearby_entities.erase(parent_entity)

func perform_collision_checks():
	"""Check for collisions with cached nearby entities"""
	collision_forces.clear()
	collision_count = 0
	is_colliding = false
	
	for other_entity in cached_nearby_entities:
		if not is_instance_valid(other_entity) or other_entity == parent_entity:
			continue
		
		# Check if entities are actually colliding
		var distance = parent_entity.global_position.distance_to(other_entity.global_position)
		var other_collision_component = get_collision_component(other_entity)
		var other_radius = other_collision_component.collision_radius if other_collision_component else 20.0
		
		var collision_distance = collision_radius + other_radius
		
		if distance < collision_distance and distance > 0.1:  # Avoid division by zero
			handle_collision(other_entity, other_collision_component, distance, collision_distance)

func handle_collision(other_entity: Node2D, other_collision_component: MassBasedCollision, distance: float, collision_distance: float):
	"""Handle collision between this entity and another"""
	is_colliding = true
	collision_count += 1
	
	# Calculate collision normal and overlap
	var collision_normal = (parent_entity.global_position - other_entity.global_position).normalized()
	var overlap = collision_distance - distance
	
	if enable_mass_based_pushing and other_collision_component:
		# Mass-based collision response
		var collision_force = calculate_mass_based_force(other_collision_component, collision_normal, overlap)
		collision_forces.append(collision_force)
		collision_occurred.emit(other_entity, collision_force)
	else:
		# Simple separation force
		var separation_force = collision_normal * collision_force_multiplier * (overlap / collision_distance)
		separation_force = separation_force.limit_length(max_collision_force)
		collision_forces.append(separation_force)
		collision_occurred.emit(other_entity, separation_force)

func calculate_mass_based_force(other_collision: MassBasedCollision, collision_normal: Vector2, overlap: float) -> Vector2:
	"""Calculate collision force based on mass difference"""
	var other_mass = other_collision.mass
	var total_mass = mass + other_mass
	
	# Mass ratio determines how much each entity is affected
	var mass_ratio = other_mass / total_mass  # How much this entity is affected
	
	# Base force calculation
	var base_force = collision_force_multiplier * (overlap / collision_radius)
	
	# Apply mass-based scaling
	var force_magnitude = base_force * mass_ratio
	force_magnitude = clamp(force_magnitude, min_collision_force, max_collision_force)
	
	return collision_normal * force_magnitude

func apply_collision_forces(delta: float):
	"""Apply accumulated collision forces to parent entity"""
	if collision_forces.is_empty() or not parent_entity.has("velocity"):
		return
	
	# Sum all collision forces
	var total_force = Vector2.ZERO
	for force in collision_forces:
		total_force += force
	
	# Apply force to velocity with mass consideration
	var acceleration = total_force / mass
	parent_entity.velocity += acceleration * delta
	
	# Apply friction to prevent infinite acceleration
	parent_entity.velocity *= friction

func get_collision_component(entity: Node2D) -> MassBasedCollision:
	"""Get MassBasedCollision component from entity"""
	for child in entity.get_children():
		if child is MassBasedCollision:
			return child
	return null

func set_mass(new_mass: float):
	"""Update entity mass"""
	var old_mass = mass
	mass = max(new_mass, 0.1)  # Minimum mass to prevent physics issues
	
	# Update spatial grid if available
	if spatial_grid:
		var entity_data = spatial_grid.get_entity_data(parent_entity)
		if entity_data:
			entity_data.mass = mass
	
	mass_changed.emit(mass)

func set_collision_radius(new_radius: float):
	"""Update collision radius"""
	collision_radius = max(new_radius, 1.0)  # Minimum radius
	
	# Update spatial grid if available
	if spatial_grid:
		var entity_data = spatial_grid.get_entity_data(parent_entity)
		if entity_data:
			entity_data.collision_radius = collision_radius

func enable_collision(enabled: bool):
	"""Enable or disable collision response"""
	enable_collision_response = enabled
	set_physics_process(enabled)

func is_entity_heavier(other_entity: Node2D) -> bool:
	"""Check if this entity is heavier than another"""
	var other_collision = get_collision_component(other_entity)
	if other_collision:
		return mass > other_collision.mass
	return true  # Assume heavier if no collision component

func can_push_entity(other_entity: Node2D) -> bool:
	"""Check if this entity can push another based on mass"""
	var other_collision = get_collision_component(other_entity)
	if not other_collision:
		return true
	
	# Can push if significantly heavier (mass ratio > 1.5)
	return mass / other_collision.mass > 1.5

func get_push_strength_against(other_entity: Node2D) -> float:
	"""Get push strength against specific entity (0.0 to 1.0)"""
	var other_collision = get_collision_component(other_entity)
	if not other_collision:
		return 1.0
	
	var mass_ratio = mass / (mass + other_collision.mass)
	return clamp(mass_ratio, 0.1, 0.9)  # Always allow some movement

func get_collision_info() -> Dictionary:
	"""Get collision information for debugging"""
	return {
		"mass": mass,
		"collision_radius": collision_radius,
		"is_colliding": is_colliding,
		"collision_count": collision_count,
		"cached_entities": cached_nearby_entities.size(),
		"collision_forces_count": collision_forces.size(),
		"enable_collision_response": enable_collision_response
	}

# Integration with existing enemy mass system
func setup_enemy_mass_from_type(enemy_type: String):
	"""Setup mass based on enemy type for integration with existing system"""
	match enemy_type:
		"goblin":
			set_mass(0.5)
			set_collision_radius(15.0)
		"skeleton":
			set_mass(0.7)
			set_collision_radius(18.0)
		"orc":
			set_mass(1.0)
			set_collision_radius(20.0)
		"wizard":
			set_mass(0.8)
			set_collision_radius(18.0)
		"elemental":
			set_mass(1.2)
			set_collision_radius(22.0)
		"golem":
			set_mass(2.0)
			set_collision_radius(30.0)
		"slime":
			set_mass(0.3)
			set_collision_radius(12.0)
		_:
			set_mass(1.0)  # Default mass
			set_collision_radius(20.0)

func _exit_tree():
	"""Clean up when component is removed"""
	if spatial_grid and is_instance_valid(parent_entity):
		spatial_grid.unregister_entity(parent_entity)