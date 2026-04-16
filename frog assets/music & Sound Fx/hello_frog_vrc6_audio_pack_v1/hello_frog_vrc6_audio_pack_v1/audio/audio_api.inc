; hello_frog audio API / common constants
; VRC6-first layout with optional 2A03 utility channels
.ifndef AUDIO_API_INC
AUDIO_API_INC = 1

.include "audio/audio_ids.inc"

; ------------------------------------------------------------
; Mapper/audio variant selection
; ------------------------------------------------------------
; Mapper 024: $x001 = low, $x002 = high
; Mapper 026: $x001 and $x002 swap
.ifndef VRC6_MAPPER
VRC6_MAPPER = 24
.endif

.if VRC6_MAPPER = 24
    VRC6_P1_CTRL = $9000
    VRC6_P1_LO   = $9001
    VRC6_P1_HI   = $9002

    VRC6_P2_CTRL = $A000
    VRC6_P2_LO   = $A001
    VRC6_P2_HI   = $A002

    VRC6_SAW_CTRL = $B000
    VRC6_SAW_LO   = $B001
    VRC6_SAW_HI   = $B002
.elseif VRC6_MAPPER = 26
    VRC6_P1_CTRL = $9000
    VRC6_P1_LO   = $9002
    VRC6_P1_HI   = $9001

    VRC6_P2_CTRL = $A000
    VRC6_P2_LO   = $A002
    VRC6_P2_HI   = $A001

    VRC6_SAW_CTRL = $B000
    VRC6_SAW_LO   = $B002
    VRC6_SAW_HI   = $B001
.else
    .error "Unsupported VRC6_MAPPER. Use 24 or 26."
.endif

VRC6_FREQ_CTRL = $9003

; ------------------------------------------------------------
; Channel mask bits
; ------------------------------------------------------------
CH_APU_P1  = %00000001
CH_APU_P2  = %00000010
CH_TRI     = %00000100
CH_NOISE   = %00001000
CH_V6P1    = %00010000
CH_V6P2    = %00100000
CH_V6SAW   = %01000000

; recommended VRC6-first masks
CH_MUSIC_CORE = CH_V6P1 | CH_V6P2 | CH_V6SAW | CH_TRI | CH_NOISE
CH_FROG_VOICE = CH_V6P1 | CH_V6SAW
CH_CONTACT    = CH_TRI | CH_NOISE

; ------------------------------------------------------------
; SFX descriptor offsets
; ------------------------------------------------------------
SFX_DESC_PRIORITY = 0
SFX_DESC_CHANNELS = 1
SFX_DESC_COOLDOWN = 2
SFX_DESC_DATA_LO  = 3
SFX_DESC_DATA_HI  = 4
SFX_DESC_SIZE     = 5

; ------------------------------------------------------------
; SFX command stream opcodes
; ------------------------------------------------------------
CMD_APU_P1 = $80 ; ctrl, timer_lo, timer_hi
CMD_APU_P2 = $81 ; ctrl, timer_lo, timer_hi
CMD_TRI    = $82 ; linear, timer_lo, timer_hi
CMD_NOISE  = $83 ; ctrl, period, lengthReload
CMD_V6P1   = $84 ; ctrl, period_lo, period_hi|$80
CMD_V6P2   = $85 ; ctrl, period_lo, period_hi|$80
CMD_V6SAW  = $86 ; rate, period_lo, period_hi|$80
CMD_WAIT   = $FE ; frames
CMD_END    = $FF

; ------------------------------------------------------------
; Music format
; one event = duration, ctrl, lo, hi
; duration = 0 => end of channel stream
; ctrl = MUS_REST_CTRL => silence channel for duration
; ------------------------------------------------------------
MUS_REST_CTRL = $FF
MUSF_LOOP     = %00000001

