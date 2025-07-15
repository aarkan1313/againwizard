# Spell Toolbar Installation Guide
## For Wizard RPG Game Project (Godot 4.4.1)

### 📋 **Overview**
This installation guide provides step-by-step instructions for integrating the Spell Toolbar system into your existing Wizard RPG project. The toolbar system is designed to be fully compatible with your current UI architecture and input systems.

### 🎯 **Features**
- **Visual Spell Toolbar**: Bottom-center spell slots with cooldown displays
- **Mouse & Keyboard Support**: Click or use hotkeys (1-5)
- **Real-time Updates**: Live cooldown timers and mana cost display
- **Seamless Integration**: Compatible with existing SpellComponent and InputHandler
- **Enhanced Input**: Mouse wheel spell selection, quick-cast mode
- **Pause-aware**: Proper handling during game pause/menus

---

## 📂 **File Structure**

### Required Files to Copy:
```
/mnt/c/FFS/edited/spell_toolbar/
├── SpellToolbar.gd              # Main toolbar component
├── SpellSlot.gd                 # Individual spell slot logic
├── SpellToolbar.tscn            # Toolbar scene file
├── ToolbarManager.gd            # Integration manager
└── Enhanced_InputHandler.gd     # Extended input system
```

### Target Locations in Your Project:
```
/mnt/c/FFS/godot/Game10/
├── scripts/ui/
│   ├── SpellToolbar.gd         # Copy here
│   └── SpellSlot.gd            # Copy here
├── scenes/ui/
│   └── SpellToolbar.tscn       # Copy here
├── scripts/managers/
│   └── ToolbarManager.gd       # Copy here
└── scripts/input/
    └── Enhanced_InputHandler.gd # Copy here (optional)
```

---

## 🔧 **Installation Steps**

### **Step 1: Copy Core Files**
```bash
# Create necessary directories if they don't exist
mkdir -p /mnt/c/FFS/godot/Game10/scripts/ui
mkdir -p /mnt/c/FFS/godot/Game10/scripts/managers
mkdir -p /mnt/c/FFS/godot/Game10/scripts/input

# Copy toolbar files
cp /mnt/c/FFS/edited/spell_toolbar/SpellToolbar.gd /mnt/c/FFS/godot/Game10/scripts/ui/
cp /mnt/c/FFS/edited/spell_toolbar/SpellSlot.gd /mnt/c/FFS/godot/Game10/scripts/ui/
cp /mnt/c/FFS/edited/spell_toolbar/SpellToolbar.tscn /mnt/c/FFS/godot/Game10/scenes/ui/
cp /mnt/c/FFS/edited/spell_toolbar/ToolbarManager.gd /mnt/c/FFS/godot/Game10/scripts/managers/
cp /mnt/c/FFS/edited/spell_toolbar/Enhanced_InputHandler.gd /mnt/c/FFS/godot/Game10/scripts/input/
```

### **Step 2: Update Main Scene (Main.tscn)**
1. **Open** `/mnt/c/FFS/godot/Game10/scenes/Main.tscn` in Godot Editor
2. **Locate** the `UI` CanvasLayer node
3. **Add** a new Node as child of UI CanvasLayer:
   - **Right-click** `UI` → **Add Child** → **Node**
   - **Name**: `ToolbarManager`
   - **Attach Script**: `res://scripts/managers/ToolbarManager.gd`
4. **Configure ToolbarManager** in Inspector:
   - ✅ **Auto Setup On Ready**: `true`
   - ✅ **Hide In Menus**: `true`
   - ✅ **Fade During Pause**: `true`
   - **Toolbar Scene Path**: `res://scenes/ui/SpellToolbar.tscn`

### **Step 3: Update Scene References (SpellToolbar.tscn)**
1. **Open** `/mnt/c/FFS/godot/Game10/scenes/ui/SpellToolbar.tscn`
2. **Update Script Path**:
   - **Select** `SpellToolbar` root node
   - **Change Script** from `res://scripts/ui/SpellToolbar.gd` to your actual path
3. **Save** the scene

### **Step 4: Optional Enhanced Input Integration**
If you want enhanced input features (mouse wheel, quick-cast):

1. **Open** `/mnt/c/FFS/godot/Game10/scripts/InputHandler.gd`
2. **Backup** the original file:
   ```bash
   cp /mnt/c/FFS/godot/Game10/scripts/InputHandler.gd /mnt/c/FFS/godot/Game10/scripts/InputHandler_backup.gd
   ```
3. **Replace** with enhanced version:
   ```bash
   cp /mnt/c/FFS/edited/spell_toolbar/Enhanced_InputHandler.gd /mnt/c/FFS/godot/Game10/scripts/InputHandler.gd
   ```

