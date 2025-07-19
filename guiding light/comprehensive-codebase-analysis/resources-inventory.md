# Asset Documentation

## Overview

This document catalogues all assets, resources, and media files in the FFS Wizard RPG project, organized by type and usage. Each asset entry includes technical specifications, usage locations, and import settings.

---

## Directory Structure

```
godot/Game10/
├── assets/                 # Source assets and effects
├── data/                   # Game data resources (.tres files)
├── textures/               # Generated and imported textures
├── shaders/                # Custom shader files
├── effects/                # Effect scene files
└── scenes/                 # Scene files with embedded resources
```

---

## Sprites/Textures

### Player Assets
**Location**: Player sprite embedded in Player.tscn  
**Format**: PNG with transparency  
**Usage**: Player character visual representation

#### Technical Specifications
- **Dimensions**: Standardized sprite size (exact dimensions in scene)
- **Import Settings**: Filter enabled, mipmaps disabled for pixel art
- **Color Format**: RGBA8 for transparency support

### Enemy Sprites

#### Core Enemy Assets
**Location**: `assets/sprites/`

##### Goblin
**File**: `goblin2.png`  
**Dimensions**: Optimized for 2D gameplay  
**Usage**: `scenes/enemies/Goblin.tscn`  
**Import Settings**: 
```
filter=true
mipmaps=false
format=RGBA8
```

##### Orc
**File**: `orc_cut-removebg-preview.png`  
**Features**: Background removed, transparent edges  
**Usage**: `scenes/enemies/Orc.tscn`  
**Processing**: Pre-processed for transparency

##### Skeleton Archer
**File**: `skeleton_archer-removebg-preview.png`  
**Type**: Ranged enemy with bow sprite  
**Usage**: `scenes/enemies/Skeleton.tscn`  
**Special Features**: Directional sprite for aiming

##### Evil Wizard
**File**: `evil_wizard_cut-removebg-preview.png`  
**Type**: Magic-based enemy sprite  
**Usage**: `scenes/enemies/Wizard.tscn`  
**Features**: Robed character with magical appearance

##### Golem
**File**: `golem_cut-removebg-preview.png`  
**Type**: Large tank enemy  
**Usage**: `scenes/enemies/Golem.tscn`  
**Features**: Stone/earth elemental design

##### Slime
**File**: `slime_generated.png`  
**Type**: Procedurally generated sprite  
**Usage**: `scenes/enemies/Slime.tscn`  
**Generation**: Created via `scripts/utils/GenerateSlimeSprite.gd`

##### Player Wizard
**File**: `pixel_wizard-removebg-preview.png`  
**Usage**: Player character representation  
**Features**: Wizard-themed pixel art design

### Spell System Textures

#### Spell Projectiles
**Location**: `textures/spell_projectiles/`  
**Purpose**: Visual representation of spell projectiles  
**Usage**: `scripts/SpellProjectile.gd` texture assignment

##### Available Projectile Textures
- `fireball_projectile.png` - Fire-based spell projectile
- `ice_shard_projectile.png` - Ice/frost spell projectile  
- `lightning_bolt_projectile.png` - Electric spell projectile
- `magic_missile_projectile.png` - Basic magic projectile
- `arcane_burst_projectile.png` - Arcane magic projectile
- `earth_spike_projectile.png` - Earth/nature projectile
- `frost_spike_projectile.png` - Enhanced ice projectile
- `flame_wave_projectile.png` - Fire wave effect
- `heal_projectile.png` - Healing spell visual
- `natures_thorn_projectile.png` - Nature/thorn projectile
- `shadow_dart_projectile.png` - Dark magic projectile
- `void_bolt_projectile.png` - Void/dark energy projectile
- `energy_burst_projectile.png` - Generic energy projectile

#### Spell Icons
**Location**: `textures/spell_icons/`  
**Purpose**: UI representation for spell toolbar  
**Usage**: `scripts/ui/SpellToolbar.gd`

