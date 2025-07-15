# **Phase 3.5b: Modular Enemy Data & Abilities System**

## **Overview**
Transform your solid Enemy.gd foundation into a modular, data-driven system with individual enemy types, abilities, and .tres data files. This builds on your existing contact damage, wave scaling, and AI while adding sophisticated enemy behaviors.

## **Goals**
✅ **Enemy Data Resources**: Individual .tres files for each enemy type  
✅ **Modular Enemy Abilities**: Pluggable ability system with cooldowns  
✅ **Individual Enemy Scenes**: Separate .tscn files for each enemy type  
✅ **Enhanced AI Behaviors**: Different movement and attack patterns  
✅ **Preparation for 8-Element System**: Enemy elemental affinities foundation  

---

## **STEP 1: Enemy Data Resource System (45 minutes)**

### **File: `scripts/data/EnemyData.gd`**
```gdscript
# EnemyData.gd - Data-driven enemy configuration
extends Resource
class_name EnemyData

@export_group("Basic Info")
@export var enemy_name: String = "Goblin"
@export var enemy_type: String = "goblin"
@export var description: String = "A small, aggressive creature"

@export_group("Base Stats")
@export var base_health: float = 40.0
@export var base_damage: float = 8.0
@export var base_speed: float = 120.0
@export var base_xp: float = 8.0

@export_group("Behavior")
@export var ai_behavior: String = "melee_aggressive"  # melee_aggressive, ranged_kiting, support_healing
@export var attack_range: float = 50.0
@export var detection_range: float = 200.0
@export var movement_pattern: String = "direct"  # direct, circling, hit_and_run

@export_group("Visual Assets")
@export var sprite_path: String = "res://assets/sprites/goblin2.png"
@export var sprite_scale: Vector2 = Vector2(0.5, 0.5)
@export var health_bar_offset: Vector2 = Vector2(-20, -45)

@export_group("Abilities")
@export var abilities: Array[EnemyAbility] = []
@export var passive_abilities: Array[String] = []  # "regeneration", "armor", "berserker"

@export_group("Audio")
@export var death_sound: String = "enemy_death_small"
@export var attack_sound: String = "enemy_attack_melee"
@export var hurt_sound: String = "enemy_hurt_generic"

@export_group("Elemental System (Phase 7 Ready)")
@export var elemental_affinity: String = "none"  # fire, water, earth, air, etc.
@export var resistances: Dictionary = {}  # "fire": 0.5, "water": 1.5
@export var weaknesses: Dictionary = {}

func validate() -> bool:
    """Validate enemy data for completeness"""
    var is_valid = true
    
    if enemy_name.is_empty():
        push_error("EnemyData: enemy_name cannot be empty")
        is_valid = false
    
    if base_health <= 0:
        push_error("EnemyData: base_health must be > 0")
        is_valid = false
    
    if not ResourceLoader.exists(sprite_path):
        push_warning("EnemyData: sprite_path does not exist: " + sprite_path)
    
    return is_valid

func get_ability_by_name(ability_name: String) -> EnemyAbility:
    """Get specific ability by name"""
    for ability in abilities:
        if ability and ability.ability_name == ability_name:
            return ability
    return null

func has_passive_ability(passive_name: String) -> bool:
    """Check if enemy has specific passive ability"""
    return passive_name in passive_abilities
```

### **File: `scripts/data/AbilityData.gd`** (Based on your proven system)
```gdscript
# AbilityData.gd - Enhanced ability data resource (based on proven past system)
extends Resource
class_name AbilityData

# Core ability properties (from your proven system)
@export var ability_name: String = ""
@export var ability_type: String = "basic"  # "charge", "enhanced_charge", "ranged", "speed_boost", "heal", "teleport"
@export var ability_description: String = ""

# Timing and availability
@export var cooldown_time: float = 3.0
@export var cast_time: float = 0.0  # Channel time before ability executes
@export var range: float = 200.0
@export var min_range: float = 0.0  # Minimum range (for charge abilities)

# Damage and effects
@export var damage: int = 30
@export var damage_type: String = "physical"  # "physical", "magical", "elemental"
@export var element_type: String = "none"  # "fire", "ice", "lightning", "earth", "wind"

# Movement abilities (charge, teleport) - Enhanced from your system
@export var charge_speed: float = 400.0
@export var charge_damage_radius: float = 50.0
@export var knockback_force: float = 0.0

# Enhanced charge system properties (from your proven implementation)
@export var warning_duration: float = 1.0  # Time to show warning before charge
@export var warning_color: Color = Color.ORANGE_RED  # Warning phase color
@export var impact_color: Color = Color.RED  # Impact phase color
@export var aoe_damage_multiplier: float = 0.7  # AOE damage as percentage of main damage
@export var enhanced_knockback_multiplier: float = 1.5  # Enhanced knockback for AOE
@export var blast_radius_multiplier: float = 1.2  # Final blast radius multiplier

# Projectile abilities (ranged)
@export var projectile_speed: float = 300.0
@export var projectile_lifetime: float = 3.0
@export var projectile_piercing: bool = false
@export var projectile_homing: bool = false
@export var projectile_explosion_radius: float = 0.0

# Buff/Debuff abilities (speed_boost, heal)
@export var effect_duration: float = 2.0
@export var speed_multiplier: float = 1.5
@export var heal_amount: int = 0
@export var heal_percentage: float = 0.0  # Heal as % of max health

# Status effects
@export var status_effects: Array[String] = []  # ["burning", "slowed", "stunned", etc.]
@export var status_duration: float = 3.0

# Visual and audio
@export var ability_color: Color = Color.WHITE
@export var cast_effect: String = ""  # Path to effect scene
@export var impact_effect: String = ""  # Path to impact effect
@export var sound_effect: String = ""  # Path to audio file

# AI behavior hints - CRITICAL for AI ability selection (from your proven system)
@export var ai_priority: int = 1  # Higher = more likely to use (0-10 scale)
@export var use_when_health_below: float = 1.0  # Use only when health below this % (1.0 = always)
@export var use_when_health_above: float = 0.0  # Use only when health above this % (0.0 = always)
@export var use_when_player_distance_min: float = 0.0
@export var use_when_player_distance_max: float = 1000.0

# Advanced properties
@export var requires_line_of_sight: bool = true
@export var can_use_while_moving: bool = true
@export var interrupts_movement: bool = false
@export var max_uses_per_combat: int = -1  # -1 = unlimited

# Quick setup functions (from your proven system)
func setup_enhanced_charge_ability(damage_val: int, speed_val: float, range_val: float, duration_val: float = 8.0, cooldown_val: float = 6.0, priority_val: int = 10):
    """Quick setup for enhanced charge abilities with AOE and warning"""
    ability_type = "enhanced_charge"
    damage = damage_val
    charge_speed = speed_val
    range = range_val
    effect_duration = duration_val
    cooldown_time = cooldown_val
    ai_priority = priority_val
    ability_color = Color.DARK_RED
    interrupts_movement = true
    charge_damage_radius = 180.0
    cast_time = 0.0  # No cast time, has warning phase instead
    requires_line_of_sight = false
    
    # Enhanced charge specific properties
    warning_duration = 1.5
    warning_color = Color.ORANGE_RED
    impact_color = Color.RED
    aoe_damage_multiplier = 0.7
    enhanced_knockback_multiplier = 1.5
    blast_radius_multiplier = 1.2

func setup_ranged_ability(damage_val: int, speed_val: float, range_val: float, cooldown_val: float = 2.5, priority_val: int = 6):
    """Quick setup for ranged abilities"""
    ability_type = "ranged"
    damage = damage_val
    projectile_speed = speed_val
    range = range_val
    cooldown_time = cooldown_val
    ai_priority = priority_val
    ability_color = Color.BLUE
    requires_line_of_sight = true
    projectile_lifetime = 3.0
    cast_time = 0.2  # Aiming time

func validate() -> bool:
    """Enhanced validation from your proven system"""
    if ability_name.is_empty():
        return false
    if ability_type.is_empty():
        return false
    if cooldown_time < 0:
        return false
    if ai_priority < 0:
        return false
    return true

func is_valid_ability() -> bool:
    """Alias for validate() to match your existing code"""
    return validate()
```

