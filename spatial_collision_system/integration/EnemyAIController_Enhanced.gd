# EnemyAIController_Enhanced.gd - Enhanced AI controller with spatial collision system
# This file shows modifications needed for EnemyAIController.gd to use the new spatial system
# INSTRUCTIONS: Merge these changes into your existing EnemyAIController.gd file

# REPLACE THE EXISTING apply_separation_force FUNCTION (around line 428-444)
func apply_separation_force():
	"""ENHANCED: Apply separation force using spatial grid system - O(1) complexity"""
	if not is_instance_valid(enemy) or not separation_enabled:
		return
	
	# Use spatial grid for efficient neighbor detection
	if SpatialGrid:
		apply_spatial_grid_separation()
	else:
		# Fallback to legacy system if spatial grid not available
		apply_legacy_separation()

func apply_spatial_grid_separation():
	"""Use spatial grid for optimized separation - NEW SYSTEM"""
	var separation_distance = GameConfig.get_separation_distance() if GameConfig else 40.0
	var separation_force = Vector2.ZERO
	var nearby_count = 0
	
	# Get nearby enemies efficiently using spatial grid
	var nearby_enemies = SpatialGrid.get_nearby_enemies(enemy.global_position, separation_distance)
	
	for other_enemy in nearby_enemies:
		if other_enemy == enemy or not is_instance_valid(other_enemy):
			continue
		
		var distance_sq = enemy.global_position.distance_squared_to(other_enemy.global_position)
		var separation_distance_sq = separation_distance * separation_distance
		
		if distance_sq < separation_distance_sq and distance_sq > 0:
			# Enhanced mass-based separation
			var separation_vector = calculate_mass_based_separation(other_enemy, distance_sq, separation_distance)
			separation_force += separation_vector
			nearby_count += 1
	
	# Apply the separation force with mass consideration
	if nearby_count > 0 and is_instance_valid(enemy):
		# Get enemy mass for proper force application
		var enemy_mass = enemy.mass if enemy.has("mass") else 1.0
		var adjusted_force = separation_force / enemy_mass  # Heavier enemies resist more
		enemy.velocity += adjusted_force

func calculate_mass_based_separation(other_enemy: Node2D, distance_sq: float, separation_distance: float) -> Vector2:
	"""Calculate separation force based on mass difference"""
	var enemy_mass = enemy.mass if enemy.has("mass") else 1.0
	var other_mass = other_enemy.mass if other_enemy.has("mass") else 1.0
	
	# Mass ratio determines separation strength
	var mass_ratio = other_mass / (enemy_mass + other_mass)
	
	var away_direction = (enemy.global_position - other_enemy.global_position).normalized()
	var distance = sqrt(distance_sq)
	var force_strength = (separation_distance - distance) / separation_distance
	
	# Apply mass-based force scaling
	var base_force = 20.0  # Configurable via GameConfig
	if GameConfig:
		base_force = GameConfig.get("separation_force_strength", 20.0)
	
	return away_direction * force_strength * base_force * mass_ratio

func apply_legacy_separation():
	"""Fallback to legacy separation system if spatial grid unavailable"""
	# This is the original implementation for compatibility
	var separation_distance = GameConfig.get_separation_distance() if GameConfig else 40.0
	var separation_force = Vector2.ZERO
	var nearby_count = 0
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for other_enemy in enemies:
		if other_enemy == enemy or not is_instance_valid(other_enemy):
			continue
		
		var distance_sq = enemy.global_position.distance_squared_to(other_enemy.global_position)
		var separation_distance_sq = separation_distance * separation_distance
		if distance_sq < separation_distance_sq and distance_sq > 0:
			var away_direction = (enemy.global_position - other_enemy.global_position).normalized()
			var distance = sqrt(distance_sq)
			var force_strength = (separation_distance - distance) / separation_distance
			separation_force += away_direction * force_strength * 20.0
			nearby_count += 1
	
	if nearby_count > 0 and is_instance_valid(enemy):
		enemy.velocity += separation_force

# ADD THESE NEW FUNCTIONS FOR LOD INTEGRATION

func setup_lod_integration():
	"""Setup integration with LOD system"""
	# This should be called during setup()
	if EnemyLODManager:
		EnemyLODManager.lod_changed.connect(_on_lod_changed)

func _on_lod_changed(entity: Node2D, old_level: int, new_level: int):
	"""Handle LOD level changes for this enemy"""
	if entity != enemy:
		return
	
	match new_level:
		EnemyLODManager.LODLevel.FULL:
			enable_full_ai()
		EnemyLODManager.LODLevel.SIMPLIFIED:
			enable_simplified_ai()
		EnemyLODManager.LODLevel.MINIMAL:
			enable_minimal_ai()
		EnemyLODManager.LODLevel.DISABLED:
			disable_ai()

func enable_full_ai():
	"""Enable full AI processing"""
	set_enabled(true)
	set_separation_enabled(true)
	min_ability_cooldown = 0.5  # Normal ability frequency
	position_update_interval = 0.2  # Normal update rate

func enable_simplified_ai():
	"""Enable simplified AI processing"""
	set_enabled(true)
	set_separation_enabled(false)  # Disable expensive separation
	min_ability_cooldown = 1.0  # Reduced ability frequency
	position_update_interval = 0.4  # Slower updates

