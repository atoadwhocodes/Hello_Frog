# VRC6 Frog Starter Pack

This pack takes your uploaded `frog_nes_sfx_pack.zip` and turns it into a **VRC6-oriented starter kit** for learning and implementation.

## Included
- `original_wavs/` — your uploaded reference WAVs
- `docs/01_vrc6_project_setup.md` — clean FamiStudio/VRC6 starting setup
- `docs/02_frog_sfx_design_sheet.md` — per-sound channel plan and frame logic
- `docs/03_engine_mapping.md` — practical engine-side trigger notes
- `data/frog_sfx_metadata.csv` / `.json` — timing and file metadata
- `famistudio/frog_vrc6_instrument_presets.txt` — starter instrument recipes
- `famistudio/frog_vrc6_sequence_reference.csv` — frame-by-frame reference
- `code/ca65_sfx_ids.inc` — ready-to-drop symbol names
- `code/frog_sfx_notes.asm` — integration notes / pseudocode

## Recommended path
1. Open the WAVs and listen in order.
2. Build **Ribbit** first in FamiStudio using the design sheet.
3. Build **Jump**, then **Land**.
4. Keep **Walk** and **Idle Shuffle** simpler and lower priority.
5. Only move to engine wiring after the five SFX feel right in emulator.

## Suggested channel philosophy
- **VRC6 Saw**: body / chest / croak mass
- **VRC6 Pulse 1**: nasal/throat edge
- **VRC6 Pulse 2**: attack accent / click / secondary motion
- **2A03 Noise**: grit / contact / shuffle
- **2A03 Triangle**: optional low thunk if you need more weight

## Important restraint
Do not force every sound to be a huge expansion-audio event.
Use VRC6 mostly for the **signature frog identity**:
- Ribbit: yes
- Jump: probably
- Land: a touch
- Walk / idle: mostly utility

That balance usually sounds stronger in an actual game than making every sound “fancy.”

## Naming
The symbol names in this pack use:
- `SFX_FROG_WALK`
- `SFX_FROG_IDLE`
- `SFX_FROG_JUMP`
- `SFX_FROG_LAND`
- `SFX_FROG_RIBBIT`

You can rename them later, but these are safe clean starters.