---

## ⚡ **Quick Integration (Automatic)**

For fastest setup, add this code to your **Player.gd** `_ready()` function:

```gdscript
func _ready():
    # ... your existing code ...
    
    # Auto-setup spell toolbar
    call_deferred("_setup_spell_toolbar")

func _setup_spell_toolbar():
    """Automatically setup spell toolbar"""
    var toolbar_manager = get_tree().get_first_node_in_group("toolbar_managers")
    if not toolbar_manager:
        # Create toolbar manager if it doesn't exist
        var ui_layer = get_tree().get_first_node_in_group("ui_layer")
        if not ui_layer:
            ui_layer = get_tree().current_scene.get_node_or_null("UI")
        
        if ui_layer:
            toolbar_manager = preload("res://scripts/managers/ToolbarManager.gd").new()
            toolbar_manager.name = "ToolbarManager"
            ui_layer.add_child(toolbar_manager)
            toolbar_manager.setup_toolbar(self, ui_layer)
```

---

## 🔍 **Manual Integration (Detailed)**

### **Player Integration**
Add to your Player script:

```gdscript
# In Player.gd _ready() function
func _ready():
    # ... existing code ...
    
    # Setup toolbar after all components are ready
    call_deferred("_initialize_toolbar")

func _initialize_toolbar():
    var spell_component = get_node_or_null("SpellComponent")
    if not spell_component:
        return
    
    # Find UI layer
    var main_scene = get_tree().current_scene
    var ui_layer = main_scene.get_node_or_null("UI")
    if not ui_layer:
        return
    
    # Create toolbar
    var toolbar_scene = preload("res://scenes/ui/SpellToolbar.tscn")
    var toolbar = toolbar_scene.instantiate()
    ui_layer.add_child(toolbar)
    toolbar.setup(spell_component)
    
    print("✅ Spell toolbar initialized")
```

### **UI Layout Integration**
The toolbar automatically positions itself at the bottom-center of the screen. Current layout compatibility:

- **Top-left**: Player stats (PlayerUI) ✅ **No conflict**
- **Top-right**: Wave display ✅ **No conflict**  
- **Bottom-center**: Spell toolbar ✅ **New position**
- **Center**: Game world ✅ **No conflict**

---

## ⚙️ **Configuration Options**

### **Toolbar Appearance**
```gdscript
# In SpellToolbar.gd or via scene inspector
@export var slot_count: int = 5                    # Number of spell slots
@export var slot_size: Vector2 = Vector2(64, 64)   # Size of each slot
@export var slot_spacing: int = 8                  # Spacing between slots
@export var show_keybinds: bool = true             # Show hotkey numbers
@export var show_cooldowns: bool = true            # Show cooldown timers
@export var show_mana_cost: bool = true           # Show mana costs
```

### **Visual Styling**
```gdscript
# Color customization
@export var normal_color: Color = Color(0.2, 0.2, 0.2, 0.8)
@export var hover_color: Color = Color(0.3, 0.3, 0.3, 0.9)
@export var pressed_color: Color = Color(0.1, 0.1, 0.1, 0.9)
@export var disabled_color: Color = Color(0.15, 0.15, 0.15, 0.6)
@export var ready_border_color: Color = Color(0.2, 0.8, 0.2, 1.0)
@export var cooldown_border_color: Color = Color(0.8, 0.2, 0.2, 1.0)
```

### **Enhanced Input Features**
```gdscript
# In Enhanced_InputHandler.gd
@export var alt_spell_casting: bool = true    # Mouse wheel selection
@export var quick_cast_mode: bool = false     # Hold-to-cast mode
@export var toolbar_toggle_key: String = "ui_cancel"  # Hide/show key
```

---

## 🧪 **Testing & Validation**

### **Basic Functionality Test**
1. **Start game** and verify toolbar appears at bottom
2. **Press keys 1-5** to cast spells
3. **Click spell slots** with mouse
4. **Verify cooldown displays** work correctly
5. **Check mana cost** updates properly

### **Advanced Features Test**
If using Enhanced Input:
1. **Mouse wheel** to change spell selection
2. **ESC key** to toggle toolbar visibility
3. **Pause game** and verify toolbar fades

### **Debug Information**
Add to any script for debugging:
```gdscript
func _input(event):
    if event.is_action_pressed("ui_home"):  # Home key
        var toolbar_manager = get_tree().get_first_node_in_group("toolbar_managers")
        if toolbar_manager:
            print(toolbar_manager.get_toolbar_state())
```

---

## 🔧 **Troubleshooting**

### **Common Issues & Solutions**