func enable_minimal_ai():
	"""Enable minimal AI - basic movement only"""
	set_enabled(true)
	set_separation_enabled(false)
	min_ability_cooldown = 2.0  # Very infrequent abilities
	position_update_interval = 0.6  # Slow updates
	
	# Force simple chasing behavior
	change_state("chasing")

func disable_ai():
	"""Disable AI processing"""
	set_enabled(false)
	set_separation_enabled(false)

func set_enabled(enabled: bool):
	"""Enable/disable AI controller"""
	set_physics_process(enabled)
	
	# Store state for when re-enabled
	if not enabled:
		set_meta("ai_disabled", true)
	else:
		if has_meta("ai_disabled"):
			remove_meta("ai_disabled")

# MODIFY EXISTING update_ai_state FUNCTION to respect LOD
func update_ai_state(delta):
	"""Enhanced AI state update with LOD considerations"""
	# Check if AI is disabled by LOD system
	if has_meta("ai_disabled"):
		return
	
	# Get current LOD level for performance adjustments
	var lod_level = EnemyLODManager.LODLevel.FULL
	if EnemyLODManager:
		lod_level = EnemyLODManager.get_entity_lod_level(enemy)
	
	# Adjust AI complexity based on LOD level
	match lod_level:
		EnemyLODManager.LODLevel.FULL:
			update_full_ai_state(delta)
		EnemyLODManager.LODLevel.SIMPLIFIED:
			update_simplified_ai_state(delta)
		EnemyLODManager.LODLevel.MINIMAL:
			update_minimal_ai_state(delta)
		_:
			return  # Disabled or unknown LOD level

func update_full_ai_state(delta):
	"""Full AI state update - existing logic"""
	# Use existing AI logic without modifications
	var target = get_cached_player_reference(delta)
	if not target:
		change_state("idle")
		return
	
	var distance_to_target = enemy.global_position.distance_to(target.global_position)
	var health_ratio = enemy.get_health_ratio()
	
	# Full AI decision making
	match state:
		"idle":
			if distance_to_target < 300.0:
				change_state("chasing")
		"chasing":
			if distance_to_target > 500.0:
				change_state("idle")
			elif can_use_ability() and distance_to_target <= get_attack_range():
				change_state("attacking")
			elif health_ratio < retreat_threshold:
				change_state("retreating")
		"attacking":
			if distance_to_target > get_attack_range() * 1.2:
				change_state("chasing")
			elif health_ratio < retreat_threshold:
				change_state("retreating")
		"retreating":
			if health_ratio > retreat_threshold + 0.1:
				change_state("chasing")

func update_simplified_ai_state(delta):
	"""Simplified AI state update"""
	var target = get_cached_player_reference(delta)
	if not target:
		return
	
	var distance_to_target = enemy.global_position.distance_to(target.global_position)
	
	# Simplified decision making - only chase and attack
	if distance_to_target <= get_attack_range() and can_use_ability():
		change_state("attacking")
	else:
		change_state("chasing")

func update_minimal_ai_state(delta):
	"""Minimal AI state update - basic following only"""
	var target = get_cached_player_reference(delta)
	if not target:
		return
	
	# Always chase - no complex decisions
	change_state("chasing")

# ADD PERFORMANCE MONITORING
func get_ai_performance_info() -> Dictionary:
	"""Get AI performance information for monitoring"""
	var info = {}
	
	info.enabled = not has_meta("ai_disabled")
	info.separation_enabled = separation_enabled
	info.state = state
	info.ability_cooldown = ability_cooldown_timer
	
	if EnemyLODManager:
		info.lod_level = EnemyLODManager.get_entity_lod_level(enemy)
	
	return info

# MODIFY setup() FUNCTION to include new systems
func setup(parent_enemy: Node, data: EnemyData):
	"""Enhanced setup with spatial collision integration"""
	# Call existing setup logic first
	if not is_instance_valid(parent_enemy) or not data:
		push_error("EnemyAIController: Invalid setup parameters")
		return
		
	enemy = parent_enemy
	enemy_data = data
	is_initialized = true
	
	# Setup LOD integration
	setup_lod_integration()
	
	# Configuration and existing setup...
	if GameConfig:
		min_ability_cooldown = GameConfig.get_ability_spam_prevention()
	
	var attack_range = enemy_data.attack_range if enemy_data else 50.0
	
	match enemy_data.ai_behavior:
		"melee_aggressive":
			preferred_distance = attack_range * 0.8
		"ranged_kiting":
			preferred_distance = attack_range * 0.5
		"support_healing":
			preferred_distance = attack_range * 0.9
	
	if is_instance_valid(enemy):
		desired_position = enemy.global_position

# COMPATIBILITY FUNCTIONS
func is_using_spatial_grid() -> bool:
	"""Check if spatial grid system is available and in use"""
	return SpatialGrid != null and SpatialGrid.total_entities > 0

func get_separation_method() -> String:
	"""Get current separation method for debugging"""
	if is_using_spatial_grid():
		return "spatial_grid"
	else:
		return "legacy"

func force_separation_method(use_spatial_grid: bool):
	"""Force specific separation method (for testing)"""
	if use_spatial_grid and not SpatialGrid:
		push_warning("Cannot force spatial grid - SpatialGrid not available")
		return
	
	set_meta("force_separation_method", "spatial_grid" if use_spatial_grid else "legacy")

func should_use_spatial_grid() -> bool:
	"""Determine if should use spatial grid based on availability and performance"""
	if has_meta("force_separation_method"):
		return get_meta("force_separation_method") == "spatial_grid"
	
	return is_using_spatial_grid()