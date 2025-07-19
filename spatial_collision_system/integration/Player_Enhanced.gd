# Player_Enhanced.gd - Player enhancements for mass-based collision system
# This file shows modifications needed for Player.gd to integrate with the new collision system
# INSTRUCTIONS: Merge these changes into your existing Player.gd file

# ADD THESE VARIABLES TO THE EXISTING PLAYER CLASS (around line 30)
# Enhanced collision system
var mass_collision_component: MassBasedCollision
var player_mass: float = 1.5  # Player is heavier than most enemies
var collision_immunity_active: bool = false
var collision_immunity_timer: float = 0.0
var collision_immunity_duration: float = 0.5  # Immunity after taking damage

# MODIFY THE EXISTING connect_signals() FUNCTION (around line 120)
func connect_signals():
	"""Enhanced signal connections with collision system"""
	# ... existing signal connection code ...
	
	# Setup enhanced collision system
	setup_mass_collision_system()

# ADD THESE NEW FUNCTIONS

func setup_mass_collision_system():
	"""Setup mass-based collision component for player"""
	# Create and configure mass collision component
	mass_collision_component = MassBasedCollision.new()
	mass_collision_component.name = "PlayerMassCollision"
	add_child(mass_collision_component)
	
	# Configure player-specific collision properties
	mass_collision_component.set_mass(player_mass)
	mass_collision_component.set_collision_radius(40.0)  # Slightly larger than player sprite
	mass_collision_component.collision_force_multiplier = 150.0  # Player pushes back harder
	mass_collision_component.enable_mass_based_pushing = true
	
	# Connect collision signals
	mass_collision_component.collision_occurred.connect(_on_player_collision_occurred)
	
	# Register with spatial grid
	if SpatialGrid:
		SpatialGrid.register_entity(self, player_mass, 40.0)

# MODIFY THE EXISTING _physics_process FUNCTION (around line 237)
func _physics_process(delta):
	"""Enhanced physics processing with collision system"""
	# Update timers
	update_timers(delta)
	update_collision_immunity(delta)
	
	# Handle input
	handle_movement_input(delta)
	handle_teleport_input(delta)
	handle_spell_input()
	
	# Apply movement
	move_and_slide()
	
	# Enhanced collision response based on mass
	handle_enhanced_collision_response()
	
	# Update visuals
	update_visuals()

func update_collision_immunity(delta: float):
	"""Update collision immunity timer"""
	if collision_immunity_active:
		collision_immunity_timer -= delta
		if collision_immunity_timer <= 0.0:
			collision_immunity_active = false
			# Re-enable collision response
			if mass_collision_component:
				mass_collision_component.enable_collision_response = true

# REPLACE THE EXISTING handle_enemy_collision_response FUNCTION (around line 450)
func handle_enhanced_collision_response():
	"""Enhanced collision response using mass-based system"""
	if not mass_collision_component or collision_immunity_active:
		return
	
	# Get collision information from mass collision component
	var collision_info = mass_collision_component.get_collision_info()
	
	if collision_info.is_colliding:
		# Handle mass-based collision response
		handle_mass_based_collisions()

func handle_mass_based_collisions():
	"""Handle collisions based on mass differences"""
	# Get nearby enemies for collision analysis
	if not SpatialGrid:
		return
	
	var nearby_enemies = SpatialGrid.get_nearby_enemies(global_position, 60.0)
	
	for enemy in nearby_enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		var enemy_collision = enemy.get_node_or_null("MassBasedCollision")
		
		if distance < 45.0 and enemy_collision:  # Close enough for collision
			handle_player_enemy_collision(enemy, enemy_collision)

func handle_player_enemy_collision(enemy: Node2D, enemy_collision: MassBasedCollision):
	"""Handle collision between player and specific enemy"""
	var enemy_mass = enemy_collision.mass
	var mass_ratio = player_mass / (player_mass + enemy_mass)
	
	# Calculate collision response
	var collision_normal = (global_position - enemy.global_position).normalized()
	var base_force = 100.0
	
	# Player collision behavior based on enemy mass
	if enemy_mass >= 2.0:  # Heavy enemies (Golem)
		# Player gets pushed back
		var push_force = collision_normal * base_force * (1.0 - mass_ratio)
		velocity += push_force
		
		# Show impact feedback
		show_heavy_collision_feedback()
		
	elif enemy_mass <= 0.5:  # Light enemies (Goblin, Slime)
		# Player pushes through easily
		var enemy_push = -collision_normal * base_force * mass_ratio * 2.0
		if enemy.has("velocity"):
			enemy.velocity += enemy_push
		
		# Minimal player impact
		velocity += collision_normal * base_force * 0.1
		
	else:  # Medium enemies
		# Mutual pushing based on mass
		var player_push = collision_normal * base_force * (1.0 - mass_ratio)
		var enemy_push = -collision_normal * base_force * mass_ratio
		
		velocity += player_push
		if enemy.has("velocity"):
			enemy.velocity += enemy_push

func show_heavy_collision_feedback():
	"""Show feedback when colliding with heavy enemies"""
	# Screen shake or visual effect
	if camera_component and camera_component.has_method("add_trauma"):
		camera_component.add_trauma(0.3)
	
	# Optional: Brief movement speed reduction
	if movement_component:
		movement_component.apply_temporary_modifier("heavy_collision", 0.7, 0.5)