---

## **STEP 2: Create Enemy Data Files (30 minutes)**

Create these .tres files in `data/enemies/`:

### **File: `data/enemies/goblin_data.tres`**
```tres
[gd_resource type="EnemyData" script_class="EnemyData" format=3]

[resource]
enemy_name = "Goblin Warrior"
enemy_type = "goblin"
description = "Small, aggressive warrior with basic melee attacks"
base_health = 40.0
base_damage = 8.0
base_speed = 120.0
base_xp = 8.0
ai_behavior = "melee_aggressive"
attack_range = 50.0
detection_range = 200.0
movement_pattern = "direct"
sprite_path = "res://assets/sprites/goblin2.png"
sprite_scale = Vector2(0.5, 0.5)
health_bar_offset = Vector2(-20, -45)
abilities = []
passive_abilities = []
death_sound = "enemy_death_small"
attack_sound = "enemy_attack_melee"
hurt_sound = "enemy_hurt_generic"
elemental_affinity = "earth"
resistances = {}
weaknesses = {"fire": 1.3}
```

### **File: `data/enemies/wizard_data.tres`**
```tres
[gd_resource type="EnemyData" script_class="EnemyData" format=3]

[resource]
enemy_name = "Dark Wizard"
enemy_type = "wizard"
description = "Magical enemy with ranged attacks and teleportation"
base_health = 60.0
base_damage = 25.0
base_speed = 100.0
base_xp = 25.0
ai_behavior = "ranged_kiting"
attack_range = 300.0
detection_range = 350.0
movement_pattern = "hit_and_run"
sprite_path = "res://assets/sprites/evil_wizard_cut-removebg-preview.png"
sprite_scale = Vector2(0.5, 0.5)
health_bar_offset = Vector2(-20, -45)
abilities = []  # Will add abilities below
passive_abilities = ["mana_shield"]
death_sound = "enemy_death_magic"
attack_sound = "enemy_attack_magic"
hurt_sound = "enemy_hurt_magic"
elemental_affinity = "dark"
resistances = {"dark": 0.5, "arcane": 0.7}
weaknesses = {"light": 1.5}
```

### **File: `data/abilities/goblin_slash.tres`**
```tres
[gd_resource type="EnemyAbility" script_class="EnemyAbility" format=3]

[resource]
ability_name = "Goblin Slash"
description = "Quick melee slash attack"
ability_type = "attack"
cooldown = 1.5
range = 60.0
damage_multiplier = 1.0
cast_time = 0.3
requires_line_of_sight = true
target_type = "player"
area_of_effect = 0.0
max_targets = 1
knockback_force = 50.0
status_effects = []
effect_duration = 0.0
cast_animation = "slash"
cast_sound = "goblin_attack"
```

### **File: `data/abilities/wizard_fireball.tres`** (Based on your proven format)
```tres
[gd_resource type="AbilityData" script_class="AbilityData" format=3]

[resource]
ability_name = "wizard_fireball"
ability_type = "ranged"
ability_description = "Wizard casts a powerful fireball that explodes on impact"
cooldown_time = 3.0
cast_time = 0.5
range = 500.0
min_range = 80.0
damage = 40
damage_type = "magical"
element_type = "fire"
projectile_speed = 350.0
projectile_lifetime = 3.5
projectile_piercing = false
projectile_homing = false
projectile_explosion_radius = 80.0
effect_duration = 2.0
status_effects = ["burning"]
status_duration = 4.0
ability_color = Color(1, 0.4, 0.1, 1)
ai_priority = 8
use_when_health_below = 1.0
use_when_health_above = 0.0
use_when_player_distance_min = 100.0
use_when_player_distance_max = 600.0
requires_line_of_sight = true
can_use_while_moving = false
interrupts_movement = true
max_uses_per_combat = -1
```

