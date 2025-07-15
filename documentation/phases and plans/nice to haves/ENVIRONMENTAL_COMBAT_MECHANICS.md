# ENVIRONMENTAL COMBAT MECHANICS

## 🎯 **OVERVIEW** 
Add environmental combat through destructible terrain, environmental hazards, and spell-environment interactions (3 days)

## 🚨 **CURRENT GAP**
**We have**: Colored background rectangles  
**We need**: Environmental combat that affects gameplay

---

## 📋 **PHASE 5B REQUIREMENTS**

### **Day 1: Destructible Terrain**

#### **Morning: Destructible Object System**
- **Create DestructibleObject.gd** component system
- **Spell projectile integration** (destroy terrain with spells)
- **Visual destruction effects** (debris, particles, screen shake)
- **Loot drops from destroyed terrain**

#### **Afternoon: Terrain Modification**
- **Real-time terrain modification** from spell impacts
- **Pathfinding updates** when terrain changes
- **Persistent terrain changes** within chunk system
- **Performance optimization** for terrain modifications

### **Day 2: Environmental Hazards**

#### **Morning: Hazard System**
- **Environmental hazard spawning** per biome type
- **Hazard damage and status effects** (burning, poisoned, slowed)
- **Visual warning systems** before hazard activation
- **Hazard interaction with spells** (extinguish fire with ice)

#### **Afternoon: Biome-Specific Hazards**
- **Fire Caves**: Lava pools, fire geysers, heat damage
- **Ice Fields**: Ice spikes, freezing zones, slippery surfaces
- **Poison Swamps**: Poison gas clouds, acid puddles
- **Crystal Caverns**: Crystal resonance, lightning fields
- **Volcanic Chamber**: Eruption patterns, lava flows

### **Day 3: Spell-Environment Interactions**

#### **Morning: Elemental Reactions**
- **Fire + Ice = Steam explosion** (damage + vision obstruction)
- **Lightning + Metal = Chain lightning** (enhanced damage)
- **Poison + Fire = Toxic explosion** (area denial)
- **Ice + Water = Freeze expansion** (terrain blocking)

#### **Afternoon: Environmental Spell Enhancement**
- **New environmental spell effects** (ice spells create ice walls)
- **Enhanced spell-terrain interactions** (spells create/destroy terrain features)
- **Environmental spell synergies** (combining elements creates new effects)
- **Spell-triggered environmental events** (major spells trigger environmental changes)

---

## ✅ **SUCCESS CRITERIA**

### **Core Environmental Combat**:
- [ ] **Destructible Terrain**: Spells can destroy terrain objects for tactical advantage
- [ ] **Environmental Hazards**: Each biome has 2-3 unique hazard types that affect combat
- [ ] **Interactive Environment**: Players can manipulate environment for strategic advantage

### **Spell-Environment Integration**:
- [ ] **Elemental Reactions**: At least 3 spell-environment combinations create unique effects
- [ ] **Tactical Terrain**: Destructible terrain changes combat tactics
- [ ] **Environmental Creation**: Spells can create new terrain features and obstacles
- [ ] **Dynamic Battlefields**: Environment changes during combat based on spell usage

### **Performance & Polish**:
- [ ] **60 FPS Maintained**: All environmental effects maintain performance
- [ ] **Visual Feedback**: Clear indicators for all environmental effects
- [ ] **Smooth Integration**: Environmental systems work with existing wave mechanics
- [ ] **Balanced Gameplay**: Environmental effects enhance rather than frustrate gameplay

---

## 🔗 **INTEGRATION POINTS**

### **Files to Modify**:
- `scripts/spells/SpellProjectile.gd` → Add environmental interaction logic
- `scripts/GameManager.gd` → Coordinate environmental systems
- `scripts/world/ChunkGenerator.gd` → Add destructible objects to chunk generation

### **New Files to Create**:
- `scripts/world/EnvironmentalEffectManager.gd` → Central environmental effect coordination
- `scripts/world/DestructibleTerrain.gd` → Destructible terrain object system
- `scripts/world/EnvironmentalHazard.gd` → Environmental hazard base class
- `scripts/world/SpellEnvironmentInteraction.gd` → Spell-environment reaction system

### **Dependencies**:
- **Existing infinite world system** (Phase 5A complete) ✅
- **Existing spell system** (Phases 1-4) ✅  
- **Existing enemy system** (Phases 1-4) ✅
- **Save/load system** for persistent terrain changes ✅

---

## 📈 **ESTIMATED IMPACT**

**Before Phase 5B**: Infinite world with visual variety but no environmental interaction

**After Phase 5B**: Interactive environment with destructible terrain, environmental hazards per biome, and spell-environment interactions for emergent gameplay

**Player Experience**: "I can destroy rocks with fireballs to create new paths, ice spells create walls for cover, and environmental hazards force tactical positioning - the environment is part of combat strategy!"

---

**Status**: Ready to begin Day 1 - Destructible Terrain Implementation