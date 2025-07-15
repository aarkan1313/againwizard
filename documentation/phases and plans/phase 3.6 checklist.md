# Phase 3.6: Save & Load System - Implementation Checklist

## 🎯 **Phase 3.6A: Save Data Structure** (45 minutes)

### File Creation
- [ ] Create `scripts/core/save/` directory
- [ ] Create `scripts/core/save/SaveData.gd`
- [ ] Create `scripts/core/save/SaveDataValidator.gd`

### SaveData.gd Implementation
- [ ] Add SaveData class with save version and metadata
- [ ] Add RunData class with Phase 3 player state
- [ ] Add player stats (Intelligence, Wisdom, Vitality, Dexterity, Level)
- [ ] Add reactive stats (max_health, max_mana, spell_damage_multiplier, etc.)
- [ ] Add wave progression (current_wave, waves_completed, total_kills)
- [ ] Add world state (world_seed, player_position, distance_from_spawn)
- [ ] Add session statistics (run_duration, damage_dealt, spells_cast)
- [ ] Add equipment placeholders (equipped_items, inventory_items)
- [ ] Add spell progression (unlocked_spells, spell_levels)
- [ ] Implement `to_dictionary()` method for JSON serialization
- [ ] Implement `from_dictionary()` method for loading
- [ ] Implement `is_valid()` validation method
- [ ] Add helper methods (start_new_run, add_kill, advance_wave, etc.)

### SaveDataValidator.gd Implementation
- [ ] Add `validate_json_string()` method
- [ ] Add `validate_save_file_path()` method
- [ ] Add `can_create_save_file()` method
- [ ] Add `sanitize_character_name()` method
- [ ] Add `generate_safe_filename()` method

### Testing Phase 3.6A
- [ ] Create test SaveData instance
- [ ] Test `to_dictionary()` and `from_dictionary()` round-trip
- [ ] Test validation methods with good and bad data
- [ ] Test character name sanitization
- [ ] Verify all Phase 3 stats are included

---

## 🎯 **Phase 3.6B: Save Manager** (60 minutes)

### File Creation
- [ ] Create `scripts/core/save/SaveManager.gd`

### SaveManager.gd Core Implementation
- [ ] Add SaveManager class extending Node
- [ ] Add constants (SAVE_FILE_PATH, AUTO_SAVE_INTERVAL)
- [ ] Add current save data variables
- [ ] Add signals (save_completed, load_completed, auto_save_triggered)
- [ ] Implement `_ready()` and `_process()` for auto-save timer

### Core Save/Load Operations
- [ ] Implement `create_new_save(character_name)` method
- [ ] Implement `save_current_game()` method
- [ ] Implement `load_saved_game()` method
- [ ] Implement `has_save_file()` method
- [ ] Implement `delete_save_file()` method

### Auto-Save System
- [ ] Implement `enable_auto_save()` method
- [ ] Implement `disable_auto_save()` method
- [ ] Implement `auto_save_current_game()` method
- [ ] Add auto-save timer processing in `_process()`

### Game State Integration
- [ ] Implement `update_save_from_game_state()` method
- [ ] Get player data (health, mana, position)
- [ ] Get player stats from StatSheet if available
- [ ] Get wave progression from GameManager
- [ ] Get world data from WorldGenerator if available
- [ ] Implement `apply_save_to_game_state()` method
- [ ] Apply player data back to game
- [ ] Apply stats back to StatSheet
- [ ] Apply wave progression to GameManager

### Utility Methods
- [ ] Add data access methods (get_current_save, get_character_name, etc.)
- [ ] Add quick save/load methods (F5/F6 for debugging)
- [ ] Add debug functions (debug_print_save_info, debug_create_test_save)
- [ ] Add input handling for debug keys
- [ ] Add emergency save on application exit

### GameManager Integration
- [ ] Add SaveManager to GameManager as child node
- [ ] Add helper methods to GameManager (start_new_game, save_game, load_game)
- [ ] Connect save/load signals to GameManager
- [ ] Add `has_saved_game()` method to GameManager

### Testing Phase 3.6B
- [ ] Test creating new save with character name
- [ ] Test manual save/load with F5/F6 keys
- [ ] Test auto-save timer (30 second intervals)
- [ ] Test save data persistence between game sessions
- [ ] Test emergency save on application exit
- [ ] Verify player position, health, mana save/load correctly
- [ ] Verify wave progression saves/loads correctly
- [ ] Test debug functions (F7 print info, F8 create test save)

---

## 🎯 **Phase 3.6C: Simple Save/Load UI** (45 minutes)

### Scene Creation
- [ ] Create `scenes/ui/MainMenu.tscn`
- [ ] Create `scenes/ui/PauseMenu.tscn` (or update existing)
- [ ] Set up MainMenu scene structure (VBox with title, buttons)
- [ ] Set up PauseMenu scene structure (VBox with pause options)
- [ ] Add NewGameDialog to MainMenu for character name input

### Script Creation
- [ ] Create `scripts/ui/MainMenuController.gd`
- [ ] Create `scripts/ui/PauseMenuController.gd` (or update existing)