#### **Toolbar Not Appearing**
- ✅ Check that `ToolbarManager` is added to UI CanvasLayer
- ✅ Verify `SpellComponent` exists on player
- ✅ Ensure `SpellToolbar.tscn` path is correct
- ✅ Check console for error messages

#### **Spells Not Casting**
- ✅ Verify `InputHandler` is working (`InputHandler.is_spell_cast_pressed()`)
- ✅ Check `SpellComponent.is_spell_ready()` returns true
- ✅ Ensure player has sufficient mana
- ✅ Verify input map has `spell_1` through `spell_5` actions

#### **Visual Issues**
- ✅ Check CanvasLayer z-order (toolbar should be on top)
- ✅ Verify no other UI elements are blocking toolbar
- ✅ Check if `mouse_filter` is set correctly on UI elements

#### **Performance Issues**
- ✅ Toolbar updates every frame - normal behavior
- ✅ If lag occurs, check for excessive debug printing
- ✅ Consider reducing `_process` frequency if needed

#### **Input Conflicts**
- ✅ Verify no other systems are capturing spell input
- ✅ Check input action priorities in InputMap
- ✅ Ensure `input_enabled` flag is true in InputHandler

---

## 📚 **Integration with Existing Systems**

### **SpellComponent Compatibility**
The toolbar automatically integrates with your existing `SpellComponent`:
- ✅ **Reads equipped spells** via `get_equipped_spells()`
- ✅ **Checks spell readiness** via `is_spell_ready()`
- ✅ **Gets cooldown info** via `get_spell_cooldown()`
- ✅ **Casts spells** via `cast_spell()`

### **GameEvents Integration**
Connects to existing game events:
- ✅ **`spell_cast`** - Visual feedback for successful casts
- ✅ **`player_mana_changed`** - Updates spell availability
- ✅ **`game_paused`** - Fade effect during pause

### **InputHandler Compatibility**
Works with existing input system:
- ✅ **Preserves existing functionality** if using Enhanced_InputHandler
- ✅ **Adds toolbar-specific features** (wheel selection, quick-cast)
- ✅ **Maintains compatibility** with current key bindings

---

## 🎨 **Customization Guide**

### **Adding Custom Spell Icons**
1. **Create icons** (64x64 recommended) for each spell
2. **Add to project** in `res://textures/spells/`
3. **Update SpellSlot.gd** `update_spell()` method:
```gdscript
func update_spell(spell: SpellData, ready: bool, cooldown: float):
    # ... existing code ...
    
    # Load custom icon
    var icon_path = "res://textures/spells/" + spell.spell_name.to_lower() + ".png"
    if ResourceLoader.exists(icon_path):
        spell_icon.texture = load(icon_path)
    
    # ... rest of method ...
```

### **Custom Positioning**
To change toolbar position, modify `SpellToolbar.gd` `_setup_ui_properties()`:
```gdscript
func _setup_ui_properties():
    # Example: Top-right positioning
    set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    position.x = get_viewport().get_visible_rect().size.x - size.x - 20
    position.y = 20
```

### **Additional Toolbar Features**
To add more functionality:
1. **Extend SpellSlot.gd** with new methods
2. **Add signals** to SpellToolbar for new events
3. **Update ToolbarManager** to handle new functionality

---

## 📋 **Final Checklist**

### **Installation Complete When:**
- [ ] ✅ All files copied to correct locations
- [ ] ✅ ToolbarManager added to Main.tscn
- [ ] ✅ SpellToolbar.tscn script paths updated
- [ ] ✅ Game starts without errors
- [ ] ✅ Toolbar appears at bottom of screen
- [ ] ✅ Spells cast via keyboard (1-5 keys)
- [ ] ✅ Spells cast via mouse clicks
- [ ] ✅ Cooldown displays work correctly
- [ ] ✅ Mana costs show properly
- [ ] ✅ Toolbar integrates with pause system

### **Enhanced Features (Optional):**
- [ ] ✅ Mouse wheel spell selection works
- [ ] ✅ ESC key toggles toolbar visibility
- [ ] ✅ Quick-cast mode functions (if enabled)
- [ ] ✅ Toolbar fades during pause
- [ ] ✅ Custom spell icons display

---

## 🆘 **Support & Further Development**

### **Contact Information**
- **Project**: Wizard RPG Phase-based Development
- **Compatibility**: Godot 4.4.1
- **Architecture**: Component-based, Event-driven

### **Future Enhancements**
- **Drag & Drop**: Spell slot reordering
- **Spell Groups**: Multiple toolbars or pages
- **Visual Effects**: Spell cast animations
- **Sound Integration**: Audio feedback for actions
- **Mobile Support**: Touch-friendly interface

---

**Installation complete! Your spell toolbar should now be fully integrated and functional.**