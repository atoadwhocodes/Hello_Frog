.setcpu "6502"

.include "audio/audio_api.inc"
.include "audio/audio_macros.inc"

.export MusicTable

.segment "RODATA"

; ---------------------------------------------------------------------
; Track descriptor format:
;   flags
;   v6p1_ptr_lo, v6p1_ptr_hi
;   v6p2_ptr_lo, v6p2_ptr_hi
;   v6saw_ptr_lo, v6saw_ptr_hi
;   tri_ptr_lo, tri_ptr_hi
;   noise_ptr_lo, noise_ptr_hi
; ---------------------------------------------------------------------

MusicTable:
    .addr Track_Title
    .addr Track_Select
    .addr Track_PlayA
    .addr Track_PlayB
    .addr Track_Tension
    .addr Track_SuccessSting
    .addr Track_FailSting
    .addr Track_Pause

Track_Title:
    .byte MUSF_LOOP
    .addr Mus_Title_V6P1
    .addr Mus_Title_V6P2
    .addr Mus_Title_V6Saw
    .addr Mus_Title_Tri
    .addr Mus_Title_Noise

Track_Select:
    .byte MUSF_LOOP
    .addr Mus_Select_V6P1
    .addr Mus_Select_V6P2
    .addr Mus_Select_V6Saw
    .addr Mus_Select_Tri
    .addr Mus_Select_Noise

Track_PlayA:
    .byte MUSF_LOOP
    .addr Mus_PlayA_V6P1
    .addr Mus_PlayA_V6P2
    .addr Mus_PlayA_V6Saw
    .addr Mus_PlayA_Tri
    .addr Mus_PlayA_Noise

Track_PlayB:
    .byte MUSF_LOOP
    .addr Mus_PlayB_V6P1
    .addr Mus_PlayB_V6P2
    .addr Mus_PlayB_V6Saw
    .addr Mus_PlayB_Tri
    .addr Mus_PlayB_Noise

Track_Tension:
    .byte MUSF_LOOP
    .addr Mus_Tension_V6P1
    .addr Mus_Tension_V6P2
    .addr Mus_Tension_V6Saw
    .addr Mus_Tension_Tri
    .addr Mus_Tension_Noise

Track_SuccessSting:
    .byte 0
    .addr Mus_Success_V6P1
    .addr Mus_Success_V6P2
    .addr Mus_Success_V6Saw
    .addr Mus_Success_Tri
    .addr Mus_Success_Noise

Track_FailSting:
    .byte 0
    .addr Mus_Fail_V6P1
    .addr Mus_Fail_V6P2
    .addr Mus_Fail_V6Saw
    .addr Mus_Fail_Tri
    .addr Mus_Fail_Noise

Track_Pause:
    .byte MUSF_LOOP
    .addr Mus_Pause_V6P1
    .addr Mus_Pause_V6P2
    .addr Mus_Pause_V6Saw
    .addr Mus_Pause_Tri
    .addr Mus_Pause_Noise

; ---------------------------------------------------------------------
; TITLE
; ---------------------------------------------------------------------
Mus_Title_V6P1:
    MUS_EVENT 24, V6P25_06, NT_P_E4_LO, NT_P_E4_HI | V6_ENABLE
    MUS_EVENT 24, V6P25_06, NT_P_G4_LO, NT_P_G4_HI | V6_ENABLE
    MUS_EVENT 24, V6P25_06, NT_P_A4_LO, NT_P_A4_HI | V6_ENABLE
    MUS_EVENT 24, V6P25_06, NT_P_G4_LO, NT_P_G4_HI | V6_ENABLE
    MUS_END

Mus_Title_V6P2:
    MUS_EVENT 48, V6P25_04, NT_P_C4_LO, NT_P_C4_HI | V6_ENABLE
    MUS_EVENT 48, V6P25_04, NT_P_D4_LO, NT_P_D4_HI | V6_ENABLE
    MUS_END

Mus_Title_V6Saw:
    MUS_EVENT 48, V6SAW_08, NT_S_C3_LO, NT_S_C3_HI | V6_ENABLE
    MUS_EVENT 48, V6SAW_08, NT_S_A3_LO, NT_S_A3_HI | V6_ENABLE
    MUS_END

Mus_Title_Tri:
    MUS_EVENT 24, TRI_16, NT_T_C3_LO, NT_T_C3_HI
    MUS_EVENT 24, TRI_16, NT_T_E3_LO, NT_T_E3_HI
    MUS_EVENT 24, TRI_16, NT_T_G3_LO, NT_T_G3_HI
    MUS_EVENT 24, TRI_16, NT_T_E3_LO, NT_T_E3_HI
    MUS_END

Mus_Title_Noise:
    MUS_EVENT 96, MUS_REST_CTRL, $00, $00
    MUS_END