### MainMenuController.gd Implementation
- [ ] Add UI references (@onready variables)
- [ ] Implement `setup_ui()` method
- [ ] Implement `connect_signals()` method
- [ ] Implement `update_button_states()` method (disable Continue if no save)
- [ ] Implement `_on_continue_pressed()` method
- [ ] Implement `_on_new_game_pressed()` method (show character dialog)
- [ ] Implement `_on_quit_pressed()` method
- [ ] Implement `_on_start_adventure_pressed()` method
- [ ] Implement character name validation
- [ ] Implement `start_game()` scene transition

### PauseMenuController.gd Implementation
- [ ] Add UI references (@onready variables)
- [ ] Implement `setup_ui()` method
- [ ] Implement `connect_signals()` method
- [ ] Implement `update_button_states()` method
- [ ] Implement `_on_resume_pressed()` method
- [ ] Implement `_on_save_pressed()` method
- [ ] Implement `_on_load_pressed()` method
- [ ] Implement `_on_main_menu_pressed()` method
- [ ] Implement save/load feedback system
- [ ] Add `show_feedback()` method for user messages
- [ ] Connect to SaveManager signals for feedback

### Input System
- [ ] Add `pause_game` action to Input Map (Escape key)
- [ ] Add pause input handling to main game scene
- [ ] Test pause menu toggle with Escape key

### UI Polish
- [ ] Add feedback messages for save/load operations
- [ ] Add button state management (disable during operations)
- [ ] Add loading indicators ("Saving..." text on buttons)
- [ ] Add color-coded feedback (green success, red error)

### Integration
- [ ] Add PauseMenu to main game scene
- [ ] Connect pause input to PauseMenu controller
- [ ] Test scene transitions (MainMenu → Game → MainMenu)
- [ ] Update main scene controller to handle pause menu

### Testing Phase 3.6C
- [ ] Test new game flow (MainMenu → Character Creation → Game)
- [ ] Test continue game flow (MainMenu → Load → Game)
- [ ] Test pause menu (Escape → Save/Load/Resume)
- [ ] Test save operation feedback (success/error messages)
- [ ] Test load operation feedback and game state restoration
- [ ] Test button state management (Continue disabled when no save)
- [ ] Test character name validation (empty name rejection)
- [ ] Test scene transitions work correctly

---

## 🔧 **Integration & Final Testing** (30 minutes)

### Complete System Testing
- [ ] **New Player Flow**: MainMenu → New Game → Enter Name → Play → Save → Quit → Continue
- [ ] **Save Persistence**: Verify position, health, mana, stats, wave progress all save/load
- [ ] **Auto-Save**: Let game run for 30+ seconds, verify auto-save occurs
- [ ] **Manual Save**: Use pause menu save, verify success feedback
- [ ] **Load Game**: Use pause menu load, verify game state restores correctly
- [ ] **Multiple Sessions**: Save, quit completely, restart, continue game
- [ ] **Error Handling**: Test with corrupted save file, verify graceful failure

### Debug Verification
- [ ] F5 Quick Save works and shows console confirmation
- [ ] F6 Quick Load works and restores game state
- [ ] F7 Print Save Info shows correct data
- [ ] F8 Create Test Save generates valid test data
- [ ] Console shows save/load operations clearly

### Performance & Polish
- [ ] Auto-save doesn't cause frame drops or stutters
- [ ] Save/load operations complete quickly (< 1 second)
- [ ] UI feedback is clear and responsive
- [ ] No memory leaks or resource issues
- [ ] Save file size is reasonable (< 100KB for Phase 3 data)

### Documentation
- [ ] Add comments to all major functions
- [ ] Document save file format and structure
- [ ] Create usage examples for other developers
- [ ] Note integration points for future features

---

## ✅ **Success Criteria**

**Phase 3.6 is complete when:**

- [ ] **Save System Works**: Can save and load all Phase 3 game state
- [ ] **Auto-Save Functions**: Game saves automatically every 30 seconds
- [ ] **UI is Functional**: Main menu and pause menu work correctly
- [ ] **Data Persistence**: Player can quit and resume exactly where they left off
- [ ] **Error Handling**: System gracefully handles missing or corrupted saves
- [ ] **Debug Tools**: F5/F6/F7/F8 debug functions work for testing
- [ ] **Future Ready**: Save structure can accommodate equipment, meta-progression, etc.

**Critical Test**: Start new game, play for 2+ minutes, advance several waves, manually save, quit game completely, restart, continue - everything should be exactly as you left it.

---

## 📋 **Quick Reference**

### Key Files Created:
- `scripts/core/save/SaveData.gd` - Data structure
- `scripts/core/save/SaveDataValidator.gd` - Validation helpers  
- `scripts/core/save/SaveManager.gd` - Save/load operations
- `scripts/ui/MainMenuController.gd` - Main menu with continue/new game
- `scripts/ui/PauseMenuController.gd` - Pause menu with save/load
- `scenes/ui/MainMenu.tscn` - Main menu scene
- `scenes/ui/PauseMenu.tscn` - Pause menu scene

### Debug Controls:
- **F5** = Quick Save
- **F6** = Quick Load  
- **F7** = Print Save Info
- **F8** = Create Test Save
- **Escape** = Toggle Pause Menu

### Save File Location:
- `user://current_game.save` (single file for Phase 3)