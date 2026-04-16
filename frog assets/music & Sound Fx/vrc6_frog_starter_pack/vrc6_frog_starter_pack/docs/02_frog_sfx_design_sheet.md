# 02 — Frog SFX Design Sheet

All timings below are based on your uploaded WAV references and translated into a practical **60 Hz frame mindset**.

## 1) RIBBIT — `SFX_FROG_RIBBIT`
Reference length: ~11.88 frames

### Role
The frog’s identity sound. This is where VRC6 matters most.

### Channel plan
- **VRC6 Saw**: main croak body
- **VRC6 Pulse 1**: throat / nasal top
- **VRC6 Pulse 2**: optional front tick or second pulse
- **2A03 Noise**: usually off or extremely tiny

### Shape
- frames 0–1: immediate attack
- frames 2–7: croak body
- frames 8–11: drop / release

### What to listen for
- “rrrib” on the front
- “-bit” or release taper on the back
- no laser-zap character
- no long sustain

## 2) JUMP — `SFX_FROG_JUMP`
Reference length: ~7.2 frames

### Role
Action start. Reads best with clarity and motion.

### Channel plan
- **VRC6 Pulse 2**: main hop click
- **VRC6 Pulse 1**: optional support
- **VRC6 Saw**: optional tiny body tail
- **2A03 Noise**: usually none

### Shape
- frame 0: attack
- frames 1–3: slight upward pitch feeling
- frames 4–6: fast decay

### What to listen for
- lively
- upward
- clean
- not explosive

## 3) LAND — `SFX_FROG_LAND`
Reference length: ~4.8 frames

### Role
Contact confirmation.

### Channel plan
- **2A03 Noise**: primary contact
- **VRC6 Saw or Triangle**: tiny body thunk
- **VRC6 Pulses**: usually off unless you need a tiny click

### Shape
- frame 0: contact burst
- frames 1–2: body thunk
- frames 3–4: silence

### What to listen for
- soft body slap
- not a snare
- not crunchy unless the surface demands it

## 4) WALK — `SFX_FROG_WALK`
Reference length: ~7.2 frames

### Role
Movement utility sound.

### Channel plan
- **2A03 Noise** or **VRC6 Pulse 2**
- optional tiny pitch alternation between left/right steps

### Shape
- short tick
- tiny settle
- then silence

### What to listen for
- readable at repetition
- not annoying over time
- doesn’t fight music

## 5) IDLE SHUFFLE — `SFX_FROG_IDLE`
Reference length: ~7.5 frames

### Role
Body wiggle / stationary life.

### Channel plan
- **2A03 Noise**: subtle rustle
- **VRC6 Pulse 2**: tiny motion tap
- avoid loud saw here

### Shape
- frame 0: small onset
- frames 1–3: micro movement
- frames 4–6: fade out

### What to listen for
- softer than walk
- a little organic
- can repeat occasionally without drawing too much attention

## Priority order for polish
1. Ribbit
2. Jump
3. Land
4. Walk
5. Idle

That order gives you the strongest return first.
