# PHASE 1-2: PLAYER MOVEMENT & COMBAT - DETAILED IMPLEMENTATION
## Building Core Gameplay (2 Days Total)

These phases create the foundational gameplay loop: player movement and spell casting. Each phase is focused and builds incrementally on the previous.

## PHASE 1: BASIC PLAYER MOVEMENT (Day 1)

### RESEARCH PHASE (30 minutes): Discovery & Analysis
**Launch 3 research agents in parallel:**
- **Agent A**: Analyze existing input system, collision setup, and component patterns
- **Agent B**: Map GameEvents integration points and signal requirements  
- **Agent C**: Review testing framework and performance validation approach

### IMPLEMENTATION PHASE (3-4 hours): Sequential Development

#### Step 1: Player Scene Setup (45 minutes)
```
Player.tscn:
├── Player (CharacterBody2D)
    ├── PlayerSprite (Sprite2D)
    ├── PlayerCollision (CollisionShape2D) 
    ├── MovementComponent (Node) - handles movement logic
    └── HealthComponent (Node) - handles health/mana
```

```gdscript
# Player.gd - Main player controller
extends CharacterBody2D
class_name Player

@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent

var player_id: String = "main_player"

func _ready():
    name = "Player"
    add_to_group("players")
    
    # Set collision layer (Layer 1 = Player)
    collision_layer = 1
    collision_mask = 4  # Only collide with environment (Layer 4)
    
    # Validate collision setup
    if not CollisionValidator.validate_player_collision(self):
        Logger.log_error("Player collision setup failed", "Player")
    
    # Initialize components
    movement_component.setup(self)
    health_component.setup(self)
    
    # Register with GameManager
    GameManager.player_reference = self
    
    print("✅ Player initialized at " + str(global_position))

func _physics_process(delta):
    if movement_component:
        movement_component.physics_update(delta)

# External API for other systems
func take_damage(amount: float) -> bool:
    if health_component:
        return health_component.take_damage(amount)
    return false

func get_health_percentage() -> float:
    if health_component:
        return health_component.current_health / health_component.max_health
    return 0.0
```

#### Step 2: Movement Component (60 minutes)
```gdscript
# MovementComponent.gd - Focused movement logic
extends Node
class_name MovementComponent

var player: CharacterBody2D
var base_speed: float = 200.0
var acceleration: float = 10.0
var friction: float = 8.0

# Dodge system
var dodge_speed: float = 400.0
var dodge_duration: float = 0.2
var dodge_cooldown: float = 1.0
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_cooldown_timer: float = 0.0

func setup(player_node: CharacterBody2D):
    player = player_node
    print("✅ MovementComponent setup complete")

func physics_update(delta: float):
    _handle_dodge(delta)
    _handle_movement(delta)
    _apply_movement()

func _handle_movement(delta: float):
    var input_vector = InputHandler.get_movement_vector()
    
    if is_dodging:
        # During dodge, maintain dodge velocity
        return
    
    if input_vector.length() > 0:
        # Accelerate toward input direction
        player.velocity = player.velocity.move_toward(input_vector * base_speed, acceleration * delta * 100)
    else:
        # Apply friction when no input
        player.velocity = player.velocity.move_toward(Vector2.ZERO, friction * delta * 100)

func _handle_dodge(delta: float):
    # Update timers
    if dodge_timer > 0:
        dodge_timer -= delta
        if dodge_timer <= 0:
            is_dodging = false
    
    if dodge_cooldown_timer > 0:
        dodge_cooldown_timer -= delta
    
    # Check for dodge input
    if Input.is_action_just_pressed("dodge") and dodge_cooldown_timer <= 0 and not is_dodging:
        _start_dodge()

func _start_dodge():
    var input_vector = InputHandler.get_movement_vector()
    if input_vector.length() > 0:
        is_dodging = true
        dodge_timer = dodge_duration
        dodge_cooldown_timer = dodge_cooldown
        player.velocity = input_vector * dodge_speed
        print("🏃 Player dodged in direction " + str(input_vector))

func _apply_movement():
    player.move_and_slide()
    
    # Keep player within screen bounds
    var screen_size = get_viewport().get_visible_rect().size
    player.global_position.x = clamp(player.global_position.x, 50, screen_size.x - 50)
    player.global_position.y = clamp(player.global_position.y, 50, screen_size.y - 50)
    
    # Emit movement event for other systems
    GameEvents.player_moved.emit(player.global_position)
```

