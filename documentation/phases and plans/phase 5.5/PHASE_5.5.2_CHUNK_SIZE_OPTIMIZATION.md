# Phase 5.5.2: Chunk Size Optimization

## Overview
**Goal**: Increase chunk size from 256px to 1024px and adjust grid to 6x6 for better performance and fewer boundary crossings.

**Timeline**: 1 day  
**Dependencies**: Phase 5.5.1 (biome fixes) must be complete

---

## Implementation Steps

### **Step 1: Update Chunk Size Constants**

**Files to modify:**
- `scripts/world/UnifiedWorldManager.gd`
- `scripts/world/SimpleChunkRenderer.gd`

**Changes:**
```gdscript
# In both files, change:
const CHUNK_SIZE = 256
# To:
const CHUNK_SIZE = 1024
```

### **Step 2: Adjust Grid Configuration**

**File**: `scripts/world/UnifiedWorldManager.gd`

**Changes:**
```gdscript
# Change from 7x7 grid (49 chunks) to 6x6 grid (36 chunks)
const ACTIVE_RADIUS = 3  # Current: 7x7 grid
# To:
const ACTIVE_RADIUS = 2  # New: 6x6 grid = 36 chunks

# Update preload count for 4x4 initial grid
const PRELOAD_COUNT = 25  # Current: 5x5 grid
# To:
const PRELOAD_COUNT = 16  # New: 4x4 grid = 16 chunks
```

### **Step 3: Update Grid Calculations**

**File**: `scripts/world/UnifiedWorldManager.gd`

**Function**: `_get_chunks_around_position()`

**Update grid size calculations:**
```gdscript
# Find all functions that use ACTIVE_RADIUS
# Verify they work correctly with the new 6x6 grid
# Test edge cases for chunk loading/unloading
```

### **Step 4: Performance Testing**

**Test scenarios:**
1. **Chunk Generation Time**: Monitor generation times with 1024px chunks
2. **Memory Usage**: Check memory consumption with larger chunks
3. **Movement Performance**: Test smooth movement between chunks
4. **Initial Load Time**: Verify 4x4 initial grid loads quickly

---

## Expected Results

### **Performance Improvements:**
- **Fewer chunk crossings**: 4x less frequent boundary crossings
- **Reduced chunk management**: 36 chunks vs 49 chunks (26% reduction)
- **Better visual consistency**: Larger visual areas per chunk

### **Potential Issues:**
- **Higher generation time**: Each chunk is 16x larger (256²→1024²)
- **Memory usage**: 16x more memory per chunk
- **Initial loading**: Longer time to generate initial world

---

## Testing Checklist

- [ ] Game starts without crashes
- [ ] Initial 4x4 grid loads properly
- [ ] Movement triggers correct chunk loading/unloading
- [ ] Performance remains stable at 60 FPS
- [ ] Memory usage stays within reasonable limits
- [ ] Debug UI shows correct chunk counts (36 max)
- [ ] All biome types still visible with larger chunks

---

## Rollback Plan

If performance issues occur:
1. Revert `CHUNK_SIZE` back to 256
2. Revert `ACTIVE_RADIUS` back to 3
3. Revert `PRELOAD_COUNT` back to 25
4. Consider intermediate size (512px) as compromise

---

## Code Changes

### **UnifiedWorldManager.gd Changes:**
```gdscript
# Line ~10: Update chunk size
const CHUNK_SIZE = 1024  # Was 256

# Line ~11: Update grid size
const ACTIVE_RADIUS = 2  # Was 3 (6x6 instead of 7x7)

# Line ~12: Update preload count
const PRELOAD_COUNT = 16  # Was 25 (4x4 instead of 5x5)
```

### **SimpleChunkRenderer.gd Changes:**
```gdscript
# Line ~10: Update chunk size to match
const CHUNK_SIZE = 1024  # Was 256
```

---

## Performance Targets

### **Acceptable Performance:**
- **Chunk generation**: <10ms per chunk (was <2ms for 256px)
- **Memory usage**: <300MB total (was <100MB)
- **FPS**: Stable 60 FPS with 36 active chunks
- **Loading time**: <2 seconds for initial 4x4 grid

### **If Performance Issues:**
- Consider 512px chunks as intermediate step
- Implement chunk generation queue
- Add LOD system for distant chunks
- Optimize terrain generation algorithms

---

## Notes

- This change affects chunk coordinate calculations
- Player movement detection may need adjustment
- POI placement will have more space within chunks
- Biome transitions will be less frequent but more noticeable
- Debug UI will show different chunk counts

**Remember**: Test thoroughly before proceeding to Phase 5.5.3!