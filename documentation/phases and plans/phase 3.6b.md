# Phase 3.6B: Simple Save Manager
**Duration**: 60 minutes  
**Goal**: Create basic save/load functionality that works with Phase 3

## What This Does

- Saves game to single file (`current_game.save`)
- Loads game from file
- Validates save data before loading
- Integrates with existing Phase 3 systems
- Auto-save every 30 seconds (optional)

## File Structure
```
scripts/core/save/
├── SaveData.gd (from Phase 3.6A)
├── SaveDataValidator.gd (from Phase 3.6A)
└── SaveManager.gd (NEW - Simple save/load)
```

## Implementation

**File: `scripts/core/save/SaveManager.gd`**

```gdscript
# SaveManager.gd - Simple save/load system for Phase 3
extends Node

# Save configuration
const SAVE_FILE_PATH = "user://current_game.save"
const AUTO_SAVE_INTERVAL = 30.0  # seconds

# Current save data
var current_save: SaveData = null
var session_start_time: float = 0.0
var auto_save_timer: float = 0.0
var auto_save_enabled: bool = false

# Signals
signal save_completed(success: bool)
signal load_completed(success: bool)
signal auto_save_triggered()

func _ready():
    print("💾 SaveManager initialized")
    session_start_time = Time.get_ticks_msec() / 1000.0
    set_process(false)  # Only process when auto-save enabled

func _process(delta):
    """Handle auto-save timer"""
    if auto_save_enabled and current_save:
        auto_save_timer += delta
        if auto_save_timer >= AUTO_SAVE_INTERVAL:
            auto_save_current_game()
            auto_save_timer = 0.0

# Core save/load operations
func create_new_save(character_name: String) -> bool:
    """Create new save with character name"""
    if character_name.strip_edges().is_empty():
        push_error("Character name cannot be empty")
        return false
    
    # Create new save data
    current_save = SaveData.new()
    current_save.character_name = SaveDataValidator.sanitize_character_name(character_name)
    
    # Initialize run data for new game
    current_save.run_data.start_new_run()
    
    print("💾 Created new save for: ", current_save.character_name)
    return true

func save_current_game() -> bool:
    """Save current game state to file"""
    if not current_save:
        push_error("No save data to save")
        return false
    
    # Update save data with current game state
    update_save_from_game_state()
    
    # Convert to JSON
    var save_dict = current_save.to_dictionary()
    var json_string = JSON.stringify(save_dict)
    
    # Write to file
    var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
    if not file:
        push_error("Failed to open save file for writing")
        save_completed.emit(false)
        return false
    
    file.store_string(json_string)
    file.close()
    
    print("💾 Game saved successfully")
    save_completed.emit(true)
    return true

func load_saved_game() -> bool:
    """Load game from file"""
    if not FileAccess.file_exists(SAVE_FILE_PATH):
        print("💾 No save file found")
        load_completed.emit(false)
        return false
    
    # Read file
    var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
    if not file:
        push_error("Failed to open save file for reading")
        load_completed.emit(false)
        return false
    
    var json_string = file.get_as_text()
    file.close()
    
    # Validate JSON
    var validation_result = SaveDataValidator.validate_json_string(json_string)
    if not validation_result.valid:
        push_error("Invalid save file: " + validation_result.error)
        load_completed.emit(false)
        return false
    
    # Create save data and load from dictionary
    current_save = SaveData.new()
    if not current_save.from_dictionary(validation_result.data):
        push_error("Failed to load save data")
        load_completed.emit(false)
        return false
    
    # Apply save data to game
    apply_save_to_game_state()
    
    print("💾 Game loaded successfully: ", current_save.character_name)
    load_completed.emit(true)
    return true

func has_save_file() -> bool:
    """Check if save file exists"""
    return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save_file() -> bool:
    """Delete current save file"""
    if not has_save_file():
        return true
    
    var success = DirAccess.open("user://").remove("current_game.save") == OK
    if success:
        current_save = null
        disable_auto_save()
        print("💾 Save file deleted")
    return success

# Auto-save functionality
func enable_auto_save():
    """Enable auto-save"""
    auto_save_enabled = true
    auto_save_timer = 0.0
    set_process(true)
    print("💾 Auto-save enabled")

func disable_auto_save():
    """Disable auto-save"""
    auto_save_enabled = false
    set_process(false)
    print("💾 Auto-save disabled")

func auto_save_current_game():
    """Perform auto-save"""
    if save_current_game():
        auto_save_triggered.emit()
        print("💾 Auto-save completed")

# Game state integration
func update_save_from_game_state():
    """Update save data from current game state"""
    if not current_save:
        return
    
    var run_data = current_save.run_data
    
    # Update session time
    var current_time = Time.get_ticks_msec() / 1000.0
    var session_time = current_time - session_start_time
    current_save.update_playtime(session_time)
    session_start_time = current_time
    
    # Update run duration
    run_data.update_run_duration()
    
    # Get player data
    var player = GameManager.get_player()
    if player:
        run_data.player_health = player.current_health
        run_data.player_max_health = player.max_health
        run_data.player_mana = player.current_mana
        run_data.player_max_mana = player.max_mana
        run_data.update_position(player.global_position)
        
        # Get player stats if stat sheet exists
        var stat_sheet = player.get_node_or_null("StatSheet")
        if stat_sheet:
            # Base stats
            run_data.base_intelligence = stat_sheet.get_stat_value("intelligence")
            run_data.base_wisdom = stat_sheet.get_stat_value("wisdom")
            run_data.base_vitality = stat_sheet.get_stat_value("vitality")
            run_data.base_dexterity = stat_sheet.get_stat_value("dexterity")
            run_data.character_level = stat_sheet.get_stat_value("level")
            
            # Reactive stats
            run_data.max_health = stat_sheet.get_stat_value("max_health")
            run_data.max_mana = stat_sheet.get_stat_value("max_mana")
            run_data.spell_damage_multiplier = stat_sheet.get_stat_value("spell_damage_multiplier")
            run_data.mana_regen_rate = stat_sheet.get_stat_value("mana_regen_rate")
            run_data.health_regen_rate = stat_sheet.get_stat_value("health_regen_rate")
            run_data.cast_speed_multiplier = stat_sheet.get_stat_value("cast_speed_multiplier")
            run_data.cooldown_reduction = stat_sheet.get_stat_value("cooldown_reduction")
            run_data.critical_chance = stat_sheet.get_stat_value("critical_chance")
            run_data.movement_speed = stat_sheet.get_stat_value("movement_speed")
            run_data.spell_projectile_speed = stat_sheet.get_stat_value("spell_projectile_speed")
            run_data.spell_range_multiplier = stat_sheet.get_stat_value("spell_range_multiplier")
    
    # Get wave progression data
    if GameManager.has_method("get_current_wave"):
        run_data.current_wave = GameManager.get_current_wave()
    
    if GameManager.has_method("get_total_kills"):
        run_data.total_kills = GameManager.get_total_kills()
    
    # Get world data if available
    var world_generator = get_tree().get_first_node_in_group("world_generator")
    if world_generator and world_generator.has_method("get_world_seed"):
        run_data.world_seed = world_generator.get_world_seed()

func apply_save_to_game_state():
    """Apply save data to current game state"""
    if not current_save:
        return
    
    var run_data = current_save.run_data
    
    # Apply to player
    var player = GameManager.get_player()
    if player:
        player.current_health = run_data.player_health
        player.max_health = run_data.player_max_health
        player.current_mana = run_data.player_mana
        player.max_mana = run_data.player_max_mana
        player.global_position = run_data.player_position
        
        # Apply stats if stat sheet exists
        var stat_sheet = player.get_node_or_null("StatSheet")
        if stat_sheet:
            # Apply base stats
            stat_sheet.set_base_stat("intelligence", run_data.base_intelligence)
            stat_sheet.set_base_stat("wisdom", run_data.base_wisdom)
            stat_sheet.set_base_stat("vitality", run_data.base_vitality)
            stat_sheet.set_base_stat("dexterity", run_data.base_dexterity)
            stat_sheet.set_base_stat("level", run_data.character_level)
    
    # Apply wave progression
    if GameManager.has_method("set_current_wave"):
        GameManager.set_current_wave(run_data.current_wave)
    
    # Apply world seed if world generator exists
    var world_generator = get_tree().get_first_node_in_group("world_generator")
    if world_generator and world_generator.has_method("set_world_seed"):
        world_generator.set_world_seed(run_data.world_seed)

# Data access methods
func get_current_save() -> SaveData:
    """Get current save data"""
    return current_save

func get_character_name() -> String:
    """Get current character name"""
    return current_save.character_name if current_save else ""

func get_playtime() -> float:
    """Get total playtime"""
    return current_save.total_playtime if current_save else 0.0

func get_current_wave() -> int:
    """Get current wave from save"""
    return current_save.run_data.current_wave if current_save else 1

func get_total_kills() -> int:
    """Get total kills from save"""
    return current_save.run_data.total_kills if current_save else 0

# Quick save/load for testing
func quick_save() -> bool:
    """Quick save (F5)"""
    if not current_save:
        create_new_save("Quick Save")
    return save_current_game()

func quick_load() -> bool:
    """Quick load (F6)"""
    return load_saved_game()

# Debug functions
func debug_print_save_info():
    """Print current save information"""
    if not current_save:
        print("💾 No save data loaded")
        return
    
    print("💾 === SAVE INFO ===")
    print("💾 Character: ", current_save.character_name)
    print("💾 Playtime: ", current_save.total_playtime, " seconds")
    print("💾 Wave: ", current_save.run_data.current_wave)
    print("💾 Kills: ", current_save.run_data.total_kills)
    print("💾 Position: ", current_save.run_data.player_position)
    print("💾 Health: ", current_save.run_data.player_health, "/", current_save.run_data.player_max_health)
    print("💾 Mana: ", current_save.run_data.player_mana, "/", current_save.run_data.player_max_mana)

func debug_create_test_save():
    """Create test save with fake data"""
    create_new_save("Test Wizard")
    current_save.run_data.current_wave = 5
    current_save.run_data.total_kills = 150
    current_save.run_data.player_position = Vector2(500, 300)
    current_save.run_data.base_intelligence = 15
    current_save.run_data.spell_damage_multiplier = 1.3
    save_current_game()

# Input handling for quick save/load (add this to _input if needed)
func _input(event):
    if OS.is_debug_build() and event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F5:
                quick_save()
            KEY_F6:
                quick_load()
            KEY_F7:
                debug_print_save_info()
            KEY_F8:
                debug_create_test_save()

# Application exit handling
func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if current_save and auto_save_enabled:
            save_current_game()
            print("💾 Emergency save on exit")
```

