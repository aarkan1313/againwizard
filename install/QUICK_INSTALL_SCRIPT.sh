#!/bin/bash
# Quick Install Script for Spell Toolbar System
# Wizard RPG Clean Rebuild - Godot 4.4.1
# Run from: /mnt/c/FFS/
# Usage: bash install/QUICK_INSTALL_SCRIPT.sh

echo "🎯 Spell Toolbar System - Quick Installation"
echo "=========================================="
echo ""

# Set up paths
PROJECT_ROOT="/mnt/c/FFS/godot/Game10"
SOURCE_DIR="/mnt/c/FFS/edited/spell_toolbar"
INSTALL_DIR="/mnt/c/FFS/install"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Check if project exists
if [ ! -d "$PROJECT_ROOT" ]; then
    print_error "Project directory not found: $PROJECT_ROOT"
    exit 1
fi

print_info "Found project directory: $PROJECT_ROOT"

# Check if source files exist
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory not found: $SOURCE_DIR"
    exit 1
fi

print_info "Found source files: $SOURCE_DIR"

echo ""
echo "🔧 Creating directory structure..."

# Create necessary directories
mkdir -p "$PROJECT_ROOT/scripts/ui"
mkdir -p "$PROJECT_ROOT/scripts/managers"
mkdir -p "$PROJECT_ROOT/scripts/input"
mkdir -p "$PROJECT_ROOT/scenes/ui"

print_status "Directory structure created"

echo ""
echo "📂 Copying toolbar files..."

# Copy main toolbar files
if cp "$SOURCE_DIR/SpellToolbar.gd" "$PROJECT_ROOT/scripts/ui/"; then
    print_status "SpellToolbar.gd copied"
else
    print_error "Failed to copy SpellToolbar.gd"
fi

if cp "$SOURCE_DIR/SpellSlot.gd" "$PROJECT_ROOT/scripts/ui/"; then
    print_status "SpellSlot.gd copied"
else
    print_error "Failed to copy SpellSlot.gd"
fi

if cp "$SOURCE_DIR/SpellToolbar.tscn" "$PROJECT_ROOT/scenes/ui/"; then
    print_status "SpellToolbar.tscn copied"
else
    print_error "Failed to copy SpellToolbar.tscn"
fi

if cp "$SOURCE_DIR/ToolbarManager.gd" "$PROJECT_ROOT/scripts/managers/"; then
    print_status "ToolbarManager.gd copied"
else
    print_error "Failed to copy ToolbarManager.gd"
fi

echo ""
echo "🎮 Enhanced Input System..."

# Check if user wants enhanced input
echo "Do you want to install the Enhanced Input System? (y/N)"
echo "This adds mouse wheel spell selection and quick-cast features."
read -r INSTALL_ENHANCED

if [[ $INSTALL_ENHANCED =~ ^[Yy]$ ]]; then
    # Backup original InputHandler
    if [ -f "$PROJECT_ROOT/scripts/InputHandler.gd" ]; then
        cp "$PROJECT_ROOT/scripts/InputHandler.gd" "$PROJECT_ROOT/scripts/InputHandler_backup.gd"
        print_status "Original InputHandler backed up to InputHandler_backup.gd"
    fi
    
    # Copy enhanced version
    if cp "$SOURCE_DIR/Enhanced_InputHandler.gd" "$PROJECT_ROOT/scripts/InputHandler.gd"; then
        print_status "Enhanced InputHandler installed"
    else
        print_error "Failed to install Enhanced InputHandler"
    fi
else
    # Copy as separate file for manual integration
    if cp "$SOURCE_DIR/Enhanced_InputHandler.gd" "$PROJECT_ROOT/scripts/input/"; then
        print_status "Enhanced_InputHandler.gd copied to scripts/input/ for manual integration"
    else
        print_error "Failed to copy Enhanced_InputHandler.gd"
    fi
fi

echo ""
echo "🔍 Verifying installation..."

# Verify all files exist
FILES_TO_CHECK=(
    "$PROJECT_ROOT/scripts/ui/SpellToolbar.gd"
    "$PROJECT_ROOT/scripts/ui/SpellSlot.gd"
    "$PROJECT_ROOT/scripts/managers/ToolbarManager.gd"
    "$PROJECT_ROOT/scenes/ui/SpellToolbar.tscn"
)

ALL_GOOD=true
for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        print_status "$(basename "$file") - OK"
    else
        print_error "$(basename "$file") - MISSING"
        ALL_GOOD=false
    fi
done

echo ""
if [ "$ALL_GOOD" = true ]; then
    print_status "All core files installed successfully!"
else
    print_error "Some files are missing. Please check the installation."
    exit 1
fi

echo ""
echo "📋 Next Steps - Manual Integration Required:"
echo ""
echo "1. Open Godot Editor"
echo "2. Open scenes/Main.tscn"
echo "3. Find the 'UI' CanvasLayer node"
echo "4. Add a new Node as child of UI:"
echo "   - Right-click UI → Add Child → Node"
echo "   - Name: ToolbarManager"
echo "   - Attach Script: res://scripts/managers/ToolbarManager.gd"
echo "5. Configure ToolbarManager in Inspector:"
echo "   - Auto Setup On Ready: ✅ true"
echo "   - Hide In Menus: ✅ true"
echo "   - Fade During Pause: ✅ true"
echo "   - Toolbar Scene Path: res://scenes/ui/SpellToolbar.tscn"
echo "6. Save the scene"
echo "7. Test the game!"
echo ""

echo "📚 Documentation available at:"
echo "   - $INSTALL_DIR/SPELL_TOOLBAR_INSTALLATION_GUIDE.md"
echo "   - $INSTALL_DIR/SPELL_TOOLBAR_CHANGELOG.md"
echo ""

echo "🧪 Testing Checklist:"
echo "   - Game starts without errors"
echo "   - Toolbar appears at bottom of screen"
echo "   - Keys 1-5 cast spells"
echo "   - Mouse clicks on slots work"
echo "   - Cooldown displays function"
echo ""

if [[ $INSTALL_ENHANCED =~ ^[Yy]$ ]]; then
    echo "🎮 Enhanced Input Features to Test:"
    echo "   - Mouse wheel changes spell selection"
    echo "   - ESC key toggles toolbar visibility"
    echo ""
fi

echo "✨ Installation complete!"
echo ""
echo "🆘 If you encounter issues:"
echo "   1. Check console for error messages"
echo "   2. Verify SpellComponent exists on player"
echo "   3. Ensure UI CanvasLayer exists in Main.tscn"
echo "   4. Check file paths match your project structure"
echo ""
echo "Happy spell casting! 🪄"