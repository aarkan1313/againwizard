# PHASE 6 FINAL IMPLEMENTATION PLAN
# Loot & Equipment System - Based on User Decisions

## 🎯 **IMPLEMENTATION OVERVIEW**

**Phase**: Loot & Equipment System  
**Duration**: 5 days  
**Architecture**: Component-based with specialized ItemData subclasses  
**Integration**: SpellComponent, GameEvents, save systems  

### **User Decision Summary:**
- **Inventory**: Fixed 8 equipment + 32 inventory slots (4x8 grid), upgradeable
- **Equipment Slots**: 7 base slots (helmet, robes, gloves, boots, ring, staff, accessory) → upgradeable to 10
- **UI**: Overlay system that pauses game, detailed stat display like character menu
- **Rarity**: 4 tiers (Rare, Epic, Legendary, Unique)
- **Loot**: Hybrid system with wave/biome/enemy rarity multipliers
- **Spell Modification**: Both stat bonuses + unique legendary effects, plus sets
- **Currency**: Multiple limited currencies, auto-calculated (no drops)

---

## 📋 **DAY-BY-DAY IMPLEMENTATION**

### **Day 1: Core Item System Architecture**

#### **Morning: Item Data Architecture (3-4 hours)**
```gdscript
# BaseItemData.gd - Foundation class
extends Resource
class_name BaseItemData

@export var item_name: String = ""
@export var description: String = ""
@export var item_level: int = 1
@export var rarity: ItemRarity.Type = ItemRarity.Type.RARE
@export var icon: Texture2D
@export var value: int = 10

enum ItemType { HELMET, ROBES, GLOVES, BOOTS, RING, STAFF, ACCESSORY }
@export var item_type: ItemType

# Base stats that all items can have
@export var stat_bonuses: Dictionary = {}  # "intelligence": 5, "spell_damage": 10
```

```gdscript
# WeaponData.gd - Staff/Wand specialization
extends BaseItemData
class_name WeaponData

@export var damage_bonus: float = 0.0
@export var cast_speed_bonus: float = 0.0
@export var spell_modifications: Array[SpellModification] = []

# SpellModification resource for unique effects
```

```gdscript
# ArmorData.gd - Defensive equipment
extends BaseItemData  
class_name ArmorData

@export var defense_bonus: float = 0.0
@export var mana_bonus: float = 0.0
@export var health_bonus: float = 0.0
```

#### **Afternoon: Item Generation System (3-4 hours)**
```gdscript
# ItemGenerator.gd - Autoload singleton
extends Node

var item_templates: Dictionary = {}  # Pre-defined base items
var affix_pools: Dictionary = {}     # Possible affixes by item type

func generate_item(item_level: int, rarity: ItemRarity.Type, force_type: BaseItemData.ItemType = -1) -> BaseItemData:
    # Core generation logic with user's hybrid rarity system
    
func calculate_drop_chance(wave_level: int, enemy_rarity: float, biome_multiplier: float) -> float:
    # Multiplier-based drop system as specified
```

### **Day 2: Inventory System & UI**

#### **Morning: Inventory Manager (3-4 hours)**
```gdscript
# InventoryManager.gd - Component for player
extends Node
class_name InventoryManager

# Equipment slots (7 base, upgradeable to 10)
var equipment_slots: Array[BaseItemData] = []
var equipment_slot_unlocks: Array[bool] = [true, true, true, true, true, true, true, false, false, false]

# Inventory grid (4x8 = 32 slots, upgradeable)
var inventory_grid: Array[BaseItemData] = []
var inventory_size: Vector2i = Vector2i(4, 8)  # Upgradeable system
```

#### **Afternoon: Inventory UI Implementation (3-4 hours)**
```gdscript
# InventoryUI.gd - Overlay interface
extends Control
class_name InventoryUI

# Overlay system that pauses game
# Detailed stat comparisons (+5 damage, -2 mana cost format)
# Similar styling to existing character stats menu (C key)
```

### **Day 3: Equipment Effects & Spell Integration**