## Integration with GameManager

**Add to your existing `GameManager.gd` AutoLoad:**

```gdscript
# Add to GameManager.gd
var save_manager: SaveManager

func _ready():
    # Existing initialization...
    
    # Initialize save manager
    save_manager = SaveManager.new()
    add_child(save_manager)
    
    # Connect save signals if needed
    save_manager.save_completed.connect(_on_save_completed)
    save_manager.load_completed.connect(_on_load_completed)

func _on_save_completed(success: bool):
    if success:
        print("🎮 Game saved successfully")
    else:
        print("🎮 Failed to save game")

func _on_load_completed(success: bool):
    if success:
        print("🎮 Game loaded successfully")
        # Refresh UI or trigger any necessary updates
    else:
        print("🎮 Failed to load game")

# Helper methods for other systems
func start_new_game(character_name: String):
    """Start new game with character name"""
    if save_manager.create_new_save(character_name):
        save_manager.enable_auto_save()
        print("🎮 Started new game: ", character_name)

func save_game():
    """Manual save"""
    save_manager.save_current_game()

func load_game():
    """Manual load"""
    return save_manager.load_saved_game()

func has_saved_game() -> bool:
    """Check if save exists"""
    return save_manager.has_save_file()
```

## Simple Usage Examples

```gdscript
# Start new game
GameManager.start_new_game("My Wizard")

# Manual save (or just wait for auto-save)
GameManager.save_game()

# Load existing game
if GameManager.has_saved_game():
    GameManager.load_game()

# Quick testing with F5/F6 keys (debug builds only)
# F5 = Quick Save
# F6 = Quick Load  
# F7 = Print save info
# F8 = Create test save
```

## Success Criteria for Phase 3.6B

✅ **Single-file save/load** working with Phase 3 data  
✅ **Auto-save every 30 seconds** (optional)  
✅ **Manual save/load** functions available  
✅ **Validates save data** before loading  
✅ **Integrates with existing systems** (Player, GameManager, Stats)  
✅ **Debug tools** for testing (F5/F6 quick save/load)  
✅ **Emergency save** on application exit  

## Next Steps: Phase 3.6C

Once this basic save system is working, we'll add:
- Simple save/load UI buttons
- "Continue Game" vs "New Game" menu
- Save file corruption handling
- Multiple save slots (optional)

The foundation is now ready to preserve your Phase 3 progress!