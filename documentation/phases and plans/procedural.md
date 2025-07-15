# Claude Code Implementation Guide: Wizard Animation System

## Prerequisites

- Claude Code CLI installed and authenticated
- Existing Godot 4.4.1 project
- Basic terminal/command line knowledge
- Your wizard sprite asset (PNG with transparency)

## Step 1: Initial Setup

Open terminal in your Godot project root directory:

```bash
# Navigate to your project
cd /path/to/your/godot/project

# Create required directories
mkdir -p scenes/characters
mkdir -p scripts/characters
mkdir -p assets/sprites
mkdir -p effects
```

## Step 2: Generate Base Wizard System

Use Claude Code to create the complete wizard character:

```bash
claude-code "Create a complete wizard character system for Godot 4.4.1 with:
- CharacterBody2D based movement with WASD controls
- Procedural animations: idle float, walking, casting, floating states
- Particle effects system with 80-150 magic particles
- Dynamic glow and aura effects
- Motion trail when moving fast
- Shadow that scales with height
- All textures created programmatically in code
- Export variables for customization
Save the main scene as scenes/characters/WizardCharacter.tscn
Save the script as scripts/characters/WizardCharacter.gd"
```

## Step 3: Add to Existing Scene

Integrate wizard into your game:

```bash
claude-code "In my main game scene at res://scenes/Main.tscn:
1. Instance the WizardCharacter scene at position (640, 360)
2. Ensure the camera follows the wizard
3. Add the wizard to 'player' group
4. Set up proper z-index layering
Do not modify existing game systems"
```

## Step 4: Create Control UI

Add the effects control panel:

```bash
claude-code "Create a UI control panel for the wizard at res://scenes/ui/WizardControls.tscn:
- Checkboxes for: particles, glow, aura, shadow, trail
- Sliders for: float_speed (0.5-5.0), float_amount (0-20), breath_amount (0-0.1)
- State display showing current animation state
- FPS counter
- Position in top-right corner
- Connect to wizard character via exported variable
Include script at scripts/ui/WizardControls.gd"
```

## Step 5: Adapt to Your Game's Style

Customize for your specific game:

```bash
# For pixel art games
claude-code "Modify WizardCharacter to use pixel-perfect rendering:
- Set all textures to use nearest neighbor filtering
- Snap positions to pixel grid
- Adjust particle size for pixel art style
- Scale effects appropriately for pixel density"

# For dark/horror games
claude-code "Adjust WizardCharacter effects for dark atmosphere:
- Change particle colors to dark purple/black
- Reduce glow intensity to 0.3-0.5
- Add flickering to glow effect
- Make shadow more prominent
- Darken all effect colors by 50%"

# For colorful/casual games
claude-code "Make WizardCharacter effects more vibrant:
- Use rainbow gradient for particles
- Increase glow intensity and add color cycling
- Make aura multicolored with rotating hues
- Add sparkle particles on idle
- Increase effect sizes by 150%"
```

## Step 6: Integration with Game Systems

### Health/Damage System
```bash
claude-code "Extend WizardCharacter with health system:
- Add health variable (default 100)
- Flash red when taking damage
- Reduce particle emission when low health
- Add invulnerability frames with transparency
- Emit red particles on damage
- Keep existing animation system intact"
```

### Magic/Mana System
```bash
claude-code "Add mana system to WizardCharacter:
- Add mana variable (default 100)
- Particles change color based on mana level
- Disable casting animation when mana < 20
- Regenerate 5 mana per second
- Blue glow intensity tied to mana percentage
- Export mana costs for different spells"
```

### Spell Casting
```bash
claude-code "Create spell system for WizardCharacter:
- Fireball spell on key 1: red projectile with particle trail
- Ice shard on key 2: blue projectile that slows enemies
- Lightning on key 3: instant hit with chain effect
- Each spell uses the wizard's particle colors
- Spells inherit wizard's glow effect color
- Add cooldown system with visual indicators"
```

## Step 7: Performance Optimization

Optimize for your target platform:

```bash
claude-code "Optimize WizardCharacter for mobile/web:
- Reduce particle count to 40 when idle, 80 when casting
- Disable trail effect by default
- Use simpler gradients (2 colors max)
- Reduce shadow resolution to 32x16
- Add quality settings: Low, Medium, High
- Auto-detect platform and adjust accordingly"
```

