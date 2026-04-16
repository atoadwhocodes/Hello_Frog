; helper macros for VRC6-first audio data
.ifndef AUDIO_MACROS_INC
AUDIO_MACROS_INC = 1

.include "audio/audio_api.inc"

.macro SFX_DESC priority, channels, cooldown, label
    .byte priority, channels, cooldown, <label, >label
.endmacro

.macro SFX_APU_P1 ctrl, lo, hi
    .byte CMD_APU_P1, ctrl, lo, hi
.endmacro

.macro SFX_APU_P2 ctrl, lo, hi
    .byte CMD_APU_P2, ctrl, lo, hi
.endmacro

.macro SFX_TRI ctrl, lo, hi
    .byte CMD_TRI, ctrl, lo, hi
.endmacro

.macro SFX_NOISE ctrl, period, len
    .byte CMD_NOISE, ctrl, period, len
.endmacro

.macro SFX_V6P1 ctrl, lo, hi
    .byte CMD_V6P1, ctrl, lo, hi
.endmacro

.macro SFX_V6P2 ctrl, lo, hi
    .byte CMD_V6P2, ctrl, lo, hi
.endmacro

.macro SFX_V6SAW rate, lo, hi
    .byte CMD_V6SAW, rate, lo, hi
.endmacro

.macro SFX_WAIT frames
    .byte CMD_WAIT, frames
.endmacro

.macro SFX_END
    .byte CMD_END
.endmacro

.macro MUS_EVENT dur, ctrl, lo, hi
    .byte dur, ctrl, lo, hi
.endmacro

.macro MUS_END
    .byte $00, $00, $00, $00
.endmacro

.endif
