# FFS Game Codebase Analysis Guide

This document organizes the FFS game codebase into logical chunks for systematic analysis. The codebase is a complex Godot game with multiple systems and extensive documentation.

## Overview
- **Primary Language**: GDScript (Godot)
- **Main Game Directory**: `/godot/Game10/`
- **Documentation**: Extensive phase-based planning and implementation guides
- **Current Branch**: `string-formula-optimization`

## Analysis Chunks

### 1. Core Game Systems (Priority: CRITICAL)
**Files to analyze together:**
- `/godot/Game10/scripts/GameManager.gd`
- `/godot/Game10/scripts/GameEvents.gd`
- `/godot/Game10/scripts/GameplayController.gd`
- `/godot/Game10/scripts/Main.gd`
- `/godot/Game10/scripts/core/GameStateManager.gd`

**Purpose**: Core game loop, state management, event system
**Estimated Review Time**: 2-3 sessions

### 2. Player & Character Systems (Priority: HIGH)
**Files to analyze together:**
- `/godot/Game10/scripts/entities/Player.gd`
- `/godot/Game10/scripts/stats/PlayerStatSheet.gd`
- `/godot/Game10/scripts/stats/StatSheet.gd`
- `/godot/Game10/scripts/stats/ComputedStat.gd`
- `/godot/Game10/scripts/stats/ReactiveStat.gd`
- `/godot/Game10/scripts/stats/StatModifier.gd`
- `/godot/Game10/scripts/factories/PlayerBuilder.gd`

**Purpose**: Player entity, stats system, character progression
**Estimated Review Time**: 2 sessions

### 3. Combat & Spell Systems (Priority: HIGH)
**Files to analyze together:**
- `/godot/Game10/scripts/Enemy.gd`
- `/godot/Game10/scripts/SpellData.gd`
- `/godot/Game10/scripts/SpellProjectile.gd`
- `/godot/Game10/scripts/components/SpellComponent.gd`
- `/godot/Game10/scripts/components/AbilityManager.gd`
- `/godot/Game10/scripts/data/AbilityData.gd`
- `/godot/Game10/scripts/enemies/EnemyAbilities.gd`
- `/godot/Game10/scripts/enemies/EnemyAIController.gd`

**Purpose**: Combat mechanics, spell casting, enemy AI
**Estimated Review Time**: 3 sessions

### 4. Component Systems (Priority: MEDIUM)
**Files to analyze together:**
- `/godot/Game10/scripts/components/HealthComponent.gd`
- `/godot/Game10/scripts/components/MovementComponent.gd`
- `/godot/Game10/scripts/components/CameraComponent.gd`
- `/godot/Game10/scripts/components/PlayerVisuals.gd`
- `/godot/Game10/scripts/components/SpellPowerModifier.gd`
- `/godot/Game10/scripts/components/WizardAbilityManager.gd`

**Purpose**: Component architecture, modular systems
**Estimated Review Time**: 2 sessions

### 5. World & Procedural Generation (Priority: MEDIUM)
**Files to analyze together:**
- `/godot/Game10/scripts/world/UnifiedWorldManager.gd`
- `/godot/Game10/scripts/world/SimpleChunkRenderer.gd`
- `/godot/Game10/scripts/BiomeService.gd`
- `/godot/Game10/scripts/procedural/` (entire directory)
- `/godot/Game10/shaders/` (shader files)

**Purpose**: World generation, chunk loading, biome systems
**Estimated Review Time**: 3-4 sessions

### 6. UI Systems (Priority: MEDIUM)
**Files to analyze together:**
- `/godot/Game10/scripts/ui/PlayerUI.gd`
- `/godot/Game10/scripts/ui/SpellToolbar.gd`
- `/godot/Game10/scripts/ui/MainMenu.gd`
- `/godot/Game10/scripts/ui/EscapeMenu.gd`
- `/godot/Game10/scripts/ui/DraggableCharacterSheet.gd`
- `/godot/Game10/scripts/ui/stats/` (stats UI directory)

**Purpose**: User interface, HUD, menus
**Estimated Review Time**: 2 sessions

### 7. Data  Save &Management (Priority: MEDIUM)
**Files to analyze together:**
- `/godot/Game10/scripts/core/save/` (entire directory)
- `/godot/Game10/scripts/core/SettingsManager.gd`
- `/godot/Game10/scripts/data/GameConstants.gd`
- `/godot/Game10/scripts/data/EnemyData.gd`

**Purpose**: Save system, data persistence, configuration
**Estimated Review Time**: 2 sessions

