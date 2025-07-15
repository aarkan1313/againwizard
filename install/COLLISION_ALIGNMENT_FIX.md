# Player Collision Alignment Fix

## Problem
When using `sprite.flip_h = true`, the sprite visually shifts position but collision shapes stay in the same place. This causes:
- Enemy attacks to miss when player faces different directions
- Collision detection inconsistencies
- Targeting issues in combat

## Root Cause
`flip_h` flips the sprite around its center point, but CharacterBody2D collision shapes are positioned relative to the body's origin, not the sprite center.

## Solution: Scale-Based Flipping
Replace `sprite.flip_h` with scale-based flipping:

### Before (Problematic):
```gdscript
sprite.flip_h = movement_direction < 0
```

### After (Fixed):
```gdscript
var base_scale = Vector2(0.5, 0.5)  # Your sprite's normal scale
if movement_direction < 0:  # Moving left
    sprite.scale = Vector2(-abs(base_scale.x), base_scale.y)  # Face left
else:  # Moving right  
    sprite.scale = Vector2(abs(base_scale.x), base_scale.y)  # Face right
```

## Why This Works
- Scale flipping (`scale.x = -0.5`) keeps the sprite centered on the CharacterBody2D
- Collision shapes remain perfectly aligned regardless of facing direction
- Enemy targeting works consistently in both directions

## Files to Update
1. **Player.gd** - `update_visuals()` function around line 528
2. **Player.gd** - `create_afterimage()` function around line 395
3. **Player.tscn** - Center collision shapes if needed

## Enhanced Wizard System
Already uses this fix - collision centered at (0,0) with scale-based sprite flipping.

## Testing
- Enable collision shape debug display
- Move left and right
- Verify collision shape stays centered on character
- Test enemy attack accuracy in both directions