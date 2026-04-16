.setcpu "6502"

.include "audio/audio_api.inc"
.include "audio/audio_macros.inc"

.export SfxTable

.segment "RODATA"

; ---------------------------------------------------------------------
; Descriptor table
; priority, channel mask, cooldown, script ptr
; ---------------------------------------------------------------------
SfxTable:
    ; $00-$04 UI
    SFX_DESC PRI_UI_LOW,  CH_APU_P1,                       0,  Sfx_UiMove
    SFX_DESC PRI_UI_MED,  CH_APU_P1 | CH_NOISE,            0,  Sfx_UiConfirm
    SFX_DESC PRI_UI_LOW,  CH_APU_P1,                       0,  Sfx_UiBack
    SFX_DESC PRI_UI_MED,  CH_APU_P1 | CH_NOISE,            0,  Sfx_UiStart
    SFX_DESC PRI_UI_MED,  CH_APU_P1,                       4,  Sfx_UiPause

    ; $05-$0F unused/reserved
    .repeat 11
        SFX_DESC PRI_NONE, 0, 0, Sfx_Null
    .endrepeat

    ; $10-$22 frog/player block
    SFX_DESC PRI_RIBBIT,  CH_V6P1 | CH_V6SAW,             28, Sfx_FrogRibbitShort
    SFX_DESC PRI_RIBBIT,  CH_V6P1 | CH_V6SAW | CH_NOISE,  40, Sfx_FrogRibbitBig
    SFX_DESC PRI_JUMP,    CH_V6P1,                         4, Sfx_FrogJumpShort
    SFX_DESC PRI_JUMP,    CH_V6P1 | CH_NOISE,              6, Sfx_FrogJumpLong
    SFX_DESC PRI_LAND,    CH_TRI | CH_NOISE,               2, Sfx_FrogLandSoft
    SFX_DESC PRI_LAND,    CH_TRI | CH_NOISE,               4, Sfx_FrogLandHeavy
    SFX_DESC PRI_MOVE_LOW,CH_NOISE,                        0, Sfx_FrogWalk1
    SFX_DESC PRI_MOVE_LOW,CH_NOISE,                        0, Sfx_FrogWalk2
    SFX_DESC PRI_MOVE_LOW,CH_NOISE,                        0, Sfx_FrogWalk3
    SFX_DESC PRI_MOVE_LOW,CH_NOISE | CH_APU_P1,           18, Sfx_FrogIdleShuffle
    SFX_DESC PRI_MOVE_LOW,CH_NOISE | CH_V6P2,              0, Sfx_FrogSwim1
    SFX_DESC PRI_MOVE_LOW,CH_NOISE | CH_V6P2,              0, Sfx_FrogSwim2
    SFX_DESC PRI_SPLASH,  CH_TRI | CH_NOISE | CH_V6SAW,    6, Sfx_FrogSplashIn
    SFX_DESC PRI_SPLASH,  CH_TRI | CH_NOISE | CH_V6P2,     6, Sfx_FrogSplashOut
    SFX_DESC PRI_CONTACT, CH_NOISE | CH_V6P2,              4, Sfx_FrogPadLand
    SFX_DESC PRI_CONTACT, CH_NOISE | CH_V6P2,              4, Sfx_FrogShoreUp
    SFX_DESC PRI_CONTACT, CH_NOISE | CH_V6P2,              4, Sfx_FrogDropThrough
    SFX_DESC PRI_FAIL,    CH_V6P1 | CH_NOISE,             12, Sfx_FrogMiss
    SFX_DESC PRI_SUCCESS, CH_V6P1 | CH_V6P2,              10, Sfx_FrogRespawn

    ; $23-$2F unused/reserved
    .repeat 13
        SFX_DESC PRI_NONE, 0, 0, Sfx_Null
    .endrepeat

    ; $30-$33 game states
    SFX_DESC PRI_SUCCESS, CH_V6P1 | CH_V6P2,              12, Sfx_GoalReached
    SFX_DESC PRI_STAGE,   CH_V6P1 | CH_V6P2 | CH_V6SAW,   24, Sfx_StageClear
    SFX_DESC PRI_FAIL,    CH_V6P1 | CH_TRI | CH_NOISE | CH_V6SAW, 16, Sfx_FailWater
    SFX_DESC PRI_SUCCESS, CH_V6P1 | CH_V6P2,               8, Sfx_Success

    ; $34-$3F unused/reserved
    .repeat 12
        SFX_DESC PRI_NONE, 0, 0, Sfx_Null
    .endrepeat

    ; $40-$44 ambient
    SFX_DESC PRI_AMBIENT, CH_NOISE,                        8, Sfx_WaterLoopSoft
    SFX_DESC PRI_AMBIENT, CH_NOISE,                        8, Sfx_WaterEdgeLap
    SFX_DESC PRI_AMBIENT, CH_NOISE,                        8, Sfx_BushRustle
    SFX_DESC PRI_AMBIENT, CH_APU_P1,                      12, Sfx_AmbientCricket
    SFX_DESC PRI_AMBIENT, CH_V6SAW | CH_V6P2,             32, Sfx_AmbientDistantFrog