#### Step 3: Health Component (45 minutes)
```gdscript
# HealthComponent.gd - Simple health/mana system
extends Node
class_name HealthComponent

var owner_entity: Node
var max_health: float = 100.0
var current_health: float = 100.0
var max_mana: float = 50.0
var current_mana: float = 50.0
var mana_regen_rate: float = 10.0  # per second

# Regeneration timer
var mana_regen_timer: Timer

func setup(entity: Node):
    owner_entity = entity
    current_health = max_health
    current_mana = max_mana
    
    # Setup mana regeneration
    mana_regen_timer = Timer.new()
    mana_regen_timer.wait_time = 0.5  # Regen every 0.5 seconds
    mana_regen_timer.timeout.connect(_regenerate_mana)
    add_child(mana_regen_timer)
    mana_regen_timer.start()
    
    print("✅ HealthComponent setup complete")

func take_damage(amount: float) -> bool:
    if amount <= 0:
        return false
    
    var old_health = current_health
    current_health = max(0, current_health - amount)
    var damage_dealt = old_health - current_health
    
    # Update GameManager state
    GameManager.player_health = current_health
    
    # Emit health change event
    GameEvents.player_health_changed.emit(current_health, max_health)
    
    print("❤️ Player took " + str(damage_dealt) + " damage. Health: " + str(current_health) + "/" + str(max_health))
    
    # Check for death
    if current_health <= 0:
        _handle_death()
    
    return true

func consume_mana(amount: float) -> bool:
    if current_mana < amount:
        print("💙 Not enough mana: " + str(current_mana) + "/" + str(amount))
        return false
    
    current_mana -= amount
    print("💙 Consumed " + str(amount) + " mana. Mana: " + str(current_mana) + "/" + str(max_mana))
    return true

func _regenerate_mana():
    if current_mana < max_mana:
        current_mana = min(max_mana, current_mana + (mana_regen_rate * 0.5))

func _handle_death():
    print("💀 Player died!")
    GameManager.current_state = GameManager.GameState.GAME_OVER
    # Game over logic here
```

### AFTERNOON BLOCK (3-4 hours): Movement Polish

#### Step 4: Input System Enhancement (30 minutes)
```gdscript
# Add to project.godot input map:
dodge = Space key (or Shift key)

# Update InputHandler.gd to include dodge
func is_dodge_pressed() -> bool:
    if not input_enabled:
        return false
    return Input.is_action_just_pressed("dodge")
```

#### Step 5: Visual Feedback (60 minutes)
```gdscript
# PlayerVisuals.gd - Handle player visual feedback
extends Node

@onready var sprite: Sprite2D = get_parent().get_node("PlayerSprite")
var base_modulate: Color = Color.WHITE
var dodge_modulate: Color = Color(1, 1, 1, 0.5)  # Semi-transparent during dodge

func _ready():
    # Connect to movement events
    var movement_comp = get_parent().get_node("MovementComponent")
    # Add visual feedback for dodge state

func show_dodge_effect():
    sprite.modulate = dodge_modulate
    var tween = create_tween()
    tween.tween_property(sprite, "modulate", base_modulate, 0.2)

func show_damage_effect():
    sprite.modulate = Color.RED
    var tween = create_tween()
    tween.tween_property(sprite, "modulate", base_modulate, 0.1)
```

#### Step 6: Player Integration (45 minutes)
```gdscript
# Add Player to Main.tscn in GameWorld/Player position
# Update GameManager.gd to track player reference

# GameManager.gd additions:
var player_reference: Player = null

func get_player_position() -> Vector2:
    if player_reference:
        return player_reference.global_position
    return Vector2.ZERO

func get_player() -> Player:
    return player_reference
```

### PHASE 1 SUCCESS CRITERIA:
```
✅ Player moves smoothly with WASD keys
✅ Player has proper collision detection (Layer 1)
✅ Dodge mechanic works with visual feedback
✅ Player stays within screen boundaries
✅ Health/mana system functional
✅ No movement-related errors for 10 minutes
✅ Movement feels responsive and natural
```

## PHASE 2: SIMPLE COMBAT SYSTEM (Day 2)

### MORNING BLOCK (3-4 hours): Spell Foundation

#### Step 1: SpellData Resource (30 minutes)
```gdscript
# SpellData.gd - Resource for spell definitions
extends Resource
class_name SpellData

@export var spell_name: String = ""
@export var base_damage: float = 25.0
@export var mana_cost: int = 10
@export var projectile_speed: float = 300.0
@export var projectile_range: float = 600.0
@export var cooldown_duration: float = 1.0

# Visual/audio references
@export var projectile_scene: PackedScene
@export var projectile_texture: Texture2D
@export var cast_sound: AudioStream

func validate() -> bool:
    return spell_name != "" and base_damage > 0 and mana_cost > 0 and projectile_speed > 0
```

