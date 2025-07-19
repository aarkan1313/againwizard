# FFS Game - Godot Wizard RPG Documentation

## Project Overview

**Game Type**: 2D Wizard RPG with Infinite World Generation  
**Engine**: Godot 4.4.1  
**Language**: GDScript  
**Current Branch**: `string-formula-optimization`  
**Architecture**: Multi-Phase Development (Currently Phase 4+)

## Technology Stack

- **Engine**: Godot 4.4.1
- **Scripting**: GDScript (with strong typing)
- **Physics**: Godot Physics 2D
- **Rendering**: 2D Renderer with custom shaders
- **Audio**: Godot Audio System
- **Save System**: Custom JSON-based persistence
- **Debug System**: Unified debug framework with extensive logging

## Main Scene Hierarchy

```
Main (Main.gd)
├── Player (Player.gd)
├── UI/ (Player UI, Health bars, Spell toolbar)
├── GameWorld/ (World container)
├── UnifiedWorldManager (Infinite world system)
├── ChunkLoadingScreen (Loading UI)
└── Various UI overlays
```

## Entry Point Configuration

**Main Scene**: `res://scenes/ui/MainMenu.tscn` (actual project entry point)  
**Gameplay Scene**: `res://scenes/Main.tscn` (loaded after menu selection)  
**Project Settings**: Located in `project.godot`

### Autoload Singletons (Load Order) - **18 Total**
1. **UnifiedDebugSystem** - `res://scripts/debug/UnifiedDebugSystem.gd`
2. **CollisionValidator** - `res://scripts/CollisionValidator.gd`
3. **GameEvents** - `res://scripts/GameEvents.gd`
4. **GameManager** - `res://scripts/GameManager.gd`
5. **MetaSaveManager** - `res://scripts/core/MetaSaveManager.gd`
6. **RunSaveManager** - `res://scripts/core/RunSaveManager.gd`
7. **GameStateManager** - `res://scripts/core/GameStateManager.gd`
8. **SettingsManager** - `res://scripts/core/SettingsManager.gd`
9. **SceneTransition** - `res://scripts/ui/SceneTransition.gd`
10. **WaveManager** - `res://scripts/WaveManager.gd`
11. **InputHandler** - `res://scripts/InputHandler.gd`
12. **StatAllocationManager** - `res://scripts/items/managers/StatAllocationManager.gd`
13. **CharacterSheetManager** - `res://scripts/items/managers/CharacterSheetManager.gd`
14. **AchievementNotificationManager** - `res://scripts/singletons/AchievementNotificationManager.gd`
15. **SaveManager** - `res://scripts/core/save/SaveManager.gd`
16. **GameConfig** - `res://scripts/singletons/GameConfig.gd`
17. **PlayerTracker** - `res://scripts/singletons/PlayerTracker.gd`
18. **BiomeService** - `res://scripts/BiomeService.gd`

## Quick Reference to Documentation Files

### Core Architecture
- **[architecture.md](./architecture.md)** - System architecture and patterns
- **[scripts-analysis.md](./scripts-analysis.md)** - Detailed script analysis

### Game Structure  
- **[scenes-map.md](./scenes-map.md)** - Complete scene hierarchy

**Note**: Additional documentation files (dependency-graph.md, game-systems.md, resources-inventory.md) referenced but not yet created in this folder.

## Core Features

### 🌍 Infinite World System
- Procedural chunk generation
- Dynamic loading/unloading
- Multiple biome support
- Performance-optimized rendering

### ⚔️ Combat System
- Wave-based enemy spawning
- Spell-based combat with 5+ spell types
- Enemy AI with different behaviors
- Experience and leveling system

### 💾 Save/Load System
- Multiple save slots
- Meta-progression tracking
- Auto-save functionality
- Robust error recovery

### 🎮 Game Progression
- Character stat progression
- Wave-based difficulty scaling
- Achievement system
- Unlock progression

### 🛠️ Development Features
- Extensive debug system
- Performance monitoring
- Validation systems
- Phase-based development architecture

## Development Phases

The project follows a structured phase-based development approach:

- **Phase 3.7**: Legacy systems (compatibility maintained)
- **Phase 4**: Current stable architecture
- **Phase 5**: Environmental spell interactions (in development)
- **Phase 6+**: Future feature expansion

## Key Design Principles

1. **Event-Driven Architecture**: Loose coupling via GameEvents system
2. **Component-Based Design**: Modular systems with clear interfaces
3. **Performance Focus**: Object pooling, efficient chunk management
4. **Error Recovery**: Robust fallback mechanisms throughout
5. **Backwards Compatibility**: Support for legacy systems
6. **Extensive Testing**: Validation systems and debug tools

## Project Structure (Verified)

**Total Code Files**: 185 (56 scenes + 129 scripts)  
**Assets**: 32 PNG textures (7 sprites + 25 spell textures), 17 .tres resources  
**Architecture**: 18 script subdirectories, 11 scene subdirectories

```
/godot/Game10/
├── scenes/ (56 files)    # Scene files (.tscn)
├── scripts/ (129 files)  # GDScript files organized in 18 subdirectories
│   ├── core/             # Core game systems and save management
│   ├── entities/         # Player, enemies, NPCs
│   ├── ui/              # User interface components
│   ├── stats/           # Character progression
│   ├── debug/           # Debug and validation systems
│   ├── components/      # Player and game components
│   ├── data/            # Data structures and constants
│   ├── effects/         # Visual effects and indicators
│   ├── enemies/         # Enemy AI and projectiles
│   ├── factories/       # Object creation patterns
│   ├── items/           # Items and UI managers
│   ├── pools/           # Object pooling systems
│   ├── singletons/      # Singleton implementations
│   ├── validation/      # System validation tools
│   ├── world/           # World and chunk systems
│   ├── utils/           # Utility functions
│   ├── test/            # Test controllers and validation
│   └── tests/           # Unit tests
├── assets/              # Art, audio, resources
├── shaders/             # Custom shaders
└── project.godot        # Project configuration
```

## Current Development Focus

**Branch**: `string-formula-optimization`  
**Focus**: Performance optimization of string handling and formula calculations in the spell system.

## Getting Started

1. Open project in Godot 4.4.1
2. **MainMenu.tscn** will auto-load as entry point
3. Select save slot and start/continue game to load **Main.tscn**
4. Check console for any initialization errors
5. Use debug shortcuts (F keys) for development features

### Debug Controls
- **F-Keys**: Various debug functions (defined in InputHandler)
- **ESC**: Pause menu / game state toggle
- **Tab**: Mouse spell mode toggle

## Related Documentation

- **Phase Planning**: `/documentation/phases and plans/`
- **Installation Guides**: `/install/` (historical)
- **Current Implementation**: This documentation set