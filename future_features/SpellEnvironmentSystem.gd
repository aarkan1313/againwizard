# SpellEnvironmentSystem.gd
# Handles spell-environment interactions for Phase 5
# Godot 4.4.1 compatible - manages environmental reactions to spells

extends Node
# SpellEnvironmentSystem - Autoload singleton (no class_name needed to avoid conflict)

# Environmental interaction data
class EnvironmentInteraction:
	var spell_type: String
	var environment_type: String
	var effect_type: String
	var effect_data: Dictionary
	var duration: float
	var position: Vector2i
	var timestamp: float
	
	func _init():
		effect_data = {}
		timestamp = Time.get_ticks_msec() / 1000.0

# Active environmental effects
var active_effects: Array[EnvironmentInteraction] = []
var interaction_rules: Dictionary = {}

# Signals for environmental interactions
signal environment_interaction_triggered(interaction_data: EnvironmentInteraction)
signal environment_effect_expired(effect_id: String)
signal magical_enhancement_activated(position: Vector2i, enhancement_type: String)

func _init():
	_initialize_interaction_rules()

func _exit_tree():
	# Cleanup when system is removed
	active_effects.clear()
	print("🧹 SpellEnvironmentSystem cleanup completed")

func _ready():
	# Connect to spell casting events
	if GameEvents:
		# Connect to enhanced spell signal for environmental interactions
		if GameEvents.has_signal("spell_cast_enhanced"):
			GameEvents.spell_cast_enhanced.connect(_on_spell_cast)
		else:
			# Fallback to basic signal if enhanced not available
			GameEvents.spell_cast.connect(_on_spell_cast_basic)
	
	# Clean up expired effects periodically
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.timeout.connect(_cleanup_expired_effects)
	timer.autostart = true
	add_child(timer)

func _initialize_interaction_rules():
	# Fire spell interactions
	interaction_rules["fireball"] = {
		"ice_fields": {
			"effect": "steam_explosion",
			"radius": 3,
			"damage_multiplier": 1.5,
			"duration": 10.0,
			"creates_water": true
		},
		"poison_swamps": {
			"effect": "toxic_ignition",
			"radius": 2,
			"damage_over_time": 5.0,
			"duration": 15.0,
			"purifies_area": true
		},
		"crystal_caverns": {
			"effect": "crystal_resonance",
			"spell_power_boost": 2.0,
			"duration": 30.0,
			"mana_cost_reduction": 0.3
		},
		"dark_forest": {
			"effect": "forest_fire",
			"spread_chance": 0.4,
			"duration": 20.0,
			"creates_ash_bonus": true
		}
	}
	
	# Lightning spell interactions
	interaction_rules["lightning"] = {
		"crystal_caverns": {
			"effect": "electric_resonance",
			"spell_power_boost": 3.0,
			"chain_lightning": true,
			"duration": 25.0
		},
		"ice_fields": {
			"effect": "flash_freeze",
			"radius": 4,
			"freeze_duration": 8.0,
			"ice_armor_bonus": 0.5
		},
		"poison_swamps": {
			"effect": "electrolysis_purification",
			"purification_radius": 5,
			"creates_oxygen": true,
			"duration": 30.0
		},
		"volcanic": {
			"effect": "magnetic_field",
			"metal_attraction": true,
			"duration": 20.0,
			"projectile_deflection": 0.7
		}
	}
	
	# Earth spell interactions
	interaction_rules["earth_spike"] = {
		"desert_ruins": {
			"effect": "ancient_awakening",
			"reveals_artifacts": true,
			"time_magic_boost": 1.8,
			"duration": 60.0
		},
		"crystal_caverns": {
			"effect": "crystal_growth",
			"creates_crystals": true,
			"mana_regeneration": 2.0,
			"duration": 45.0
		},
		"volcanic": {
			"effect": "lava_channel",
			"creates_lava_flow": true,
			"fire_damage_boost": 1.6,
			"duration": 40.0
		},
		"plains": {
			"effect": "fertile_ground",
			"healing_bonus": 1.4,
			"nature_magic_boost": 1.5,
			"duration": 35.0
		}
	}
	
	# Frost spell interactions
	interaction_rules["frost"] = {
		"fire_caves": {
			"effect": "thermal_shock",
			"radius": 3,
			"damage_multiplier": 2.0,
			"creates_obsidian": true,
			"duration": 15.0
		},
		"poison_swamps": {
			"effect": "frozen_toxins",
			"preserves_area": true,
			"creates_safe_zone": true,
			"duration": 50.0
		},
		"volcanic": {
			"effect": "rapid_cooling",
			"creates_rock_platforms": true,
			"temperature_control": true,
			"duration": 30.0
		},
		"ice_fields": {
			"effect": "absolute_zero",
			"time_dilation": 0.5,
			"ice_magic_mastery": 2.5,
			"duration": 20.0
		}
	}
	
	# Nature spell interactions
	interaction_rules["nature_magic"] = {
		"dark_forest": {
			"effect": "forest_communion",
			"reveals_secrets": true,
			"stealth_bonus": 2.0,
			"duration": 60.0
		},
		"poison_swamps": {
			"effect": "bio_remediation",
			"purifies_toxins": true,
			"creates_healing_blooms": true,
			"duration": 90.0
		},
		"plains": {
			"effect": "growth_acceleration",
			"resource_generation": true,
			"nature_harmony": 2.0,
			"duration": 120.0
		},
		"desert_ruins": {
			"effect": "oasis_creation",
			"creates_water_source": true,
			"life_magic_boost": 1.8,
			"duration": 180.0
		}
	}

