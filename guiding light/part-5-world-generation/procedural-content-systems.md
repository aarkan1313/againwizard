# Procedural Content Systems

## StandaloneProceduralManager.gd - Core System

**Location**: `/scripts/procedural/StandaloneProceduralManager.gd`  
**Extends**: Node  
**Purpose**: Simplified procedural manager for isolated testing and content generation

### Quality Management System

#### Quality Level Enumeration
```gdscript
enum QualityLevel {
    LOW,     # Mobile/performance optimization
    MEDIUM,  # Standard desktop systems
    HIGH,    # High-end systems with enhanced effects
    ULTRA    # Development/showcase quality
}
```

#### Configuration Parameters
```gdscript
@export var quality_level: QualityLevel = QualityLevel.MEDIUM
@export var enable_particle_effects: bool = true
@export var enable_glow_effects: bool = true
```

### Signal System
```gdscript
signal procedural_content_generated(type: String, id: String, resource: Resource)
```

### Animation Generation Pipeline

#### WizardAnimationGenerator Integration
```gdscript
var animation_generator: WizardAnimationGenerator

func generate_wizard_animations(wizard_config: Dictionary) -> Dictionary:
    if not animation_generator:
        push_error("Animation generator not initialized")
        return {}
    
    var animations = animation_generator.generate_animation_set(wizard_config)
    
    if not animations.is_empty():
        procedural_content_generated.emit("wizard_animation", "complete_set", animations)
        print("✅ Generated ", animations.keys().size(), " animation components")
    
    return animations
```

---

## SlimeSpriteGenerator.gd - Dynamic Sprite Creation

**Location**: `/scripts/procedural/SlimeSpriteGenerator.gd`  
**Extends**: RefCounted  
**Class Name**: SlimeSpriteGenerator  
**Purpose**: Procedural sprite generation for slime enemies

### Static Texture Generation

#### Core Slime Generation Algorithm
```gdscript
static func generate_slime_texture() -> ImageTexture:
    var size = 64
    var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
    
    var center = Vector2(size / 2, size / 2)
    var main_radius = 28.0
    var highlight_radius = 15.0
    
    # Color palette
    var slime_color = Color(0.2, 0.8, 0.3, 1.0)      # Bright green
    var slime_dark = Color(0.1, 0.6, 0.2, 1.0)       # Darker green for shading
    var highlight_color = Color(0.6, 1.0, 0.7, 0.8)  # Light green highlight
    var shine_color = Color(1.0, 1.0, 1.0, 0.6)      # White shine
```

#### Advanced Rendering Techniques

##### Squash Factor Animation
```gdscript
# Main slime body (circular with slight squash)
var squash_factor = 1.0 + 0.2 * sin((pos.y / float(size)) * PI)
var adjusted_radius = main_radius * squash_factor

if distance_from_center <= adjusted_radius:
    # Create gradient from center to edge
    var gradient = 1.0 - (distance_from_center / adjusted_radius)
    var final_color = slime_color.lerp(slime_dark, 1.0 - gradient * 0.7)
```

##### Procedural Texture Details
```gdscript
# Add noise for organic texture
var noise_factor = sin(x * 0.3) * cos(y * 0.4) * 0.1
final_color = final_color.lerp(slime_dark, noise_factor)

# Bottom shadow for depth
if y > center.y + 10:
    var shadow_strength = (y - center.y - 10) / 15.0
    final_color = final_color.lerp(slime_dark, shadow_strength * 0.5)
```

##### Multi-Layer Highlighting System
```gdscript
# Highlight blob (upper left)
var highlight_center = center + Vector2(-8, -12)
var highlight_distance = pos.distance_to(highlight_center)
if highlight_distance <= highlight_radius:
    var highlight_strength = 1.0 - (highlight_distance / highlight_radius)
    var current_color = image.get_pixel(x, y)
    if current_color.a > 0:  # Only add highlight to existing slime
        var highlighted = current_color.lerp(highlight_color, highlight_strength * 0.6)
        image.set_pixel(x, y, highlighted)

# Small shine spot (upper right)
var shine_center = center + Vector2(6, -8)
var shine_distance = pos.distance_to(shine_center)
if shine_distance <= 4:
    var shine_strength = 1.0 - (shine_distance / 4.0)
    var current_color = image.get_pixel(x, y)
    if current_color.a > 0:  # Only add shine to existing slime
        var shined = current_color.lerp(shine_color, shine_strength * 0.8)
        image.set_pixel(x, y, shined)
```

