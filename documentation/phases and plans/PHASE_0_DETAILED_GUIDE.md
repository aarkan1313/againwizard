# PHASE 0: MINIMAL INFRASTRUCTURE - DETAILED IMPLEMENTATION
## Foundation Setup (1-2 Days Maximum)

This phase creates the absolute minimum infrastructure needed to support all future phases while avoiding the architectural issues that caused the 47+ fix iterations.

## DAY 0.1: CORE FOUNDATION (4-6 hours)

### MORNING BLOCK (3-4 hours): Project Setup

#### Step 1: Clean Project Creation (30 minutes)
```gdscript
# Create new Godot 4.4.1 project
# Project name: "WizardRPG_Clean" 
# Location: Outside existing project to avoid contamination

# Essential project settings only:
Project Settings → Physics:
- 2D Physics Layer 1: "Player"
- 2D Physics Layer 2: "Enemies" 
- 2D Physics Layer 3: "Projectiles"
- 2D Physics Layer 4: "Environment"

Project Settings → Input Map:
- move_left: A key
- move_right: D key  
- move_up: W key
- move_down: S key
- cast_spell_1: 1 key
- pause_game: Escape key
```

#### Step 2: Essential Singletons Only (60 minutes)
```gdscript
# GameEvents.gd - Minimal event system
extends Node

# Only the 5 most critical events
signal player_moved(new_position: Vector2)
signal player_health_changed(current: float, maximum: float)
signal enemy_died(enemy_name: String, xp_awarded: int)
signal spell_cast(spell_name: String, damage: float)
signal wave_completed(wave_number: int)

func _ready():
    print("✅ GameEvents initialized")

# Simple validation
func emit_player_health_changed(current: float, maximum: float):
    if current < 0 or maximum <= 0 or current > maximum:
        push_error("Invalid health values: " + str(current) + "/" + str(maximum))
        return
    player_health_changed.emit(current, maximum)
```

```gdscript
# GameManager.gd - Minimal game state
extends Node

enum GameState { PLAYING, PAUSED, GAME_OVER }
var current_state: GameState = GameState.PLAYING

var player_health: float = 100.0
var player_max_health: float = 100.0
var current_wave: int = 1

func _ready():
    print("✅ GameManager initialized")

func pause_game():
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true
    elif current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false

func _input(event):
    if event.is_action_pressed("pause_game"):
        pause_game()
```

#### Step 3: AutoLoad Setup (15 minutes)
```
Project Settings → AutoLoad:
1. GameEvents: res://scripts/GameEvents.gd
2. GameManager: res://scripts/GameManager.gd

# Only these 2 - no more complexity!
```

#### Step 4: Basic Logging System (30 minutes)
```gdscript
# Logger.gd - Simple error tracking
extends Node

var error_count: int = 0
var warning_count: int = 0

func _ready():
    print("✅ Logger initialized")

func log_error(message: String, source: String = "Unknown"):
    error_count += 1
    var formatted = "❌ ERROR [" + source + "]: " + message
    print(formatted)
    push_error(formatted)

func log_warning(message: String, source: String = "Unknown"):
    warning_count += 1
    var formatted = "⚠️ WARNING [" + source + "]: " + message
    print(formatted)
    push_warning(formatted)

func get_error_summary() -> String:
    return "Errors: " + str(error_count) + ", Warnings: " + str(warning_count)
```

### AFTERNOON BLOCK (3-4 hours): Scene Structure

