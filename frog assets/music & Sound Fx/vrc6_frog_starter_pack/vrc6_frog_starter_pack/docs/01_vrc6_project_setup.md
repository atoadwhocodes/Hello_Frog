# 01 — VRC6 Project Setup

## FamiStudio starting setup
Use this as the clean first build environment.

### Project
- Expansion audio: **VRC6**
- Region: **NTSC**
- Goal: **SFX-first test project**
- Make a project with one song only if you want a scratch timeline, but keep the sound effects isolated.

### Mixer mindset
- Keep the **VRC6 Saw** under control.
- Start with the saw at a moderate level and raise it only if the ribbit feels too thin.
- If the saw dominates, the sound will stop reading as “frog” and start reading as “synth effect.”

### Sound effect design rules
- Favor **short envelopes**
- Favor **clear attacks**
- Use **pitch shape** more than long sustain
- Do not stack three loud channels unless the sound is meant to be special

## Learning order
1. Ribbit
2. Jump
3. Land
4. Walk
5. Idle Shuffle

That order teaches:
- layering
- pitch motion
- short transient design
- repetition control
- subtlety

## Initial instrument pool
Create only these first:

### VRC6 Saw — `CROAK_BODY`
Use for ribbit body.
- strong start
- fast decay
- optional mild downward pitch curve

### VRC6 Pulse — `THROAT_EDGE`
Use for ribbit attack / nasal tone.
- medium volume
- short decay
- 25% or 50% duty trial

### VRC6 Pulse — `HOP_CLICK`
Use for jump click / motion accent.
- bright
- very short
- tiny pitch rise or static blip

### 2A03 Noise — `LAND_SOFT`
Use for landing / shuffle grit.
- low to mid volume
- very short
- avoid harsh burst unless the frog is heavy

### 2A03 Triangle — `BODY_THUNK`
Optional.
- only if land feels too weightless

## First checkpoint
After you build the ribbit:
- mute channels one by one
- confirm the **saw** gives body
- confirm the **pulse** gives identity
- confirm the sound still works when shortened slightly

If it only sounds good at full length, it probably needs a cleaner shape.