### Animated Frame Generation

#### Multi-Frame Animation System
```gdscript
static func generate_animated_slime_frames() -> Array[ImageTexture]:
    var frames: Array[ImageTexture] = []
    
    # Generate 4 frames with slight variations for bouncy animation
    for frame in range(4):
        var size = 64
        var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
        var center = Vector2(size / 2, size / 2)
        
        # Frame-specific variations for animation
        var bounce_offset = sin(frame * PI / 2) * 3.0
        var squash_variation = 1.0 + (sin(frame * PI / 2) * 0.1)
```

---

## Additional Procedural Systems

### Advanced Components
- **AdvancedParticleManager.gd**: Advanced particle system management
- **DynamicEffectsManager.gd**: Runtime effects generation  
- **EnhancedWizardAnimationGenerator.gd**: Complex animation system
- **PerformanceMonitor.gd**: Procedural performance tracking

### Control and Testing
- **RealTimeControlSystem.gd**: Real-time parameter control
- **DraggableControlPanel.gd**: Interactive control interface
- **TestWizardController.gd**: Wizard system testing
- **CameraController.gd**: Procedural scene camera control

### Integration Support
- **GenerateSlimeSprite.gd**: Utility sprite generation
- **SpellEnvironmentSystem.gd**: Future environmental integration

The procedural content systems provide comprehensive dynamic content generation with quality scaling and performance optimization  
**Extends**: Node  
**Purpose**: Simplified procedural manager for isolated testing and wizard animation generation

### Core Quality System

#### Quality Level Enumeration
```gdscript
enum QualityLevel {
    LOW,     # Mobile/performance
    MEDIUM,  # Standard desktop  
    HIGH,    # High-end systems
    ULTRA    # Development/showcase
}
```

#### Configurable Effect Settings
```gdscript
@export var quality_level: QualityLevel = QualityLevel.MEDIUM
@export var enable_particle_effects: bool = true
@export var enable_glow_effects: bool = true
```

### Wizard Animation Generation System

#### Animation Set Generation
```gdscript
func generate_animation_set(wizard_config: Dictionary) -> Dictionary:
    var animations = {}
    
    # Core wizard properties
    var wizard_colors = wizard_config.get("colors", _get_default_colors())
    var wizard_size = wizard_config.get("size", Vector2(32, 48))
    var effect_intensity = wizard_config.get("effect_intensity", 1.0)
    
    # Generate each animation type
    animations["idle_float"] = _generate_idle_float_animation(wizard_colors, wizard_size, effect_intensity)
    animations["walking"] = _generate_walking_animation(wizard_colors, wizard_size, effect_intensity)
    animations["casting"] = _generate_casting_animation(wizard_colors, wizard_size, effect_intensity)
    animations["floating_fast"] = _generate_floating_fast_animation(wizard_colors, wizard_size, effect_intensity)
    
    # Generate particle systems
    if enable_particle_effects:
        animations["particles"] = _generate_particle_systems(wizard_colors, effect_intensity)
    
    # Generate glow effects
    if enable_glow_effects:
        animations["glow"] = _generate_glow_system(wizard_colors, wizard_size, effect_intensity)
    
    return animations
```

#### Animation Type Specifications

##### Idle Float Animation
```gdscript
func _generate_idle_float_animation(colors: Dictionary, size: Vector2, intensity: float) -> Dictionary:
    return {
        "type": "idle_float",
        "duration": 3.0,
        "float_amount": 8.0 * intensity,
        "breath_amount": 0.05 * intensity,
        "particle_emission": 50 * intensity,
        "properties": {
            "loop": true,
            "particle_color": colors.primary,
            "glow_intensity": 0.6 * intensity
        }
    }
```

##### Walking Animation
```gdscript
func _generate_walking_animation(colors: Dictionary, size: Vector2, intensity: float) -> Dictionary:
    return {
        "type": "walking", 
        "duration": 0.5,
        "bob_amount": 4.0 * intensity,
        "lean_angle": 5.0 * intensity,
        "particle_emission": 80 * intensity,
        "properties": {
            "loop": true,
            "particle_color": colors.secondary,
            "glow_intensity": 0.8 * intensity,
            "footstep_effects": true
        }
    }
```