; ---------------------------------------------------------------------
; SELECT
; ---------------------------------------------------------------------
Mus_Select_V6P1:
    MUS_EVENT 18, V6P25_06, NT_P_A4_LO, NT_P_A4_HI | V6_ENABLE
    MUS_EVENT 18, V6P25_06, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    MUS_EVENT 18, V6P25_06, NT_P_A4_LO, NT_P_A4_HI | V6_ENABLE
    MUS_EVENT 18, V6P25_06, NT_P_G4_LO, NT_P_G4_HI | V6_ENABLE
    MUS_END

Mus_Select_V6P2:
    MUS_EVENT 36, V6P25_04, NT_P_E4_LO, NT_P_E4_HI | V6_ENABLE
    MUS_EVENT 36, V6P25_04, NT_P_D4_LO, NT_P_D4_HI | V6_ENABLE
    MUS_END

Mus_Select_V6Saw:
    MUS_EVENT 36, V6SAW_08, NT_S_A3_LO, NT_S_A3_HI | V6_ENABLE
    MUS_EVENT 36, V6SAW_08, NT_S_G3_LO, NT_S_G3_HI | V6_ENABLE
    MUS_END

Mus_Select_Tri:
    MUS_EVENT 18, TRI_16, NT_T_A2_LO, NT_T_A2_HI
    MUS_EVENT 18, TRI_16, NT_T_C3_LO, NT_T_C3_HI
    MUS_EVENT 18, TRI_16, NT_T_E3_LO, NT_T_E3_HI
    MUS_EVENT 18, TRI_16, NT_T_C3_LO, NT_T_C3_HI
    MUS_END

Mus_Select_Noise:
    MUS_EVENT 72, MUS_REST_CTRL, $00, $00
    MUS_END

; ---------------------------------------------------------------------
; PLAY A
; ---------------------------------------------------------------------
Mus_PlayA_V6P1:
    MUS_EVENT 32, V6P25_06, NT_P_E4_LO, NT_P_E4_HI | V6_ENABLE
    MUS_EVENT 32, V6P25_06, NT_P_G4_LO, NT_P_G4_HI | V6_ENABLE
    MUS_EVENT 32, V6P25_06, NT_P_A4_LO, NT_P_A4_HI | V6_ENABLE
    MUS_EVENT 32, V6P25_06, NT_P_G4_LO, NT_P_G4_HI | V6_ENABLE
    MUS_END

Mus_PlayA_V6P2:
    MUS_EVENT 64, V6P25_04, NT_P_C4_LO, NT_P_C4_HI | V6_ENABLE
    MUS_EVENT 64, V6P25_04, NT_P_D4_LO, NT_P_D4_HI | V6_ENABLE
    MUS_END

Mus_PlayA_V6Saw:
    MUS_EVENT 64, V6SAW_08, NT_S_C3_LO, NT_S_C3_HI | V6_ENABLE
    MUS_EVENT 64, V6SAW_08, NT_S_E3_LO, NT_S_E3_HI | V6_ENABLE
    MUS_END

Mus_PlayA_Tri:
    MUS_EVENT 32, TRI_16, NT_T_C3_LO, NT_T_C3_HI
    MUS_EVENT 32, TRI_16, NT_T_E3_LO, NT_T_E3_HI
    MUS_EVENT 32, TRI_16, NT_T_G3_LO, NT_T_G3_HI
    MUS_EVENT 32, TRI_16, NT_T_E3_LO, NT_T_E3_HI
    MUS_END

Mus_PlayA_Noise:
    MUS_EVENT 128, MUS_REST_CTRL, $00, $00
    MUS_END

; ---------------------------------------------------------------------
; PLAY B
; ---------------------------------------------------------------------
Mus_PlayB_V6P1:
    MUS_EVENT 32, V6P25_06, NT_P_D4_LO, NT_P_D4_HI | V6_ENABLE
    MUS_EVENT 32, V6P25_06, NT_P_F4_LO, NT_P_F4_HI | V6_ENABLE
    MUS_EVENT 32, V6P25_06, NT_P_G4_LO, NT_P_G4_HI | V6_ENABLE
    MUS_EVENT 32, V6P25_06, NT_P_F4_LO, NT_P_F4_HI | V6_ENABLE
    MUS_END

Mus_PlayB_V6P2:
    MUS_EVENT 64, V6P25_04, NT_P_B3_LO, NT_P_B3_HI | V6_ENABLE
    MUS_EVENT 64, V6P25_04, NT_P_A3_LO, NT_P_A3_HI | V6_ENABLE
    MUS_END

Mus_PlayB_V6Saw:
    MUS_EVENT 64, V6SAW_08, NT_S_G3_LO, NT_S_G3_HI | V6_ENABLE
    MUS_EVENT 64, V6SAW_08, NT_S_D3_LO, NT_S_D3_HI | V6_ENABLE
    MUS_END

Mus_PlayB_Tri:
    MUS_EVENT 32, TRI_16, NT_T_G3_LO, NT_T_G3_HI
    MUS_EVENT 32, TRI_16, NT_T_E3_LO, NT_T_E3_HI
    MUS_EVENT 32, TRI_16, NT_T_D3_LO, NT_T_D3_HI
    MUS_EVENT 32, TRI_16, NT_T_E3_LO, NT_T_E3_HI
    MUS_END