#### **Morning: Stat System Integration (3-4 hours)**
```gdscript
# EquipmentStatsManager.gd - Component
extends Node
class_name EquipmentStatsManager

func calculate_total_bonuses() -> Dictionary:
    # Aggregate all equipment bonuses
    # Feed into existing SpellComponent calculations
    
func apply_spell_modifications(spell_component: SpellComponent):
    # Apply legendary/unique effects to spells
    # Handle set bonuses (commented system for future)
```

#### **Afternoon: SpellComponent Integration (3-4 hours)**
- Modify existing SpellComponent to accept equipment bonuses
- Equipment multipliers work alongside power adjustment system
- Legendary effects modify spell behavior
- Set bonus framework (commented for future implementation)

### **Day 4: Currency & Vendor Systems**

#### **Morning: Currency System (3-4 hours)**
```gdscript
# CurrencyManager.gd - Autoload singleton
extends Node

# Multiple currencies as specified: Gold, gems, elemental essences
# Auto-calculated system - no physical drops
# Track currency gain from kills, achievements, etc.

var currencies: Dictionary = {
    "gold": 0,
    "arcane_gems": 0, 
    "fire_essence": 0,
    "ice_essence": 0,
    "shadow_essence": 0
}
```

#### **Afternoon: Basic Vendor System (3-4 hours)**
```gdscript
# VendorManager.gd - Foundation for Phase 7 hub integration
extends Node
class_name VendorManager

# Simple buy/sell functionality
# Prepare for hub world integration in Phase 7
# Fixed vendor stocks with basic rotation
```

### **Day 5: Integration, Save System & Testing**

#### **Morning: Save System Integration (3-4 hours)**
```gdscript
# Extend existing save systems to handle inventory data
# Equipment in MetaSaveManager (persistent across runs)
# Consumables/temporary items in RunSaveManager
# Full inventory persistence as specified
```

#### **Afternoon: Testing & Polish (3-4 hours)**
- Integration testing with existing SpellComponent
- Performance testing with item generation
- UI responsiveness and visual polish
- GameEvents integration for item pickup/equip signals

---

## 🔧 **TECHNICAL SPECIFICATIONS**

### **Equipment Slot Configuration:**
```gdscript
enum EquipmentSlot {
    HELMET = 0,
    ROBES = 1, 
    GLOVES = 2,
    BOOTS = 3,
    RING_1 = 4,
    STAFF = 5,
    ACCESSORY_1 = 6,
    # Upgradeable slots
    RING_2 = 7,      # Unlockable
    AMULET = 8,      # Unlockable  
    ACCESSORY_2 = 9  # Unlockable
}
```

### **Rarity System:**
```gdscript
enum ItemRarity {
    RARE = 0,      # Yellow - 1-2 affixes
    EPIC = 1,      # Purple - 2-3 affixes  
    LEGENDARY = 2, # Orange - 3-4 affixes + unique effect
    UNIQUE = 3     # Red - Fixed stats + powerful unique effect
}
```

### **Drop Calculation:**
```gdscript
func calculate_final_drop_chance(base_chance: float, wave_level: int, enemy_rarity: float, biome_multiplier: float) -> float:
    var wave_bonus = wave_level * 0.01  # 1% per wave
    var total_multiplier = (1.0 + wave_bonus) * enemy_rarity * biome_multiplier
    return min(base_chance * total_multiplier, 0.95)  # Cap at 95%
```

---

## 🎮 **USER EXPERIENCE FEATURES**

### **Inventory Interface:**
- **Overlay System**: Pauses game when opened (Tab key)
- **Detailed Tooltips**: Show exact stat changes (+5 damage, -2 mana cost)
- **Equipment Comparison**: Side-by-side current vs new item
- **Auto-Sort**: Button for organizing inventory  
- **Visual Rarity**: Color-coded borders and glow effects