#### Step 5: Collision Layer Validation (45 minutes)
```gdscript
# CollisionValidator.gd - Prevent layer mistakes
class_name CollisionValidator extends RefCounted

const LAYER_PLAYER = 1
const LAYER_ENEMIES = 2  
const LAYER_PROJECTILES = 3
const LAYER_ENVIRONMENT = 4

static func validate_player_collision(body: CharacterBody2D) -> bool:
    if body.collision_layer != LAYER_PLAYER:
        Logger.log_error("Player collision_layer should be " + str(LAYER_PLAYER), "CollisionValidator")
        return false
    return true

static func validate_enemy_collision(body: CharacterBody2D) -> bool:
    if body.collision_layer != LAYER_ENEMIES:
        Logger.log_error("Enemy collision_layer should be " + str(LAYER_ENEMIES), "CollisionValidator")
        return false
    return true

static func validate_projectile_collision(body: RigidBody2D) -> bool:
    if body.collision_layer != LAYER_PROJECTILES:
        Logger.log_error("Projectile collision_layer should be " + str(LAYER_PROJECTILES), "CollisionValidator")
        return false
    return true
```

#### Step 6: Main Scene Structure (60 minutes)
```
Main.tscn:
├── Main (Node2D)
    ├── GameWorld (Node2D)
    │   ├── Player (will add in Phase 1)
    │   └── Enemies (Node2D) - container for enemy spawning
    ├── UI (CanvasLayer)
    │   ├── DebugPanel (Control) - minimal debug info
    │   └── BasicHUD (Control) - health bar only
    └── Systems (Node)
        ├── WaveManager (Node) - empty for now
        └── SpellManager (Node) - empty for now
```

#### Step 7: Basic Input Handling (45 minutes)
```gdscript
# InputHandler.gd - Single source for input
extends Node

var input_enabled: bool = true

func _ready():
    print("✅ InputHandler initialized")

func _input(event):
    if not input_enabled:
        return
        
    # Only handle pause for now
    if event.is_action_pressed("pause_game"):
        GameManager.pause_game()

func get_movement_vector() -> Vector2:
    if not input_enabled:
        return Vector2.ZERO
        
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_axis("move_left", "move_right")
    input_vector.y = Input.get_axis("move_up", "move_down")
    return input_vector.normalized()

func is_spell_cast_pressed(spell_index: int) -> bool:
    if not input_enabled:
        return false
    return Input.is_action_just_pressed("cast_spell_" + str(spell_index))
```

#### Step 8: Basic UI Framework (30 minutes)
```gdscript
# BasicHUD.gd - Minimal UI
extends Control

@onready var health_label: Label = $HealthLabel

func _ready():
    # Connect to health changes
    GameEvents.player_health_changed.connect(_on_player_health_changed)
    _update_health_display()

func _on_player_health_changed(current: float, maximum: float):
    _update_health_display()

func _update_health_display():
    health_label.text = "Health: " + str(GameManager.player_health) + "/" + str(GameManager.player_max_health)
```

### END OF DAY 0.1 VALIDATION

#### Success Criteria Checklist:
```
✅ Project runs without any errors in console
✅ Can press ESC to pause/unpause game
✅ Health display shows "Health: 100/100"
✅ Collision layers properly configured in project settings
✅ Basic scene structure loads correctly
✅ Input system responds to key presses
✅ GameEvents and GameManager singletons working
✅ No warnings or errors for 5 minutes of running
```

#### Quality Gate Test:
```gdscript
# QualityGateDay0.gd - Validation script
func run_day_0_validation() -> bool:
    var checks = [
        _check_autoloads_exist(),
        _check_scene_loads(),
        _check_input_system(),
        _check_collision_layers(),
        _check_no_runtime_errors()
    ]
    
    var passed = 0
    for check in checks:
        if check:
            passed += 1
    
    print("Day 0 Quality Gate: " + str(passed) + "/5 checks passed")
    return passed == 5

func _check_autoloads_exist() -> bool:
    return GameEvents != null and GameManager != null

func _check_scene_loads() -> bool:
    var main_scene = load("res://Main.tscn")
    return main_scene != null

func _check_input_system() -> bool:
    return InputHandler.get_movement_vector() is Vector2

func _check_collision_layers() -> bool:
    return ProjectSettings.get_setting("layer_names/2d_physics/layer_1") == "Player"

func _check_no_runtime_errors() -> bool:
    return Logger.error_count == 0
```