# Handle enhanced spell casting events (Phase 5)
func _on_spell_cast(spell_data: Dictionary):
	if not spell_data.has("spell_type") or not spell_data.has("position"):
		return
	
	var spell_type = spell_data["spell_type"]
	var cast_position = spell_data["position"]
	
	# Convert Vector2 to Vector2i for environment checking
	var cast_position_i = Vector2i(int(cast_position.x), int(cast_position.y))
	
	# Get environment type at cast position
	var environment_type = _get_environment_type_at_position(cast_position_i)
	
	if environment_type == "":
		return
	
	# Check for interaction rules
	if spell_type in interaction_rules:
		var spell_rules = interaction_rules[spell_type]
		if environment_type in spell_rules:
			var interaction_data = spell_rules[environment_type]
			_trigger_environment_interaction(spell_type, environment_type, cast_position_i, interaction_data)

# Fallback handler for basic spell signal (backward compatibility)
func _on_spell_cast_basic(spell_name: String, damage: float):
	# Convert basic spell signal to enhanced format
	var spell_data = {
		"spell_type": spell_name.to_lower(),
		"damage": damage,
		"position": Vector2i.ZERO,  # No position data available from basic signal
		"timestamp": Time.get_ticks_msec() / 1000.0
	}
	
	# Only process if we have valid position data (would need to be set elsewhere)
	if spell_data["position"] != Vector2i.ZERO:
		_on_spell_cast(spell_data)

# Trigger environmental interaction
func _trigger_environment_interaction(spell_type: String, environment_type: String, position: Vector2i, interaction_data: Dictionary):
	var interaction = EnvironmentInteraction.new()
	interaction.spell_type = spell_type
	interaction.environment_type = environment_type
	interaction.position = position
	interaction.effect_data = interaction_data.duplicate(true)
	interaction.duration = interaction_data.get("duration", 30.0)
	interaction.effect_type = interaction_data.get("effect", "unknown")
	
	# Add to active effects
	active_effects.append(interaction)
	
	# Apply immediate effects
	_apply_interaction_effects(interaction)
	
	# Emit signal
	environment_interaction_triggered.emit(interaction)

# Apply interaction effects
func _apply_interaction_effects(interaction: EnvironmentInteraction):
	var effect_data = interaction.effect_data
	var position = interaction.position
	
	# Spell power modifications
	if effect_data.has("spell_power_boost"):
		_apply_spell_power_boost(position, effect_data["spell_power_boost"], interaction.duration)
	
	# Area effects
	if effect_data.has("radius"):
		_apply_area_effect(position, effect_data["radius"], interaction)
	
	# Environmental modifications
	if effect_data.has("creates_water"):
		_create_water_at_position(position)
	
	if effect_data.has("creates_crystals"):
		_create_crystals_at_position(position)
	
	if effect_data.has("purifies_area"):
		_purify_area(position, effect_data.get("purification_radius", 2))
	
	# Magical enhancement zones
	if effect_data.has("mana_regeneration"):
		_create_mana_regeneration_zone(position, effect_data["mana_regeneration"], interaction.duration)
	
	if effect_data.has("healing_bonus"):
		_create_healing_zone(position, effect_data["healing_bonus"], interaction.duration)

# Get environment type at world position
func _get_environment_type_at_position(world_position: Vector2i) -> String:
	# This would typically query the chunk generator or world data
	# For now, we'll use a simplified approach
	
	# Check if we have access to chunk data
	if not GameManager or not GameManager.has_method("get_biome_at_position"):
		return ""
	
	return GameManager.get_biome_at_position(world_position)

# Apply spell power boost in area
func _apply_spell_power_boost(position: Vector2i, boost_multiplier: float, duration: float):
	magical_enhancement_activated.emit(position, "spell_power_boost")
	
	# This would typically modify player stats or create enhancement zones
	if GameEvents:
		GameEvents.emit_signal("magical_enhancement_applied", {
			"type": "spell_power",
			"multiplier": boost_multiplier,
			"position": position,
			"duration": duration
		})

