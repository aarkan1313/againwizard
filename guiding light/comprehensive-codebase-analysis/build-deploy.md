# Build Configuration

## Overview

This document details the build configuration, export settings, deployment procedures, and platform-specific configurations for the FFS Wizard RPG project. The game is built using Godot 4.4.1 with specific optimization settings for different target platforms.

---

## Export Presets

### Project Export Configuration
**Engine**: Godot 4.4.1  
**Renderer**: Forward Plus (Vulkan/OpenGL)  
**Export Location**: Platform-specific output directories

#### Available Export Presets
Based on typical Godot project configuration:

```
Export Presets:
├── Windows Desktop (x64)
├── Linux/X11 (x64)  
├── macOS (Universal)
├── Web (HTML5/WebGL2)
└── Android (ARM64/ARMv7)
```

### Windows Desktop Export
**Target**: Windows 10/11 x64  
**Executable**: `FFS_WizardRPG.exe`

#### Windows Export Settings
```ini
# Windows-specific configuration
platform/windows/export/x86_64=true
platform/windows/binary_format/embed_pck=false
platform/windows/binary_format/executable_path=""
platform/windows/codesign/enable=false

# Performance settings
application/boot_splash/bg_color=Color(0.14, 0.14, 0.16, 1)
application/boot_splash/show_image=true
application/boot_splash/image="res://icon.svg"
```

#### Windows Optimization
- **Threading**: Multi-threaded resource loading enabled
- **Memory**: 4GB RAM recommended, 2GB minimum
- **Graphics**: DirectX 11/12 or Vulkan support
- **Storage**: 500MB installation size

### Linux Export
**Target**: Linux x64 (Ubuntu 18.04+ compatible)  
**Executable**: `FFS_WizardRPG.x86_64`

#### Linux Dependencies
```bash
# Required system libraries
libGL.so.1          # OpenGL rendering
libX11.so.6         # X11 window system  
libXrandr.so.2      # Display configuration
libasound.so.2      # Audio system (ALSA)
libpulse.so.0       # PulseAudio (optional)
```

### macOS Export
**Target**: macOS 10.14+ (Universal Binary)  
**Bundle**: `FFS WizardRPG.app`

#### macOS Configuration
```ini
# macOS-specific settings
platform/macos/export/universal=true
platform/macos/signing/app_id="com.example.ffs_wizardrpg"
platform/macos/info/copyright="Copyright © 2024"
platform/macos/info/version="1.0.0"
```

### Web Export
**Target**: Modern browsers with WebGL2 support  
**Output**: HTML5 + WASM bundle

#### Web-Specific Optimizations
```ini
# Web export configuration
platform/web/variant/threads=false  # Single-threaded for compatibility
platform/web/variant/extensions=false
platform/web/export/convert_text_to_binary=true

# Performance settings
rendering/textures/canvas_textures/default_texture_filter=1
rendering/renderer/rendering_method="gl_compatibility"
```

#### Browser Compatibility
- **Chrome**: 88+ (recommended)
- **Firefox**: 78+
- **Safari**: 14.1+
- **Edge**: 88+

---

## Platform-Specific Settings

### Display Configuration

#### Resolution and Window Settings
```gdscript
# project.godot display settings
[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/mode=3  # Fullscreen mode
window/size/resizable=true
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

#### Scaling Options
- **Desktop**: Native resolution with UI scaling
- **Mobile**: Adaptive UI scaling based on screen density
- **Web**: Browser-based scaling with minimum viewport

### Input Configuration

#### Platform-Specific Input Maps
```gdscript
# Cross-platform input handling
[input]
# Desktop: Keyboard + Mouse
move_left=Key(A)
move_right=Key(D)
spell_1=Key(1)

# Mobile: Touch controls (future)
touch_move=TouchScreen
touch_spell=TouchScreen

# Gamepad: Controller support (future)
gamepad_move=JoyAxis(0,1)
gamepad_spell=JoyButton(0)
```

### Audio System Configuration

#### Audio Driver Selection
```ini
# Platform-specific audio drivers
[audio]
# Windows: DirectSound/WASAPI
driver/enable_input=true
driver/output_latency=15

