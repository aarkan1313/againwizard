# Core System Breakdown

## Overview

This document details the core game systems in the FFS Wizard RPG, organized by functional categories. Each system entry includes its purpose, key components, data structures, and integration patterns.

---

## Input System

### Input Maps
**Configuration**: `project.godot` input map section  
**Handler**: `scripts/InputHandler.gd` (singleton)

#### Movement Controls
- **WASD**: Player movement (move_left, move_right, move_up, move_down)
- **Implementation**: Direct input polling in Player.gd movement system

#### Spell Casting
- **Number Keys 1-9, 0**: Spell slots 1-10
- **Tab**: Toggle mouse spell mode for targeting
- **Implementation**: SpellComponent.gd processes spell input through InputHandler

#### Special Actions
- **Space**: Teleport ability with collision avoidance
- **C**: Character sheet toggle
- **P**: Pause game
- **Escape**: Main menu/escape

#### Debug Controls (Development)
- **F1**: Add XP (`debug_add_xp`)
- **F4**: Force wave spawn (`debug_force_wave`)
- **F3**: Add enemies (`debug_add_enemies`)
- **F12**: Print stats (`debug_print_stats`)
- **Delete**: Toggle verbose logging

### Device Support
- **Keyboard Only**: Primary input method
- **Mouse**: Spell targeting and UI interaction
- **Controller Support**: Not currently implemented

---

## Movement/Physics

### Physics Configuration
**Engine**: Godot Physics2D  
**Collision Layers**: 4-layer system

#### Collision Layer Setup
1. **Layer 1 - Player**: Player character and related entities
2. **Layer 2 - Enemies**: Enemy entities and AI-controlled objects  
3. **Layer 3 - Projectiles**: Spell projectiles and thrown objects
4. **Layer 4 - Environment**: Static world geometry and obstacles

### Movement Component System
**Script**: `scripts/components/MovementComponent.gd`  
**Purpose**: Handles physics and movement for all entities

#### Player Movement
```gdscript
@export var base_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0
```

**Features**:
- Stat-based speed calculation: `base_speed + dexterity × 5`
- Screen boundary enforcement
- Smooth acceleration/deceleration
- Integration with teleport system

#### Enemy Movement
- **AI Pathfinding**: Basic line-of-sight movement toward player
- **Collision Avoidance**: Basic separation from other enemies
- **Speed Scaling**: Wave-based speed increases (+8% per wave)

### Teleport System
**Implementation**: `Player.gd` advanced teleport mechanics

**Features**:
- **Collision-Safe Teleporting**: Checks for valid destination
- **Enemy Avoidance**: Prevents teleporting into enemies
- **Cooldown Management**: 1-second default cooldown
- **Visual Feedback**: Screen flash and particle effects

---

## Animation System

### AnimationPlayer Usage
**Primary Scenes**: Limited AnimationPlayer usage
**Implementation**: Mostly code-driven animations via Tween

#### Tween-Based Animations
**XP Orb Animations** (`scripts/items/XPOrb.gd`):
```gdscript
# Spawn animation
var tween = create_tween()
tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)

# Floating animation
var float_tween = create_tween()
float_tween.set_loops()
float_tween.tween_property(sprite, "position:y", -5, 1.0)
```

**Damage Number Animations** (`scripts/ui/DamageNumber.gd`):
- Floating upward movement
- Color-coded damage types
- Scale and fade animations
- Performance-optimized with pooling

#### Particle Animations
**HealEffect** (`scenes/effects/HealEffect.gd`):
- GPU-based particle system
- Orbital motion clusters
- Green healing theme with gradient colors
- Procedural texture generation

**Advanced Particle Manager** (`scripts/procedural/AdvancedParticleManager.gd`):
- Multiple effect types: magic_ambient, sparkle_burst, ember_trail
- Lightning bolt generation
- Rune circle systems
- Object pooling for performance

### Animation Trees
**Status**: Not currently implemented
**Future Enhancement**: Could be added for complex character animations

---

## Audio System