#### Step 2: Basic Spell Projectile (60 minutes)
```gdscript
# SpellProjectile.gd - Simple projectile behavior
extends RigidBody2D
class_name SpellProjectile

var spell_data: SpellData
var damage: float = 0.0
var travel_distance: float = 0.0
var max_range: float = 600.0
var start_position: Vector2

func _ready():
    # Set collision layer (Layer 3 = Projectiles)
    collision_layer = 4  # Don't collide with other projectiles
    collision_mask = 2   # Only hit enemies (Layer 2)
    
    if not CollisionValidator.validate_projectile_collision(self):
        Logger.log_error("Projectile collision setup failed", "SpellProjectile")
    
    # Connect collision signal
    body_entered.connect(_on_body_entered)
    
    # Auto-destroy after range
    start_position = global_position

func setup(spell_data_resource: SpellData, damage_amount: float, direction: Vector2):
    spell_data = spell_data_resource
    damage = damage_amount
    max_range = spell_data.projectile_range
    
    # Set velocity
    linear_velocity = direction.normalized() * spell_data.projectile_speed
    
    print("✨ " + spell_data.spell_name + " projectile launched")

func _physics_process(delta):
    # Check travel distance
    travel_distance = start_position.distance_to(global_position)
    if travel_distance >= max_range:
        _destroy_projectile()

func _on_body_entered(body: Node):
    if body.is_in_group("enemies"):
        _hit_enemy(body)
    elif body.collision_layer == 4:  # Environment
        _hit_environment()

func _hit_enemy(enemy: Node):
    print("💥 " + spell_data.spell_name + " hit " + enemy.name + " for " + str(damage) + " damage")
    
    # Deal damage to enemy
    if enemy.has_method("take_damage"):
        enemy.take_damage(damage)
    
    # Create visual effect
    _create_impact_effect()
    
    # Destroy projectile
    _destroy_projectile()

func _hit_environment():
    print("💥 " + spell_data.spell_name + " hit environment")
    _create_impact_effect()
    _destroy_projectile()

func _create_impact_effect():
    # Simple visual feedback
    var effect = preload("res://effects/ImpactEffect.tscn").instantiate()
    get_tree().current_scene.add_child(effect)
    effect.global_position = global_position

func _destroy_projectile():
    queue_free()
```

#### Step 3: Spell Casting System (90 minutes)
```gdscript
# SpellComponent.gd - Handles spell casting for player
extends Node
class_name SpellComponent

var owner_entity: Node
var health_component: HealthComponent
var equipped_spells: Array[SpellData] = []
var spell_cooldowns: Dictionary = {}

# Default spells
var fireball_spell: SpellData

func setup(entity: Node, health_comp: HealthComponent):
    owner_entity = entity
    health_component = health_comp
    
    # Load default spell
    _load_default_spells()
    print("✅ SpellComponent setup complete")

func _load_default_spells():
    # Create basic fireball spell
    fireball_spell = SpellData.new()
    fireball_spell.spell_name = "Fireball"
    fireball_spell.base_damage = 25.0
    fireball_spell.mana_cost = 10
    fireball_spell.projectile_speed = 300.0
    fireball_spell.projectile_range = 600.0
    fireball_spell.cooldown_duration = 1.0
    
    equipped_spells.append(fireball_spell)

func _process(delta):
    # Update cooldowns
    for spell_name in spell_cooldowns.keys():
        spell_cooldowns[spell_name] -= delta
        if spell_cooldowns[spell_name] <= 0:
            spell_cooldowns.erase(spell_name)

func cast_spell(spell_index: int) -> bool:
    if spell_index >= equipped_spells.size():
        return false
    
    var spell = equipped_spells[spell_index]
    
    # Check cooldown
    if spell.spell_name in spell_cooldowns:
        print("🕐 " + spell.spell_name + " on cooldown")
        return false
    
    # Check mana
    if not health_component.consume_mana(spell.mana_cost):
        return false
    
    # Get cast direction (toward mouse)
    var cast_direction = _get_cast_direction()
    
    # Create projectile
    _create_projectile(spell, cast_direction)
    
    # Set cooldown
    spell_cooldowns[spell.spell_name] = spell.cooldown_duration
    
    # Emit event
    GameEvents.spell_cast.emit(spell.spell_name, spell.base_damage)
    
    return true

func _get_cast_direction() -> Vector2:
    var mouse_pos = get_global_mouse_position()
    var player_pos = owner_entity.global_position
    return (mouse_pos - player_pos).normalized()

func _create_projectile(spell: SpellData, direction: Vector2):
    # Create projectile scene
    var projectile = preload("res://scenes/SpellProjectile.tscn").instantiate()
    get_tree().current_scene.add_child(projectile)
    projectile.global_position = owner_entity.global_position
    projectile.setup(spell, spell.base_damage, direction)
```

