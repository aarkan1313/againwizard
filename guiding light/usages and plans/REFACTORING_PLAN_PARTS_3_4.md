# Refactoring Plan: Guiding Light Parts 3 & 4
## Combat Systems & Component Architecture

This document provides a comprehensive refactoring plan for the code identified in Guiding Light Parts 3 and 4, organized by importance, need, and impact.

---

## 🔥 CRITICAL PRIORITY (Immediate Action Required)

### 1. Extract Large Method Responsibilities
**Files**: `Enemy.gd`, `SpellComponent.gd`, `SpellProjectile.gd`
**Need**: High - Maintainability Crisis
**Impact**: High - Affects all combat systems

#### Issues:
- `SpellComponent.cast_spell()`: 111 lines handling too many responsibilities
- `Enemy._ready()`: 79 lines with mixed initialization concerns  
- `SpellProjectile._create_spell_impact_texture()`: 60+ lines switch statement

#### Refactoring Actions:
```gdscript
# Break down SpellComponent.cast_spell()
func cast_spell(spell_index: int) -> bool:
    var validation_result = validate_spell_cast(spell_index)
    if not validation_result.is_valid:
        return false
    
    var spell_instance = create_spell_instance(spell_index, validation_result)
    return execute_spell_cast(spell_instance)

func validate_spell_cast(spell_index: int) -> CastValidationResult
func create_spell_instance(spell_index: int, validation: CastValidationResult) -> SpellInstance
func execute_spell_cast(spell_instance: SpellInstance) -> bool
```

**Estimated Effort**: 2-3 days
**Risk**: Medium (requires careful testing of spell system)

### 2. Eliminate Code Duplication in Movement Systems
**Files**: `Enemy.gd`, `MovementComponent.gd`
**Need**: High - DRY Principle Violation
**Impact**: High - Performance and maintainability

#### Issues:
- Movement calculation duplicated between ranged kiting and melee movement
- Distance calculation patterns repeated throughout combat system

#### Refactoring Actions:
```gdscript
class_name MovementStrategy
extends RefCounted

func execute_movement(enemy: Enemy, target: Node, speed: float) -> Vector2:
    pass

class_name MeleeMovementStrategy extends MovementStrategy
class_name RangedKitingMovementStrategy extends MovementStrategy
```

**Estimated Effort**: 1-2 days
**Risk**: Low (self-contained system)

---

## ⚡ HIGH PRIORITY (Next Sprint)

### 3. Implement Spell Effect Factory Pattern
**Files**: `SpellProjectile.gd`, `SpellComponent.gd`
**Need**: High - Performance and Extensibility
**Impact**: High - Affects all spell casting

#### Issues:
- Procedural texture creation on every spell cast instead of caching
- Hardcoded spell effect creation throughout system
- No reusable texture generation system

#### Refactoring Actions:
```gdscript
class_name SpellEffectFactory
extends RefCounted

static var _texture_cache: Dictionary = {}

func create_projectile_texture(spell_name: String) -> Texture2D:
    if spell_name in _texture_cache:
        return _texture_cache[spell_name]
    
    var texture = generate_spell_texture(spell_name)
    _texture_cache[spell_name] = texture
    return texture

func create_impact_effect(spell_name: String, position: Vector2) -> Node2D
```

**Estimated Effort**: 2-3 days
**Risk**: Medium (affects visual consistency)

### 4. Create Ability Selection Strategy Pattern
**Files**: `AbilityManager.gd`, `WizardAbilityManager.gd`
**Need**: High - AI Decision Making Improvements
**Impact**: Medium-High - Enemy AI behavior

#### Issues:
- Complex scoring logic hardcoded in `select_best_ability()`
- No pluggable AI strategies for different enemy behaviors
- Duplicate ability validation patterns

#### Refactoring Actions:
```gdscript
class_name AbilitySelectionStrategy
extends RefCounted

func select_ability(context: AbilityContext, available: Array[AbilityData]) -> AbilityData:
    pass

class_name AggressiveSelectionStrategy extends AbilitySelectionStrategy
class_name DefensiveSelectionStrategy extends AbilitySelectionStrategy
class_name BalancedSelectionStrategy extends AbilitySelectionStrategy
```