; ---------------------------------------------------------------------
; Null/unused entry
; ---------------------------------------------------------------------
Sfx_Null:
    SFX_END

; ---------------------------------------------------------------------
; UI
; ---------------------------------------------------------------------
Sfx_UiMove:
    SFX_APU_P1 APU_P25_08, NT_P_E6_LO, NT_P_E6_HI
    SFX_WAIT 1
    SFX_APU_P1 APU_P25_04, NT_P_G6_LO, NT_P_G6_HI
    SFX_WAIT 1
    SFX_END

Sfx_UiConfirm:
    SFX_APU_P1 APU_P25_10, NT_P_C6_LO, NT_P_C6_HI
    SFX_NOISE  N_04, $05, $00
    SFX_WAIT 1
    SFX_APU_P1 APU_P25_06, NT_P_G6_LO, NT_P_G6_HI
    SFX_WAIT 2
    SFX_END

Sfx_UiBack:
    SFX_APU_P1 APU_P25_08, NT_P_G6_LO, NT_P_G6_HI
    SFX_WAIT 1
    SFX_APU_P1 APU_P25_04, NT_P_E6_LO, NT_P_E6_HI
    SFX_WAIT 1
    SFX_END

Sfx_UiStart:
    SFX_APU_P1 APU_P25_10, NT_P_C6_LO, NT_P_C6_HI
    SFX_NOISE  N_05, $04, $00
    SFX_WAIT 1
    SFX_APU_P1 APU_P25_08, NT_P_E6_LO, NT_P_E6_HI
    SFX_WAIT 1
    SFX_APU_P1 APU_P25_06, NT_P_G6_LO, NT_P_G6_HI
    SFX_WAIT 2
    SFX_END

Sfx_UiPause:
    SFX_APU_P1 APU_P12_08, NT_P_D6_LO, NT_P_D6_HI
    SFX_WAIT 2
    SFX_END

; ---------------------------------------------------------------------
; Frog identity / movement
; ---------------------------------------------------------------------
Sfx_FrogRibbitShort:
    SFX_V6SAW V6SAW_18, NT_S_A3_LO, NT_S_A3_HI | V6_ENABLE
    SFX_V6P1  V6P25_12, NT_P_E5_LO, NT_P_E5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_16, NT_S_G3_LO, NT_S_G3_HI | V6_ENABLE
    SFX_V6P1  V6P25_10, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_12, NT_S_F3_LO, NT_S_F3_HI | V6_ENABLE
    SFX_V6P1  V6P25_06, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_END

Sfx_FrogRibbitBig:
    SFX_NOISE N_03, $05, $00
    SFX_V6SAW V6SAW_24, NT_S_B3_LO, NT_S_B3_HI | V6_ENABLE
    SFX_V6P1  V6P50_12, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_20, NT_S_A3_LO, NT_S_A3_HI | V6_ENABLE
    SFX_V6P1  V6P50_10, NT_P_F5_LO, NT_P_F5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_18, NT_S_G3_LO, NT_S_G3_HI | V6_ENABLE
    SFX_V6P1  V6P25_08, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_12, NT_S_E3_LO, NT_S_E3_HI | V6_ENABLE
    SFX_V6P1  V6P25_04, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    SFX_WAIT 4
    SFX_END

Sfx_FrogJumpShort:
    SFX_V6P1 V6P25_12, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_08, NT_P_B5_LO, NT_P_B5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_04, NT_P_A5_LO, NT_P_A5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_END

Sfx_FrogJumpLong:
    SFX_NOISE N_03, $07, $00
    SFX_V6P1 V6P25_12, NT_P_F5_LO, NT_P_F5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_10, NT_P_A5_LO, NT_P_A5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_08, NT_P_C6_LO, NT_P_C6_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_04, NT_P_A5_LO, NT_P_A5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_END

Sfx_FrogLandSoft:
    SFX_TRI   TRI_24, NT_T_D3_LO, NT_T_D3_HI
    SFX_NOISE N_08, $07, $00
    SFX_WAIT 1
    SFX_TRI   TRI_16, NT_T_C3_LO, NT_T_C3_HI
    SFX_NOISE N_04, $08, $00
    SFX_WAIT 2
    SFX_END