##### Available Spell Icons
Matching icon set for all projectile types:
- `fireball_icon.png`
- `ice_shard_icon.png`
- `lightning_bolt_icon.png`
- `magic_missile_icon.png`
- `arcane_burst_icon.png`
- `earth_spike_icon.png`
- `frost_spike_icon.png`
- `flame_wave_icon.png`
- `heal_icon.png`
- `natures_thorn_icon.png`
- `shadow_dart_icon.png`
- `void_bolt_icon.png`
- `energy_burst_icon.png`

#### Technical Specifications
**Format**: PNG with transparency  
**Dimensions**: Consistent sizing for UI integration  
**Import Settings**:
```
filter=true
mipmaps=false
compression=Lossless
format=RGBA8
```

### Effect Assets

#### Bone Arrow Effect
**Location**: `assets/effects/bone_arrow.svg`  
**Format**: SVG vector graphics  
**Usage**: Skeleton enemy projectile effects  
**Features**: Scalable vector format for crisp rendering

#### Procedural Textures
**Generation**: Multiple scripts create textures at runtime
- **HealEffect.gd**: Green orb textures for healing particles
- **ImpactEffect.gd**: Circle impact textures for spell hits
- **DamageNumber.gd**: Font rendering for damage text

---

## Audio Files

### Music vs SFX Organization
**Current Status**: Audio structure prepared but not fully implemented

#### Music Directory Structure (Planned)
```
audio/
├── music/
│   ├── menu_theme.ogg
│   ├── gameplay_theme.ogg
│   └── boss_theme.ogg
└── sfx/
    ├── spells/
    ├── combat/
    └── ui/
```

#### Sound Effect Categories
- **Spell Casting**: Magic sound effects for 13 spell types
- **Combat**: Hit sounds, damage impacts, enemy deaths
- **UI**: Button clicks, menu transitions, notifications
- **Environmental**: Ambient world sounds, footsteps

### Audio Format Standards
- **Music**: OGG Vorbis for compression efficiency
- **SFX**: WAV for low-latency effects
- **Streaming**: Enabled for music, disabled for SFX
- **Loop Settings**: Configured per audio type

---

## Fonts

### Font Usage
**Current Implementation**: Default Godot fonts with size overrides
**UI Integration**: Label and Control nodes use theme font overrides

#### Font Applications
- **Damage Numbers**: Size 14, bold weight for visibility
- **UI Labels**: Standard sizing with theme integration
- **Debug Text**: Monospace font for debug output

#### Font Resources (Planned)
- **UI Font**: Clean sans-serif for interface elements
- **Damage Font**: Bold font for damage numbers
- **Decorative Font**: Fantasy-themed font for titles

---

## Scenes (Reusable Scene Resources)

### Effect Scenes
**Location**: `scenes/effects/`  
**Purpose**: Reusable visual effect components

#### Core Effect Scenes
- **HealEffect.tscn**: Healing particle system
- **EnemyDeath.tscn**: Enemy death particle effects
- **DamageNumber.tscn**: Floating damage text
- **ImpactEffect.tscn**: Spell impact visual feedback
- **MuzzleFlash.tscn**: Projectile launch effects
- **Shockwave.tscn**: Area effect visuals

#### Combat Effect Scenes
- **MeleeTelegraph.tscn**: Melee attack warning indicators
- **RangedTelegraph.tscn**: Ranged attack warning indicators
- **SlamAreaIndicator.tscn**: Area attack preview
- **GroundCrack.tscn**: Environmental damage effects
- **GroundDebris.tscn**: Particle debris from impacts

### UI Component Scenes
**Location**: `scenes/ui/`  
**Purpose**: Reusable interface components

#### Primary UI Scenes
- **PlayerUI.tscn**: Main gameplay interface
- **SpellToolbar.tscn**: Spell selection toolbar
- **DamageNumber.tscn**: Combat feedback text
- **AchievementNotification.tscn**: Achievement popup
- **ChunkLoadingScreen.tscn**: World loading interface

---

## Resources (Custom .tres Files)

### Game Data Resources
**Location**: `data/`

#### Core Configuration
**File**: `game_constants.tres`  
**Type**: GameConstants resource  
**Purpose**: Global game configuration values  
**Usage**: Referenced by all major systems

#### Enemy Data Resources
**Location**: `data/enemies/`  
**Type**: EnemyData resources