# MODIFY THE EXISTING take_damage FUNCTION (around line 600)
func take_damage(amount: float, source: Node = null, damage_type: String = ""):
	"""Enhanced damage handling with collision immunity"""
	var damage_taken = false
	
	# ... existing damage logic ...
	
	if damage_taken:
		# Activate collision immunity after taking damage
		collision_immunity_active = true
		collision_immunity_timer = collision_immunity_duration
		
		# Temporarily disable collision response
		if mass_collision_component:
			mass_collision_component.enable_collision_response = false
		
		# ... rest of existing damage handling ...

# ENHANCE THE EXISTING TELEPORT SYSTEM (around line 365)
func start_teleport(direction: Vector2):
	"""Enhanced teleport with collision system integration"""
	if is_teleporting or not can_teleport():
		return
	
	# ... existing teleport setup ...
	
	# Disable mass collision during teleport
	if mass_collision_component:
		mass_collision_component.enable_collision(false)
	
	# ... rest of existing teleport code ...

func end_teleport():
	"""Enhanced teleport end with collision safety"""
	# ... existing teleport end logic ...
	
	# Re-enable mass collision with safety check
	if mass_collision_component:
		call_deferred("restore_collision_after_teleport")
	
	# ... rest of existing teleport end code ...

func restore_collision_after_teleport():
	"""Safely restore collision after teleport"""
	if not mass_collision_component:
		return
	
	# Check for overlaps before restoring collision
	var safe_position = find_safe_position_for_collision_restore()
	if safe_position != global_position:
		global_position = safe_position
	
	# Re-enable collision
	mass_collision_component.enable_collision(true)
	
	# Brief immunity to prevent immediate damage
	collision_immunity_active = true
	collision_immunity_timer = 0.3

# ADD SIGNAL HANDLER FOR COLLISION EVENTS
func _on_player_collision_occurred(other_entity: Node2D, force: Vector2):
	"""Handle player collision events"""
	if not is_instance_valid(other_entity):
		return
	
	# Check if colliding with enemy
	if other_entity.is_in_group("enemies"):
		# Optional: Contact damage from heavy enemies
		if other_entity.has("mass") and other_entity.mass >= 1.5:
			var contact_damage = other_entity.get("contact_damage") if other_entity.has("contact_damage") else 0.0
			if contact_damage > 0.0 and not collision_immunity_active:
				take_damage(contact_damage, other_entity, "contact")
	
	# Visual/audio feedback for significant collisions
	if force.length() > 100.0:
		show_collision_impact_effect(force)

func show_collision_impact_effect(force: Vector2):
	"""Show visual effect for collision impact"""
	# Particle effect or screen shake
	if force.length() > 200.0:
		# Strong collision
		if camera_component and camera_component.has_method("add_trauma"):
			camera_component.add_trauma(0.5)
	else:
		# Medium collision
		if camera_component and camera_component.has_method("add_trauma"):
			camera_component.add_trauma(0.2)

# ADD CONFIGURATION FUNCTIONS
func set_player_mass(new_mass: float):
	"""Set player mass (for upgrades, equipment, etc.)"""
	player_mass = max(new_mass, 0.5)  # Minimum mass
	if mass_collision_component:
		mass_collision_component.set_mass(player_mass)

func get_player_mass() -> float:
	"""Get current player mass"""
	return player_mass

func set_collision_immunity(duration: float):
	"""Set collision immunity for specific duration"""
	collision_immunity_active = true
	collision_immunity_timer = duration
	if mass_collision_component:
		mass_collision_component.enable_collision_response = false

# ADD DEBUG FUNCTIONS
func get_collision_debug_info() -> Dictionary:
	"""Get collision system debug information"""
	var info = {}
	
	if mass_collision_component:
		info.collision_component = mass_collision_component.get_collision_info()
	
	info.player_mass = player_mass
	info.collision_immunity_active = collision_immunity_active
	info.collision_immunity_timer = collision_immunity_timer
	
	return info

func can_push_enemy(enemy: Node2D) -> bool:
	"""Check if player can push specific enemy"""
	if not mass_collision_component or not enemy.has("mass"):
		return true
	
	var enemy_mass = enemy.mass
	return player_mass >= enemy_mass * 0.8  # Can push if not much lighter

# INTEGRATION WITH EXISTING SYSTEMS
func handle_movement_input(delta):
	"""Enhanced movement input with collision considerations"""
	# ... existing movement input code ...
	
	# Adjust movement based on collision state
	if mass_collision_component and mass_collision_component.is_colliding:
		# Slightly reduce movement speed when pushing through enemies
		var collision_count = mass_collision_component.collision_count
		if collision_count > 0:
			var speed_reduction = 1.0 - (collision_count * 0.1)  # 10% reduction per collision
			speed_reduction = max(speed_reduction, 0.5)  # Minimum 50% speed
			
			if movement_component:
				movement_component.apply_temporary_modifier("collision_resistance", speed_reduction, 0.1)

# OPTIONAL: UPGRADE SYSTEM INTEGRATION
func apply_mass_upgrade(upgrade_factor: float):
	"""Apply mass upgrade (heavier player can push more enemies)"""
	var new_mass = player_mass * upgrade_factor
	set_player_mass(new_mass)
	
	# Visual feedback
	print("Player mass increased to: ", new_mass)

# PERFORMANCE OPTIMIZATION
func _exit_tree():
	"""Cleanup when player is removed"""
	# Unregister from spatial grid
	if SpatialGrid:
		SpatialGrid.unregister_entity(self)
	
	# Cleanup mass collision component
	if mass_collision_component:
		mass_collision_component.queue_free()