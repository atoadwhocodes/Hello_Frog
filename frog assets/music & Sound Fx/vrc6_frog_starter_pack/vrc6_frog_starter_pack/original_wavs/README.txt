Frog NES SFX Pack

Files
- frog_walk.wav               : two-step walking tick, good for alternating footstep playback
- frog_idle_shuffle.wav       : stationary wiggle / idle body movement
- frog_jump.wav               : upward hop / leap
- frog_land.wav               : soft landing / body slap
- frog_ribbit_button.wav      : croak / ribbit for button press or interaction

Format
- 44.1 kHz mono WAV
- Designed as NES-style reference assets using pulse / triangle / noise style synthesis

Suggested engine mapping
- WALK: trigger per step or every 6-10 frames during movement
- IDLE SHUFFLE: low frequency use while stationary, every 24-40 frames or on direction tap without travel
- JUMP: play on jump start
- LAND: play on ground contact
- RIBBIT: play on face/button action, possibly rate-limited to prevent spam

Notes
These are reference-ready assets. If you want, I can also convert this exact set into:
- FamiStudio instrument/effect guidance
- Pently/MML note + drum sequences
- ca65-friendly event tables / sound IDs