# Linux: ALSA/PulseAudio  
driver/enable_input=true
driver/mix_rate=44100

# Web: Web Audio API
driver/output_latency=50  # Higher latency for web
```

---

## Build Automation

### Godot Command-Line Export
**Tool**: Godot headless build system

#### Automated Build Script
```bash
#!/bin/bash
# build.sh - Automated build script

GODOT_BINARY="godot"
PROJECT_PATH="."
EXPORT_PATH="builds/"

# Ensure export directory exists
mkdir -p "$EXPORT_PATH"

# Windows build
echo "Building Windows version..."
$GODOT_BINARY --headless --export-release "Windows Desktop" \
    "$EXPORT_PATH/windows/FFS_WizardRPG.exe" --path "$PROJECT_PATH"

# Linux build  
echo "Building Linux version..."
$GODOT_BINARY --headless --export-release "Linux/X11" \
    "$EXPORT_PATH/linux/FFS_WizardRPG.x86_64" --path "$PROJECT_PATH"

# Web build
echo "Building Web version..."
$GODOT_BINARY --headless --export-release "Web" \
    "$EXPORT_PATH/web/index.html" --path "$PROJECT_PATH"

echo "Build completed!"
```

#### CI/CD Integration (GitHub Actions)
```yaml
# .github/workflows/build.yml
name: Build and Export
on: [push, pull_request]

jobs:
  export:
    name: Export Game
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        
      - name: Setup Godot
        uses: lihop/setup-godot@v2
        with:
          version: "4.4.1"
          
      - name: Import assets
        run: godot --headless --import
        
      - name: Export Windows
        run: godot --headless --export-release "Windows Desktop" builds/windows/game.exe
        
      - name: Export Linux
        run: godot --headless --export-release "Linux/X11" builds/linux/game.x86_64
        
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: game-builds
          path: builds/
```

---

## Version Control Considerations

### Git Configuration
**Repository**: Git-based version control with LFS support

#### .gitignore Configuration
```gitignore
# Godot-specific ignores
.godot/
.import/
*.tmp

# Build outputs
builds/
exports/
dist/

# Platform-specific
.DS_Store
Thumbs.db
*.log

# IDE files
.vscode/
.idea/

# Temporary files
*~
*.swp
*.swo
```

#### Git LFS Configuration
```gitattributes
# Large binary assets
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.ogg filter=lfs diff=lfs merge=lfs -text
*.wav filter=lfs diff=lfs merge=lfs -text
*.mp3 filter=lfs diff=lfs merge=lfs -text