##### Spell Casting Animation
```gdscript
func _generate_casting_animation(colors: Dictionary, size: Vector2, intensity: float) -> Dictionary:
    return {
        "type": "casting",
        "duration": 1.5,
        "energy_buildup": 0.8,
        "particle_emission": 150 * intensity,
        "properties": {
            "loop": false,
            "particle_color": colors.accent,
            "glow_intensity": 1.2 * intensity,
            "energy_buildup": true
        }
    }
```

#### Particle System Generation
```gdscript
func _generate_particle_systems(colors: Dictionary, intensity: float) -> Dictionary:
    var particle_systems = {}
    
    particle_systems["magic_ambient"] = {
        "emission_count": int(50 * intensity * _get_quality_multiplier()),
        "colors": [colors.primary, colors.secondary, colors.accent],
        "size_range": Vector2(1, 3),
        "lifetime": 3.0
    }
    
    particle_systems["spell_casting"] = {
        "emission_count": int(150 * intensity * _get_quality_multiplier()),
        "colors": [colors.accent, Color.WHITE],
        "size_range": Vector2(2, 6),
        "lifetime": 1.5,
        "burst_mode": true
    }
    
    return particle_systems
```

---

## SlimeSpriteGenerator.gd

**Location**: `/scripts/procedural/SlimeSpriteGenerator.gd`  
**Extends**: RefCounted  
**Purpose**: Procedural sprite generation for slime enemy using algorithmic texture creation

### Static Texture Generation

#### Core Slime Texture Algorithm
```gdscript
static func generate_slime_texture() -> ImageTexture:
    var size = 64
    var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
    
    var center = Vector2(size / 2, size / 2)
    var main_radius = 28.0
    var highlight_radius = 15.0
    
    # Color palette
    var slime_color = Color(0.2, 0.8, 0.3, 1.0)  # Bright green
    var slime_dark = Color(0.1, 0.6, 0.2, 1.0)   # Darker green for shading
    var highlight_color = Color(0.6, 1.0, 0.7, 0.8)  # Light green highlight
    var shine_color = Color(1.0, 1.0, 1.0, 0.6)  # White shine
```

#### Advanced Shading Techniques
```gdscript
# Fill the slime body with gradient and squash effect
for x in range(size):
    for y in range(size):
        var pos = Vector2(x, y)
        var distance_from_center = pos.distance_to(center)
        
        # Main slime body (circular with slight squash)
        var squash_factor = 1.0 + 0.2 * sin((pos.y / float(size)) * PI)
        var adjusted_radius = main_radius * squash_factor
        
        if distance_from_center <= adjusted_radius:
            # Create gradient from center to edge
            var gradient = 1.0 - (distance_from_center / adjusted_radius)
            var final_color = slime_color.lerp(slime_dark, 1.0 - gradient * 0.7)
            
            # Add noise for organic texture
            var noise_factor = sin(x * 0.3) * cos(y * 0.4) * 0.1
            final_color = final_color.lerp(slime_dark, noise_factor)
            
            # Bottom shadow for depth
            if y > center.y + 10:
                var shadow_strength = (y - center.y - 10) / 15.0
                final_color = final_color.lerp(slime_dark, shadow_strength * 0.5)
            
            image.set_pixel(x, y, final_color)
```

#### Highlight and Shine Effects
```gdscript
# Highlight blob (upper left)
var highlight_center = center + Vector2(-8, -12)
var highlight_distance = pos.distance_to(highlight_center)
if highlight_distance <= highlight_radius:
    var highlight_strength = 1.0 - (highlight_distance / highlight_radius)
    var current_color = image.get_pixel(x, y)
    if current_color.a > 0:  # Only add highlight to existing slime
        var highlighted = current_color.lerp(highlight_color, highlight_strength * 0.6)
        image.set_pixel(x, y, highlighted)

# Small shine spot (upper right)
var shine_center = center + Vector2(6, -8)
var shine_distance = pos.distance_to(shine_center)
if shine_distance <= 4:
    var shine_strength = 1.0 - (shine_distance / 4.0)
    var current_color = image.get_pixel(x, y)
    if current_color.a > 0:  # Only add shine to existing slime
        var shined = current_color.lerp(shine_color, shine_strength * 0.8)
        image.set_pixel(x, y, shined)
```

### Animated Frame Generation

