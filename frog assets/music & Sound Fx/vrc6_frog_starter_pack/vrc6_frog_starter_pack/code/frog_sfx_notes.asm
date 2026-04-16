; frog_sfx_notes.asm
; pseudocode / integration notes only
; adapt to your engine's queue/priority model

; Suggested priority (high -> low):
;   RIBBIT, LAND, JUMP, WALK, IDLE

; Example trigger points:
; - WALK: every 6-10 frames during movement cadence
; - IDLE: every 24-40 frames while stationary
; - JUMP: on jump start
; - LAND: on ground contact
; - RIBBIT: on face/button action with 10-16 frame cooldown

; Example API shape
;   jsr Sfx_Play
;   lda #SFX_FROG_RIBBIT
;   jsr Sfx_Play

; Example anti-clutter rule
; If RIBBIT starts:
;   - cancel IDLE
;   - optionally suppress WALK for 1 frame
; If LAND starts:
;   - cancel IDLE
;   - allow LAND to override WALK

; Example per-sound channel philosophy:
; RIBBIT:
;   VRC6 Saw     = body
;   VRC6 Pulse 1 = throat edge
;   VRC6 Pulse 2 = optional front click
;
; JUMP:
;   VRC6 Pulse 2 = main
;   VRC6 Pulse 1 = optional support
;
; LAND:
;   2A03 Noise   = contact
;   Triangle     = optional body thunk
;
; WALK:
;   Noise or Pulse 2, very short
;
; IDLE:
;   Noise rustle + tiny pulse motion
