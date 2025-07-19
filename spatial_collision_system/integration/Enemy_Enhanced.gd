# Enemy_Enhanced.gd - Enhanced enemy with spatial collision system integration
# This file shows the modifications needed for Enemy.gd to integrate with the new collision system
# INSTRUCTIONS: Merge these changes into your existing Enemy.gd file

# ADD THESE IMPORTS AT THE TOP
# (No additional imports needed as autoloads are automatically available)

# ADD THESE VARIABLES TO THE EXISTING ENEMY CLASS (around line 43)
# Enhanced collision system
var mass_collision_component: MassBasedCollision
var spatial_grid_registered: bool = false
var last_spatial_position: Vector2 = Vector2.ZERO

# ADD THIS TO _ready() FUNCTION (after line 78)
func _ready():
	# ... existing _ready() code ...
	
	# Setup enhanced collision system
	setup_mass_collision_system()
	
	# Register with spatial grid
	register_with_spatial_grid()

# ADD THESE NEW FUNCTIONS

func setup_mass_collision_system():
	"""Setup mass-based collision component"""
	# Create and configure mass collision component
	mass_collision_component = MassBasedCollision.new()
	mass_collision_component.name = "MassBasedCollision"
	add_child(mass_collision_component)
	
	# Configure based on enemy type
	mass_collision_component.setup_enemy_mass_from_type(enemy_type)
	
	# Connect collision signals
	mass_collision_component.collision_occurred.connect(_on_mass_collision_occurred)
	
	# Add to collision components group for optimization
	mass_collision_component.add_to_group("mass_collision_components")

func register_with_spatial_grid():
	"""Register enemy with spatial grid system"""
	if SpatialGrid:
		var collision_radius = 20.0
		if main_collision and main_collision.shape is CircleShape2D:
			collision_radius = main_collision.shape.radius
		
		SpatialGrid.register_entity(self, mass, collision_radius)
		spatial_grid_registered = true
		last_spatial_position = global_position

# MODIFY THE EXISTING _physics_process FUNCTION (around line 163)
func _physics_process(delta):
	if is_dead:
		return
	
	# Update spatial grid position if moved significantly
	update_spatial_grid_position()
	
	# ... rest of existing _physics_process code ...

# ADD THIS NEW FUNCTION
func update_spatial_grid_position():
	"""Update position in spatial grid if moved significantly"""
	if not spatial_grid_registered or not SpatialGrid:
		return
	
	var position_delta = global_position.distance_to(last_spatial_position)
	if position_delta > 10.0:  # Only update if moved 10+ pixels
		SpatialGrid.update_entity_position(self, last_spatial_position, global_position)
		last_spatial_position = global_position

# REPLACE THE EXISTING apply_wave_scaling FUNCTION (around line 544)
func apply_wave_scaling():
	"""Apply wave scaling multipliers with mass-based collision integration"""
	if WaveManager:
		wave_multipliers = WaveManager.get_current_enemy_multipliers()
		
		if wave_multipliers.has("health"):
			max_health *= wave_multipliers.health
			health = max_health
		
		if wave_multipliers.has("damage"):
			damage *= wave_multipliers.damage
		
		if wave_multipliers.has("speed"):
			speed *= wave_multipliers.speed
		
		# Update mass based on scaling (larger enemies are heavier)
		if wave_multipliers.has("health") and mass_collision_component:
			var health_scaling = wave_multipliers.health
			var new_mass = mass * sqrt(health_scaling)  # Square root to avoid extreme mass changes
			mass_collision_component.set_mass(new_mass)
			mass = new_mass  # Update local mass property too
		
		# Update components
		if health_component:
			health_component.max_health = max_health
			health_component.current_health = min(health, max_health)
		
		if movement_component:
			movement_component.base_speed = speed

# ADD THIS SIGNAL HANDLER
func _on_mass_collision_occurred(other_entity: Node2D, force: Vector2):
	"""Handle mass-based collision events"""
	# Optional: Add visual feedback for collisions
	if force.length() > 50.0:  # Only for significant collisions
		show_collision_feedback(force)

