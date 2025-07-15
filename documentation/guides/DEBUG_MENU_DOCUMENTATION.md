# Unified Debug System Documentation

## Overview
The UnifiedDebugSystem is a comprehensive in-game debug menu for the Wizard RPG project. It provides extensive debugging capabilities across all game systems.

## Access
- **F1** - Open/close main debug menu
- **Shift+F1** - Open/close collision debug overlay
- **F2** - Show player stats
- **F3** - Test stat system  
- **F12** - Take screenshot

## Debug Menu Features

### Panel Controls
- **Draggable** - Click and drag from the header area (top 40 pixels)
- **Resizable** - Click and drag from bottom-right corner (currently being debugged)
- **Minimizable** - Click the minimize button in header

## Debug Tabs

### 1. Player Tab
**Status Display:**
- Current health/max health
- Current mana/max mana
- Player position
- Player state

**Working Actions:**
- **Heal (H)** - Restore player to full health
- **Damage** - Deal 20 damage to player
- **Full Mana (M)** - Restore mana to full
- **God Mode (G)** - Toggle invincibility
- **Reset CDs (C)** - Reset all spell cooldowns
- **Teleport** - Teleport player to mouse position
- **Level Up** - Trigger level up event
- **+1000 XP** - Add experience points

**Stat Manipulation:**
- **+INT/WIS/VIT/DEX** - Increase stats by 5
- **Reset Stats** - Set all stats to 10
- **Max Stats** - Set all stats to 100

**Partially Working:**
- **Speed x2** - Toggle double movement speed (if MovementComponent supports it)
- **No Clip** - Toggle collision (basic implementation)

### 2. Enemy Tab
**Status Display:**
- Enemy count
- Selected enemy info
- Enemy types list

**Working Actions:**
- **Clear All** - Remove all enemies from scene
- **Disable AI** - Stop enemy movement/attacks
- **One-Hit Mode** - Enemies die in one hit

**Not Yet Implemented:**
- Enemy selection system
- Individual enemy manipulation

### 3. Game Tab
**Status Display:**
- Current wave number
- Enemy count
- Score (if implemented)
- Game state

**Working Actions:**
- **Spawn Enemy** - Spawn enemy at mouse position
- **Clear Enemies** - Remove all enemies
- **Kill 10/50 Enemies** - Add to wave kill counter
- **Next Wave** - Complete current wave and advance
- **Skip Wave** - Clear enemies and advance wave
- **Toggle Spawn** - Pause/resume enemy spawning
- **Jump to Wave 5/10** - Skip to specific wave (using WaveManager.debug_set_wave)
- **+Goblin/Skeleton/Orc** - Spawn specific enemy type at mouse
- **Spawn x10** - Spawn 10 random enemies
- **Freeze All** - Stop all enemy physics/movement

**Not Yet Implemented:**
- **Force Boss Wave** - Boss system not implemented
- **Spawn Elite** - Elite enemies not implemented

### 4. Debug Tab
**System Info:**
- FPS display
- Memory usage
- Performance metrics

**Options:**
- **Show FPS** - Toggle FPS display
- **Show Collision Shapes** - Toggle collision visualization
- **Verbose Logging** - Enable detailed logging
- **Performance Monitor** - Track performance metrics
- **Clear Debug Log** - Clear debug output

### 5. Spells Tab
**Display:**
- Spell system status
- Active spell info

**Working Actions:**
- **Restore Mana** - Fill mana to maximum
- **Reset Cooldowns** - Clear all spell cooldowns
- **Test All Spells** - Cast each spell with delay
- **Cast Spell 1-5** - Cast specific spell by index
- **Damage x10/x100** - Set spell damage multiplier (stored as meta)

**Partially Working:**
- **Toggle Infinite Mana** - If HealthComponent supports infinite_mana_enabled

**Not Yet Implemented (UI exists but no effect):**
- **Toggle No Cooldowns** - Requires SpellComponent modification
- **Toggle Rapid Fire** - Requires casting system modification
- **Toggle Multi-Cast** - Requires projectile system modification
- **Toggle Homing/Piercing/Explosions/Giant** - Requires spell effect system

### 6. Testing Tab
**Test Runner:**
- **Run All Tests** - Execute comprehensive test suite
- **Phase Validation** - Validate game phases
- **Collision Tests** - Test collision layers
- **Signal Tests** - Test event system
- **Performance Tests** - Stress test with many enemies

**Additional Testing (proposed):**
- **Validate Game State** - Check all systems
- **Test Damage Numbers** - Display damage popups
- **Spawn All Enemy Types** - Test each enemy type
- **Rapid Spell Test** - Cast spells rapidly
- **Force Milestone Check** - Test wave rewards
- **Add 100 Kills** - Quick wave progression

## Hotkey Reference

### Global Hotkeys
- **F1** - Toggle main debug menu
- **Shift+F1** - Toggle collision debug
- **F2** - Show player stats
- **F3** - Test stat system
- **F12** - Take screenshot

### Debug Hotkeys (when menu open)
- **H** - Heal player
- **M** - Restore mana
- **G** - Toggle god mode
- **C** - Reset cooldowns
- **K** - Kill 10 enemies
- **Shift+K** - Kill 50 enemies

### Number Keys
- **1-5** - Cast spell by index

## Implementation Notes

### Working Systems
1. **Player manipulation** - Health, mana, position, stats
2. **Enemy spawning** - Via EnemySpawner class
3. **Wave control** - Via WaveManager debug methods
4. **Spell casting** - Via SpellComponent
5. **Event system** - Via GameEvents signals
6. **Collision debug** - Visual overlay system

### Systems Requiring Implementation
1. **Spell modifiers** - Need hooks in SpellComponent
2. **Enemy selection** - Need targeting system
3. **Boss waves** - Boss system not implemented
4. **Elite enemies** - Special enemy types not implemented
5. **Some stat modifications** - Need deeper integration

### Known Issues
1. **Resize functionality** - Panel resizing not working properly
2. **Some toggle states** - Not all toggles have visual feedback
3. **Performance monitoring** - Basic implementation only

## Debug Logging

The system uses categorized logging:
- `LogCategory.PLAYER` - Player-related debug info
- `LogCategory.ENEMY` - Enemy system debug info
- `LogCategory.SPELLS` - Spell system debug info
- `LogCategory.GAMEMANAGER` - Game state debug info
- `LogCategory.VISUAL` - Visual effects debug info

## Best Practices

1. **Test in development** - Don't ship with debug menu enabled
2. **Check console** - Debug output provides detailed feedback
3. **Save before testing** - Some debug commands can break game state
4. **Use hotkeys** - Faster than clicking buttons
5. **Monitor performance** - Watch FPS when spawning many enemies

## Future Enhancements

1. **Command Console** - Text-based command input
2. **State Save/Load** - Quick save/restore for testing
3. **Record/Replay** - Input recording for reproducible tests
4. **Network Debug** - Multiplayer debugging tools
5. **Asset Validation** - Check for missing resources
6. **Profiler Integration** - Detailed performance analysis