Sfx_FrogLandHeavy:
    SFX_TRI   TRI_31, NT_T_E3_LO, NT_T_E3_HI
    SFX_NOISE N_12, $06, $00
    SFX_WAIT 1
    SFX_TRI   TRI_24, NT_T_C3_LO, NT_T_C3_HI
    SFX_NOISE N_08, $07, $00
    SFX_WAIT 1
    SFX_TRI   TRI_16, NT_T_A2_LO, NT_T_A2_HI
    SFX_NOISE N_04, $08, $00
    SFX_WAIT 3
    SFX_END

Sfx_FrogWalk1:
    SFX_NOISE N_05, $08, $00
    SFX_WAIT 1
    SFX_END

Sfx_FrogWalk2:
    SFX_NOISE N_04, $07, $00
    SFX_WAIT 1
    SFX_END

Sfx_FrogWalk3:
    SFX_NOISE N_04, $09, $00
    SFX_WAIT 1
    SFX_END

Sfx_FrogIdleShuffle:
    SFX_NOISE  N_03, $0A, $00
    SFX_APU_P1 APU_P12_03, NT_P_C5_LO, NT_P_C5_HI
    SFX_WAIT 1
    SFX_NOISE  N_02, $09, $00
    SFX_WAIT 2
    SFX_END

Sfx_FrogSwim1:
    SFX_V6P2 V6P25_08, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_NOISE N_03, $04, $00
    SFX_WAIT 1
    SFX_V6P2 V6P25_04, NT_P_E5_LO, NT_P_E5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_END

Sfx_FrogSwim2:
    SFX_V6P2 V6P25_08, NT_P_E5_LO, NT_P_E5_HI | V6_ENABLE
    SFX_NOISE N_03, $05, $00
    SFX_WAIT 1
    SFX_V6P2 V6P25_04, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_END

Sfx_FrogSplashIn:
    SFX_TRI   TRI_31, NT_T_E3_LO, NT_T_E3_HI
    SFX_NOISE N_12, $03, $00
    SFX_V6SAW V6SAW_16, NT_S_C4_LO, NT_S_C4_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_TRI   TRI_24, NT_T_C3_LO, NT_T_C3_HI
    SFX_NOISE N_08, $05, $00
    SFX_V6SAW V6SAW_12, NT_S_A3_LO, NT_S_A3_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_END

Sfx_FrogSplashOut:
    SFX_TRI   TRI_24, NT_T_C3_LO, NT_T_C3_HI
    SFX_NOISE N_10, $04, $00
    SFX_V6P2  V6P25_08, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_TRI   TRI_16, NT_T_E3_LO, NT_T_E3_HI
    SFX_NOISE N_05, $06, $00
    SFX_V6P2  V6P25_04, NT_P_E5_LO, NT_P_E5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_END

Sfx_FrogPadLand:
    SFX_NOISE N_05, $08, $00
    SFX_V6P2  V6P25_06, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_END

Sfx_FrogShoreUp:
    SFX_NOISE N_06, $09, $00
    SFX_V6P2  V6P25_06, NT_P_F5_LO, NT_P_F5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_NOISE N_03, $08, $00
    SFX_V6P2  V6P25_04, NT_P_A5_LO, NT_P_A5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_END

Sfx_FrogDropThrough:
    SFX_V6P2  V6P25_08, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_NOISE N_03, $09, $00
    SFX_WAIT 1
    SFX_V6P2  V6P25_04, NT_P_E5_LO, NT_P_E5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_END

Sfx_FrogMiss:
    SFX_V6P1 V6P25_10, NT_P_F5_LO, NT_P_F5_HI | V6_ENABLE
    SFX_NOISE N_05, $08, $00
    SFX_WAIT 1
    SFX_V6P1 V6P25_06, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_WAIT 3
    SFX_END

Sfx_FrogRespawn:
    SFX_V6P1 V6P25_08, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    SFX_V6P2 V6P25_06, NT_P_G4_LO, NT_P_G4_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_08, NT_P_E5_LO, NT_P_E5_HI | V6_ENABLE
    SFX_V6P2 V6P25_06, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_06, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_V6P2 V6P25_04, NT_P_E5_LO, NT_P_E5_HI | V6_ENABLE
    SFX_WAIT 3
    SFX_END

