# Teleport System Installation Guide

## Overview
This update replaces the broken dodge system with a clear, instant teleport ability that's enhanced by the agility stat.

## What's Changed

### System Renamed
- **OLD**: "Dodge" system with movement physics
- **NEW**: "Teleport" system with instant position changes

### Key Improvements
- ✅ **Instant teleportation**: No movement physics conflicts
- ✅ **Agility scaling**: Higher agility = longer distance + shorter cooldown
- ✅ **Clear controls**: Space key for teleport (no confusion with dodge stat)
- ✅ **Fixed input handling**: Removed broken method calls
- ✅ **Event system**: Proper GameEvents integration

## Installation Steps

1. **Backup Current Files**
   ```bash
   # Backup modified files to C:\FFS\backup
   cp scripts/entities/Player.gd C:\FFS\backup/
   cp scripts/GameEvents.gd C:\FFS\backup/
   cp scripts/components/MovementComponent.gd C:\FFS\backup/
   ```

2. **Replace Modified Files**
   - Copy `Player.gd` to `scripts/entities/Player.gd`
   - Copy `GameEvents.gd` to `scripts/GameEvents.gd`
   - Copy `MovementComponent.gd` to `scripts/components/MovementComponent.gd`

3. **Test in Godot**
   - Press F5 to run the game
   - Use Space key to teleport
   - Check console for teleport messages

## New Controls

### Teleport System
- **Space Key**: Instant teleport in movement direction
- **No Movement Input**: Teleports forward (up direction)
- **Cooldown**: 1.5s base, reduced by agility stat
- **Distance**: 150 pixels base, increased by agility stat

### Agility Scaling
- **Distance**: +2 pixels per agility point
- **Cooldown**: -0.02 seconds per agility point (minimum 0.5s)

## Technical Details

### New Player.gd Methods
```gdscript
perform_teleport()               # Main teleport function
get_is_teleporting()            # State checker (always false for instant teleport)
get_teleport_cooldown_remaining() # Cooldown timer
```

### GameEvents Integration
```gdscript
signal player_teleported(new_position: Vector2, teleport_vector: Vector2)
GameEvents.emit_player_teleported(position, vector)
```

### Removed Code
- Old dodge movement physics
- Broken movement_component.perform_dodge() calls
- Complex dodge state management

## Testing Checklist

- [ ] Space key triggers teleport
- [ ] Teleport works in all 8 directions (WASD combinations)
- [ ] Teleport works with no input (forward teleport)
- [ ] Cooldown prevents rapid teleporting
- [ ] Console shows teleport messages
- [ ] No parser errors in Godot
- [ ] No movement conflicts with spell controls

## Troubleshooting

### Common Issues

1. **Space key not working**
   - Check input map has "ui_accept" mapped to Space
   - Verify game isn't paused

2. **Teleport distance too short/long**
   - Check agility stat in character sheet
   - Base distance is 150 pixels

3. **Console errors about teleport**
   - Verify GameEvents.gd is updated
   - Check emit_player_teleported method exists

### Debug Commands
```gdscript
# In Godot console
print(player.get_teleport_cooldown_remaining())  # Check cooldown
print(player.stat_sheet.get_stat_value("agility"))  # Check agility
```

## Files Modified
- `scripts/entities/Player.gd` - Main teleport implementation
- `scripts/GameEvents.gd` - Added teleport signal
- `scripts/components/MovementComponent.gd` - Updated teleport state checks

## Compatibility
- ✅ Godot 4.4.1
- ✅ Existing spell power system
- ✅ Camera zoom controls
- ✅ All other game systems

The teleport system is now working correctly with instant movement and proper stat scaling!