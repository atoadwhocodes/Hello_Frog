; hello_frog audio IDs
; VRC6-tuned audio constants for ca65

.ifndef AUDIO_IDS_INC
AUDIO_IDS_INC = 1

; -----------------------------
; SFX IDs
; -----------------------------
SFX_UI_MOVE              = $00
SFX_UI_CONFIRM           = $01
SFX_UI_BACK              = $02
SFX_UI_START             = $03
SFX_UI_PAUSE             = $04

SFX_FROG_RIBBIT_SHORT    = $10
SFX_FROG_RIBBIT_BIG      = $11
SFX_FROG_JUMP_SHORT      = $12
SFX_FROG_JUMP_LONG       = $13
SFX_FROG_LAND_SOFT       = $14
SFX_FROG_LAND_HEAVY      = $15
SFX_FROG_WALK_1          = $16
SFX_FROG_WALK_2          = $17
SFX_FROG_WALK_3          = $18
SFX_FROG_IDLE_SHUFFLE    = $19
SFX_FROG_SWIM_1          = $1A
SFX_FROG_SWIM_2          = $1B
SFX_FROG_SPLASH_IN       = $1C
SFX_FROG_SPLASH_OUT      = $1D
SFX_FROG_PAD_LAND        = $1E
SFX_FROG_SHORE_UP        = $1F
SFX_FROG_DROP_THROUGH    = $20
SFX_FROG_MISS            = $21
SFX_FROG_RESPAWN         = $22

SFX_GOAL_REACHED         = $30
SFX_STAGE_CLEAR          = $31
SFX_FAIL_WATER           = $32
SFX_SUCCESS              = $33

SFX_WATER_LOOP_SOFT      = $40
SFX_WATER_EDGE_LAP       = $41
SFX_BUSH_RUSTLE          = $42
SFX_AMBIENT_CRICKET      = $43
SFX_AMBIENT_DISTANT_FROG = $44

SFX_MAX_ID               = $44

; -----------------------------
; Music IDs
; -----------------------------
MUS_TITLE                = $00
MUS_SELECT               = $01
MUS_PLAY_A               = $02
MUS_PLAY_B               = $03
MUS_TENSION              = $04
MUS_SUCCESS_STING        = $05
MUS_FAIL_STING           = $06
MUS_PAUSE                = $07

MUS_MAX_ID               = $07

.endif