### AudioStreamPlayer Configuration
**Current Implementation**: Basic audio support structure in place
**Bus Configuration**: Default bus setup

#### Audio Categories
- **Music**: Background music (not currently implemented)
- **SFX**: Sound effects for spells and combat
- **UI**: Interface feedback sounds
- **Ambient**: Environmental audio

#### Dynamic Audio
**Spell Sounds**: Referenced in SpellComponent but not fully implemented
**Combat Audio**: Impact and damage sound hooks available
**UI Feedback**: Button clicks and menu sounds prepared

### Audio Management
**Future Implementation**: Dedicated AudioManager singleton planned
**Volume Control**: Integrated with SettingsManager
**3D Audio**: Not required for 2D game

---

## UI System

### Control Node Architecture
**Primary UI**: Canvas-based Control nodes
**UI Manager**: Multiple specialized UI controllers

#### Core UI Components

##### PlayerUI System
**Script**: `scripts/ui/PlayerUI.gd`  
**Scene**: `scenes/ui/PlayerUI.tscn`

**Components**:
- Health Bar (ProgressBar)
- Mana Bar (ProgressBar)  
- XP Display (Label)
- Level Display
- Stats Panel integration

##### Spell Toolbar
**Script**: `scripts/ui/SpellToolbar.gd`  
**Features**:
- 10 spell slots (0-9 keys)
- Visual cooldown indicators
- Spell icon assignment
- Drag-and-drop functionality (planned)

##### Menu Systems
**MainMenu** (`scripts/ui/MainMenu.gd`):
- Save slot selection (3 slots)
- New Game/Continue/Settings/Quit
- Character management dialog

**EscapeMenu** (`scripts/ui/EscapeMenu.gd`):
- In-game pause menu
- Save/Load options
- Settings access
- Return to main menu

#### Themes and Styling
**Theme System**: Default Godot themes with custom modifications
**Color Schemes**: Health (red), Mana (blue), XP (yellow/green)
**Font System**: Built-in fonts with size overrides

#### UI Signal Patterns
```gdscript
# Health bar updates
GameEvents.player_health_changed.connect(_on_health_changed)

# Spell casting feedback
GameEvents.spell_cast.connect(_on_spell_cast_feedback)

# Level progression
GameEvents.level_up.connect(_on_level_up_display)
```

### Containers and Layout
- **VBoxContainer**: Vertical UI stacking
- **HBoxContainer**: Horizontal spell toolbar
- **GridContainer**: Character stat displays
- **Control**: Custom positioning for overlays

---

## Save/Load System

### Save Architecture
**Primary Manager**: `scripts/core/save/SaveManager.gd` (singleton)  
**Data Classes**: SaveData.gd, CharacterData.gd, RunData.gd

#### Save Types

##### Meta-Progression Save
**Manager**: `scripts/core/save/MetaSaveManager.gd`  
**Purpose**: Persistent progression across runs
**Data**: Unlocks, achievements, meta-stats

##### Run-Specific Save  
**Manager**: `scripts/core/save/RunSaveManager.gd`  
**Purpose**: Current game session data
**Data**: Player stats, world state, current wave

##### Character Save
**Class**: `scripts/core/save/CharacterData.gd`  
**Data Structure**:
```gdscript
player_level: int
current_xp: int
allocated_stats: Dictionary
current_health: float
current_mana: float
player_position: Vector2
```

#### File Management
**Save Slots**: 3 available save slots
**File Format**: Godot's binary resource format (.tres)
**Location**: User data directory
**Validation**: `scripts/core/save/SaveDataValidator.gd`

#### Error Handling
- **Corruption Detection**: Checksum validation
- **Backup Creation**: Automatic backup before overwriting
- **Recovery**: Fallback to previous save on corruption
- **Migration**: Save format version handling

### Autosave System
**Implementation**: `Main.gd` autosave setup
**Triggers**: Wave completion, level up, manual saves
**Frequency**: Configurable through SettingsManager

---

## Scene Management

### Scene Transition System
**Manager**: `scripts/ui/SceneTransition.gd` (singleton)  
**Purpose**: Smooth transitions between game scenes

