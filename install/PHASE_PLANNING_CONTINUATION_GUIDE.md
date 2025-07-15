# PHASE PLANNING CONTINUATION GUIDE
## For New Chat Sessions - Wizard RPG Development

### 🎯 **CURRENT PROJECT STATUS**

**Project**: Wizard RPG Clean Rebuild  
**Location**: `C:\FFS\godot\Game10` (ONLY active project)  
**Engine**: Godot 4.4.1  
**Architecture**: Component-based with autoload singletons  

### 📋 **COMPLETED PHASES**

- ✅ **Phase 0**: Infrastructure (16 autoloads, collision layers, input system)
- ✅ **Phase 1**: Player Movement (WASD, dodge, health/mana systems)  
- ✅ **Phase 2**: Spell System (5 spells, projectiles, mana consumption)
- ✅ **Phase 3**: Enemy System (5 enemies, waves, AI, stats)
- ✅ **Phase 4**: Game Foundation (save system, main menu, UI)
- 🔄 **Phase 5**: Infinite World System (IN PROGRESS - Day 1 complete)

### 🌍 **PHASE 5 CURRENT STATUS**

**Day 1 COMPLETED**:
- ✅ HeavyChunkLoader autoload (50 chunk preloading)
- ✅ ChunkGenerator with weighted rarity system
- ✅ RareChunkTracker (navigation markers every 50 kills)
- ✅ GameManager integration
- ✅ Loading screen UI
- ✅ Full game startup integration

**Remaining Days 2-8**: Chunk rendering, biome visuals, terrain interaction, enemy spawning integration, save system integration, performance optimization, testing.

### 🎮 **GAME VISION ESTABLISHED**

**Core Concept**: Infinite continuous world with chunk-based generation
- **No discrete arenas** - seamless exploration
- **Weighted rarity system** for biomes and POIs
- **Heavy preloading** (50 chunks at start, 5 ahead during runtime)
- **Save system** maintains 3x3 chunks around player
- **Wave system** as background difficulty only
- **All enemy types everywhere** (biome preferences noted for future)
- **Rare chunk markers** every 50 kills for navigation

### 📝 **PLANNING METHODOLOGY**

#### **Step 1: Context Review**
Read these key files:
- `/mnt/c/FFS/install/PHASE_5_FINAL_IMPLEMENTATION.md` - Current phase details
- `/mnt/c/FFS/install/REVISED_PHASE_PLAN.md` - Overall 5-9 plan
- `/mnt/c/FFS/CLAUDE.md` - Project instructions and standards

#### **Step 2: Question Generation Pattern**
When planning future phases, use this format:

```
# PHASE X IMPLEMENTATION QUESTIONS
# [Phase Title] - Specific Details

================================================================================
                          [MAJOR CATEGORY NAME]
================================================================================

1. [SPECIFIC TOPIC]:
   [Detailed question about implementation choice]
   A) [Option A with pros/cons]
   B) [Option B with pros/cons]  
   C) [Option C with pros/cons]
   
   Answer: _______________________________________________________________

2. [NEXT TOPIC]:
   [Question about integration or priority]
   - [Sub-question about technical approach]
   - [Sub-question about user experience]
   - [Sub-question about performance impact]
   
   Answer: _______________________________________________________________
```

#### **Step 3: User Feedback Integration**
The user prefers:
- **Detailed questions in .txt files** (easier to read and answer)
- **Specific implementation choices** with clear options
- **Technical depth** with architecture considerations
- **Integration awareness** (how does this affect other systems?)
- **Performance considerations** explicitly called out

### 🔧 **TECHNICAL ARCHITECTURE CONTEXT**

#### **Current Systems**:
- **16 Autoload Singletons** (see project.godot)
- **Component-based entities** (HealthComponent, MovementComponent, etc.)
- **Event-driven architecture** via GameEvents singleton
- **Phase 4 save system** with RunSaveManager and MetaSaveManager
- **Wave progression** via kill count (not location-based)