### 8. Effects & Visual Systems (Priority: LOW)
**Files to analyze together:**
- `/godot/Game10/scripts/effects/` (entire directory)
- `/godot/Game10/scripts/items/XPOrb.gd`
- `/godot/Game10/scripts/ui/DamageNumber.gd`

**Purpose**: Visual effects, particles, animations
**Estimated Review Time**: 1-2 sessions

### 9. Input & Controls (Priority: LOW)
**Files to analyze together:**
- `/godot/Game10/scripts/InputHandler.gd`
- `/godot/Game10/scripts/input/` (entire directory)

**Purpose**: Input handling, controls
**Estimated Review Time**: 1 session

### 10. Debug & Testing Systems (Priority: LOW)
**Files to analyze together:**
- `/godot/Game10/scripts/debug/` (entire directory)
- `/godot/Game10/scripts/test/` (entire directory)
- `/godot/Game10/scripts/validation/` (entire directory)
- `/godot/Game10/scripts/TestRunner.gd`
- `/godot/Game10/scripts/QualityGate.gd`

**Purpose**: Development tools, testing, validation
**Estimated Review Time**: 1-2 sessions

### 11. Utilities & Singletons (Priority: LOW)
**Files to analyze together:**
- `/godot/Game10/scripts/singletons/` (entire directory)
- `/godot/Game10/scripts/utils/` (entire directory)
- `/godot/Game10/scripts/pools/` (object pooling)
- `/godot/Game10/scripts/Logger.gd`
- `/godot/Game10/scripts/LogManager.gd`

**Purpose**: Utility functions, global managers, object pooling
**Estimated Review Time**: 1 session

## Documentation Context

### Phase Documentation
The `/documentation/phases and plans/` directory contains extensive planning documents:
- **Phase 0-9**: Detailed implementation phases
- **Current Focus**: String optimization (current branch)
- **Enemy System**: Major refactor documentation in `enemy fix/`
- **Future Features**: Environmental systems, UI improvements

### Installation Guides
Multiple installation and validation guides suggest the codebase has undergone significant refactoring and has automated testing systems.

## Analysis Strategy

1. **Start with Core Systems** (Chunks 1-3) to understand fundamental architecture
2. **Review Component Systems** (Chunk 4) to understand modularity approach
3. **Analyze World Systems** (Chunk 5) if working on procedural generation
4. **Review UI/Save Systems** (Chunks 6-7) for feature work
5. **Check Debug/Utils** (Chunks 10-11) when troubleshooting

## CRITICAL ANALYSIS RULE: Active Code Only

**⚠️ MANDATORY: Analyze ONLY active code files (.gd, .tscn, .cs, etc.) - NOT documentation**

### What TO Analyze:
- ✅ **GDScript files** (.gd) - Live game logic
- ✅ **Scene files** (.tscn) - Active scene structure
- ✅ **Resource files** (.tres) - Game data
- ✅ **Shader files** (.gdshader) - Active rendering code
- ✅ **Project configuration** (project.godot) - Active settings

### What NOT to Analyze:
- ❌ **Documentation files** (.md, .txt, README files)
- ❌ **Design documents** (planning, phase docs, guides)
- ❌ **Installation guides** (setup instructions)
- ❌ **Comments within code** (use only as context, not primary analysis)
- ❌ **TODO lists or planning files**

### Documentation Usage Rule:
- **Reference Only**: Documentation can be used to understand context or verify findings
- **Never Primary Source**: Never build analysis from documentation content
- **Cross-Reference**: Use docs to confirm what you find in active code
- **Historical Context**: Phase documents can provide background but not current state

### Verification Methods:
1. **File Extension Check**: Ensure analyzing .gd, .tscn, .cs files
2. **Code Structure Validation**: Look for class declarations, extends statements
3. **Active Variables**: Verify real variable declarations with actual values
4. **Working Systems**: Confirm functional code with signal connections, method calls
5. **Live Dependencies**: Check for actual @onready references and component connections

## Key Observations

- **Heavy use of component architecture**
- **Extensive debug and validation systems**
- **Complex procedural generation system**
- **Phase-based development approach**
- **Multiple backup systems and migration guides**
- **Performance optimization focus (object pooling, LOD systems)**

## Recommended Approach for Each Session

1. Pick one chunk based on your current task
2. Read the main scripts first to understand architecture
3. Check related scene files (`.tscn`) for component relationships
4. Review any relevant documentation in `/documentation/`
5. Look for test files related to the system
6. Check for migration guides if encountering errors

This guide ensures systematic analysis while respecting context limits and maintaining focus on specific game systems.