#### Transition Types
- **Fade In/Out**: Standard scene transitions
- **Loading Screens**: For world generation
- **Instant**: Debug and fast transitions

#### Scene Loading Patterns

##### Static Scene Loading
```gdscript
# Main menu to gameplay
SceneTransition.change_scene("res://scenes/Main.tscn")

# Return to menu
SceneTransition.change_scene("res://scenes/ui/MainMenu.tscn")
```

##### Dynamic Scene Loading
```gdscript
# Enemy spawning
var scene_path = "res://scenes/enemies/" + enemy_type.capitalize() + ".tscn"
var enemy_scene = load(scene_path)

# Effect creation
var effect_scene = preload("res://scenes/effects/HealEffect.tscn")
```

#### Loading Screen Integration
**Script**: `scripts/ui/ChunkLoadingScreen.gd`  
**Purpose**: Display progress during world generation
**Features**: Progress bars, loading tips, smooth animations

### Scene Hierarchy Management
**Pattern**: Clear separation between GameWorld and UI layers
**GameWorld**: All game entities and logic
**UI**: Interface overlays and menus

---

## Game State Management

### State Architecture
**Manager**: `scripts/core/GameStateManager.gd` (singleton)  
**Pattern**: State machine with defined transitions

#### Game States
```gdscript
enum Phase4GameState {
    LOADING,      # Initial loading and world generation
    PLAYING,      # Active gameplay
    PAUSED,       # Game paused via escape menu
    GAME_OVER,    # Player death state
    TRANSITIONING # Scene transitions
}
```

#### State Transitions
- **LOADING** → **PLAYING**: World generation complete
- **PLAYING** → **PAUSED**: Escape menu opened
- **PLAYING** → **GAME_OVER**: Player health reaches 0
- **GAME_OVER** → **LOADING**: Restart game
- **Any State** → **TRANSITIONING**: Scene change initiated

### Pause Handling
**Implementation**: `GameManager.gd` pause coordination
**Features**:
- Full game pause (physics, enemies, timers)
- UI remains responsive
- Save functionality available while paused
- Background dimming effect

#### Pause Integration
```gdscript
func pause_game():
    get_tree().paused = true
    GameStateManager.change_state(GameStateManager.Phase4GameState.PAUSED)
    
func unpause_game():
    get_tree().paused = false
    GameStateManager.change_state(GameStateManager.Phase4GameState.PLAYING)
```

---

## Performance Considerations

### Optimization Strategies

#### Object Pooling
**Projectiles**: `scripts/pools/ProjectilePool.gd`
- Reuse SpellProjectile and EnemyProjectile instances
- Significant reduction in garbage collection

**Damage Numbers**: DamageNumber.gd static pooling
- Limit concurrent damage numbers to 20
- Performance optimization for combat feedback

#### Chunk-Based Loading
**World Manager**: `scripts/world/UnifiedWorldManager.gd`
- 2048px chunks with 9×9 active grid
- Dynamic loading/unloading based on player position
- Memory management for infinite world

#### Update Throttling
**Enemy AI**: Distance-based update frequency
- Close enemies: Full update rate
- Distant enemies: Reduced update frequency
- AI sleeping for very distant enemies

#### Cache Optimization
**Spell Cooldowns**: 30% UI performance improvement
**Distance Calculations**: Distance-squared optimization (25-30% boost)
**Component References**: @onready caching

### Memory Management
- **Automatic Cleanup**: Godot reference counting
- **Manual Cleanup**: Explicit queue_free() for temporary objects
- **Resource Preloading**: Critical assets loaded at startup
- **Texture Streaming**: Procedural texture generation

### Frame Rate Targets
- **Target FPS**: 60 FPS
- **Minimum FPS**: 30 FPS acceptable
- **Performance Monitoring**: Built-in FPS tracking in GameManager
- **Optimization Tools**: UnifiedDebugSystem performance logging

This comprehensive system breakdown demonstrates how all major game systems integrate to create a cohesive, performant wizard RPG experience with modern game development practices.