### **File: `data/abilities/golem_devastator.tres`** (Enhanced charge from your system)
```tres
[gd_resource type="AbilityData" script_class="AbilityData" format=3]

[resource]
ability_name = "golem_devastator"
ability_type = "enhanced_charge"
ability_description = "Golem charges with devastating force, creating an AOE blast"
cooldown_time = 22.5
cast_time = 0.0
range = 920.0
min_range = 100.0
damage = 85
damage_type = "physical"
element_type = "earth"
charge_speed = 960.0
charge_damage_radius = 140.0
knockback_force = 400.0
effect_duration = 8.0
ability_color = Color(0.4, 0.2, 0.1, 1)
ai_priority = 10
warning_duration = 1.0
warning_color = Color(1, 0.7, 0.3, 1)
impact_color = Color(1, 0.2, 0.2, 1)
aoe_damage_multiplier = 0.7
enhanced_knockback_multiplier = 1.5
blast_radius_multiplier = 1.2
use_when_health_below = 1.0
use_when_health_above = 0.0
use_when_player_distance_min = 120.0
use_when_player_distance_max = 1000.0
requires_line_of_sight = false
can_use_while_moving = true
interrupts_movement = true
max_uses_per_combat = -1
```

---

## **STEP 3: Enhanced Enemy AI Controller (60 minutes)**

### **File: `scripts/enemies/EnemyAIController.gd`**
```gdscript
# EnemyAIController.gd - Modular AI behavior system
extends Node
class_name EnemyAIController

var enemy: Node  # Reference to parent enemy
var enemy_data: EnemyData
var current_target: Node
var state: String = "idle"  # idle, chasing, attacking, retreating, casting
var state_timer: float = 0.0

# AI Behavior parameters
var last_ability_cast_time: Dictionary = {}
var preferred_distance: float = 50.0
var retreat_threshold: float = 0.25  # Retreat when health < 25%

# Pathfinding and movement
var desired_position: Vector2
var movement_timer: float = 0.0
var position_update_interval: float = 0.2  # Update desired position every 200ms

signal ai_state_changed(new_state: String)
signal ability_cast_requested(ability: EnemyAbility, target_position: Vector2)

func setup(parent_enemy: Node, data: EnemyData):
    """Initialize AI controller"""
    enemy = parent_enemy
    enemy_data = data
    
    # Set preferred distance based on AI behavior
    match enemy_data.ai_behavior:
        "melee_aggressive":
            preferred_distance = enemy_data.attack_range * 0.8
        "ranged_kiting":
            preferred_distance = enemy_data.attack_range * 0.7
        "support_healing":
            preferred_distance = enemy_data.attack_range * 0.9
    
    print("🧠 AI Controller setup for ", enemy_data.enemy_name, " (", enemy_data.ai_behavior, ")")

func _ready():
    set_process(true)

func _process(delta):
    if not enemy or not enemy_data:
        return
    
    state_timer += delta
    movement_timer += delta
    
    # Update AI state
    update_ai_state(delta)
    
    # Execute current behavior
    execute_current_behavior(delta)

func update_ai_state(delta: float):
    """Update AI state based on conditions"""
    var player = get_player_reference()
    if not player:
        change_state("idle")
        return
    
    var distance_to_player = enemy.global_position.distance_to(player.global_position)
    var health_percentage = enemy.current_health / enemy.max_health
    
    # State transition logic
    match state:
        "idle":
            if distance_to_player <= enemy_data.detection_range:
                change_state("chasing")
        
        "chasing":
            if distance_to_player > enemy_data.detection_range * 1.2:
                change_state("idle")
            elif distance_to_player <= enemy_data.attack_range:
                if should_retreat(health_percentage):
                    change_state("retreating")
                else:
                    change_state("attacking")
        
        "attacking":
            if distance_to_player > enemy_data.attack_range * 1.1:
                change_state("chasing")
            elif should_retreat(health_percentage):
                change_state("retreating")
        
        "retreating":
            if health_percentage > retreat_threshold * 1.5 and distance_to_player > enemy_data.attack_range:
                change_state("chasing")
        
        "casting":
            # Casting state automatically returns to previous state when done
            pass

func change_state(new_state: String):
    """Change AI state with proper cleanup"""
    if state == new_state:
        return
    
    var old_state = state
    state = new_state
    state_timer = 0.0
    
    ai_state_changed.emit(new_state)
    print("🧠 ", enemy_data.enemy_name, " AI: ", old_state, " → ", new_state)

func execute_current_behavior(delta: float):
    """Execute behavior for current state"""
    match state:
        "idle":
            execute_idle_behavior()
        "chasing":
            execute_chase_behavior()
        "attacking":
            execute_attack_behavior()
        "retreating":
            execute_retreat_behavior()
        "casting":
            execute_casting_behavior()

func execute_idle_behavior():
    """Idle behavior - minimal movement"""
    enemy.velocity = Vector2.ZERO

func execute_chase_behavior():
    """Chase the player"""
    var player = get_player_reference()
    if not player:
        return
    
    update_desired_position_for_chase(player.global_position)
    move_towards_desired_position()

func execute_attack_behavior():
    """Attack behavior - use abilities"""
    var player = get_player_reference()
    if not player:
        return
    
    # Position for optimal attack
    update_desired_position_for_attack(player.global_position)
    move_towards_desired_position()
    
    # Try to cast abilities
    attempt_ability_cast(player)

func execute_retreat_behavior():
    """Retreat from player"""
    var player = get_player_reference()
    if not player:
        return
    
    # Move away from player
    var retreat_direction = (enemy.global_position - player.global_position).normalized()
    desired_position = enemy.global_position + retreat_direction * 200.0
    move_towards_desired_position()

func execute_casting_behavior():
    """Casting state - minimal movement"""
    enemy.velocity = enemy.velocity * 0.3  # Slow movement while casting

func update_desired_position_for_chase(player_pos: Vector2):
    """Update desired position for chasing"""
    if movement_timer < position_update_interval:
        return
    
    movement_timer = 0.0
    
    match enemy_data.movement_pattern:
        "direct":
            desired_position = player_pos
        "circling":
            var angle = Time.get_ticks_msec() * 0.001  # Circling motion
            var circle_offset = Vector2(cos(angle), sin(angle)) * preferred_distance
            desired_position = player_pos + circle_offset
        "hit_and_run":
            # Get close, then retreat periodically
            if state_timer > 3.0:  # Retreat every 3 seconds
                var retreat_dir = (enemy.global_position - player_pos).normalized()
                desired_position = player_pos + retreat_dir * preferred_distance * 1.5
                state_timer = 0.0
            else:
                desired_position = player_pos

func update_desired_position_for_attack(player_pos: Vector2):
    """Update desired position for attacking"""
    if movement_timer < position_update_interval:
        return
    
    movement_timer = 0.0
    
    match enemy_data.ai_behavior:
        "melee_aggressive":
            # Get close for melee
            desired_position = player_pos
        "ranged_kiting":
            # Maintain distance
            var direction_to_player = (player_pos - enemy.global_position).normalized()
            desired_position = player_pos - direction_to_player * preferred_distance
        "support_healing":
            # Stay at medium range
            var direction_to_player = (player_pos - enemy.global_position).normalized()
            desired_position = player_pos - direction_to_player * (preferred_distance * 0.8)

func move_towards_desired_position():
    """Move towards the desired position"""
    var direction = (desired_position - enemy.global_position).normalized()
    var movement_speed = enemy_data.base_speed * enemy.movement_speed_multiplier if enemy.has_method("get_movement_speed_multiplier") else enemy_data.base_speed
    
    enemy.velocity = direction * movement_speed

func attempt_ability_cast(target: Node):
    """Try to cast available abilities"""
    for ability in enemy_data.abilities:
        if can_cast_ability(ability, target):
            cast_ability(ability, target)
            break  # Only cast one ability at a time

func can_cast_ability(ability: EnemyAbility, target: Node) -> bool:
    """Check if ability can be cast"""
    if not ability:
        return false
    
    # Check cooldown
    var last_cast = last_ability_cast_time.get(ability.ability_name, 0.0)
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_cast < ability.cooldown:
        return false
    
    # Check range
    if not ability.can_cast(enemy.global_position, target.global_position):
        return false
    
    # Check line of sight
    if ability.requires_line_of_sight:
        if not has_line_of_sight(target):
            return false
    
    return true

func cast_ability(ability: EnemyAbility, target: Node):
    """Cast an ability"""
    last_ability_cast_time[ability.ability_name] = Time.get_unix_time_from_system()
    
    # Change to casting state
    change_state("casting")
    
    # Emit signal for ability execution
    ability_cast_requested.emit(ability, target.global_position)
    
    # Return to previous state after cast time
    var cast_timer = Timer.new()
    cast_timer.wait_time = ability.cast_time
    cast_timer.one_shot = true
    cast_timer.timeout.connect(_on_cast_complete)
    enemy.add_child(cast_timer)
    cast_timer.start()
    
    print("✨ ", enemy_data.enemy_name, " casting ", ability.ability_name)

func _on_cast_complete():
    """Handle completion of ability cast"""
    if state == "casting":
        change_state("attacking")  # Return to attacking
    
    # Clean up timer
    var timer = get_children().filter(func(child): return child is Timer and child.is_stopped())
    for t in timer:
        t.queue_free()

func should_retreat(health_percentage: float) -> bool:
    """Determine if enemy should retreat"""
    return health_percentage < retreat_threshold

func has_line_of_sight(target: Node) -> bool:
    """Check if enemy has line of sight to target"""
    var space_state = enemy.get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(
        enemy.global_position, 
        target.global_position
    )
    query.exclude = [enemy]
    query.collision_mask = 4  # Environment layer
    
    var result = space_state.intersect_ray(query)
    return result.is_empty()  # Clear line of sight if no collision

func get_player_reference() -> Node:
    """Get reference to player"""
    if GameManager and GameManager.has_method("get_player"):
        return GameManager.get_player()
    elif GameManager and GameManager.player_reference:
        return GameManager.player_reference
    else:
        var players = enemy.get_tree().get_nodes_in_group("players")
        return players[0] if players.size() > 0 else null
```

