; VRC6 trigger template for hello-pond.asm
; replace example state names with your actual symbols/branches

.include "audio/audio_api.inc"

; one-time setup
;   jsr Audio_Init
;
; once per frame
;   jsr Audio_Update

; ------------------------------------------------------------
; jump start
; ------------------------------------------------------------
; when frog leaves stable ground by player action
;   lda #SFX_FROG_JUMP_SHORT
;   jsr Sfx_Play

; ------------------------------------------------------------
; long jump branch
; ------------------------------------------------------------
; stronger launch / special pad launch
;   lda #SFX_FROG_JUMP_LONG
;   jsr Sfx_Play

; ------------------------------------------------------------
; land resolution
; ------------------------------------------------------------
; small settle
;   lda #SFX_FROG_LAND_SOFT
;   jsr Sfx_Play
;
; heavy settle
;   lda #SFX_FROG_LAND_HEAVY
;   jsr Sfx_Play

; ------------------------------------------------------------
; walking cadence
; ------------------------------------------------------------
; every 6-8 frames while grounded and actually moving:
;   lda frog_walk_phase
;   and #$03
;   beq @walk1
;   cmp #$01
;   beq @walk2
; @walk3:
;   lda #SFX_FROG_WALK_3
;   bne @do_walk
; @walk2:
;   lda #SFX_FROG_WALK_2
;   bne @do_walk
; @walk1:
;   lda #SFX_FROG_WALK_1
; @do_walk:
;   jsr Sfx_Play

; ------------------------------------------------------------
; swim cadence
; ------------------------------------------------------------
; every 8-10 frames while in swim state:
;   lda frog_swim_phase
;   and #$01
;   beq @swim1
;   lda #SFX_FROG_SWIM_2
;   bne @do_swim
; @swim1:
;   lda #SFX_FROG_SWIM_1
; @do_swim:
;   jsr Sfx_Play

; ------------------------------------------------------------
; water transitions
; ------------------------------------------------------------
; entering water:
;   lda #SFX_FROG_SPLASH_IN
;   jsr Sfx_Play
;
; leaving water with larger exit motion:
;   lda #SFX_FROG_SPLASH_OUT
;   jsr Sfx_Play
;
; swim -> shore/top bank:
;   lda #SFX_FROG_SHORE_UP
;   jsr Sfx_Play
;
; swim/air -> lily pad:
;   lda #SFX_FROG_PAD_LAND
;   jsr Sfx_Play
;
; down + A drop-through:
;   lda #SFX_FROG_DROP_THROUGH
;   jsr Sfx_Play

; ------------------------------------------------------------
; frog voice
; ------------------------------------------------------------
; manual croak or idle event:
;   lda #SFX_FROG_RIBBIT_SHORT
;   jsr Sfx_Play
;
; rarer bigger idle/title croak:
;   lda #SFX_FROG_RIBBIT_BIG
;   jsr Sfx_Play

; ------------------------------------------------------------
; fail / success
; ------------------------------------------------------------
; small miss:
;   lda #SFX_FROG_MISS
;   jsr Sfx_Play
;
; water fail:
;   lda #SFX_FAIL_WATER
;   jsr Sfx_Play
;   lda #MUS_FAIL_STING
;   jsr Music_Play
;
; goal reached:
;   lda #SFX_GOAL_REACHED
;   jsr Sfx_Play
;
; stage clear:
;   lda #SFX_STAGE_CLEAR
;   jsr Sfx_Play
;   lda #MUS_SUCCESS_STING
;   jsr Music_Play

; ------------------------------------------------------------
; menu / title
; ------------------------------------------------------------
; title:
;   lda #MUS_TITLE
;   jsr Music_Play
;
; menu/select:
;   lda #MUS_SELECT
;   jsr Music_Play
;   lda #SFX_UI_MOVE
;   jsr Sfx_Play
;
; confirm:
;   lda #SFX_UI_CONFIRM
;   jsr Sfx_Play
;
; gameplay:
;   lda #MUS_PLAY_A
;   jsr Music_Play
