# Updated Controls Documentation - Teleport System

## Complete Control Scheme

### 🌟 **Spell Power System**
- **1-9, 0** - Select spell to modify power level
- **= (Plus Key)** - Increase selected spell power (+1 level)
- **- (Minus Key)** - Decrease selected spell power (-1 level)
- **Visual Feedback**: Green +N or red -N displayed on spell slots

### ⚡ **Teleport System (NEW)**
- **Space Key** - Instant teleport in movement direction
  - **With WASD held**: Teleports in that direction
  - **No input**: Teleports forward (up direction)
  - **Cooldown**: 1.5s base, reduced by agility stat
  - **Distance**: 150 pixels base, increased by agility stat

### 🏃 **Movement & Combat**
- **W/A/S/D** - Character movement
- **1-9, 0** - Cast spells (keyboard mode)
- **Mouse Clicks** - Cast assigned spells (mouse mode)

### 📹 **Camera Controls**
- **Shift + =** - Zoom in
- **Shift + -** - Zoom out

### 📊 **UI & Stats**
- **TAB** - Open/close stat allocation panel
- **C** - Open/close character sheet

## Teleport Mechanics

### Base Stats
- **Distance**: 150 pixels
- **Cooldown**: 1.5 seconds
- **Direction**: Based on WASD input or forward default

### Agility Scaling
- **Distance Enhancement**: +2 pixels per agility point
- **Cooldown Reduction**: -0.02 seconds per agility point
- **Minimum Cooldown**: 0.5 seconds

### Examples
```
Agility 10: 170 distance, 1.3s cooldown
Agility 25: 200 distance, 1.0s cooldown  
Agility 50: 250 distance, 0.5s cooldown
```

## Control Changes from Previous Version

### ✅ **What Changed**
- **Space Key**: Now teleports instead of dodge movement
- **Instant Action**: No movement physics or duration
- **Stat Integration**: Meaningful agility scaling

### ✅ **What Stayed the Same**
- **Movement**: WASD still controls character movement
- **Spells**: All spell casting controls unchanged
- **Camera**: Zoom controls still work with Shift modifier
- **UI**: All interface controls remain identical

## Technical Notes

### Input Priority
1. **Spell Power**: +/- keys (highest priority)
2. **Camera Zoom**: Shift + +/- keys
3. **Teleport**: Space key
4. **Movement**: WASD keys
5. **Spell Casting**: Number keys or mouse

### No Conflicts
- ✅ Teleport (Space) doesn't interfere with spell power (+/-)
- ✅ Camera zoom (Shift +/-) separated from spell power
- ✅ Movement (WASD) works independently
- ✅ All existing hotkeys preserved

## Status Display

### Visual Feedback
- **Spell Power**: Green +N or red -N on spell slots
- **Teleport**: Instant position change (no animation)
- **Cooldown**: Console message shows remaining time

### Debug Information
```gdscript
# Check teleport status
player.get_teleport_cooldown_remaining()  # Time remaining
player.stat_sheet.get_stat_value("agility")  # Current agility
```

## Quick Reference Card

```
MOVEMENT:        W/A/S/D
TELEPORT:        Space (instant, direction-based)
SPELL POWER:     1-9,0 (select) → +/- (adjust)
SPELL CAST:      1-9,0 (keyboard) or Mouse (assigned)
CAMERA ZOOM:     Shift + +/-
STAT PANEL:      TAB
CHARACTER SHEET: C
```

---

**The teleport system provides instant, responsive movement with meaningful stat progression and zero control conflicts.**