---

## **STEP 4: Enhanced Enemy Class (45 minutes)**

Now let's modify your existing Enemy.gd to use the modular system:

### **File: `scripts/enemies/Enemy.gd` (Enhanced Version)**
```gdscript
# Enemy.gd - Enhanced modular enemy system
extends CharacterBody2D
class_name Enemy

# Data-driven configuration
@export var enemy_data_resource: EnemyData
var enemy_data: EnemyData

# Core components
var ai_controller: EnemyAIController
var ability_handler: EnemyAbilityHandler

# Your existing variables (preserved)
var enemy_type: String = "goblin"
var enemy_id: String = ""
var max_health: float
var damage: float
var movement_speed: float
var xp_reward: float
var current_health: float
var wave_multipliers: Dictionary = {}
var wave_number: int = 1
var is_dead: bool = false

# Your existing contact damage system (preserved)
var contact_damage_immunity_duration: float = 1.0
var last_contact_damage_time: float = 0.0
var damage_area: Area2D

# Visual components (preserved)
var health_bar: ProgressBar
var damage_number_scene: PackedScene
var has_damage_number_created: bool = false

# Enhanced features
var movement_speed_multiplier: float = 1.0
var damage_multiplier: float = 1.0

signal enemy_initialized(enemy: Enemy)
signal enemy_damaged(damage_amount: float, remaining_health: float)
signal enemy_death(enemy: Enemy)
signal ability_used(ability_name: String, target_position: Vector2)

func _ready():
    # Load enemy data if not set
    if not enemy_data and enemy_data_resource:
        enemy_data = enemy_data_resource
    elif not enemy_data:
        # Fallback to load by type
        load_enemy_data_by_type(enemy_type)
    
    # Initialize with loaded data
    if enemy_data:
        initialize_from_data()
    else:
        # Your existing fallback system
        initialize_basic_enemy()
    
    # Your existing setup
    setup_contact_damage_system()
    setup_components()

func load_enemy_data_by_type(type: String):
    """Load enemy data from .tres file"""
    var data_path = "res://data/enemies/" + type + "_data.tres"
    if ResourceLoader.exists(data_path):
        enemy_data = load(data_path)
        print("✅ Loaded enemy data: ", data_path)
    else:
        push_error("Enemy data not found: " + data_path)

func initialize_from_data():
    """Initialize enemy using EnemyData resource"""
    if not enemy_data or not enemy_data.validate():
        push_error("Invalid enemy data")
        return
    
    # Set basic properties
    enemy_type = enemy_data.enemy_type
    enemy_id = enemy_type + "_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())
    
    # Set stats
    max_health = enemy_data.base_health
    damage = enemy_data.base_damage
    movement_speed = enemy_data.base_speed
    xp_reward = enemy_data.base_xp
    current_health = max_health
    
    # Add to group
    add_to_group("enemies")
    set_collision_layers()
    
    print("👹 Enemy initialized from data: ", enemy_data.enemy_name, " (", enemy_type, ")")

func setup_components():
    """Setup AI and ability components"""
    # Setup AI Controller
    ai_controller = EnemyAIController.new()
    ai_controller.name = "AIController"
    add_child(ai_controller)
    ai_controller.setup(self, enemy_data)
    ai_controller.ability_cast_requested.connect(_on_ability_cast_requested)
    
    # Setup Ability Handler
    ability_handler = EnemyAbilityHandler.new()
    ability_handler.name = "AbilityHandler"
    add_child(ability_handler)
    ability_handler.setup(self, enemy_data)
    ability_handler.ability_executed.connect(_on_ability_executed)
    
    # Setup visuals
    setup_data_driven_visuals()

func setup_data_driven_visuals():
    """Setup visuals using enemy data"""
    var sprite = get_node_or_null("EnemySprite")
    if sprite and enemy_data:
        # Load sprite from data
        if ResourceLoader.exists(enemy_data.sprite_path):
            sprite.texture = load(enemy_data.sprite_path)
            sprite.scale = enemy_data.sprite_scale
        else:
            create_fallback_visuals(sprite)
    
    setup_health_bar()

# Your existing wave scaling integration (preserved)
func initialize_with_wave_scaling(type: String, wave_multipliers_dict: Dictionary):
    enemy_type = type
    wave_multipliers = wave_multipliers_dict
    wave_number = wave_multipliers_dict.get("wave", 1)
    
    # Load data first
    load_enemy_data_by_type(type)
    if enemy_data:
        initialize_from_data()
    else:
        initialize_basic_enemy()
    
    # Apply wave scaling
    apply_wave_scaling()
    
    # Setup everything else
    setup_components()
    enemy_initialized.emit(self)

func apply_wave_scaling():
    """Apply wave-based scaling to stats"""
    if wave_multipliers.is_empty():
        return
    
    max_health *= wave_multipliers.get("health", 1.0)
    damage *= wave_multipliers.get("damage", 1.0)
    movement_speed *= wave_multipliers.get("speed", 1.0)
    current_health = max_health
    
    # Update multipliers for AI
    movement_speed_multiplier = wave_multipliers.get("speed", 1.0)
    damage_multiplier = wave_multipliers.get("damage", 1.0)
    
    print("👹 Wave ", wave_number, " scaling applied to ", enemy_data.enemy_name if enemy_data else enemy_type)

func _physics_process(delta):
    if is_dead:
        return
    
    # Let AI controller handle movement
    if ai_controller:
        move_and_slide()

# Your existing contact damage and death systems (preserved)
func setup_contact_damage_system():
    # ... your existing contact damage code unchanged
    pass

func take_damage(amount: float, damage_source: String = "") -> bool:
    # ... your existing damage code unchanged
    return true

func die():
    # ... your existing death code unchanged
    pass

# New ability system integration
func _on_ability_cast_requested(ability: EnemyAbility, target_position: Vector2):
    """Handle AI requesting to cast an ability"""
    if ability_handler:
        ability_handler.cast_ability(ability, target_position)

func _on_ability_executed(ability_name: String, target_position: Vector2, success: bool):
    """Handle ability execution"""
    if success:
        ability_used.emit(ability_name, target_position)
        print("⚡ ", enemy_data.enemy_name if enemy_data else enemy_type, " used ", ability_name)

# Helper methods for AI
func get_movement_speed_multiplier() -> float:
    return movement_speed_multiplier

func get_damage_multiplier() -> float:
    return damage_multiplier

# Your existing utility methods (preserved)
func get_enemy_info() -> Dictionary:
    var info = {
        "type": enemy_type,
        "id": enemy_id,
        "current_health": current_health,
        "max_health": max_health,
        "damage": damage,
        "speed": movement_speed,
        "xp_reward": xp_reward,
        "wave_number": wave_number,
        "is_dead": is_dead,
        "wave_multipliers": wave_multipliers
    }
    
    if enemy_data:
        info.merge({
            "name": enemy_data.enemy_name,
            "ai_behavior": enemy_data.ai_behavior,
            "abilities": enemy_data.abilities.size(),
            "elemental_affinity": enemy_data.elemental_affinity
        })
    
    return info
```