func show_collision_feedback(force: Vector2):
	"""Visual feedback for collision events"""
	# Simple screen shake or particle effect
	if sprite:
		var tween = create_tween()
		var shake_offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))
		tween.tween_property(sprite, "position", shake_offset, 0.1)
		tween.tween_property(sprite, "position", Vector2.ZERO, 0.1)

# MODIFY THE EXISTING die() FUNCTION (around line 299)
func die():
	"""Handle enemy death with spatial grid cleanup"""
	if is_dead:
		return
	
	is_dead = true
	
	# Unregister from spatial grid
	if spatial_grid_registered and SpatialGrid:
		SpatialGrid.unregister_entity(self)
		spatial_grid_registered = false
	
	# ... rest of existing die() code ...

# ADD THIS FUNCTION FOR DEBUG/MONITORING
func get_enhanced_debug_info() -> Dictionary:
	"""Get enhanced debug information including collision system"""
	var info = get_debug_info()  # Call existing debug method
	
	# Add collision system info
	if mass_collision_component:
		info["collision_system"] = mass_collision_component.get_collision_info()
	
	info["spatial_grid_registered"] = spatial_grid_registered
	info["mass"] = mass
	
	# Add LOD information if available
	if EnemyLODManager:
		info["lod_level"] = EnemyLODManager.get_entity_lod_level(self)
	
	return info

# OPTIONAL: ADD THESE FUNCTIONS FOR ADVANCED FEATURES

func can_push_player() -> bool:
	"""Check if enemy can push player based on mass"""
	return mass > 1.2  # Only heavy enemies can push player

func get_collision_strength_vs_player() -> float:
	"""Get collision strength against player"""
	if mass_collision_component:
		# Assume player mass is 1.5
		var player_mass = 1.5
		return mass / (mass + player_mass)
	return 0.5

func set_collision_enabled(enabled: bool):
	"""Enable/disable collision system (for abilities, teleporting, etc.)"""
	if mass_collision_component:
		mass_collision_component.enable_collision(enabled)

# INTEGRATION WITH EXISTING ABILITY SYSTEM
func set_movement_enabled(enabled: bool):
	"""Enhanced movement control with collision system integration"""
	# Call existing method
	if not enabled:
		velocity = Vector2.ZERO
		set_meta("movement_disabled", true)
		# Disable collision during abilities
		set_collision_enabled(false)
	else:
		if has_meta("movement_disabled"):
			remove_meta("movement_disabled")
		# Re-enable collision after abilities
		set_collision_enabled(true)

# PERFORMANCE OPTIMIZATION INTEGRATION
func _exit_tree():
	"""Cleanup when enemy is removed"""
	# Ensure cleanup from spatial grid
	if spatial_grid_registered and SpatialGrid:
		SpatialGrid.unregister_entity(self)
	
	# Cleanup mass collision component
	if mass_collision_component:
		mass_collision_component.queue_free()

# COMPATIBILITY WITH EXISTING SEPARATION SYSTEM
# This allows gradual migration from old to new system
func use_legacy_separation() -> bool:
	"""Check if should use legacy separation system"""
	# Use new system if LOD level is FULL, legacy for others
	if EnemyLODManager:
		var lod_level = EnemyLODManager.get_entity_lod_level(self)
		return lod_level != EnemyLODManager.LODLevel.FULL
	return false  # Default to new system

# EXAMPLE USAGE OF NEW FEATURES
func handle_special_collision_behavior():
	"""Example of how to use enhanced collision features"""
	if mass_collision_component:
		# Check if colliding with something
		if mass_collision_component.is_colliding:
			# Adjust behavior based on collision
			match enemy_type:
				"golem":
					# Golems push through everything
					mass_collision_component.collision_force_multiplier = 200.0
				"slime":
					# Slimes are bouncy
					mass_collision_component.friction = 0.9
				"wizard":
					# Wizards try to avoid collisions
					if mass_collision_component.collision_count > 2:
						# Teleport away or use special ability
						pass