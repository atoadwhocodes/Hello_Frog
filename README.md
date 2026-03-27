# Hello_Frog

NES scene demo and character pipeline for the Hello Frog project.

## Repository Hardening

- Build outputs such as `*.o` and `*.nes` are ignored.
- Line endings are normalized through `.gitattributes`.
- The generator resolves paths from the repository root instead of the current working directory.

## Project Layout

- `hello-pond.asm` - main NES program.
- `gen-chr.py` - regenerates `pond-font.chr` and `frog_scene.chr`.
- `Fonts/` and `frog assets/` - source assets used by the generator and ROM.