**Estimated Effort**: 3-4 days
**Risk**: Medium (requires AI behavior testing)

---

## 🛠️ MEDIUM PRIORITY (Future Sprint)

### 5. Extract Enemy Type System
**Files**: `Enemy.gd`, `EnemySpawner.gd`
**Need**: Medium - Type Safety and Extensibility
**Impact**: Medium - Enemy system maintainability

#### Issues:
- Hardcoded enemy type strings throughout system
- No type safety for enemy classification
- Switch statements based on string comparison

#### Refactoring Actions:
```gdscript
enum EnemyType {
    GOBLIN,
    ORC, 
    SKELETON,
    WIZARD,
    GOLEM,
    ELEMENTAL
}

class_name EnemyTypeManager
extends RefCounted

static func get_enemy_data(type: EnemyType) -> EnemyData
static func get_enemy_scene(type: EnemyType) -> PackedScene
```

**Estimated Effort**: 1-2 days
**Risk**: Low (mostly structural changes)

### 6. Implement Component Communication System
**Files**: All component files in `/scripts/components/`
**Need**: Medium - Architecture Improvement
**Impact**: Medium - Component system scalability

#### Issues:
- Direct component references creating tight coupling
- No standardized inter-component communication
- Component dependency order issues

#### Refactoring Actions:
```gdscript
class_name ComponentEventBus
extends RefCounted

signal component_event(event_type: String, data: Dictionary)

func broadcast_event(event_type: String, data: Dictionary = {})
func subscribe_to_event(event_type: String, callback: Callable)
```

**Estimated Effort**: 3-4 days
**Risk**: Medium-High (affects all components)

### 7. Create Enemy Factory Pattern
**Files**: `EnemySpawner.gd`
**Need**: Medium - Performance and Object Management
**Impact**: Medium - Spawning system efficiency

#### Issues:
- Scene loading on every spawn instead of preloading
- No enemy object pooling
- Complex enemy creation logic scattered

#### Refactoring Actions:
```gdscript
class_name EnemyFactory
extends RefCounted

static var _preloaded_scenes: Dictionary = {}
static var _enemy_pools: Dictionary = {}

func create_enemy(type: EnemyType, position: Vector2, wave_data: Dictionary) -> Enemy
func return_enemy_to_pool(enemy: Enemy)
func preload_enemy_scenes(types: Array[EnemyType])
```

**Estimated Effort**: 2-3 days
**Risk**: Medium (requires object pooling implementation)

---

## 🔧 LOW PRIORITY (Technical Debt)

### 8. Standardize Distance Calculations
**Files**: `Enemy.gd`, `AbilityManager.gd`, multiple combat files
**Need**: Low - Performance Consistency
**Impact**: Low-Medium - Combat precision

#### Issues:
- Mixed usage of `distance_to()` and `distance_squared_to()`
- Inconsistent distance optimization patterns
- Duplicate distance utility functions

#### Refactoring Actions:
```gdscript
class_name DistanceUtils
extends RefCounted

static func is_in_range_squared(from: Vector2, to: Vector2, range_sq: float) -> bool:
    return from.distance_squared_to(to) <= range_sq

static func get_closest_target(from: Vector2, targets: Array[Vector2]) -> Vector2
```

**Estimated Effort**: 1 day
**Risk**: Low (self-contained utility)

### 9. Extract Wave Configuration System
**Files**: `WaveManager.gd`
**Need**: Low - Data-Driven Design
**Impact**: Low - Game balancing flexibility

#### Issues:
- Hardcoded wave progression values
- No external configuration for wave parameters
- Difficulty scaling logic embedded in manager

#### Refactoring Actions:
```gdscript
class_name WaveConfiguration
extends Resource

@export var kill_thresholds: Array[int]
@export var health_scaling: float = 1.2
@export var damage_scaling: float = 1.15
@export var speed_scaling: float = 1.08
@export var enemy_unlocks: Dictionary

class_name DifficultyScaler
extends RefCounted

func calculate_multipliers(wave: int, config: WaveConfiguration) -> Dictionary
```

