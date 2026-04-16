# Hello_Frog

NES scene demo and character pipeline for the Hello Frog project.

## Repository Hardening

- Build outputs such as `*.o` and `*.nes` are ignored.
- Line endings are normalized through `.gitattributes`.
- The generator resolves paths from the repository root instead of the current working directory.
- The linker configuration now lives in-repo as `nes.cfg` so a clean checkout can rebuild the ROM.

## Build

Prerequisites:

- Python 3 with Pillow installed (`python -m pip install pillow`)
- cc65 on `PATH` so `ca65` and `ld65` are available

From the repository root:

```powershell
.\build.ps1
```

The script regenerates `pond-font.chr` and `frog_scene.chr`, assembles `hello-pond.asm`, builds the bundled VRC6 audio objects from `frog assets/music & Sound Fx/hello_frog_vrc6_audio_pack_v1/`, and links `hello-pond.nes`.

## Project Layout

- `hello-pond.asm` - main NES program.
- `nes.cfg` - cc65/ld65 linker layout for the NES ROM.
- `build.ps1` - root rebuild entry point for assets and ROM output.
- `gen-chr.py` - regenerates `pond-font.chr` and `frog_scene.chr` using a fixed bitmap font table plus the frog sprite assets.
- `extract_gif_frames.py` - exports ordered PNG frames and a manifest from the frog GIF.
- `frog_animation_manifest.json` - generated frame-to-CHR mapping for the full hat-based toad selector.
- `frog_scene.chr` - composed CHR output that overlays the frog-folder scene source with the generated font/background/frog animation tiles and is what the ROM now includes.
- Boot flow: title screen -> hat/tint select screen -> pond test scene, with VRC6 music/SFX wired per state.
- `frog assets/` - source sprite sheets, landscape tiles, CHR, and VRC6 audio assets used by the generator and ROM.