### **Equipment Effects:**
- **Stat Bonuses**: Direct modifiers to intelligence, spell damage, etc.
- **Legendary Effects**: "Fireball chains to 2 targets", "Heal creates damage shield"
- **Set Bonuses**: Framework implemented but commented for future use
- **Power Integration**: Works with existing spell power adjustment system

### **Currency System:**
- **Auto-Calculation**: No physical currency drops, calculated and awarded
- **Multiple Types**: Gold + elemental essences for different upgrade paths
- **Limited Scope**: Start with basic system, expand in Phase 7

---

## 🔗 **INTEGRATION POINTS**

### **SpellComponent Integration:**
```gdscript
# Modified SpellComponent methods
func calculate_enhanced_damage(base_damage: float) -> float:
    var equipment_bonus = equipment_manager.get_spell_damage_bonus()
    var stat_bonus = player_stat_sheet.get_stat_value("spell_damage_multiplier") 
    # Equipment multipliers work alongside power adjustment
    return base_damage * equipment_bonus * stat_bonus * power_modifier.get_damage_multiplier()
```

### **GameEvents Integration:**
```gdscript
# New signals in GameEvents.gd
signal item_picked_up(item_name: String, rarity: ItemRarity.Type)
signal item_equipped(item: BaseItemData, slot: EquipmentSlot)
signal currency_gained(currency_type: String, amount: int)
```

### **Save System Integration:**
```gdscript
# MetaSaveManager addition (persistent equipment)
var player_equipment: Dictionary = {}
var unlocked_equipment_slots: Array[bool] = []

# RunSaveManager addition (temporary inventory)
var current_inventory: Array[Dictionary] = []
```

---

## 🧪 **TESTING REQUIREMENTS**

### **Core Functionality Tests:**
1. **Item Generation**: Verify rarity distribution matches expected rates
2. **Inventory Management**: Test pickup, equip, unequip, drop functionality
3. **Stat Integration**: Confirm equipment bonuses affect spell calculations
4. **UI Responsiveness**: Ensure inventory overlay performs well
5. **Save/Load**: Verify equipment persistence across sessions

### **Integration Tests:**
1. **SpellComponent**: Equipment bonuses work with power adjustment
2. **Performance**: No FPS drops with large item databases
3. **GameEvents**: All item-related events fire correctly
4. **Balance**: Equipment provides meaningful but not overpowered bonuses

### **Edge Case Tests:**
1. **Full Inventory**: Proper handling when inventory is full
2. **Invalid Items**: Graceful handling of corrupted item data
3. **Save Corruption**: Fallback systems for damaged save files
4. **Extreme Values**: Very high item levels and stats

---

## 🎯 **SUCCESS CRITERIA**

### **Phase 6 Complete When:**
- [ ] Player can find and equip 7 different equipment types
- [ ] Equipment provides visible stat bonuses affecting spell performance
- [ ] Inventory system handles 32+ items with upgrade potential
- [ ] Rarity system generates items with appropriate affix counts
- [ ] Currency system tracks multiple resource types
- [ ] All systems integrate with existing SpellComponent without regression
- [ ] Save system preserves equipment and inventory across sessions
- [ ] UI provides clear stat comparisons and equipment management

### **Quality Gates:**
- [ ] Maintains 60 FPS with full inventory and equipment
- [ ] No regression in existing spell casting or movement systems  
- [ ] Equipment bonuses provide 10-30% power increase at appropriate levels
- [ ] Item generation creates meaningful choices between equipment pieces

---

## 🔄 **Phase 7 Preparation**

### **Hub World Integration Points:**
- Vendor system architecture ready for hub merchants
- Currency system prepared for hub-based spending
- Equipment upgrade systems ready for hub services
- Inventory UI compatible with hub interface design

### **Architecture Decisions:**
- Equipment data structure supports hub-based modifications
- Save system separation supports hub vs run-based persistence
- Event system ready for hub-based equipment services

---

*This implementation plan provides a complete roadmap for Phase 6 based on your specific answers to the planning questions. The modular architecture ensures clean integration with existing systems while preparing for Phase 7 hub world features.*