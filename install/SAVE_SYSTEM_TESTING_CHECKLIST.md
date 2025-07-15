# Save System Testing Checklist - Phase 4 Wizard RPG
*Comprehensive Testing Guide for Save System Refactor*

## 🎯 **TESTING OVERVIEW**

This checklist ensures thorough testing of the refactored save system across all phases of implementation. Use this document to validate each component and catch issues early.

---

## 📋 **PRE-IMPLEMENTATION TESTING**

### **Current System Baseline**
- [ ] **Document current save file locations**
  ```bash
  ls -la ~/.local/share/godot/app_userdata/*/
  find . -name "*.save" -o -name "*.dat"
  ```
- [ ] **Test existing save functionality**
  - [ ] Save current game works
  - [ ] Load existing saves works
  - [ ] Auto-save functions properly
  - [ ] No error messages in console
- [ ] **Backup existing save files**
  ```bash
  mkdir -p /mnt/c/FFS/backups/player_saves_$(date +%Y%m%d)
  cp -r ~/.local/share/godot/app_userdata/* /mnt/c/FFS/backups/player_saves_*/
  ```
- [ ] **Record performance baseline**
  - [ ] Save time: _____ seconds
  - [ ] Load time: _____ seconds
  - [ ] File sizes: _____ KB

---

## 🔧 **PHASE 1 TESTING: CONSOLIDATION**

### **Disable Conflicting Systems**
- [ ] **MetaSaveManager disabled**
  - [ ] Warning messages appear in console
  - [ ] All public functions return early
  - [ ] No new save files created by MetaSaveManager
  - [ ] Check: `grep -n "SYSTEM_DISABLED" scripts/core/MetaSaveManager.gd`

- [ ] **RunSaveManager disabled**
  - [ ] Warning messages appear in console
  - [ ] All public functions return early
  - [ ] No new run save files created
  - [ ] Check: `grep -n "SYSTEM_DISABLED" scripts/core/RunSaveManager.gd`

### **File Path Consistency**
- [ ] **SaveManager uses multi-slot pattern consistently**
  - [ ] No more single file path switching
  - [ ] All saves go to `user://save_slot_X.save` format
  - [ ] Current slot tracking works properly
  - [ ] Check save file names in user directory

### **Basic Save/Load Functionality**
- [ ] **Save to specific slots**
  - [ ] Save to slot 0: `SaveManager.save_to_slot(0)`
  - [ ] Save to slot 1: `SaveManager.save_to_slot(1)`
  - [ ] Save to slot 4: `SaveManager.save_to_slot(4)`
  - [ ] Verify files created: `save_slot_0.save`, etc.

- [ ] **Load from specific slots**
  - [ ] Load from slot 0: `SaveManager.load_from_slot(0)`
  - [ ] Load from slot 1: `SaveManager.load_from_slot(1)`
  - [ ] Player position restored correctly
  - [ ] Health/mana values restored correctly

- [ ] **Error handling for invalid slots**
  - [ ] `SaveManager.save_to_slot(-1)` returns false
  - [ ] `SaveManager.save_to_slot(99)` returns false
  - [ ] `SaveManager.load_from_slot(-1)` returns false
  - [ ] Appropriate error messages logged

### **Integration Verification**
- [ ] **No conflicts between save systems**
  - [ ] Only SaveManager creates save files
  - [ ] No duplicate or conflicting save data
  - [ ] UI integrates with SaveManager only

---

## 🔧 **PHASE 2 TESTING: SIMPLIFICATION**

### **Simplified State Restoration**
- [ ] **Player state restoration**
  - [ ] Player position restored accurately
  - [ ] Health/mana values correct
  - [ ] Player stats (Int, Wis, Vit, Dex) restored
  - [ ] XP and level progression intact
  - [ ] Available stat points preserved

- [ ] **Game progression restoration**
  - [ ] Current wave number correct
  - [ ] Total kills count accurate
  - [ ] Kills this wave preserved
  - [ ] WaveManager properly notified
  - [ ] Enemy spawning resumes correctly

- [ ] **World state clearing**
  - [ ] All enemies cleared before load
  - [ ] All projectiles cleared before load
  - [ ] Telegraph indicators cleared
  - [ ] No leftover entities from previous session

### **Input System Restoration**
- [ ] **Input handler re-enabled**
  - [ ] Player can move after load
  - [ ] Spell casting works after load
  - [ ] All input keys respond properly
  - [ ] No input lag or unresponsiveness

- [ ] **Player processing restored**
  - [ ] Player physics processing enabled
  - [ ] Player can interact with world
  - [ ] Collision detection works
  - [ ] Animation systems functional

