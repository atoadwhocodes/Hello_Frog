# 03 — Engine Mapping

## Sound IDs
Use these IDs as a clean starter set.

```asm
SFX_FROG_WALK   = $20
SFX_FROG_IDLE   = $21
SFX_FROG_JUMP   = $22
SFX_FROG_LAND   = $23
SFX_FROG_RIBBIT = $24
```

## Trigger guidance

### WALK
- Trigger on footstep cadence, not every frame.
- Good starting rate: every **6–10 frames** while moving.

### IDLE
- Trigger rarely.
- Good starting rate: every **24–40 frames** while stationary, or on a direction tap without travel.

### JUMP
- Trigger on jump start.
- Do not retrigger in air.

### LAND
- Trigger on ground contact only.
- Give it higher priority than walk/idle for that frame.

### RIBBIT
- Trigger on button/face action.
- Add a short cooldown so the player cannot spam it into mush.
- Good starting cooldown: **10–16 frames**.

## Priority suggestion
From highest to lowest:
1. RIBBIT
2. LAND
3. JUMP
4. WALK
5. IDLE

## Polyphony discipline
When music is active:
- allow ribbit to take the best channels
- let walk/idle degrade gracefully
- keep land short so it can coexist

## Good first engine rule
If a higher-priority frog sound starts:
- cancel or ignore idle
- optionally suppress walk for 1 frame

That alone cleans up a lot of in-game clutter.