; ------------------------------------------------------------
; priorities
; ------------------------------------------------------------
PRI_NONE      = 0
PRI_AMBIENT   = 8
PRI_UI_LOW    = 16
PRI_UI_MED    = 24
PRI_MOVE_LOW  = 28
PRI_MOVE_MED  = 36
PRI_CONTACT   = 48
PRI_JUMP      = 56
PRI_LAND      = 72
PRI_SPLASH    = 76
PRI_FAIL      = 88
PRI_SUCCESS   = 92
PRI_RIBBIT    = 100
PRI_STAGE     = 110

; ------------------------------------------------------------
; 2A03 note timers (NTSC, pulse formula)
; usable for APU pulse and VRC6 pulse channels
; ------------------------------------------------------------
NT_P_C3_LO  = $AB
NT_P_C3_HI  = $01
NT_P_D3_LO  = $7C
NT_P_D3_HI  = $01
NT_P_E3_LO  = $52
NT_P_E3_HI  = $01
NT_P_F3_LO  = $3E
NT_P_F3_HI  = $01
NT_P_G3_LO  = $1B
NT_P_G3_HI  = $01
NT_P_A3_LO  = $FB
NT_P_A3_HI  = $00
NT_P_B3_LO  = $E0
NT_P_B3_HI  = $00

NT_P_C4_LO  = $D5
NT_P_C4_HI  = $00
NT_P_D4_LO  = $BD
NT_P_D4_HI  = $00
NT_P_E4_LO  = $A9
NT_P_E4_HI  = $00
NT_P_F4_LO  = $9F
NT_P_F4_HI  = $00
NT_P_G4_LO  = $8E
NT_P_G4_HI  = $00
NT_P_A4_LO  = $7E
NT_P_A4_HI  = $00
NT_P_B4_LO  = $70
NT_P_B4_HI  = $00

NT_P_C5_LO  = $6A
NT_P_C5_HI  = $00
NT_P_D5_LO  = $5E
NT_P_D5_HI  = $00
NT_P_E5_LO  = $54
NT_P_E5_HI  = $00
NT_P_F5_LO  = $4D
NT_P_F5_HI  = $00
NT_P_FS5_LO = $49
NT_P_FS5_HI = $00
NT_P_G5_LO  = $46
NT_P_G5_HI  = $00
NT_P_A5_LO  = $3E
NT_P_A5_HI  = $00
NT_P_B5_LO  = $38
NT_P_B5_HI  = $00

NT_P_C6_LO  = $34
NT_P_C6_HI  = $00
NT_P_D6_LO  = $2F
NT_P_D6_HI  = $00
NT_P_E6_LO  = $2A
NT_P_E6_HI  = $00
NT_P_G6_LO  = $23
NT_P_G6_HI  = $00
NT_P_B6_LO  = $1C
NT_P_B6_HI  = $00

; ------------------------------------------------------------
; VRC6 saw note timers (NTSC, saw formula)
; ------------------------------------------------------------
NT_S_C3_LO = $D0
NT_S_C3_HI = $03
NT_S_D3_LO = $66
NT_S_D3_HI = $03
NT_S_E3_LO = $07
NT_S_E3_HI = $03
NT_S_F3_LO = $DB
NT_S_F3_HI = $02
NT_S_G3_LO = $8B
NT_S_G3_HI = $02
NT_S_A3_LO = $44
NT_S_A3_HI = $02
NT_S_B3_LO = $05
NT_S_B3_HI = $02

NT_S_C4_LO = $E8
NT_S_C4_HI = $01
NT_S_D4_LO = $B2
NT_S_D4_HI = $01
NT_S_E4_LO = $83
NT_S_E4_HI = $01
NT_S_F4_LO = $6D
NT_S_F4_HI = $01
NT_S_G4_LO = $45
NT_S_G4_HI = $01
NT_S_A4_LO = $22
NT_S_A4_HI = $01
NT_S_B4_LO = $02
NT_S_B4_HI = $01