Mus_PlayB_Noise:
    MUS_EVENT 128, MUS_REST_CTRL, $00, $00
    MUS_END

; ---------------------------------------------------------------------
; TENSION
; ---------------------------------------------------------------------
Mus_Tension_V6P1:
    MUS_EVENT 24, V6P25_06, NT_P_E4_LO, NT_P_E4_HI | V6_ENABLE
    MUS_EVENT 24, MUS_REST_CTRL, $00, $00
    MUS_EVENT 24, V6P25_06, NT_P_D4_LO, NT_P_D4_HI | V6_ENABLE
    MUS_EVENT 24, MUS_REST_CTRL, $00, $00
    MUS_END

Mus_Tension_V6P2:
    MUS_EVENT 48, V6P25_04, NT_P_B3_LO, NT_P_B3_HI | V6_ENABLE
    MUS_EVENT 48, V6P25_04, NT_P_A3_LO, NT_P_A3_HI | V6_ENABLE
    MUS_END

Mus_Tension_V6Saw:
    MUS_EVENT 96, MUS_REST_CTRL, $00, $00
    MUS_END

Mus_Tension_Tri:
    MUS_EVENT 24, TRI_16, NT_T_E3_LO, NT_T_E3_HI
    MUS_EVENT 24, TRI_16, NT_T_D3_LO, NT_T_D3_HI
    MUS_EVENT 24, TRI_16, NT_T_C3_LO, NT_T_C3_HI
    MUS_EVENT 24, TRI_16, NT_T_D3_LO, NT_T_D3_HI
    MUS_END

Mus_Tension_Noise:
    MUS_EVENT 96, MUS_REST_CTRL, $00, $00
    MUS_END

; ---------------------------------------------------------------------
; SUCCESS / FAIL STINGS
; ---------------------------------------------------------------------
Mus_Success_V6P1:
    MUS_EVENT 4, V6P25_10, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    MUS_EVENT 4, V6P25_10, NT_P_B5_LO, NT_P_B5_HI | V6_ENABLE
    MUS_EVENT 8, V6P25_10, NT_P_D6_LO, NT_P_D6_HI | V6_ENABLE
    MUS_END

Mus_Success_V6P2:
    MUS_EVENT 4, V6P25_04, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    MUS_EVENT 4, V6P25_04, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    MUS_EVENT 8, V6P25_04, NT_P_B5_LO, NT_P_B5_HI | V6_ENABLE
    MUS_END

Mus_Success_V6Saw:
    MUS_EVENT 16, V6SAW_12, NT_S_G4_LO, NT_S_G4_HI | V6_ENABLE
    MUS_END

Mus_Success_Tri:
    MUS_EVENT 16, TRI_24, NT_T_G3_LO, NT_T_G3_HI
    MUS_END

Mus_Success_Noise:
    MUS_EVENT 16, MUS_REST_CTRL, $00, $00
    MUS_END

Mus_Fail_V6P1:
    MUS_EVENT 4, V6P25_08, NT_P_F5_LO, NT_P_F5_HI | V6_ENABLE
    MUS_EVENT 4, V6P25_08, NT_P_D5_LO, NT_P_D5_HI | V6_ENABLE
    MUS_EVENT 8, V6P25_06, NT_P_C5_LO, NT_P_C5_HI | V6_ENABLE
    MUS_END

Mus_Fail_V6P2:
    MUS_EVENT 16, MUS_REST_CTRL, $00, $00
    MUS_END

Mus_Fail_V6Saw:
    MUS_EVENT 16, V6SAW_10, NT_S_F3_LO, NT_S_F3_HI | V6_ENABLE
    MUS_END

Mus_Fail_Tri:
    MUS_EVENT 16, TRI_24, NT_T_F2_LO, NT_T_F2_HI
    MUS_END

Mus_Fail_Noise:
    MUS_EVENT 4, N_06, $04, $00
    MUS_EVENT 12, MUS_REST_CTRL, $00, $00
    MUS_END

; ---------------------------------------------------------------------
; PAUSE
; ---------------------------------------------------------------------
Mus_Pause_V6P1:
    MUS_EVENT 12, V6P25_04, NT_P_C6_LO, NT_P_C6_HI | V6_ENABLE
    MUS_EVENT 12, MUS_REST_CTRL, $00, $00
    MUS_END

Mus_Pause_V6P2:
    MUS_EVENT 12, V6P25_04, NT_P_G5_LO, NT_P_G5_HI | V6_ENABLE
    MUS_EVENT 12, MUS_REST_CTRL, $00, $00
    MUS_END

Mus_Pause_V6Saw:
    MUS_EVENT 24, MUS_REST_CTRL, $00, $00
    MUS_END

Mus_Pause_Tri:
    MUS_EVENT 24, TRI_16, NT_T_C3_LO, NT_T_C3_HI
    MUS_END

Mus_Pause_Noise:
    MUS_EVENT 24, MUS_REST_CTRL, $00, $00
    MUS_END
