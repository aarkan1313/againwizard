# Phase 3.6C: Simple Save/Load UI
**Duration**: 45 minutes  
**Goal**: Add basic UI for save/load functionality to Phase 3

## What This Adds

- Simple "Save Game" and "Load Game" buttons in pause menu
- "Continue" vs "New Game" on main menu (if save exists)
- Character name input for new games
- Basic feedback messages

## File Structure
```
scenes/ui/
├── PauseMenu.tscn (UPDATE - add save/load buttons)
├── MainMenu.tscn (NEW - simple main menu)
└── NewGameDialog.tscn (NEW - character name input)

scripts/ui/
├── PauseMenuController.gd (UPDATE - add save/load)
├── MainMenuController.gd (NEW - simple version)
└── NewGameDialog.gd (NEW - character input)
```

## Implementation

### Step 1: Update Pause Menu with Save/Load

**File: `scripts/ui/PauseMenuController.gd`** (Update existing or create new)

```gdscript
# PauseMenuController.gd - Add save/load to pause menu
extends Control
class_name PauseMenuController

# UI references
@onready var resume_button: Button = $VBox/ResumeButton
@onready var save_button: Button = $VBox/SaveButton
@onready var load_button: Button = $VBox/LoadButton
@onready var main_menu_button: Button = $VBox/MainMenuButton
@onready var quit_button: Button = $VBox/QuitButton

# Feedback
@onready var feedback_label: Label = $FeedbackLabel

func _ready():
    print("🎮 PauseMenuController initialized")
    setup_ui()
    connect_signals()
    update_button_states()

func setup_ui():
    """Setup UI components"""
    resume_button.text = "Resume"
    save_button.text = "Save Game"
    load_button.text = "Load Game"
    main_menu_button.text = "Main Menu"
    quit_button.text = "Quit"
    
    feedback_label.text = ""
    feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func connect_signals():
    """Connect button signals"""
    resume_button.pressed.connect(_on_resume_pressed)
    save_button.pressed.connect(_on_save_pressed)
    load_button.pressed.connect(_on_load_pressed)
    main_menu_button.pressed.connect(_on_main_menu_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    
    # Connect to save manager signals
    if GameManager.save_manager:
        GameManager.save_manager.save_completed.connect(_on_save_completed)
        GameManager.save_manager.load_completed.connect(_on_load_completed)

func update_button_states():
    """Update button availability"""
    # Load button only enabled if save file exists
    load_button.disabled = not GameManager.has_saved_game()

func show_feedback(message: String, color: Color = Color.WHITE):
    """Show feedback message"""
    feedback_label.text = message
    feedback_label.add_theme_color_override("font_color", color)
    
    # Clear message after 3 seconds
    await get_tree().create_timer(3.0).timeout
    if feedback_label.text == message:  # Only clear if it's still the same message
        feedback_label.text = ""

# Button handlers
func _on_resume_pressed():
    """Resume game"""
    hide_pause_menu()

func _on_save_pressed():
    """Save current game"""
    save_button.disabled = true
    save_button.text = "Saving..."
    
    GameManager.save_game()

func _on_load_pressed():
    """Load saved game"""
    load_button.disabled = true
    load_button.text = "Loading..."
    
    GameManager.load_game()

func _on_main_menu_pressed():
    """Return to main menu"""
    # Save before going to main menu
    if GameManager.save_manager.current_save:
        GameManager.save_game()
    
    get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_quit_pressed():
    """Quit game"""
    get_tree().quit()

# Save/Load feedback
func _on_save_completed(success: bool):
    """Handle save completion"""
    save_button.disabled = false
    save_button.text = "Save Game"
    
    if success:
        show_feedback("Game Saved!", Color.GREEN)
    else:
        show_feedback("Save Failed!", Color.RED)
    
    update_button_states()

func _on_load_completed(success: bool):
    """Handle load completion"""
    load_button.disabled = false
    load_button.text = "Load Game"
    
    if success:
        show_feedback("Game Loaded!", Color.GREEN)
        hide_pause_menu()  # Resume after successful load
    else:
        show_feedback("Load Failed!", Color.RED)

# Pause menu visibility
func show_pause_menu():
    """Show pause menu"""
    visible = true
    get_tree().paused = true
    update_button_states()

func hide_pause_menu():
    """Hide pause menu"""
    visible = false
    get_tree().paused = false

func _input(event):
    """Handle input"""
    if event.is_action_pressed("pause_game"):  # Assuming you have this action
        if visible:
            hide_pause_menu()
        else:
            show_pause_menu()
```

### Step 2: Simple Main Menu

**File: `scripts/ui/MainMenuController.gd`**

