# Input Actions Setup for 10-Slot Spell Toolbar

## Required Input Actions

To use the 10-slot spell toolbar (keys 1-9, 0), you need to add the following input actions to your project:

### Current Actions (should already exist):
- `spell_1` - Key: 1
- `spell_2` - Key: 2  
- `spell_3` - Key: 3
- `spell_4` - Key: 4
- `spell_5` - Key: 5

### New Actions to Add:
- `spell_6` - Key: 6
- `spell_7` - Key: 7
- `spell_8` - Key: 8
- `spell_9` - Key: 9
- `spell_0` - Key: 0

## How to Add Input Actions in Godot:

1. **Open Project Settings**:
   - Go to `Project` → `Project Settings`

2. **Navigate to Input Map**:
   - Click on the `Input Map` tab

3. **Add Each New Action**:
   For each action (`spell_6`, `spell_7`, `spell_8`, `spell_9`, `spell_0`):
   
   a. In the "Add new action" field, type the action name (e.g., `spell_6`)
   b. Click the "Add" button
   c. Click the "+" button next to the new action
   d. Press the corresponding key (e.g., press "6" for `spell_6`)
   e. Click "OK"

4. **Verify All Actions**:
   Make sure you have all 10 spell actions:
   - spell_1 → Key: 1
   - spell_2 → Key: 2
   - spell_3 → Key: 3
   - spell_4 → Key: 4
   - spell_5 → Key: 5
   - spell_6 → Key: 6
   - spell_7 → Key: 7
   - spell_8 → Key: 8
   - spell_9 → Key: 9
   - spell_0 → Key: 0

5. **Save Project Settings**:
   - Click "Close" to save and exit Project Settings

## Testing the Setup:

After adding the input actions:
1. Start your game
2. The toolbar should show 10 slots with numbers 1-9, 0
3. Each slot should have a colored icon representing the spell element
4. Press keys 1-9 and 0 to cast the corresponding spells

## Spell-to-Slot Mapping:

1. **Fireball** (Orange-Red) - Key: 1
2. **Magic Missile** (Purple) - Key: 2
3. **Ice Shard** (Cyan) - Key: 3
4. **Lightning Bolt** (Yellow) - Key: 4
5. **Heal** (Lime Green) - Key: 5
6. **Earth Spike** (Brown) - Key: 6
7. **Wind Blade** (Light Gray) - Key: 7
8. **Water Bolt** (Deep Sky Blue) - Key: 8
9. **Shadow Dart** (Dim Gray) - Key: 9
10. **Light Beam** (White) - Key: 0

## Troubleshooting:

If spells don't cast when pressing keys 6-9 or 0:
1. Verify the input actions are properly configured
2. Check that the action names match exactly (case-sensitive)
3. Ensure the keys are assigned to the correct actions
4. Restart the game after adding new input actions

Your 10-slot spell toolbar is now ready to use! 🪄