### AFTERNOON BLOCK (3-4 hours): Combat Integration

#### Step 4: Input Integration (30 minutes)
```gdscript
# Update Player.gd to handle spell casting
func _input(event):
    if GameManager.current_state != GameManager.GameState.PLAYING:
        return
    
    # Check for spell casting
    for i in range(1, 6):  # Keys 1-5
        if InputHandler.is_spell_cast_pressed(i):
            _cast_spell(i - 1)  # Convert to 0-based index

func _cast_spell(spell_index: int):
    var spell_component = get_node("SpellComponent")
    if spell_component:
        spell_component.cast_spell(spell_index)
```

#### Step 5: Create Required Scenes (60 minutes)
```
SpellProjectile.tscn:
├── SpellProjectile (RigidBody2D)
    ├── ProjectileSprite (Sprite2D) - simple colored circle
    ├── ProjectileCollision (CollisionShape2D) - small circle
    └── ProjectileArea (Area2D) - for enemy detection
        └── AreaCollision (CollisionShape2D)

ImpactEffect.tscn:
├── ImpactEffect (Node2D)
    ├── EffectSprite (Sprite2D) - explosion graphic
    └── EffectTimer (Timer) - auto-destroy after 0.5 seconds
```

#### Step 6: Damage Number Display (45 minutes)
```gdscript
# DamageNumber.gd - Floating damage numbers
extends Label

func setup(damage_amount: float, start_pos: Vector2):
    text = str(int(damage_amount))
    global_position = start_pos
    modulate = Color.RED
    
    # Animate upward movement and fade
    var tween = create_tween()
    tween.parallel().tween_property(self, "global_position", start_pos + Vector2(0, -50), 1.0)
    tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
    tween.tween_callback(queue_free)

# Call this when projectile hits enemy:
func _show_damage_number(position: Vector2, damage: float):
    var damage_number = preload("res://ui/DamageNumber.tscn").instantiate()
    get_tree().current_scene.add_child(damage_number)
    damage_number.setup(damage, position)
```

#### Step 7: Basic Mana UI (45 minutes)
```gdscript
# Update BasicHUD.gd to show mana
@onready var mana_label: Label = $ManaLabel

func _ready():
    GameEvents.player_health_changed.connect(_on_player_health_changed)
    _update_displays()

func _update_displays():
    var player = GameManager.get_player()
    if player and player.health_component:
        var health_comp = player.health_component
        health_label.text = "Health: " + str(int(health_comp.current_health)) + "/" + str(int(health_comp.max_health))
        mana_label.text = "Mana: " + str(int(health_comp.current_mana)) + "/" + str(int(health_comp.max_mana))
```

### PHASE 2 SUCCESS CRITERIA:
```
✅ Can cast spell with "1" key
✅ Projectile travels toward mouse cursor
✅ Projectile has proper collision detection
✅ Mana consumption works correctly
✅ Mana regenerates over time
✅ Spell cooldown system functional
✅ Visual feedback for spell casting
✅ Damage numbers display (if target exists)
✅ No spell-related errors for 10 minutes
```

## INTEGRATION VALIDATION (End of Phase 2)

### Quality Gate Checklist:
```gdscript
# QualityGatePhase2.gd
func validate_phase_2() -> bool:
    return (
        _test_player_movement() and
        _test_spell_casting() and
        _test_mana_system() and
        _test_collision_layers() and
        _test_no_runtime_errors()
    )

func _test_player_movement() -> bool:
    var player = GameManager.get_player()
    return player != null and player.movement_component != null

func _test_spell_casting() -> bool:
    var player = GameManager.get_player()
    if not player:
        return false
    var spell_comp = player.get_node("SpellComponent")
    return spell_comp != null and spell_comp.equipped_spells.size() > 0

func _test_mana_system() -> bool:
    var player = GameManager.get_player()
    if not player:
        return false
    var health_comp = player.health_component
    return health_comp != null and health_comp.max_mana > 0

func _test_collision_layers() -> bool:
    # Verify player is on layer 1, projectiles will be on layer 3
    var player = GameManager.get_player()
    return player != null and player.collision_layer == 1

func _test_no_runtime_errors() -> bool:
    return Logger.error_count == 0
```

These two phases create a solid foundation for the rest of the game: responsive player movement and functional spell casting. Each phase builds incrementally and can be validated independently before moving to the next phase.