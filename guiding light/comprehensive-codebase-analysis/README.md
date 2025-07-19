# FFS - Wizard RPG Game

**Godot Version:** 4.4.1  
**Project Type:** 2D Action RPG with Procedural Generation  
**Current Branch:** string-formula-optimization

## Project Overview

FFS is a comprehensive 2D wizard-themed action RPG built in Godot 4.4.1. The game features a sophisticated spell-casting system, procedural world generation, wave-based enemy encounters, and extensive character progression mechanics.

### Key Features

- **Advanced Spell System**: 13+ unique spells with procedural casting mechanics
- **Procedural World Generation**: Dynamic biome-based terrain with chunk loading
- **Component Architecture**: Modular systems for health, movement, abilities, and stats
- **Wave-Based Combat**: Dynamic enemy spawning with scaling difficulty
- **Character Progression**: Stat allocation, experience system, and ability unlocks
- **Visual Effects**: Particle systems, attack indicators, and combat feedback
- **Save/Load System**: Persistent game state with multiple save slots

## Technology Stack

- **Engine**: Godot 4.4.1 (Forward Plus renderer)
- **Language**: GDScript (with typed syntax)
- **Architecture**: Component-based Entity System
- **Resolution**: 1920x1080 (Fullscreen mode 3)
- **Physics**: Godot Physics2D with 4-layer collision system

## Project Structure

```
godot/Game10/
├── assets/               # Sprites, effects, and visual assets
├── data/                # Game data resources (.tres files)
├── scenes/              # Scene files organized by system
├── scripts/             # GDScript source code
├── shaders/             # Custom shader files
├── textures/            # Generated and imported textures
└── project.godot        # Main project configuration
```

## Main Scene Hierarchy

**Entry Point**: `res://scenes/ui/MainMenu.tscn` (uid://c8j5yq2wmvnxp)

### Core Scenes
- **MainMenu.tscn** - Title screen and navigation (actual project entry point)
- **Main.tscn** - Primary gameplay scene loaded after menu selection
- **GameplayMain.tscn** - Additional gameplay scene with world systems
- **Player.tscn** - Player entity with components

### System Scenes
- **Enemy.tscn** - Base enemy template
- **SpellProjectile.tscn** - Spell casting projectiles
- **PlayerUI.tscn** - HUD and interface elements
- **SpellToolbar.tscn** - Spell selection interface

## Autoload Singletons

The game uses 17 autoloaded singletons for global systems:

### Core Systems
- **GameManager** - Primary game loop and state coordination
- **GameEvents** - Event bus for system communication
- **GameStateManager** - Game state persistence and transitions
- **UnifiedDebugSystem** - Development and debugging tools

### Input & UI
- **InputHandler** - Input processing and action mapping
- **SceneTransition** - Scene loading and transitions
- **AchievementNotificationManager** - Achievement display system

### Data Management
- **SaveManager** - Game save/load operations
- **MetaSaveManager** - Meta-progression persistence
- **RunSaveManager** - Run-specific data management
- **SettingsManager** - Game configuration management

### Game Systems
- **WaveManager** - Enemy wave spawning and progression
- **BiomeService** - Procedural biome generation
- **PlayerTracker** - Player state and statistics
- **CollisionValidator** - Physics validation system

### Specialized Managers
- **StatAllocationManager** - Character stat distribution
- **CharacterSheetManager** - Character sheet UI management
- **GameConfig** - Global game configuration

## Input Mapping

### Movement Controls
- **WASD** - Player movement (move_left, move_right, move_up, move_down)
- **Space** - Teleport ability
- **C** - Character sheet toggle

### Spell Casting
- **1-9, 0** - Spell slots 1-10 (spell_1 through spell_0)
- **Tab** - Toggle mouse spell mode

### System Controls
- **P** - Pause game
- **Escape** - Main menu/escape

### Debug Controls (Development)
- **F1** - Add XP (debug_add_xp)
- **F4** - Force wave spawn (debug_force_wave)
- **F3** - Add enemies (debug_add_enemies)
- **F12** - Print stats (debug_print_stats)
- **Delete** - Toggle verbose logging

## Physics Layers

The game uses a 4-layer collision system:

1. **Layer 1 - Player**: Player character and related entities
2. **Layer 2 - Enemies**: Enemy entities and AI-controlled objects
3. **Layer 3 - Projectiles**: Spell projectiles and thrown objects
4. **Layer 4 - Environment**: Static world geometry and obstacles

## Documentation Index

This project includes comprehensive documentation organized by system:

### Core Documentation
- [architecture.md](architecture.md) - System Architecture Overview
- [scenes-map.md](scenes-map.md) - Complete Scene Analysis
- [scripts-analysis.md](scripts-analysis.md) - GDScript Code Analysis
- [dependency-graph.md](dependency-graph.md) - System Dependencies

### System Documentation
- [game-systems.md](game-systems.md) - Core Game Systems
- [node-patterns.md](node-patterns.md) - Common Node Patterns
- [signals-events.md](signals-events.md) - Signal Flow Documentation
- [gameplay-flow.md](gameplay-flow.md) - Game Flow Analysis

### Technical Documentation
- [data-structures.md](data-structures.md) - Data Management
- [resources-inventory.md](resources-inventory.md) - Asset Documentation
- [performance-analysis.md](performance-analysis.md) - Performance Analysis
- [interactions-map.md](interactions-map.md) - Interaction Systems

### Development Documentation
- [issues-todo.md](issues-todo.md) - Technical Debt & Improvements
- [build-deploy.md](build-deploy.md) - Build Configuration

## Development Status

**Current Focus**: String optimization and performance improvements  
**Phase**: Advanced development with extensive systems integration  
**Stability**: Production-ready with comprehensive testing and validation systems

## Getting Started

1. Open the project in Godot 4.4.1
2. Ensure all autoloads are properly configured
3. Run the main scene (`res://scenes/Main.tscn`)
4. Use debug controls for testing and development

## Architecture Notes

- **Component-based design** for modularity and reusability
- **Event-driven communication** through GameEvents singleton
- **Extensive validation systems** for data integrity
- **Performance optimization** through object pooling and LOD systems
- **Modular save system** supporting multiple progression types

For detailed technical information, refer to the linked documentation files above.