#### Bouncy Animation System
```gdscript
static func generate_animated_slime_frames() -> Array[ImageTexture]:
    var frames: Array[ImageTexture] = []
    
    # Generate 4 frames with slight variations for bouncy animation
    for frame in range(4):
        var size = 64
        var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
        var center = Vector2(size / 2, size / 2)
        
        # Animate the squash factor
        var bounce_phase = (frame / 4.0) * PI * 2
        var squash_multiplier = 1.0 + 0.3 * sin(bounce_phase)
        var stretch_multiplier = 1.0 + 0.2 * cos(bounce_phase)
        
        # Apply squash and stretch to create bouncy effect
        for x in range(size):
            for y in range(size):
                var pos = Vector2(x, y)
                var local_pos = pos - center
                local_pos.x *= stretch_multiplier
                local_pos.y *= squash_multiplier
                var adjusted_distance = local_pos.length()
                
                if adjusted_distance <= main_radius:
                    var gradient = 1.0 - (adjusted_distance / main_radius)
                    var final_color = slime_color.lerp(slime_dark, 1.0 - gradient * 0.7)
                    image.set_pixel(x, y, final_color)
```

### File System Integration

#### Texture Export System
```gdscript
static func save_slime_texture_to_file(file_path: String) -> bool:
    var texture = generate_slime_texture()
    var image = texture.get_image()
    
    # Ensure directory exists
    var dir = DirAccess.open("res://")
    var path_parts = file_path.split("/")
    var current_path = "res://"
    
    for i in range(path_parts.size() - 1):  # Skip the filename
        current_path += path_parts[i] + "/"
        if not dir.dir_exists(current_path):
            dir.make_dir(current_path)
    
    # Save the image
    var error = image.save_png(file_path)
    if error == OK:
        print("✅ Slime texture saved to: %s" % file_path)
        return true
    else:
        print("❌ Failed to save slime texture: Error %d" % error)
        return false
```

---

## AdvancedParticleManager.gd

**Location**: `/scripts/procedural/AdvancedParticleManager.gd`  
**Extends**: Node2D  
**Purpose**: Advanced particle system manager for wizard effects with performance optimization

### Particle Pool System

#### Performance Optimization Architecture
```gdscript
var particle_pools = {}
var active_particles = []
var max_particles = 500

func _initialize_particle_pools():
    for effect_name in effect_configs.keys():
        particle_pools[effect_name] = []
        for i in range(50):  # Pre-allocate particles
            particle_pools[effect_name].append(_create_particle(effect_name))
```

### Effect Configuration System

#### Comprehensive Effect Definitions
```gdscript
var effect_configs = {
    "magic_ambient": {
        "emission_rate": 25.0,
        "lifetime": 3.0,
        "size_range": Vector2(1, 4),
        "velocity_range": Vector2(-30, 30),
        "gravity": Vector2(0, -20),
        "colors": [Color.PURPLE, Color.MAGENTA, Color.WHITE]
    },
    "sparkle_burst": {
        "emission_rate": 100.0,
        "lifetime": 1.5,
        "size_range": Vector2(2, 6),
        "velocity_range": Vector2(-80, 80),
        "gravity": Vector2(0, 0),
        "colors": [Color.WHITE, Color.YELLOW, Color.CYAN],
        "burst_mode": true
    },
    "ember_trail": {
        "emission_rate": 40.0,
        "lifetime": 2.0,
        "size_range": Vector2(2, 5),
        "velocity_range": Vector2(-50, 50),
        "gravity": Vector2(0, 20),
        "colors": [Color.ORANGE_RED, Color.YELLOW, Color.RED],
        "heat_effect": true
    },
    "lightning_spark": {
        "emission_rate": 200.0,
        "lifetime": 0.3,
        "size_range": Vector2(1, 2),
        "velocity_range": Vector2(-100, 100),
        "gravity": Vector2(0, 0),
        "colors": [Color.WHITE, Color.CYAN, Color.BLUE],
        "electric_effect": true
    }
}
```

### Advanced Effect Systems

#### Lightning Bolt Generation
```gdscript
func create_lightning_bolt(start_pos: Vector2, end_pos: Vector2, color: Color = Color.WHITE):
    var bolt = {
        "points": [],
        "life": lightning_duration,
        "max_life": lightning_duration,
        "color": color,
        "width": randf_range(2, 6)
    }
    
    # Generate jagged lightning path
    var segments = 8
    var distance = start_pos.distance_to(end_pos)
    
    bolt.points.append(start_pos)
    
    for i in range(1, segments):
        var t = i / float(segments)
        var base_point = start_pos.lerp(end_pos, t)
        var perpendicular = (end_pos - start_pos).rotated(PI * 0.5).normalized()
        var jag_amount = randf_range(-distance * 0.2, distance * 0.2)
        var jagged_point = base_point + perpendicular * jag_amount
        bolt.points.append(jagged_point)
    
    bolt.points.append(end_pos)
    lightning_bolts.append(bolt)
```

