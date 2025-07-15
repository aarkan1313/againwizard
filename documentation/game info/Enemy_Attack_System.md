# Enemy Attack & Ability System (Phase 3.7)

## Overview
The enhanced enemy attack system provides diverse combat behaviors with visual telegraphs, procedural animations, and integrated ability support. Enemies are divided into melee attackers and ability-only casters.

## Enemy Types & Combat Capabilities

### 🗡️ **Melee Attackers** (Basic Attack + Abilities)

#### **Goblin** 
Fast, aggressive melee fighter with quick strikes.
- **Basic Attack**: Quick lunge attack
  - Attack Range: 40 units
  - Base Damage: 8
  - Attack Cooldown: 1.2 seconds
  - Telegraph Duration: 0.3s (yellow/low threat)
  - Special Feature: Lunges forward at 150 units/s during attack
- **Abilities**: 40% chance to use configured abilities instead of basic attack
- **Movement**: Direct pursuit, circles when close

#### **Orc**
Heavy melee bruiser with knockback attacks.
- **Basic Attack**: Heavy slam with knockback
  - Attack Range: 60 units
  - Base Damage: 15
  - Attack Cooldown: 2.5 seconds
  - Telegraph Duration: 0.6s (orange/medium threat)
  - Special Feature: Knocks player back 200 units on hit
- **Abilities**: 40% chance to use configured abilities
- **Movement**: Slower but steady approach

#### **Golem**
Devastating tank with ground-shaking attacks.
- **Basic Attack**: Ground pound
  - Attack Range: 70 units
  - Base Damage: 25
  - Attack Cooldown: 4.0 seconds
  - Telegraph Duration: 1.0s (dark red/extreme threat)
  - Special Feature: Heavy knockback of 400 units
- **Abilities**: 40% chance to use configured abilities
- **Movement**: Slow but relentless

### 🔮 **Ability-Only Enemies** (No Basic Attacks)

#### **Skeleton** 💀
Undead caster relying entirely on abilities.
- **No basic attacks** - uses abilities exclusively
- Ability Range: 100 units
- Ability Cooldown: 2.0 seconds between casts
- Abilities defined in EnemyData resource

#### **Wizard** 🧙
Powerful mage with long-range magical attacks.
- **No basic attacks** - uses abilities exclusively
- Ability Range: 150 units (longest range)
- Ability Cooldown: 3.0 seconds between casts
- Abilities defined in EnemyData resource

#### **Elemental** 🔥
Magical being of pure energy.
- **No basic attacks** - uses abilities exclusively
- Ability Range: 120 units
- Ability Cooldown: 2.5 seconds between casts
- Abilities defined in EnemyData resource

## Movement AI Patterns

### Melee Enemy Behavior
- **Pursuit**: Move directly toward player when far away
- **Optimal Distance**: Circle around player when within attack range
- **Attack State**: Stop all movement during attack execution
- **Smart Positioning**: Avoid clumping with other enemies

### Ranged Enemy Behavior
- **Distance Management**: 
  - Back away if too close (< 60% of attack range)
  - Move closer if too far (> 90% of attack range)
  - Strafe at optimal distance (60-90% of range)
- **Line of Sight**: Attempt to maintain clear shot to player
- **Kiting**: Move perpendicular to player for evasive strafing

## Visual Effects & Feedback

### Attack Telegraph System
All attacks include clear visual warnings:
- **Color-coded threat levels**:
  - Yellow = Low threat (Goblin)
  - Orange = Medium threat (Orc)
  - Dark Red = Extreme threat (Golem)
- **Telegraph animations**: 
  - Color pulse effect on sprite
  - Scale breathing animation
  - Integration with TelegraphSystem for area warnings

### Attack Animations
Enemy-specific procedural animations:
- **Goblin**: Quick horizontal slash (scale X stretch)
- **Orc**: Heavy downward slam (scale bounce)
- **Golem**: Ground pound (compress then expand)
- **Default**: Simple scale pulse

### Hit Effects
- **Impact particles**: 8 orange particles burst from hit location
- **Damage numbers**: Yellow floating text showing damage dealt
- **Hit flash**: Enemy briefly flashes red when taking damage
- **Knockback**: Physical push effect for applicable attacks

## Damage Calculation & Scaling

### Base Damage Formula
```
Final Damage = Base Damage × Wave Multiplier × Damage Multiplier × Reactive Modifier
```

### Damage Modifiers
- **Wave Multiplier**: Increases with each wave (from WaveManager)
- **Damage Multiplier**: From buffs, abilities, or status effects
- **Reactive Modifier**: 
  - Berserker Mode: 50% damage boost when enemy health < 30%
  - Other conditional modifiers from abilities

### Scaling System
All enemy stats scale with waves:
- Health multiplier
- Damage multiplier
- Speed multiplier
- XP reward multiplier

## Attack State Management

### Attack Phases
1. **Idle**: Looking for attack opportunities
2. **Telegraph**: Warning phase with visual indicators
3. **Execute**: Attack animation and damage dealing
4. **Recovery**: Brief cooldown before next action

### Cooldown System
- Each enemy type has specific cooldowns
- Cooldowns prevent attack spam
- Ability usage has separate cooldown tracking
- Global ability cooldown prevents ability overlap

## Integration Points

### GameEvents Integration
- Emits `enemy_attack_hit` signal on successful hits
- Tracks combat events for statistics
- Enables other systems to react to combat

### TelegraphSystem Integration
- Shows area warnings for attacks
- Color-coded threat visualization
- Automatic cleanup after attacks

### UnifiedDebugSystem Integration
- Enemy state tracking
- Attack cooldown visualization
- Debug rendering of attack ranges

## Configuration & Customization

### EnemyData Resource
Each enemy's abilities are defined in their EnemyData resource:
- Ability list with cooldowns and effects
- Sprite and visual configuration
- Base stats and scaling factors
- AI behavior patterns

### Attack Parameters
Easily adjustable in `setup_attack_parameters()`:
- Attack ranges
- Damage values
- Cooldown timers
- Telegraph durations
- Special effects (lunge speed, knockback force)

## Performance Considerations

- **Optimized for 50+ enemies**: Efficient state management
- **Procedural effects**: No texture loading during combat
- **Automatic cleanup**: Effects self-destruct after use
- **Lightweight animations**: Tween-based, no heavy computations

## Tips for Players

### Combat Strategy
- **Watch for telegraphs**: React to color-coded warnings
- **Exploit cooldowns**: Attack during enemy recovery phases
- **Manage distance**: Stay out of melee range for casters
- **Priority targets**: Focus on high-threat enemies first

### Enemy Weaknesses
- **Goblins**: Low health, vulnerable after lunge
- **Orcs**: Slow attack speed, predictable patterns
- **Golems**: Very slow movement, long telegraphs
- **Casters**: Fragile when approached in melee range