#### **Key Integration Points**:
- **GameManager** - Central state management and player tracking
- **WaveManager** - Kill-based difficulty scaling (background only)
- **SaveManager** - Persistent game state
- **GameEvents** - Signal-based communication
- **EnemySpawner** - Spawn system that needs chunk integration

### 📊 **REMAINING PHASES OVERVIEW**

Based on established plan:

**Phase 6**: Loot & Equipment System (5 days)
- Diablo-style grid inventory (8 equipment slots)
- Item modification of spell behavior
- Elemental affixes and crafting materials

**Phase 7**: Hub World & Persistent Progression (4 days)  
- Menu-driven hub with merchants and upgrades
- Talent trees and spell customization
- Portal system for zone selection

**Phase 8**: Dungeon System & Special Areas (7 days)
- Traditional dungeons that pause wave system
- Hand-crafted encounters vs procedural spawning
- Unique rewards and puzzle elements

**Phase 9**: Endgame & Advanced Mechanics (5 days)
- Prestige system and challenge modes
- 50+ spell combinations with left+right mouse
- Infinite progression scaling

### 🎯 **PLANNING SESSION WORKFLOW**

#### **For Immediate Next Planning**:

1. **Ask**: "What phase should we plan next? Phase 5 Day 2+ or Phase 6?"

2. **If Phase 5 continuation**:
   - Review Day 1 implementation 
   - Plan Days 2-8 with specific technical tasks
   - Focus on chunk rendering and biome systems

3. **If Phase 6 planning**:
   - Create detailed questions about loot system
   - Focus on inventory UI, item generation, spell modification
   - Consider integration with existing spell component system

#### **For Each Planning Session**:

1. **Generate 15-25 questions** covering:
   - Technical implementation choices
   - UI/UX design decisions  
   - Integration with existing systems
   - Performance and scalability
   - Future-proofing for later phases

2. **Save questions** to `/mnt/c/FFS/install/PHASE_X_QUESTIONS.txt`

3. **After user answers**, create detailed implementation plan as:
   `/mnt/c/FFS/install/PHASE_X_FINAL_IMPLEMENTATION.md`

### 🚨 **CRITICAL PROJECT RULES**

#### **File Management**:
- **NEVER touch** `/mnt/c/FFS/godot/Game10` files during planning
- **Save all plans** to `/mnt/c/FFS/install/` folder
- **Create installation-ready files** in `/mnt/c/FFS/edited/[feature_name]/`

#### **Development Standards**:
- **Component-based architecture** - follow existing patterns
- **Event-driven signals** - use GameEvents for communication
- **Performance first** - 60 FPS minimum target
- **Save system integration** - all features must be saveable
- **Godot 4.4.1 compatibility** - verify all API usage

#### **Quality Gates**:
- **No regression** - preserve all existing functionality
- **Architectural integrity** - maintain component boundaries  
- **Documentation** - include installation guides and changelogs
- **Testing** - provide test scripts for major features

### 📚 **REFERENCE MATERIALS**

#### **Key Files to Reference**:
- `CLAUDE.md` - Project instructions and standards
- `COMMON_GODOT_ERRORS_GUIDE.md` - Error patterns to avoid
- `project.godot` - Current autoload configuration
- `scripts/GameManager.gd` - Central state management
- `scripts/WaveManager.gd` - Wave progression system

#### **Documentation Pattern**:
```
# [FileName].gd
# Purpose: [Clear description]
# Godot Version: 4.4.1 (verified via official docs)
# Dependencies: [List other systems]
# API References: [Official documentation sections]
```

### 🎬 **GETTING STARTED**

To continue development planning, start with:

1. **Read current status**: Check the latest implementation files
2. **Choose next phase**: Decide what to plan (Phase 5 continuation or Phase 6)
3. **Generate questions**: Create detailed .txt file with implementation questions
4. **Get user feedback**: User answers questions with specific preferences
5. **Create implementation plan**: Detailed day-by-day plan with code examples

**Remember**: The user values thorough planning, specific technical choices, and detailed implementation guidance. Always provide concrete options and clear integration points with existing systems.

---

*This guide ensures continuity across chat sessions while maintaining the established development methodology and project standards.*