## DAY 0.2: TESTING FRAMEWORK (Optional - 2-3 hours)

Only implement if Day 0.1 completed successfully and you have extra time.

### Simple Test Framework (90 minutes)
```gdscript
# TestFramework.gd - Basic automated testing
class_name TestFramework extends RefCounted

static func test_scene_loading() -> bool:
    var scene_paths = [
        "res://Main.tscn"
        # Add more as we create them
    ]
    
    for path in scene_paths:
        var scene = load(path)
        if not scene:
            Logger.log_error("Failed to load scene: " + path, "TestFramework")
            return false
        
        var instance = scene.instantiate()
        if not instance:
            Logger.log_error("Failed to instantiate scene: " + path, "TestFramework")
            return false
        
        instance.queue_free()
    
    return true

static func test_collision_setup() -> bool:
    # Test that collision layers are configured correctly
    var player_layer = ProjectSettings.get_setting("layer_names/2d_physics/layer_1")
    var enemy_layer = ProjectSettings.get_setting("layer_names/2d_physics/layer_2")
    
    if player_layer != "Player":
        Logger.log_error("Player layer not configured correctly", "TestFramework")
        return false
    
    if enemy_layer != "Enemies":
        Logger.log_error("Enemy layer not configured correctly", "TestFramework") 
        return false
    
    return true

static func run_all_tests() -> bool:
    var tests = [
        test_scene_loading(),
        test_collision_setup()
    ]
    
    var passed = 0
    for test_result in tests:
        if test_result:
            passed += 1
    
    print("Test Results: " + str(passed) + "/" + str(tests.size()) + " passed")
    return passed == tests.size()
```

### Automated Quality Gate (60 minutes)
```gdscript
# QualityGate.gd - Automated validation
extends Node

func _ready():
    if OS.is_debug_build():
        # Run quality gates in debug builds
        call_deferred("run_quality_gates")

func run_quality_gates() -> bool:
    print("🔍 Running Quality Gates...")
    
    var gates = [
        _gate_no_errors(),
        _gate_scene_integrity(),
        _gate_autoload_health(),
        _gate_input_system(),
        _gate_collision_setup()
    ]
    
    var passed = 0
    for gate in gates:
        if gate:
            passed += 1
            print("✅ Gate passed")
        else:
            print("❌ Gate failed")
    
    var success = passed == gates.size()
    print("🎯 Quality Gates: " + str(passed) + "/" + str(gates.size()) + " " + ("PASSED" if success else "FAILED"))
    
    return success

func _gate_no_errors() -> bool:
    return Logger.error_count == 0

func _gate_scene_integrity() -> bool:
    return TestFramework.test_scene_loading()

func _gate_autoload_health() -> bool:
    return GameEvents != null and GameManager != null

func _gate_input_system() -> bool:
    return InputHandler.get_movement_vector() is Vector2

func _gate_collision_setup() -> bool:
    return TestFramework.test_collision_setup()
```

## PHASE 0 COMPLETION CRITERIA

### Mandatory Requirements:
1. **Clean Project**: Loads without any errors or warnings
2. **Basic Singletons**: GameEvents and GameManager working
3. **Input System**: Can detect movement keys and pause
4. **Collision Layers**: Properly configured for all entity types
5. **Scene Structure**: Main scene with organized hierarchy
6. **Basic UI**: Health display that updates reactively

### Optional Enhancements:
1. **Test Framework**: Automated validation of core systems
2. **Quality Gates**: Automated checks for common issues
3. **Logging System**: Error tracking and debugging support

### Success Validation:
- Project runs for 10 minutes without errors
- All input responses work correctly  
- Quality gates pass (if implemented)
- Ready for Phase 1 player implementation

This foundation prevents the collision layer chaos, signal parameter mismatches, and autoload issues that caused the previous 47+ fix iterations while remaining minimal and focused.