#### Rune Circle System
```gdscript
var rune_circles = []
var rune_symbols = ["☆", "◊", "△", "◯", "✧", "◈", "⬢", "※"]

func create_rune_circle(position: Vector2, radius: float, duration: float = 3.0):
    var circle = {
        "position": position,
        "radius": radius,
        "life": duration,
        "max_life": duration,
        "symbols": [],
        "rotation_speed": randf_range(0.5, 2.0)
    }
    
    # Generate symbols around the circle
    var symbol_count = 8
    for i in range(symbol_count):
        var angle = (i / float(symbol_count)) * PI * 2
        var symbol = {
            "text": rune_symbols[randi() % rune_symbols.size()],
            "angle": angle,
            "distance": radius
        }
        circle.symbols.append(symbol)
    
    rune_circles.append(circle)
```

#### Motion Trail System
```gdscript
var motion_trail = []
var max_trail_length = 30

func update_motion_trail(position: Vector2):
    motion_trail.append({
        "position": position,
        "life": 1.0,
        "max_life": 1.0
    })
    
    # Limit trail length for performance
    if motion_trail.size() > max_trail_length:
        motion_trail.pop_front()
```

### Particle Emission Methods

#### Standard Emission
```gdscript
func emit_particles(effect_name: String, position: Vector2, count: int = 1, intensity: float = 1.0):
    if not effect_configs.has(effect_name):
        push_warning("Unknown particle effect: " + effect_name)
        return
    
    var config = effect_configs[effect_name]
    var actual_count = int(count * intensity)
    
    for i in range(actual_count):
        var particle = _get_particle_from_pool(effect_name)
        if particle:
            _configure_particle(particle, effect_name, position, intensity)
            active_particles.append(particle)
    
    particle_effect_triggered.emit(effect_name)
```

#### Burst Emission
```gdscript
func emit_burst(effect_name: String, position: Vector2, count: int = 20, intensity: float = 1.0):
    var config = effect_configs[effect_name]
    var burst_count = int(count * intensity)
    
    for i in range(burst_count):
        var particle = _get_particle_from_pool(effect_name)
        if particle:
            var angle = (i / float(burst_count)) * PI * 2
            var speed = randf_range(50, 150) * intensity
            
            particle.position = position
            particle.velocity = Vector2(cos(angle), sin(angle)) * speed
            particle.life = config.lifetime
            particle.max_life = config.lifetime
            
            _configure_particle(particle, effect_name, position, intensity)
            active_particles.append(particle)
```

## Procedural System Integration

### Performance Optimization Patterns

#### Object Pooling
- Pre-allocated particle objects to avoid runtime allocation
- Pool management for different effect types
- Maximum particle limits to maintain frame rate

#### Quality Scaling
- Quality-based multipliers for emission counts
- Conditional feature enabling (particles, glow effects)
- LOD system for distant effects

#### Memory Management
- Automatic cleanup of expired effects
- Trail length limitations
- Pool size management

### Content Generation Pipeline

#### Wizard Animation Pipeline
1. **Configuration Input**: Color scheme, size, intensity
2. **Animation Generation**: Multiple animation types with parameters
3. **Particle System Creation**: Quality-scaled particle effects
4. **Glow System Setup**: Dynamic lighting effects
5. **Animator Creation**: Component for runtime control

#### Sprite Generation Pipeline
1. **Algorithmic Design**: Mathematical texture generation
2. **Layered Effects**: Gradients, highlights, shadows, noise
3. **Animation Frames**: Squash-and-stretch animation sequences
4. **Export System**: File system integration for asset pipeline

#### Particle Effect Pipeline
1. **Pool Initialization**: Pre-allocation for performance
2. **Configuration System**: Data-driven effect definitions
3. **Emission Control**: Standard and burst emission modes
4. **Advanced Effects**: Lightning bolts, rune circles, motion trails
5. **Lifecycle Management**: Automatic cleanup and recycling

### Extensibility Features

#### Modular Effect System
- Plugin-style effect configurations
- Runtime effect modification
- Signal-based event integration

#### Quality Adaptation
- Performance-based quality scaling
- Platform-specific optimizations
- User preference integration

The procedural content systems provide a robust foundation for dynamic content generation with strong performance characteristics and extensive customization capabilities.