##### Available Enemy Data Files
- `goblin_data.tres` - Goblin enemy configuration
- `orc_data.tres` - Orc enemy stats and behavior
- `skeleton_data.tres` - Skeleton archer configuration
- `wizard_data.tres` - Evil wizard enemy setup
- `golem_data.tres` - Golem tank enemy data
- `slime_data.tres` - Slime enemy properties

##### EnemyData Structure
```gdscript
enemy_name: String
max_health: float
damage: float
speed: float
xp_reward: int
sprite_texture: Texture2D
abilities: Array[AbilityData]
```

#### Ability Data Resources
**Location**: `data/abilities/`  
**Type**: AbilityData resources

##### Available Ability Files
- `goblin_claw.tres` - Goblin melee attack
- `orc_cleave.tres` - Orc area melee attack
- `skeleton_bone_arrow.tres` - Skeleton ranged attack
- `wizard_fireball.tres` - Wizard magical projectile
- `golem_earth_slam.tres` - Golem ground slam ability
- `golem_stone_strike.tres` - Golem single target attack
- `slime_bounce.tres` - Slime movement ability

##### AbilityData Structure
```gdscript
ability_name: String
damage: float
range: float
cooldown: float
cast_time: float
projectile_speed: float (for ranged)
area_radius: float (for AOE)
```

---

## Shaders

### Custom Shader Files
**Location**: `shaders/`  
**Format**: Godot .gdshader files

#### Available Shaders

##### Biome Blending Shader
**File**: `biome_blending.gdshader`  
**Purpose**: Smooth transitions between different biome areas  
**Usage**: World generation visual blending  
**Features**: Multi-texture blending, smooth interpolation

##### Enhanced Terrain Shader
**File**: `enhanced_terrain.gdshader`  
**Purpose**: Advanced terrain rendering with detail textures  
**Features**: Normal mapping, texture splatting, detail enhancement

##### GPU Terrain Generator
**File**: `gpu_terrain_generator.gdshader`  
**Purpose**: GPU-accelerated terrain height generation  
**Usage**: Real-time world generation optimization  
**Features**: Noise generation, height mapping, performance optimization

#### Shader Applications
- **World Rendering**: Terrain and biome visual effects
- **Particle Effects**: Custom particle shaders for spells
- **UI Effects**: Screen transitions and special effects
- **Post-Processing**: Screen-space effects and filters

### Shader Integration
**Material Usage**: Applied to specific nodes requiring custom rendering
**Performance**: GPU-optimized for real-time rendering
**Compatibility**: Godot 4.4.1 Forward Plus renderer optimized

---

## Asset Pipeline and Import Settings

### Import Configuration Standards

#### Texture Import Settings
```ini
# Sprites and Icons
filter=true
mipmaps=false
format=RGBA8

# UI Elements  
filter=true
mipmaps=false
format=RGBA8

# Effects and Particles
filter=true
mipmaps=true (for scaled effects)
format=RGBA8
```

#### Audio Import Settings (Planned)
```ini
# Music
format=OGG Vorbis
quality=0.7
loop=true
streaming=true

# SFX
format=WAV
quality=1.0
loop=false
streaming=false
```

### Asset Optimization

#### Memory Usage Optimization
- **Texture Compression**: RGBA8 for transparency, RGB8 for opaque
- **Mipmap Generation**: Enabled for scalable effects
- **Streaming**: Audio streaming for large files

#### Performance Considerations
- **Texture Atlas**: Potential future optimization for sprites
- **Resource Preloading**: Critical assets loaded at startup
- **Dynamic Loading**: Effects and particles loaded on demand

### Asset Creation Guidelines

#### Sprite Requirements
- **Transparency**: PNG format with alpha channel
- **Sizing**: Consistent dimensions within enemy types
- **Style**: Pixel art or clean vector style
- **Background**: Transparent or pre-removed

#### Icon Requirements  
- **Size**: Consistent dimensions for UI integration
- **Style**: Matching visual theme across all icons
- **Clarity**: High contrast for UI visibility
- **Format**: PNG with transparency support

This comprehensive asset inventory demonstrates the project's well-organized resource structure, supporting both current functionality and future expansion while maintaining performance and visual consistency.