# Godot binary files
*.import filter=lfs diff=lfs merge=lfs -text
*.tscn filter=lfs diff=lfs merge=lfs -text
*.tres filter=lfs diff=lfs merge=lfs -text
```

### Release Branching Strategy
```
Main Branch: main
├── Development: develop
├── Feature Branches: feature/*
├── Release Branches: release/*
└── Hotfix Branches: hotfix/*
```

---

## Required Project Settings

### Engine Configuration
**File**: `project.godot` core settings

#### Application Settings
```ini
[application]
config/name="Wizard RPG Game"
config/version="1.0.0"
config/description="2D Wizard Action RPG"
config/icon="res://icon.svg"
config/features=PackedStringArray("4.4", "Forward Plus")
run/main_scene="uid://c8j5yq2wmvnxp"  # MainMenu.tscn
```

#### Rendering Configuration
```ini
[rendering]
renderer/rendering_method="forward_plus"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=1
anti_aliasing/quality/msaa_2d=2
anti_aliasing/quality/screen_space_aa=1
```

#### Physics Settings
```ini
[physics]
2d/default_gravity=980
2d/default_gravity_vector=Vector2(0, 1)
2d/physics_engine="GodotPhysics2D"

[layer_names]
2d_physics/layer_1="player"
2d_physics/layer_2="enemies"  
2d_physics/layer_3="projectiles"
2d_physics/layer_4="environment"
```

#### Memory and Performance
```ini
[memory]
limits/message_queue/max_size_mb=32
multithread/thread_model=1

[rendering]
limits/rendering/max_renderable_elements=128000
limits/rendering/max_renderable_lights=256
```

---

## Deployment Procedures

### Development Deployment
**Target**: Local development and testing

#### Development Build Process
1. **Asset Validation**: Verify all assets imported correctly
2. **Script Compilation**: Check for syntax errors
3. **Scene Validation**: Ensure all scene references valid
4. **Export Testing**: Test export process for target platform
5. **Runtime Testing**: Verify functionality on target system

#### Development Quality Gates
```gdscript
# QualityGate.gd development checks
func validate_development_build() -> bool:
    var issues = []
    
    # Check for missing references
    issues.append_array(check_missing_scene_references())
    issues.append_array(check_missing_script_references())
    issues.append_array(check_missing_resource_references())
    
    # Validate system integration
    issues.append_array(validate_autoload_dependencies())
    issues.append_array(validate_input_map_configuration())
    
    if issues.size() > 0:
        UnifiedDebugSystem.log_error("Build validation failed: " + str(issues))
        return false
    
    return true
```

### Production Deployment
**Target**: Public release builds

#### Production Build Pipeline
1. **Code Freeze**: Lock repository to specific commit
2. **Automated Testing**: Run full test suite
3. **Performance Validation**: Verify frame rate targets
4. **Asset Optimization**: Compress textures and audio
5. **Multi-Platform Build**: Generate all target platform builds
6. **Quality Assurance**: Manual testing on target hardware
7. **Release Package**: Create distribution packages

#### Production Quality Checks
```bash
#!/bin/bash
# production_validate.sh

echo "Running production validation..."

# Performance validation
echo "Checking performance requirements..."
if ! ./scripts/validate_performance.sh; then
    echo "❌ Performance validation failed"
    exit 1
fi

# Asset validation
echo "Validating assets..."
if ! ./scripts/validate_assets.sh; then
    echo "❌ Asset validation failed"
    exit 1
fi

# Build validation
echo "Validating builds..."
for platform in windows linux web; do
    if ! ./scripts/validate_build.sh "$platform"; then
        echo "❌ Build validation failed for $platform"
        exit 1
    fi
done

echo "✅ Production validation passed"
```

### Distribution Platforms

#### Desktop Distribution
- **Steam**: Primary PC distribution platform
- **itch.io**: Independent game distribution
- **Direct Download**: Website-hosted downloads

#### Web Distribution
- **itch.io**: Web game hosting
- **Newgrounds**: Flash/HTML5 game platform
- **Self-Hosted**: Own website deployment

#### Mobile Distribution (Future)
- **Google Play Store**: Android distribution
- **Apple App Store**: iOS distribution
- **Alternative Android Stores**: Samsung, Amazon, etc.

---

## Build Optimization Strategies

### Asset Optimization

#### Texture Optimization
```ini
# Texture import settings for different platforms
[Desktop]
compress/mode=2          # VRAM compression
compress/quality=0.7     # High quality

[Mobile]
compress/mode=4          # ETC2 compression
compress/quality=0.5     # Balanced quality

[Web]
compress/mode=1          # Lossy compression
compress/quality=0.6     # Web-optimized
```

#### Audio Optimization
```ini
# Audio compression settings
[Music]
format=OGG_VORBIS
quality=0.7
loop=true
stream=true

[SFX]
format=WAV
quality=1.0
loop=false
stream=false
```

### Code Optimization
```ini
# GDScript compilation settings
[script]
compilation_mode=3       # Optimized compilation
debug_symbols=false      # Remove debug info for release
```

### Performance Monitoring
```gdscript
# Build-time performance validation
func validate_performance_targets():
    var performance_requirements = {
        "target_fps": 60,
        "min_fps": 30,
        "max_memory_mb": 512,
        "max_startup_time": 5.0
    }
    
    return check_performance_against_targets(performance_requirements)
```

This comprehensive build configuration ensures reliable, optimized builds across all target platforms while maintaining development efficiency and production quality standards.