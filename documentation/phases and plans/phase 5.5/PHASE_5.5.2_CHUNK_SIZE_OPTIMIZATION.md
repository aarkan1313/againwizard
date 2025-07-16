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
# Change from 11x11 grid (121 chunks) to 9x9 grid (81 chunks)
const ACTIVE_RADIUS = 5  # Current: 11x11 grid
# To:
const ACTIVE_RADIUS = 4  # New: 9x9 grid = 81 chunks

# Update preload count for 8x8 initial grid
const PRELOAD_COUNT = 81  # Current: 9x9 grid
# To:
const PRELOAD_COUNT = 64  # New: 8x8 grid = 64 chunks
```

### **Step 3: Update Grid Calculations**

**File**: `scripts/world/UnifiedWorldManager.gd`

**Function**: `_get_chunks_around_position()`

**Update grid size calculations:**
```gdscript
# Find all functions that use ACTIVE_RADIUS
# Verify they work correctly with the new 9x9 grid
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
- **Reduced chunk management**: 81 chunks vs 121 chunks (33% reduction)
- **Better visual consistency**: Larger visual areas per chunk
- **Improved coverage**: 67% more area covered with fewer chunks

### **Potential Issues:**
- **Higher generation time**: Each chunk is 16x larger (256²→1024²)
- **Memory usage**: 16x more memory per chunk
- **Initial loading**: Longer time to generate initial world

---

## Testing Checklist

- [ ] Game starts without crashes
- [ ] Initial 8x8 grid loads properly (64 chunks)
- [ ] Movement triggers correct chunk loading/unloading
- [ ] Performance remains stable at 60 FPS
- [ ] Memory usage stays within reasonable limits
- [ ] Debug UI shows correct chunk counts (81 max active)
- [ ] All biome types still visible with larger chunks

---

## Rollback Plan

If performance issues occur:
1. Revert `CHUNK_SIZE` back to 512
2. Revert `ACTIVE_RADIUS` back to 5
3. Revert `PRELOAD_COUNT` back to 81
4. Consider intermediate size (768px) as compromise

---

## Code Changes

### **UnifiedWorldManager.gd Changes:**
```gdscript
# Line ~10: Update chunk size
const CHUNK_SIZE = 1024  # Was 512

# Line ~11: Update grid size  
const ACTIVE_RADIUS = 4  # Was 5 (9x9 instead of 11x11)

# Line ~12: Update preload count
const PRELOAD_COUNT = 64  # Was 81 (8x8 instead of 9x9)
```

### **SimpleChunkRenderer.gd Changes:**
```gdscript
# Line ~10: Update chunk size to match
const CHUNK_SIZE = 1024  # Was 512
```

---

## Performance Targets

### **Acceptable Performance:**
- **Chunk generation**: <15ms per chunk (was <5ms for 512px)
- **Memory usage**: <400MB total (was <200MB)
- **FPS**: Stable 60 FPS with 81 active chunks
- **Loading time**: <5 seconds for initial 8x8 grid

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