### **Game System Integration**
- [ ] **GameManager state**
  - [ ] Game state set to PLAYING after load
  - [ ] Player reference updated correctly
  - [ ] Game statistics preserved

- [ ] **Enemy spawning system**
  - [ ] Enemy spawner restarted properly
  - [ ] Spawn rates appropriate for current wave
  - [ ] No duplicate enemies spawning
  - [ ] Spawn statistics reset correctly

### **Error Recovery**
- [ ] **Missing player handling**
  - [ ] Player respawned if missing during load
  - [ ] Player added to correct groups
  - [ ] Player components initialized properly

- [ ] **Corrupted save handling**
  - [ ] Invalid JSON detected and handled
  - [ ] Backup restoration when needed
  - [ ] User notified of corruption issues
  - [ ] Graceful degradation when possible

---

## 🔧 **PHASE 3 TESTING: POLISH & TESTING**

### **UI Integration**
- [ ] **SaveLoadMenu functionality**
  - [ ] Slot selection works correctly
  - [ ] Save progress feedback displayed
  - [ ] Load progress feedback displayed
  - [ ] Error messages shown to user
  - [ ] Menu closes properly after operations

- [ ] **Pause state management**
  - [ ] Game pauses during save/load UI
  - [ ] Game unpauses after UI closes
  - [ ] No stuck pause states
  - [ ] Input restored after unpause

### **Auto-Save System**
- [ ] **Auto-save functionality**
  - [ ] Auto-save triggers at configured intervals
  - [ ] Auto-save doesn't interfere with manual saves
  - [ ] Auto-save uses current slot correctly
  - [ ] Auto-save can be enabled/disabled

- [ ] **Auto-save performance**
  - [ ] No gameplay interruption during auto-save
  - [ ] Frame rate stable during auto-save
  - [ ] Auto-save completion feedback

### **Error Handling & Recovery**
- [ ] **User-friendly error messages**
  - [ ] Clear error descriptions
  - [ ] Helpful troubleshooting suggestions
  - [ ] Appropriate message duration
  - [ ] No technical jargon in user messages

- [ ] **Backup and recovery**
  - [ ] Backups created before overwriting saves
  - [ ] Backup restoration works when needed
  - [ ] Multiple backup versions maintained
  - [ ] Old backups cleaned up appropriately

---

## 🧪 **COMPREHENSIVE TESTING SCENARIOS**

### **Scenario 1: New Player Experience**
1. [ ] Start new game
2. [ ] Play for 5-10 minutes
3. [ ] Save to slot 1
4. [ ] Verify save file created
5. [ ] Close game and restart
6. [ ] Load from slot 1
7. [ ] Verify all progress restored

### **Scenario 2: Multiple Save Slots**
1. [ ] Create saves in slots 0, 1, 2
2. [ ] Load from slot 1
3. [ ] Make different progress
4. [ ] Save to slot 3
5. [ ] Load from slot 0
6. [ ] Verify different game state
7. [ ] Load from slot 3
8. [ ] Verify recent progress

### **Scenario 3: Save Overwriting**
1. [ ] Create save in slot 2
2. [ ] Note current wave/stats
3. [ ] Make significant progress
4. [ ] Save to slot 2 (overwrite)
5. [ ] Verify new progress saved
6. [ ] Load from slot 2
7. [ ] Verify new data, not old data

### **Scenario 4: Error Recovery**
1. [ ] Create valid save in slot 1
2. [ ] Manually corrupt save file
3. [ ] Attempt to load corrupted save
4. [ ] Verify error handling
5. [ ] Check if backup restoration offered
6. [ ] Verify game remains stable

### **Scenario 5: Performance Under Load**
1. [ ] Reach high wave number (10+)
2. [ ] Have multiple enemies active
3. [ ] Trigger save operation
4. [ ] Monitor frame rate during save
5. [ ] Verify save completes successfully
6. [ ] Test load with complex game state

### **Scenario 6: Auto-Save Integration**
1. [ ] Enable auto-save
2. [ ] Play for auto-save interval
3. [ ] Verify auto-save triggers
4. [ ] Manually save during auto-save timer
5. [ ] Verify no conflicts
6. [ ] Check both saves are valid

---

## 📊 **PERFORMANCE TESTING**

### **Benchmarking Tests**
- [ ] **Save Performance**
  ```gdscript
  # Run in debug console:
  var results = SaveManager.run_performance_benchmark()
  print("Save performance: ", results)
  ```
  - [ ] Average save time: _____ seconds (target: <2s)
  - [ ] Maximum save time: _____ seconds (target: <5s)
  - [ ] Save file size: _____ KB