---

## **STEP 5: Ability Handler System (30 minutes)**

### **File: `scripts/enemies/EnemyAbilities.gd`** (Enhanced from your proven system)
```gdscript
# EnemyAbilities.gd - Enhanced ability system based on proven implementation
extends Node
class_name EnemyAbilities

signal ability_used(ability_name: String)
signal ability_cooldown_finished(ability_name: String)
signal ability_cast_started(ability_name: String)
signal ability_cast_finished(ability_name: String)

# Ability management
var available_abilities: Array[AbilityData] = []
var ability_cooldowns: Dictionary = {}
var active_effects: Dictionary = {}

# References - Enhanced player detection from your proven system
var enemy: Node
var player: Node = null
var player_last_found_time: float = 0.0
var player_search_interval: float = 0.5

# State management
var is_casting: bool = false
var current_cast_ability: AbilityData = null
var cast_time_remaining: float = 0.0
var is_charging: bool = false
var charge_target_position: Vector2
var original_speed: float = 0.0

# Enhanced charge system from your proven implementation
var is_warning_phase: bool = false
var warning_indicator: Node2D = null
var aoe_indicator: Node2D = null
var warning_time_remaining: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO
var charge_start_time: float = 0.0
var tracking_lock_duration: float = 0.2

# Damage control from your proven system
var damage_applied_this_charge: bool = false
var last_aoe_damage_time: float = 0.0
var aoe_damage_interval: float = 0.5  # Maximum once per 0.5 seconds

# Performance optimization
var last_ability_attempt: float = 0.0
var ability_attempt_cooldown: float = 0.5
var debug_mode: bool = false

func initialize(abilities: Array, enemy_ref: Node):
    enemy = enemy_ref
    original_speed = enemy.movement_speed if enemy.has_method("get_movement_speed") else 120.0
    
    # Convert Array to typed Array[AbilityData]
    available_abilities.clear()
    for ability in abilities:
        if ability is AbilityData:
            available_abilities.append(ability as AbilityData)
    
    # Initialize cooldowns
    for ability in available_abilities:
        if ability.validate():
            ability_cooldowns[ability.ability_name] = 0.0
    
    # Enhanced player search from your system
    find_player_reference_bulletproof()
    
    print("⚡ Enhanced EnemyAbilities initialized with ", available_abilities.size(), " abilities")

func _process(delta):
    update_cooldowns(delta)
    update_active_effects(delta)
    update_casting(delta)
    update_enhanced_charge_system(delta)  # From your proven system
    
    # Enhanced player detection
    var current_time = Time.get_ticks_msec() / 1000.0
    if current_time - player_last_found_time > player_search_interval:
        find_player_reference_bulletproof()
        player_last_found_time = current_time
    
    # Try to use abilities periodically
    if current_time - last_ability_attempt > ability_attempt_cooldown:
        try_use_preferred_ability()
        last_ability_attempt = current_time

func find_player_reference_bulletproof():
    """Enhanced player detection from your proven system"""
    if player and is_instance_valid(player):
        return
    
    # Method 1: Group lookup
    var group_nodes = get_tree().get_nodes_in_group("players")
    for node in group_nodes:
        if node and is_instance_valid(node) and node.has_method("take_damage"):
            player = node
            return
    
    # Method 2: Alternative group name
    group_nodes = get_tree().get_nodes_in_group("player")
    for node in group_nodes:
        if node and is_instance_valid(node) and node.has_method("take_damage"):
            player = node
            return
    
    # Method 3: GameManager reference
    if GameManager and GameManager.has_method("get_player"):
        var found_player = GameManager.get_player()
        if found_player and is_instance_valid(found_player):
            player = found_player
            return

func try_use_preferred_ability():
    """Enhanced ability selection from your proven system"""
    if not player or not is_instance_valid(player):
        return
    
    if not enemy or not is_instance_valid(enemy):
        return
    
    if is_casting or is_charging or is_warning_phase:
        return
    
    # Get best ability to use
    var preferred_ability = get_preferred_ability_enhanced()
    if preferred_ability.is_empty():
        return
    
    # Try to use it
    try_use_ability(preferred_ability)

func get_preferred_ability_enhanced() -> String:
    """Enhanced ability selection with improved charge conditions"""
    if not player or available_abilities.is_empty():
        return ""
    
    # Get distance to player
    var distance_to_player = enemy.global_position.distance_to(player.global_position)
    
    # Collect usable abilities
    var usable_abilities: Array[AbilityData] = []
    
    for ability in available_abilities:
        if can_use_ability_enhanced(ability, distance_to_player):
            usable_abilities.append(ability)
    
    if usable_abilities.is_empty():
        return ""
    
    # Sort by priority (higher = better)
    usable_abilities.sort_custom(func(a, b): return a.ai_priority > b.ai_priority)
    
    return usable_abilities[0].ability_name

func can_use_ability_enhanced(ability_data: AbilityData, distance_to_player: float) -> bool:
    """Enhanced ability usage conditions from your proven system"""
    if not ability_data or not ability_data.validate():
        return false
    
    # Check cooldown
    if ability_cooldowns.get(ability_data.ability_name, 0.0) > 0:
        return false
    
    # Check distance constraints
    if distance_to_player < ability_data.use_when_player_distance_min:
        return false
    if distance_to_player > ability_data.use_when_player_distance_max:
        return false
    
    # Check health constraints
    var health_percent = enemy.get_health_percent() if enemy.has_method("get_health_percent") else 1.0
    if health_percent > ability_data.use_when_health_below:
        return false
    if health_percent < ability_data.use_when_health_above:
        return false
    
    # Type-specific enhanced checks
    match ability_data.ability_type:
        "enhanced_charge":
            return distance_to_player > 100 and distance_to_player < ability_data.range
        "charge":
            return distance_to_player > 50 and distance_to_player < 400
        "ranged":
            return distance_to_player > 100 and distance_to_player < 600
        "speed_boost":
            return not active_effects.has("speed_boost")
        "heal":
            return health_percent < 0.6
        _:
            return distance_to_player < 100

func try_use_ability(ability_name: String) -> bool:
    var ability_data = get_ability_data(ability_name)
    if not ability_data:
        return false
    
    # Enhanced charge requires warning phase (from your proven system)
    if ability_data.ability_type == "enhanced_charge":
        start_enhanced_charge_warning(ability_data)
    elif ability_data.cast_time > 0:
        start_casting(ability_data)
    else:
        execute_ability(ability_data)
    
    return true

func start_enhanced_charge_warning(ability_data: AbilityData):
    """Enhanced charge warning system from your proven implementation"""
    is_warning_phase = true
    current_cast_ability = ability_data
    warning_time_remaining = ability_data.warning_duration
    
    # Calculate charge direction (straight line to player)
    charge_direction = (player.global_position - enemy.global_position).normalized()
    
    # Create visual warning indicator
    create_charge_warning_visual(ability_data)
    
    # Visual feedback on enemy
    if enemy.has_method("get_sprite"):
        var sprite = enemy.get_sprite()
        if sprite:
            sprite.modulate = Color(1.1, 0.9, 0.8, 1.0)
    
    ability_cast_started.emit(ability_data.ability_name)
    
    print("⚠️ Enhanced charge warning started!")

func create_charge_warning_visual(ability_data: AbilityData):
    """Create visual warning indicators from your proven system"""
    # Create warning line showing charge path
    warning_indicator = Line2D.new()
    warning_indicator.name = "ChargeWarningLine"
    warning_indicator.width = 3.0
    warning_indicator.default_color = ability_data.warning_color
    
    # Calculate charge path
    var charge_distance = ability_data.range
    var end_point = enemy.global_position + (charge_direction * charge_distance)
    
    # Add points to line
    warning_indicator.add_point(Vector2.ZERO)
    warning_indicator.add_point(enemy.to_local(end_point))
    
    # Add to enemy
    enemy.add_child(warning_indicator)

func update_enhanced_charge_system(delta):
    """Enhanced charge system from your proven implementation"""
    if is_warning_phase:
        warning_time_remaining -= delta
        update_warning_visual_effects()
        
        if warning_time_remaining <= 0:
            complete_warning_phase()
    
    if is_charging:
        update_charge_physics(delta)

func complete_warning_phase():
    """Complete warning phase and start actual charge"""
    is_warning_phase = false
    
    # Remove warning indicator
    if warning_indicator:
        warning_indicator.queue_free()
        warning_indicator = null
    
    # Reset damage tracking for new charge
    damage_applied_this_charge = false
    last_aoe_damage_time = 0.0
    
    # Start actual charge
    if current_cast_ability and current_cast_ability.ability_type == "enhanced_charge":
        execute_enhanced_charge_attack(current_cast_ability)

func update_charge_physics(delta):
    """Enhanced charge physics from your proven system"""
    if not is_charging or not current_cast_ability:
        return
    
    # Enhanced tracking during charge
    if player and is_instance_valid(player):
        var current_time = Time.get_ticks_msec() / 1000.0
        var time_since_charge_start = current_time - charge_start_time
        
        # Fast tracking only during initial lock-in period
        if time_since_charge_start < tracking_lock_duration:
            var target_direction = (player.global_position - enemy.global_position).normalized()
            var lock_tracking = 5.0 * delta
            charge_direction = charge_direction.lerp(target_direction, lock_tracking)
            charge_direction = charge_direction.normalized()
    
    # Move with enhanced tracking
    enemy.velocity = charge_direction * current_cast_ability.charge_speed
    
    # Controlled AOE damage during charge
    check_charge_aoe_damage_controlled()

func check_charge_aoe_damage_controlled():
    """Controlled AOE damage from your proven system"""
    if not player or not current_cast_ability:
        return
    
    var current_time = Time.get_ticks_msec() / 1000.0
    
    # Only apply AOE damage once per interval
    if current_time - last_aoe_damage_time < aoe_damage_interval:
        return
    
    var distance_to_player = enemy.global_position.distance_to(player.global_position)
    var aoe_radius = current_cast_ability.charge_damage_radius
    
    # Apply AOE damage if player is within range
    if distance_to_player <= aoe_radius:
        var aoe_damage = int(current_cast_ability.damage * current_cast_ability.aoe_damage_multiplier)
        if player.has_method("take_damage"):
            player.take_damage(aoe_damage)
            last_aoe_damage_time = current_time
            
            print("💥 Enhanced charge AOE hit for ", aoe_damage, " damage!")
            
            # Apply knockback
            if current_cast_ability.knockback_force > 0 and player.has_method("apply_knockback"):
                var knockback_dir = (player.global_position - enemy.global_position).normalized()
                player.apply_knockback(knockback_dir * current_cast_ability.knockback_force)

func execute_enhanced_charge_attack(ability_data: AbilityData):
    """Execute enhanced charge from your proven system"""
    if not player:
        return
    
    is_charging = true
    charge_start_time = Time.get_ticks_msec() / 1000.0
    
    # Reset damage tracking for new charge
    damage_applied_this_charge = false
    last_aoe_damage_time = charge_start_time
    
    # Visual feedback
    if enemy.has_method("get_sprite"):
        var sprite = enemy.get_sprite()
        if sprite:
            sprite.modulate = ability_data.impact_color
    
    # Apply enhanced charge velocity
    enemy.velocity = charge_direction * ability_data.charge_speed
    
    # Set charge completion timer
    var charge_timer = Timer.new()
    charge_timer.wait_time = ability_data.effect_duration
    charge_timer.one_shot = true
    charge_timer.timeout.connect(func(): 
        complete_enhanced_charge_attack(ability_data)
        charge_timer.queue_free()
    )
    add_child(charge_timer)
    charge_timer.start()
    
    print("🚀💥 Enhanced charge attack started!")

func execute_ability(ability_data: AbilityData):
    """Execute ability based on type"""
    # Start cooldown
    ability_cooldowns[ability_data.ability_name] = ability_data.cooldown_time
    
    # Execute based on type
    match ability_data.ability_type:
        "enhanced_charge":
            execute_enhanced_charge_attack(ability_data)
        "ranged":
            execute_ranged_shot(ability_data)
        "speed_boost":
            execute_speed_boost(ability_data)
        "heal":
            execute_heal(ability_data)
        _:
            execute_basic_attack(ability_data)
    
    ability_used.emit(ability_data.ability_name)

func execute_ranged_shot(ability_data: AbilityData):
    """Execute ranged shot with enhanced projectile spawning"""
    if not player:
        return
    
    # Visual feedback
    if enemy.has_method("get_sprite"):
        var sprite = enemy.get_sprite()
        if sprite:
            sprite.modulate = ability_data.ability_color
            var tween = create_tween()
            tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)
    
    # Spawn enhanced projectile
    spawn_enhanced_projectile(ability_data)

func spawn_enhanced_projectile(ability_data: AbilityData):
    """Spawn enhanced projectile system"""
    # Try to find projectile scene
    var projectile_scene_path = "res://scenes/spells/EnemyProjectile.tscn"
    if not ResourceLoader.exists(projectile_scene_path):
        # Fallback to direct damage for now
        execute_fallback_ranged_attack(ability_data)
        return
    
    var projectile_scene = load(projectile_scene_path)
    var projectile = projectile_scene.instantiate()
    get_tree().current_scene.add_child(projectile)
    
    # Setup projectile
    projectile.global_position = enemy.global_position
    var direction = (player.global_position - enemy.global_position).normalized()
    
    # Enhanced projectile setup
    if projectile.has_method("setup_projectile"):
        var params = {
            "damage": ability_data.damage,
            "speed": ability_data.projectile_speed,
            "lifetime": ability_data.projectile_lifetime,
            "direction": direction,
            "explosion_radius": ability_data.projectile_explosion_radius,
            "status_effects": ability_data.status_effects,
            "status_duration": ability_data.status_duration
        }
        projectile.setup_projectile(params)
    else:
        # Basic setup
        if projectile.has_method("set_velocity"):
            projectile.set_velocity(direction * ability_data.projectile_speed)
        if projectile.has_method("set_damage"):
            projectile.set_damage(ability_data.damage)

func execute_fallback_ranged_attack(ability_data: AbilityData):
    """Fallback ranged attack when no projectile scene available"""
    if not player:
        return
    
    var distance_to_player = enemy.global_position.distance_to(player.global_position)
    var melee_range = 80.0
    
    # Only hit if in melee range (fallback behavior)
    if distance_to_player <= melee_range:
        if player.has_method("take_damage"):
            player.take_damage(ability_data.damage)
            print("🎯 Fallback ranged hit for ", ability_data.damage, " damage")

# Additional methods for speed boost, heal, etc. would follow...
func execute_speed_boost(ability_data: AbilityData):
    """Execute speed boost ability"""
    if not active_effects.has("speed_boost"):
        if enemy.has_method("set_movement_speed"):
            enemy.set_movement_speed(original_speed * ability_data.speed_multiplier)
        elif enemy.has_property("movement_speed"):
            enemy.movement_speed *= ability_data.speed_multiplier
        
        active_effects["speed_boost"] = ability_data.effect_duration
        
        # Visual feedback
        if enemy.has_method("get_sprite"):
            var sprite = enemy.get_sprite()
            if sprite:
                sprite.modulate = ability_data.ability_color

func execute_heal(ability_data: AbilityData):
    """Execute heal ability"""
    var heal_amount: int
    
    if ability_data.heal_percentage > 0:
        heal_amount = int(enemy.max_health * ability_data.heal_percentage)
    else:
        heal_amount = ability_data.heal_amount
    
    if enemy.has_method("heal"):
        enemy.heal(heal_amount)
    elif enemy.has_property("current_health"):
        var old_health = enemy.current_health
        enemy.current_health = min(enemy.max_health, enemy.current_health + heal_amount)
        var actual_heal = enemy.current_health - old_health
        
        print("💚 Healed for ", actual_heal, " HP!")

func execute_basic_attack(ability_data: AbilityData):
    """Execute basic attack ability"""
    if not player or not player.has_method("take_damage"):
        return
    
    var distance_to_player = enemy.global_position.distance_to(player.global_position)
    if distance_to_player <= ability_data.range:
        player.take_damage(ability_data.damage)
        
        # Visual feedback
        if enemy.has_method("get_sprite"):
            var sprite = enemy.get_sprite()
            if sprite:
                sprite.modulate = ability_data.ability_color
                var tween = create_tween()
                tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
        
        print("💥 Basic attack for ", ability_data.damage, " damage!")

# Utility methods from your proven system
func get_ability_data(ability_name: String) -> AbilityData:
    for ability in available_abilities:
        if ability.ability_name == ability_name:
            return ability
    return null

func update_cooldowns(delta):
    for ability_name in ability_cooldowns:
        if ability_cooldowns[ability_name] > 0:
            ability_cooldowns[ability_name] -= delta
            if ability_cooldowns[ability_name] <= 0:
                ability_cooldowns[ability_name] = 0.0
                ability_cooldown_finished.emit(ability_name)

func update_active_effects(delta):
    var effects_to_remove = []
    for effect_name in active_effects:
        active_effects[effect_name] -= delta
        if active_effects[effect_name] <= 0:
            effects_to_remove.append(effect_name)
    
    for effect_name in effects_to_remove:
        end_effect(effect_name)
        active_effects.erase(effect_name)

func update_casting(delta):
    if not is_casting:
        return
    
    cast_time_remaining -= delta
    if cast_time_remaining <= 0:
        complete_cast()

func complete_cast():
    if not current_cast_ability:
        return
    
    execute_ability(current_cast_ability)
    ability_cast_finished.emit(current_cast_ability.ability_name)
    
    is_casting = false
    current_cast_ability = null
    cast_time_remaining = 0.0

func start_casting(ability_data: AbilityData):
    is_casting = true
    current_cast_ability = ability_data
    cast_time_remaining = ability_data.cast_time
    
    # Visual feedback
    if enemy.has_method("get_sprite"):
        var sprite = enemy.get_sprite()
        if sprite:
            sprite.modulate = ability_data.ability_color
    
    ability_cast_started.emit(ability_data.ability_name)

func end_effect(effect_name: String):
    match effect_name:
        "speed_boost":
            if enemy.has_method("set_movement_speed"):
                enemy.set_movement_speed(original_speed)
            elif enemy.has_property("movement_speed"):
                enemy.movement_speed = original_speed
    
    # Reset visual
    if enemy.has_method("get_sprite"):
        var sprite = enemy.get_sprite()
        if sprite:
            sprite.modulate = Color.WHITE
```