NT_S_C5_LO = $F3
NT_S_C5_HI = $00
NT_S_D5_LO = $D9
NT_S_D5_HI = $00
NT_S_E5_LO = $C1
NT_S_E5_HI = $00
NT_S_F5_LO = $B6
NT_S_F5_HI = $00
NT_S_G5_LO = $A2
NT_S_G5_HI = $00
NT_S_A5_LO = $90
NT_S_A5_HI = $00
NT_S_B5_LO = $80
NT_S_B5_HI = $00

NT_S_C6_LO = $79
NT_S_C6_HI = $00
NT_S_D6_LO = $6C
NT_S_D6_HI = $00
NT_S_E6_LO = $60
NT_S_E6_HI = $00
NT_S_G6_LO = $51
NT_S_G6_HI = $00

; ------------------------------------------------------------
; triangle note timers (approx NTSC)
; ------------------------------------------------------------
NT_T_F2_LO  = $80
NT_T_F2_HI  = $02
NT_T_A2_LO  = $FB
NT_T_A2_HI  = $01
NT_T_B2_LO  = $C4
NT_T_B2_HI  = $01
NT_T_C3_LO  = $AB
NT_T_C3_HI  = $01
NT_T_D3_LO  = $7C
NT_T_D3_HI  = $01
NT_T_E3_LO  = $52
NT_T_E3_HI  = $01
NT_T_F3_LO  = $3E
NT_T_F3_HI  = $01
NT_T_G3_LO  = $1B
NT_T_G3_HI  = $01
NT_T_A3_LO  = $FB
NT_T_A3_HI  = $00

; ------------------------------------------------------------
; convenience control values
; ------------------------------------------------------------

; 2A03 pulse control: DDLC VVVV using constant volume
APU_P12_12 = $1C ; 12.5%, vol 12
APU_P12_10 = $1A
APU_P12_08 = $18
APU_P12_06 = $16
APU_P12_04 = $14
APU_P12_03 = $13
APU_P12_00 = $10

APU_P25_14 = $5E ; 25%, vol 14
APU_P25_12 = $5C
APU_P25_10 = $5A
APU_P25_09 = $59
APU_P25_08 = $58
APU_P25_07 = $57
APU_P25_06 = $56
APU_P25_05 = $55
APU_P25_04 = $54
APU_P25_03 = $53
APU_P25_00 = $50

TRI_31 = $9F
TRI_24 = $98
TRI_16 = $90
TRI_00 = $80

N_12 = $1C
N_10 = $1A
N_09 = $19
N_08 = $18
N_07 = $17
N_06 = $16
N_05 = $15
N_04 = $14
N_03 = $13
N_02 = $12
N_01 = $11
N_00 = $10

; VRC6 pulse control: MDDD VVVV
; D=3 ~= 25%, D=7 = 50%
V6P25_15 = $3F
V6P25_14 = $3E
V6P25_12 = $3C
V6P25_10 = $3A
V6P25_08 = $38
V6P25_06 = $36
V6P25_04 = $34
V6P25_00 = $30

V6P50_15 = $7F
V6P50_12 = $7C
V6P50_10 = $7A
V6P50_08 = $78
V6P50_06 = $76
V6P50_04 = $74
V6P50_00 = $70

; VRC6 saw accumulator rates
V6SAW_06 = $06
V6SAW_08 = $08
V6SAW_10 = $0A
V6SAW_12 = $0C
V6SAW_16 = $10
V6SAW_18 = $12
V6SAW_20 = $14
V6SAW_24 = $18
V6SAW_28 = $1C
V6SAW_32 = $20
V6SAW_36 = $24
V6SAW_40 = $28

; high-byte enable bit for VRC6 period high registers
V6_ENABLE = $80

; soft silence values
APU_PULSE_SILENT = $10
NOISE_SILENT     = $10
TRI_SILENT       = $80

; audio entry points for gameplay code
.ifndef AUDIO_DRIVER_IMPL
.import Audio_Init
.import Audio_Update
.import Sfx_Play
.import Music_Play
.import Music_Stop
.endif

.endif