## Step 8: Save System Integration

Add persistence:

```bash
claude-code "Add save/load functionality to WizardCharacter:
- Save position, health, mana, current state
- Save all effect toggle states
- Save animation speed preferences
- Create save_data() method returning dictionary
- Create load_data(data: Dictionary) method
- Integrate with existing game save system"
```

## Common Claude Code Commands

### Debugging Issues
```bash
# Fix movement problems
claude-code "Debug why wizard movement feels sluggish. Check physics settings, adjust acceleration to 2000, friction to 1500"

# Fix effect layering
claude-code "Fix particle effects rendering behind wizard sprite. Ensure proper z-index ordering"

# Fix performance
claude-code "Profile and optimize wizard effects. Add LOD system based on camera distance"
```

### Adding Features
```bash
# Footstep effects
claude-code "Add footstep particles when wizard walks. Emit 2-3 dust particles per step at ground level"

# Interaction system
claude-code "Add interaction prompt when wizard near interactable objects. Show 'E' key prompt above wizard"

# Companion pet
claude-code "Create magical companion that follows wizard. Small floating orb with particle trail, bobs near wizard shoulder"
```

### Batch Operations
```bash
# Create multiple wizard variants
claude-code "Using WizardCharacter as base, create:
1. FireWizard - red/orange effects, fire particles
2. IceWizard - blue/white effects, snow particles  
3. NatureWizard - green effects, leaf particles
Save each as separate scene inheriting from base"

# Create enemy wizards
claude-code "Duplicate WizardCharacter as EnemyWizard:
- Remove player input controls
- Add AI controller for movement
- Change effects to red/hostile colors
- Add aggro range detection
- Face player when in range"
```

## Best Practices with Claude Code

1. **Incremental Changes**: Make small, specific requests rather than huge rewrites
2. **Preserve Existing**: Always mention "do not modify existing systems" when needed
3. **Test Frequently**: Run the game after each change to catch issues early
4. **Version Control**: Commit before major Claude Code operations
5. **Clear Context**: Provide file paths and specific requirements
6. **Iterative Refinement**: Use follow-up commands to refine results

## Troubleshooting

### Common Issues and Fixes

**Wizard not appearing:**
```bash
claude-code "Debug why WizardCharacter not visible in scene. Check node paths, ensure sprite has texture, verify z-index"
```

**Effects not working:**
```bash
claude-code "Trace why particle effects aren't showing. Add debug prints, check if nodes exist, verify emitting = true"
```

**Performance problems:**
```bash
claude-code "Analyze performance bottlenecks in wizard effects. Add metrics overlay, identify heavy operations, implement optimizations"
```

**Integration conflicts:**
```bash
claude-code "Resolve conflicts between wizard system and existing player controller. Merge functionality, preserve both systems' features"
```

## Advanced Integration

### Multiplayer Support
```bash
claude-code "Make WizardCharacter multiplayer-ready:
- Add network synchronization for position and state
- Sync effect toggles across network
- Optimize particle count for network play
- Add player ID and color customization
- Only process input for local player"
```

### Procedural Generation
```bash
claude-code "Create wizard variation generator:
- Randomize effect colors based on seed
- Generate unique particle patterns
- Vary animation speeds within ranges
- Create 100 unique wizard appearances
- Save configurations as resources"
```

### Modding Support
```bash
claude-code "Make wizard system moddable:
- Move all magic numbers to exported variables
- Create WizardConfig resource type
- Allow loading custom effect textures
- Support custom animation curves
- Document all hookable methods"
```

## Quick Reference Card

| Task | Claude Code Command |
|------|-------------------|
| Add feature | `claude-code "Add [feature] to WizardCharacter..."` |
| Fix bug | `claude-code "Debug and fix [issue] in wizard system..."` |
| Optimize | `claude-code "Optimize wizard [aspect] for [platform]..."` |
| Integrate | `claude-code "Integrate wizard with existing [system]..."` |
| Customize | `claude-code "Modify wizard effects to match [style]..."` |
| Generate variant | `claude-code "Create [type]Wizard variant with [changes]..."` |

## Final Notes

- Always backup before major changes
- Test on target platform regularly  
- Keep commands specific and contextual
- Build features incrementally
- Preserve existing functionality unless explicitly changing it
- Use version control between Claude Code sessions