**Estimated Effort**: 1-2 days
**Risk**: Low (data structure changes)

### 10. Implement Global Error Handling
**Files**: All analyzed files
**Need**: Low - Error Management
**Impact**: Low - Debugging and monitoring

#### Issues:
- Scattered `push_error()` calls throughout codebase
- No centralized error logging or handling
- Inconsistent error reporting patterns

#### Refactoring Actions:
```gdscript
class_name ErrorHandler
extends RefCounted

enum ErrorLevel {
    WARNING,
    ERROR,
    CRITICAL
}

static func log_error(level: ErrorLevel, message: String, context: Dictionary = {})
static func handle_component_error(component: Node, error: String)
```

**Estimated Effort**: 1 day
**Risk**: Very Low (additive changes)

---

## 📋 IMPLEMENTATION ROADMAP

### Phase 1: Critical Foundation (Week 1-2)
1. Extract Large Method Responsibilities
2. Eliminate Movement System Duplication
3. Begin Spell Effect Factory Implementation

### Phase 2: Performance & Architecture (Week 3-4)
1. Complete Spell Effect Factory
2. Implement Ability Selection Strategy
3. Create Enemy Type System

### Phase 3: System Integration (Week 5-6)
1. Component Communication System
2. Enemy Factory Pattern
3. Distance Calculation Standardization

### Phase 4: Polish & Configuration (Week 7-8)
1. Wave Configuration System
2. Global Error Handling
3. Testing and validation of all refactored systems

---

## 🎯 SUCCESS METRICS

### Code Quality Metrics:
- **Cyclomatic Complexity**: Reduce average from ~15 to <8 per method
- **Method Length**: No methods >30 lines (currently many >50 lines)
- **Code Duplication**: Eliminate identified duplicate patterns
- **Test Coverage**: Maintain >80% coverage during refactoring

### Performance Metrics:
- **Spell Casting**: 50% reduction in texture generation time
- **Enemy Spawning**: 30% reduction in instantiation time
- **Movement Calculations**: 25% reduction in distance calculation overhead

### Maintainability Metrics:
- **Component Coupling**: Reduce direct dependencies by 60%
- **Configuration Flexibility**: 100% externalization of hardcoded values
- **Error Handling**: Centralized logging for 100% of identified error points

---

## ⚠️ RISKS AND MITIGATION

### High Risk Items:
1. **Component Communication Refactor**: Could break existing functionality
   - **Mitigation**: Implement incrementally with feature flags
   - **Testing**: Comprehensive integration tests before deployment

2. **Spell System Changes**: Visual consistency concerns
   - **Mitigation**: Maintain visual regression test suite
   - **Testing**: Side-by-side comparison of old vs new effects

### Medium Risk Items:
1. **AI Behavior Changes**: Could affect game balance
   - **Mitigation**: A/B testing with old and new AI systems
   - **Testing**: Extensive playtesting with different difficulty levels

### Low Risk Items:
1. **Utility Function Changes**: Self-contained improvements
   - **Mitigation**: Unit tests for all utility functions
   - **Testing**: Performance benchmarks to verify improvements

---

## 📊 RESOURCE ALLOCATION

### Developer Hours Estimate:
- **Critical Priority**: 40-50 hours
- **High Priority**: 60-70 hours  
- **Medium Priority**: 45-55 hours
- **Low Priority**: 20-25 hours

**Total Estimated Effort**: 165-200 hours (4-5 weeks with 1 developer)

### Required Skills:
- Advanced Godot/GDScript knowledge
- Design pattern implementation experience
- Performance optimization expertise
- Game systems architecture understanding

### Dependencies:
- Access to existing test suite
- Ability to run performance benchmarks
- Coordination with art team for visual effect validation
- Game design team input for AI behavior changes

---

*This refactoring plan provides a systematic approach to improving the codebase identified in Guiding Light Parts 3 & 4, with clear priorities, effort estimates, and risk mitigation strategies.*