---

## **STEP 6: Individual Enemy Scenes (30 minutes)**

Create individual .tscn files for each enemy type:

### **File: `scenes/enemies/Goblin.tscn`**
```
Goblin (Enemy)
├── EnemySprite (Sprite2D)
├── EnemyCollision (CollisionShape2D)
├── DamageArea (Area2D)
│   └── DamageCollision (CollisionShape2D)
└── HealthBarContainer (Control)
    └── HealthBar (ProgressBar)
```

**Settings for Goblin.tscn:**
- Enemy script: `res://scripts/enemies/Enemy.gd`
- Enemy Data Resource: `res://data/enemies/goblin_data.tres`
- Collision layers set appropriately
- DamageArea configured for contact damage

### **File: `scenes/enemies/Wizard.tscn`**
Similar structure but with:
- Enemy Data Resource: `res://data/enemies/wizard_data.tres`
- Potentially different sprite scale
- Different collision size

---

## **SUCCESS CRITERIA**

✅ **Data-Driven System**: All enemy properties controlled by .tres files  
✅ **Modular AI**: Different behaviors (melee aggressive, ranged kiting, support healing)  
✅ **Ability System**: Enemies can cast different abilities with cooldowns  
✅ **Individual Scenes**: Each enemy type has its own .tscn file  
✅ **Enhanced Combat**: Projectiles, area attacks, and status effects  
✅ **Wave Integration**: All new systems work with existing wave scaling  
✅ **Performance Optimized**: AI updates efficiently for 100+ enemies  
✅ **Future Ready**: Elemental system hooks prepared for Phase 7  

## **Testing Protocol**

1. **Create a test scene** with Goblin and Wizard enemies
2. **Verify AI behaviors** - Goblin should charge, Wizard should kite
3. **Test abilities** - Goblin melee attacks, Wizard fireballs
4. **Confirm wave scaling** - Higher waves should make enemies tougher
5. **Performance test** - Spawn 20+ enemies and maintain 60 FPS

## **Integration Notes**

- **Your existing Enemy.gd** contact damage system is preserved
- **Wave scaling integration** works exactly as before
- **Spawner compatibility** maintained - just point to new enemy scenes
- **GameEvents integration** unchanged
- **Future Phase 7** elemental system hooks are ready

**Phase 3.5b transforms your solid foundation into a sophisticated enemy system ready for the challenges ahead!** 🧙‍♂️⚔️