- [ ] **Load Performance**
  - [ ] Average load time: _____ seconds (target: <3s)
  - [ ] Maximum load time: _____ seconds (target: <7s)
  - [ ] Memory usage after load: _____ MB

### **Stress Testing**
- [ ] **Large Save Files**
  - [ ] Play to wave 20+ with high stats
  - [ ] Save with many unlocked spells
  - [ ] Load complex save files
  - [ ] Verify no performance degradation

- [ ] **Rapid Save/Load Cycles**
  - [ ] Save and load 10 times rapidly
  - [ ] Monitor memory usage
  - [ ] Check for memory leaks
  - [ ] Verify data consistency

---

## 🔍 **VALIDATION TESTING**

### **Data Integrity**
- [ ] **Save Data Validation**
  ```gdscript
  # Test save validation:
  var results = SaveManager.test_save_system()
  print("Validation results: ", results)
  ```
  - [ ] All validation tests pass
  - [ ] No data corruption detected
  - [ ] Save/load cycle preserves all data

- [ ] **Cross-Save Compatibility**
  - [ ] Saves created on different sessions load correctly
  - [ ] No version conflicts
  - [ ] Migration works for existing saves

### **Edge Case Testing**
- [ ] **Boundary Conditions**
  - [ ] Save at level 1 with minimal progress
  - [ ] Save at maximum level with full progress
  - [ ] Save with 0 health (edge case)
  - [ ] Save with maximum stat values

- [ ] **Invalid Data Handling**
  - [ ] Attempt save with invalid character name
  - [ ] Attempt save with negative values
  - [ ] Load save with missing data fields
  - [ ] Load save with extra unknown fields

---

## 🐛 **DEBUGGING & TROUBLESHOOTING**

### **Common Issues Checklist**
- [ ] **Save Files Not Created**
  - Check user directory permissions
  - Verify disk space available
  - Check for conflicting processes
  - Review console error messages

- [ ] **Load Fails**
  - Verify save file exists and is readable
  - Check JSON validity with external validator
  - Review save data structure
  - Test with known good save file

- [ ] **Input Not Restored**
  - Check InputHandler autoload status
  - Verify player node process modes
  - Check pause state after load
  - Review input restoration code

- [ ] **Game State Inconsistent**
  - Verify GameManager state updates
  - Check WaveManager integration
  - Review enemy spawner restart
  - Monitor console for state errors

### **Debug Console Commands**
```gdscript
# Get save system status:
print(SaveManager.get_save_system_status())

# Run comprehensive tests:
SaveManager.test_save_system()

# Performance benchmark:
SaveManager.run_performance_benchmark()

# Debug save data:
SaveManager.debug_print_save_info()

# Validate specific save:
var info = SaveDataValidator.get_save_file_info("user://save_slot_0.save")
print(info)
```

---

## ✅ **FINAL VALIDATION**

### **Sign-Off Checklist**
- [ ] **All Phase 1 tests passed**
- [ ] **All Phase 2 tests passed**
- [ ] **All Phase 3 tests passed**
- [ ] **Performance targets met**
- [ ] **No critical bugs remain**
- [ ] **User experience is smooth**
- [ ] **Documentation updated**
- [ ] **Code review completed**

### **Acceptance Criteria**
- [ ] Save success rate: 99.9%+
- [ ] Load success rate: 99.9%+
- [ ] Save time: <2 seconds average
- [ ] Load time: <3 seconds average
- [ ] No data loss incidents
- [ ] Clean error handling
- [ ] Intuitive user interface

---

## 📝 **TEST EXECUTION LOG**

### **Phase 1 Testing Results**
```
Date: ___________
Tester: ___________
Results:
- [ ] All tests passed
- [ ] Issues found: ___________
- [ ] Issues resolved: ___________
```

### **Phase 2 Testing Results**
```
Date: ___________
Tester: ___________
Results:
- [ ] All tests passed
- [ ] Issues found: ___________
- [ ] Issues resolved: ___________
```

### **Phase 3 Testing Results**
```
Date: ___________
Tester: ___________
Results:
- [ ] All tests passed
- [ ] Issues found: ___________
- [ ] Issues resolved: ___________
```

### **Final Validation**
```
Date: ___________
Reviewer: ___________
Status: [ ] APPROVED / [ ] NEEDS REVISION
Notes: ___________
```

---

*This comprehensive testing checklist ensures the save system refactor meets all quality and performance requirements. Document all test results and address any issues before proceeding to the next phase.*