# Apply area-based effects
func _apply_area_effect(center_position: Vector2i, radius: int, interaction: EnvironmentInteraction):
	var effect_type = interaction.effect_type
	var effect_data = interaction.effect_data
	
	# Performance safety: limit radius to prevent excessive calculations
	var safe_radius = min(radius, 10)  # Max 10 tile radius
	
	# Calculate affected positions
	var affected_positions: Array[Vector2i] = []
	for x in range(-safe_radius, safe_radius + 1):
		for y in range(-safe_radius, safe_radius + 1):
			var distance = sqrt(x * x + y * y)
			if distance <= safe_radius:
				affected_positions.append(Vector2i(center_position.x + x * 32, center_position.y + y * 32))
	
	# Apply effects to each position
	for pos in affected_positions:
		match effect_type:
			"steam_explosion":
				_create_steam_effect(pos, effect_data.get("damage_multiplier", 1.0))
			"toxic_ignition":
				_create_toxic_fire(pos, effect_data.get("damage_over_time", 1.0))
			"flash_freeze":
				_create_freeze_zone(pos, effect_data.get("freeze_duration", 5.0))
			"thermal_shock":
				_create_thermal_shock(pos, effect_data.get("damage_multiplier", 1.5))

# Environmental modification functions
func _create_water_at_position(position: Vector2i):
	# Modify terrain to create water tiles
	if GameEvents:
		GameEvents.emit_signal("terrain_modified", {
			"position": position,
			"new_type": "water",
			"source": "spell_interaction"
		})

func _create_crystals_at_position(position: Vector2i):
	# Create magical crystal formations
	if GameEvents:
		GameEvents.emit_signal("magical_structure_created", {
			"type": "arcane_crystal",
			"position": position,
			"properties": {"mana_regeneration": 1.5}
		})

func _purify_area(center_position: Vector2i, radius: int):
	# Remove negative environmental effects
	if GameEvents:
		GameEvents.emit_signal("area_purified", {
			"center": center_position,
			"radius": radius,
			"removes": ["poison", "corruption", "darkness"]
		})

func _create_mana_regeneration_zone(position: Vector2i, regeneration_rate: float, duration: float):
	magical_enhancement_activated.emit(position, "mana_regeneration")
	
	if GameEvents:
		GameEvents.emit_signal("enhancement_zone_created", {
			"type": "mana_regeneration",
			"position": position,
			"rate": regeneration_rate,
			"duration": duration
		})

func _create_healing_zone(position: Vector2i, healing_bonus: float, duration: float):
	magical_enhancement_activated.emit(position, "healing_zone")
	
	if GameEvents:
		GameEvents.emit_signal("enhancement_zone_created", {
			"type": "healing",
			"position": position,
			"bonus": healing_bonus,
			"duration": duration
		})

# Effect creation functions
func _create_steam_effect(position: Vector2i, damage_multiplier: float):
	if GameEvents:
		GameEvents.emit_signal("particle_effect_created", {
			"type": "steam_explosion",
			"position": position,
			"damage_multiplier": damage_multiplier
		})

func _create_toxic_fire(position: Vector2i, dot_damage: float):
	if GameEvents:
		GameEvents.emit_signal("persistent_effect_created", {
			"type": "toxic_fire",
			"position": position,
			"damage_per_second": dot_damage,
			"duration": 15.0
		})

func _create_freeze_zone(position: Vector2i, freeze_duration: float):
	if GameEvents:
		GameEvents.emit_signal("status_effect_zone_created", {
			"type": "freeze",
			"position": position,
			"duration": freeze_duration,
			"movement_penalty": 0.8
		})

func _create_thermal_shock(position: Vector2i, damage_multiplier: float):
	if GameEvents:
		GameEvents.emit_signal("instant_effect_triggered", {
			"type": "thermal_shock",
			"position": position,
			"damage_multiplier": damage_multiplier,
			"effect": "brittle_terrain"
		})

# Cleanup expired effects
func _cleanup_expired_effects():
	var current_time = Time.get_ticks_msec() / 1000.0
	var expired_effects: Array[EnvironmentInteraction] = []
	
	for effect in active_effects:
		if current_time - effect.timestamp > effect.duration:
			expired_effects.append(effect)
	
	# Remove expired effects
	for expired in expired_effects:
		active_effects.erase(expired)
		environment_effect_expired.emit(expired.effect_type)

# Get active effects at position
func get_active_effects_at_position(position: Vector2i, radius: int = 1) -> Array[EnvironmentInteraction]:
	var nearby_effects: Array[EnvironmentInteraction] = []
	
	for effect in active_effects:
		var distance = position.distance_to(effect.position)
		if distance <= radius * 32:  # Convert to world units
			nearby_effects.append(effect)
	
	return nearby_effects

# Check if position has specific enhancement
func has_enhancement_at_position(position: Vector2i, enhancement_type: String) -> bool:
	var nearby_effects = get_active_effects_at_position(position, 2)
	
	for effect in nearby_effects:
		if effect.effect_data.has(enhancement_type):
			return true
	
	return false

# Get enhancement value at position
func get_enhancement_value(position: Vector2i, enhancement_type: String) -> float:
	var nearby_effects = get_active_effects_at_position(position, 2)
	var total_value = 0.0
	
	for effect in nearby_effects:
		if effect.effect_data.has(enhancement_type):
			total_value += effect.effect_data[enhancement_type]
	
	return total_value