; ---------------------------------------------------------------------
; Goal / fail / success
; ---------------------------------------------------------------------
Sfx_GoalReached:
    SFX_V6P1 V6P25_12, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_V6P2 V6P25_08, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_10, NT_P_B5_LO, NT_P_B5_HI | V6_ENABLE
    SFX_V6P2 V6P25_06, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_08, NT_P_D6_LO, NT_P_D6_HI | V6_ENABLE
    SFX_V6P2 V6P25_04, NT_P_B5_LO, NT_P_B5_HI | V6_ENABLE
    SFX_WAIT 3
    SFX_END

Sfx_StageClear:
    SFX_V6SAW V6SAW_20, NT_S_C4_LO, NT_S_C4_HI | V6_ENABLE
    SFX_V6P1  V6P25_12, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_V6P2  V6P25_08, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_20, NT_S_D4_LO, NT_S_D4_HI | V6_ENABLE
    SFX_V6P1  V6P25_10, NT_P_A5_LO, NT_P_A5_HI | V6_ENABLE
    SFX_V6P2  V6P25_06, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_20, NT_S_E4_LO, NT_S_E4_HI | V6_ENABLE
    SFX_V6P1  V6P25_08, NT_P_B5_LO, NT_P_B5_HI | V6_ENABLE
    SFX_V6P2  V6P25_06, NT_P_E5_LO, NT_P_E5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_16, NT_S_G4_LO, NT_S_G4_HI | V6_ENABLE
    SFX_V6P1  V6P25_06, NT_P_D6_LO, NT_P_D6_HI | V6_ENABLE
    SFX_V6P2  V6P25_04, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_WAIT 6
    SFX_END

Sfx_FailWater:
    SFX_NOISE N_12, $03, $00
    SFX_TRI   TRI_31, NT_T_E3_LO, NT_T_E3_HI
    SFX_V6SAW V6SAW_20, NT_S_A3_LO, NT_S_A3_HI | V6_ENABLE
    SFX_V6P1  V6P50_10, NT_P_A5_LO, NT_P_A5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_NOISE N_09, $04, $00
    SFX_TRI   TRI_24, NT_T_C3_LO, NT_T_C3_HI
    SFX_V6SAW V6SAW_16, NT_S_F3_LO, NT_S_F3_HI | V6_ENABLE
    SFX_V6P1  V6P25_08, NT_P_F5_LO, NT_P_F5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_NOISE N_06, $06, $00
    SFX_TRI   TRI_16, NT_T_A2_LO, NT_T_A2_HI
    SFX_V6SAW V6SAW_12, NT_S_D3_LO, NT_S_D3_HI | V6_ENABLE
    SFX_V6P1  V6P25_04, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_WAIT 5
    SFX_END

Sfx_Success:
    SFX_V6P1 V6P25_10, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_V6P2 V6P25_06, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_08, NT_P_B5_LO, NT_P_B5_HI | V6_ENABLE
    SFX_V6P2 V6P25_04, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    SFX_WAIT 1
    SFX_V6P1 V6P25_06, NT_P_D6_LO, NT_P_D6_HI | V6_ENABLE
    SFX_WAIT 3
    SFX_END

; ---------------------------------------------------------------------
; Ambient / world
; ---------------------------------------------------------------------
Sfx_WaterLoopSoft:
    SFX_NOISE N_02, $06, $00
    SFX_WAIT 3
    SFX_NOISE N_01, $08, $00
    SFX_WAIT 3
    SFX_END

Sfx_WaterEdgeLap:
    SFX_NOISE N_03, $07, $00
    SFX_WAIT 2
    SFX_NOISE N_01, $09, $00
    SFX_WAIT 2
    SFX_END

Sfx_BushRustle:
    SFX_NOISE N_04, $0A, $00
    SFX_WAIT 1
    SFX_NOISE N_02, $09, $00
    SFX_WAIT 1
    SFX_END

Sfx_AmbientCricket:
    SFX_APU_P1 APU_P12_04, NT_P_B6_LO, NT_P_B6_HI
    SFX_WAIT 1
    SFX_APU_P1 APU_P12_00, NT_P_B6_LO, NT_P_B6_HI
    SFX_WAIT 2
    SFX_APU_P1 APU_P12_04, NT_P_B6_LO, NT_P_B6_HI
    SFX_WAIT 1
    SFX_END

Sfx_AmbientDistantFrog:
    SFX_V6SAW V6SAW_10, NT_S_F3_LO, NT_S_F3_HI | V6_ENABLE
    SFX_V6P2  V6P25_04, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    SFX_WAIT 2
    SFX_V6SAW V6SAW_08, NT_S_D3_LO, NT_S_D3_HI | V6_ENABLE
    SFX_V6P2  V6P25_04, NT_P_A4_LO, NT_P_A4_HI | V6_ENABLE
    SFX_WAIT 4
    SFX_END