```gdscript
# MainMenuController.gd - Simple main menu for Phase 3
extends Control
class_name MainMenuController

# UI references
@onready var title_label: Label = $VBox/TitleLabel
@onready var continue_button: Button = $VBox/ContinueButton
@onready var new_game_button: Button = $VBox/NewGameButton
@onready var quit_button: Button = $VBox/QuitButton

# New game dialog
@onready var new_game_dialog: AcceptDialog = $NewGameDialog
@onready var character_name_input: LineEdit = $NewGameDialog/VBox/CharacterNameInput
@onready var start_button: Button = $NewGameDialog/VBox/StartButton

func _ready():
    print("🎮 MainMenuController initialized")
    setup_ui()
    connect_signals()
    update_button_states()

func setup_ui():
    """Setup UI components"""
    title_label.text = "Wizard RPG"
    continue_button.text = "Continue"
    new_game_button.text = "New Game"
    quit_button.text = "Quit"
    
    new_game_dialog.title = "Create New Character"
    character_name_input.placeholder_text = "Enter wizard name..."
    start_button.text = "Start Adventure"

func connect_signals():
    """Connect UI signals"""
    continue_button.pressed.connect(_on_continue_pressed)
    new_game_button.pressed.connect(_on_new_game_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    
    start_button.pressed.connect(_on_start_adventure_pressed)
    character_name_input.text_submitted.connect(_on_name_submitted)

func update_button_states():
    """Update button availability"""
    # Continue button only enabled if save file exists
    continue_button.disabled = not GameManager.has_saved_game()
    
    if continue_button.disabled:
        continue_button.text = "No Save Found"
    else:
        continue_button.text = "Continue"

# Button handlers
func _on_continue_pressed():
    """Continue existing game"""
    if GameManager.load_game():
        start_game()
    else:
        print("Failed to load game")

func _on_new_game_pressed():
    """Show new game dialog"""
    character_name_input.text = ""
    character_name_input.grab_focus()
    new_game_dialog.popup_centered()

func _on_quit_pressed():
    """Quit application"""
    get_tree().quit()

func _on_start_adventure_pressed():
    """Start new adventure"""
    var character_name = character_name_input.text.strip_edges()
    
    if character_name.is_empty():
        # Show error feedback
        character_name_input.placeholder_text = "Name required!"
        character_name_input.add_theme_color_override("placeholder_color", Color.RED)
        return
    
    # Create new game
    GameManager.start_new_game(character_name)
    new_game_dialog.hide()
    start_game()

func _on_name_submitted(text: String):
    """Handle enter key in name input"""
    _on_start_adventure_pressed()

func start_game():
    """Start the game scene"""
    get_tree().change_scene_to_file("res://scenes/Main.tscn")
```

### Step 3: Scene Files (Simplified Versions)

**File: `scenes/ui/MainMenu.tscn`** (Create this scene)

```
MainMenu (Control)
├── VBox (VBoxContainer)
│   ├── TitleLabel (Label) - "Wizard RPG"
│   ├── Spacer (Control) - size_flags_vertical: EXPAND_FILL
│   ├── ContinueButton (Button)
│   ├── NewGameButton (Button)
│   └── QuitButton (Button)
└── NewGameDialog (AcceptDialog)
    └── VBox (VBoxContainer)
        ├── Instructions (Label) - "Enter your wizard's name:"
        ├── CharacterNameInput (LineEdit)
        └── StartButton (Button)
```

**File: `scenes/ui/PauseMenu.tscn`** (Update existing or create)

```
PauseMenu (Control)
├── Background (ColorRect) - color: Color(0, 0, 0, 0.5)
├── VBox (VBoxContainer) - centered
│   ├── Title (Label) - "Game Paused"
│   ├── ResumeButton (Button)
│   ├── SaveButton (Button)
│   ├── LoadButton (Button)
│   ├── MainMenuButton (Button)
│   └── QuitButton (Button)
└── FeedbackLabel (Label) - bottom center
```

### Step 4: Integration with Main Scene

**Add to your main game scene (`Main.tscn` or whatever your main scene is):**

```gdscript
# Add to your main game controller
extends Node2D

@onready var pause_menu: PauseMenuController = $UI/PauseMenu

func _ready():
    # Existing initialization...
    
    # Hide pause menu initially
    if pause_menu:
        pause_menu.visible = false

func _input(event):
    # Existing input handling...
    
    # Handle pause
    if event.is_action_pressed("pause_game"):
        if pause_menu:
            if pause_menu.visible:
                pause_menu.hide_pause_menu()
            else:
                pause_menu.show_pause_menu()
```

### Step 5: Add Input Map

**Add to your project's Input Map (Project Settings → Input Map):**

```
pause_game = Escape key
```

## Simple Usage Flow

### New Player Experience:
1. **Launch game** → MainMenu appears
2. **Click "New Game"** → Character name dialog
3. **Enter wizard name** → Game starts with new save
4. **Press Escape** → Pause menu with save option
5. **Auto-save** happens every 30 seconds

### Returning Player Experience:
1. **Launch game** → MainMenu appears with "Continue" enabled
2. **Click "Continue"** → Load last save and resume
3. **Or click "New Game"** → Start fresh character

### During Gameplay:
1. **Press Escape** → Pause menu
2. **Click "Save Game"** → Manual save with feedback
3. **Click "Load Game"** → Reload last save
4. **Click "Resume"** → Continue playing

## Success Criteria for Phase 3.6C

✅ **Main menu** with Continue/New Game options  
✅ **Character creation** with name input  
✅ **Pause menu** with save/load buttons  
✅ **Visual feedback** for save/load operations  
✅ **Button states** reflect save file availability  
✅ **Keyboard shortcuts** work (Escape for pause)  
✅ **Scene transitions** work correctly  

## Testing Checklist

- [ ] Create new character and start game
- [ ] Manual save from pause menu shows success message
- [ ] Auto-save works (check console logs)
- [ ] Load game restores player position and stats
- [ ] Continue button disabled when no save exists
- [ ] Escape key toggles pause menu
- [ ] Character name validation works

## Integration Notes

This simple UI works with your existing Phase 3 systems and will gracefully expand when you add:
- **Phase 7**: Equipment will save/load automatically
- **Phase 8**: Boss progression will persist
- **Phase 9**: Tower hub will use the same save system
- **Phase 10**: Meta-progression will accumulate

The foundation is now complete and ready for your expanding game features!