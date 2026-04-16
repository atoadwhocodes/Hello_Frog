.setcpu "6502"

AUDIO_DRIVER_IMPL = 1
.include "audio/audio_api.inc"

.import SfxTable
.import MusicTable

.export Audio_Init
.export Audio_Update
.export Sfx_Play
.export Music_Play
.export Music_Stop

.exportzp audio_sfx_ptr_lo
.exportzp audio_sfx_ptr_hi
.exportzp audio_sfx_wait
.exportzp audio_sfx_priority
.exportzp audio_sfx_channels
.exportzp audio_sfx_active
.exportzp audio_sfx_id
.exportzp audio_music_id
.exportzp audio_music_active
.exportzp audio_music_flags

.segment "ZEROPAGE"
audio_sfx_ptr_lo:      .res 1
audio_sfx_ptr_hi:      .res 1
audio_sfx_wait:        .res 1
audio_sfx_priority:    .res 1
audio_sfx_channels:    .res 1
audio_sfx_active:      .res 1
audio_sfx_id:          .res 1

audio_music_id:        .res 1
audio_music_active:    .res 1
audio_music_flags:     .res 1

music_v6p1_ptr_lo:     .res 1
music_v6p1_ptr_hi:     .res 1
music_v6p1_start_lo:   .res 1
music_v6p1_start_hi:   .res 1
music_v6p1_wait:       .res 1

music_v6p2_ptr_lo:     .res 1
music_v6p2_ptr_hi:     .res 1
music_v6p2_start_lo:   .res 1
music_v6p2_start_hi:   .res 1
music_v6p2_wait:       .res 1

music_v6saw_ptr_lo:    .res 1
music_v6saw_ptr_hi:    .res 1
music_v6saw_start_lo:  .res 1
music_v6saw_start_hi:  .res 1
music_v6saw_wait:      .res 1

music_tri_ptr_lo:      .res 1
music_tri_ptr_hi:      .res 1
music_tri_start_lo:    .res 1
music_tri_start_hi:    .res 1
music_tri_wait:        .res 1

music_noise_ptr_lo:    .res 1
music_noise_ptr_hi:    .res 1
music_noise_start_lo:  .res 1
music_noise_start_hi:  .res 1
music_noise_wait:      .res 1

audio_tmp:             .res 1
audio_tmp2:            .res 1
audio_ptr_tmp_lo:      .res 1
audio_ptr_tmp_hi:      .res 1

.segment "BSS"
audio_sfx_cooldown:    .res SFX_MAX_ID + 1

.segment "CODE"

.proc Audio_Init
    lda #$40
    sta $4017               ; disable frame IRQ, 4-step mode
    lda #$0F
    sta $4015               ; enable pulse/triangle/noise

    lda #$00
    sta VRC6_FREQ_CTRL      ; initialize VRC6 audio scale/halt register

    jsr Silence_ApuP1
    jsr Silence_ApuP2
    jsr Silence_Tri
    jsr Silence_Noise
    jsr Silence_V6P1
    jsr Silence_V6P2
    jsr Silence_V6Saw

    lda #$00
    sta audio_sfx_ptr_lo
    sta audio_sfx_ptr_hi
    sta audio_sfx_wait
    sta audio_sfx_priority
    sta audio_sfx_channels
    sta audio_sfx_active
    sta audio_sfx_id

    sta audio_music_id
    sta audio_music_active
    sta audio_music_flags

    sta music_v6p1_ptr_lo
    sta music_v6p1_ptr_hi
    sta music_v6p1_start_lo
    sta music_v6p1_start_hi
    sta music_v6p1_wait

    sta music_v6p2_ptr_lo
    sta music_v6p2_ptr_hi
    sta music_v6p2_start_lo
    sta music_v6p2_start_hi
    sta music_v6p2_wait

    sta music_v6saw_ptr_lo
    sta music_v6saw_ptr_hi
    sta music_v6saw_start_lo
    sta music_v6saw_start_hi
    sta music_v6saw_wait

    sta music_tri_ptr_lo
    sta music_tri_ptr_hi
    sta music_tri_start_lo
    sta music_tri_start_hi
    sta music_tri_wait

    sta music_noise_ptr_lo
    sta music_noise_ptr_hi
    sta music_noise_start_lo
    sta music_noise_start_hi
    sta music_noise_wait

    jsr Audio_ClearCooldowns
    rts
.endproc

.proc Audio_Update
    jsr Audio_TickCooldowns
    jsr Music_Update

    lda audio_sfx_active
    beq :+
    jsr Sfx_Update
:
    rts
.endproc

; A = SFX id
.proc Sfx_Play
    cmp #(SFX_MAX_ID + 1)
    bcs @done
    sta audio_tmp
    tax
    lda audio_sfx_cooldown, x
    bne @done

    jsr Sfx_IdToOffsetY

    lda SfxTable + SFX_DESC_PRIORITY, y
    cmp audio_sfx_priority
    bcc @done

    lda audio_tmp
    sta audio_sfx_id

    lda SfxTable + SFX_DESC_PRIORITY, y
    sta audio_sfx_priority
    lda SfxTable + SFX_DESC_CHANNELS, y
    sta audio_sfx_channels
    lda SfxTable + SFX_DESC_DATA_LO, y
    sta audio_sfx_ptr_lo
    lda SfxTable + SFX_DESC_DATA_HI, y
    sta audio_sfx_ptr_hi

    lda SfxTable + SFX_DESC_COOLDOWN, y
    ldx audio_sfx_id
    sta audio_sfx_cooldown, x

    lda #$00
    sta audio_sfx_wait
    lda #$01
    sta audio_sfx_active
@done:
    rts
.endproc

; A = music id
.proc Music_Play
    cmp #(MUS_MAX_ID + 1)
    bcs @done
    sta audio_music_id
    jsr Music_LoadTrack
@done:
    rts
.endproc

.proc Music_Stop
    lda #$00
    sta audio_music_active
    sta audio_music_id
    sta audio_music_flags

    sta music_v6p1_wait
    sta music_v6p2_wait
    sta music_v6saw_wait
    sta music_tri_wait
    sta music_noise_wait

    sta music_v6p1_ptr_lo
    sta music_v6p1_ptr_hi
    sta music_v6p2_ptr_lo
    sta music_v6p2_ptr_hi
    sta music_v6saw_ptr_lo
    sta music_v6saw_ptr_hi
    sta music_tri_ptr_lo
    sta music_tri_ptr_hi
    sta music_noise_ptr_lo
    sta music_noise_ptr_hi

    jsr Silence_V6P1
    jsr Silence_V6P2
    jsr Silence_V6Saw
    jsr Silence_Tri
    jsr Silence_Noise
    rts
.endproc

; ------------------------------------------------------------------
; Helpers
; ------------------------------------------------------------------
.proc Audio_ClearCooldowns
    lda #$00
    ldx #SFX_MAX_ID
@loop:
    sta audio_sfx_cooldown, x
    dex
    bpl @loop
    rts
.endproc

.proc Audio_TickCooldowns
    ldx #SFX_MAX_ID
@loop:
    lda audio_sfx_cooldown, x
    beq :+
    dec audio_sfx_cooldown, x
:
    dex
    bpl @loop
    rts
.endproc

.proc Sfx_IdToOffsetY
    lda audio_tmp
    asl a
    asl a
    clc
    adc audio_tmp
    tay
    rts
.endproc

.proc Music_IdToOffsetY
    lda audio_music_id
    asl a
    tay
    rts
.endproc

.proc Sfx_AdvancePtr
    clc
    adc audio_sfx_ptr_lo
    sta audio_sfx_ptr_lo
    bcc :+
    inc audio_sfx_ptr_hi
:
    rts
.endproc

.proc Music_AdvancePtr
    clc
    lda audio_ptr_tmp_lo
    adc #4
    sta audio_ptr_tmp_lo
    bcc :+
    inc audio_ptr_tmp_hi
:
    rts
.endproc

.proc Silence_ApuP1
    lda #APU_PULSE_SILENT
    sta $4000
    rts
.endproc

.proc Silence_ApuP2
    lda #APU_PULSE_SILENT
    sta $4004
    rts
.endproc

.proc Silence_Tri
    lda #TRI_SILENT
    sta $4008
    rts
.endproc

.proc Silence_Noise
    lda #NOISE_SILENT
    sta $400C
    rts
.endproc

.proc Silence_V6P1
    lda #$00
    sta VRC6_P1_CTRL
    sta VRC6_P1_HI
    rts
.endproc

.proc Silence_V6P2
    lda #$00
    sta VRC6_P2_CTRL
    sta VRC6_P2_HI
    rts
.endproc

.proc Silence_V6Saw
    lda #$00
    sta VRC6_SAW_CTRL
    sta VRC6_SAW_HI
    rts
.endproc

.proc Sfx_Stop
    lda audio_sfx_channels
    and #CH_APU_P1
    beq :+
    jsr Silence_ApuP1
:
    lda audio_sfx_channels
    and #CH_APU_P2
    beq :+
    jsr Silence_ApuP2
:
    lda audio_sfx_channels
    and #CH_TRI
    beq :+
    jsr Silence_Tri
:
    lda audio_sfx_channels
    and #CH_NOISE
    beq :+
    jsr Silence_Noise
:
    lda audio_sfx_channels
    and #CH_V6P1
    beq :+
    jsr Silence_V6P1
:
    lda audio_sfx_channels
    and #CH_V6P2
    beq :+
    jsr Silence_V6P2
:
    lda audio_sfx_channels
    and #CH_V6SAW
    beq :+
    jsr Silence_V6Saw
:
    lda #$00
    sta audio_sfx_active
    sta audio_sfx_priority
    sta audio_sfx_wait
    sta audio_sfx_id
    rts
.endproc

.proc Sfx_Update
    lda audio_sfx_wait
    beq @parse
    dec audio_sfx_wait
    rts

@parse:
@loop:
    ldy #$00
    lda (audio_sfx_ptr_lo), y
    cmp #CMD_END
    bne :+
    jmp @end
:
    cmp #CMD_WAIT
    bne :+
    jmp @wait
:
    cmp #CMD_APU_P1
    bne :+
    jmp @apu_p1
:
    cmp #CMD_APU_P2
    bne :+
    jmp @apu_p2
:
    cmp #CMD_TRI
    bne :+
    jmp @tri
:
    cmp #CMD_NOISE
    bne :+
    jmp @noise
:
    cmp #CMD_V6P1
    bne :+
    jmp @v6p1
:
    cmp #CMD_V6P2
    bne :+
    jmp @v6p2
:
    cmp #CMD_V6SAW
    bne :+
    jmp @v6saw
:
    jmp @end

@apu_p1:
    iny
    lda (audio_sfx_ptr_lo), y
    sta $4000
    iny
    lda (audio_sfx_ptr_lo), y
    sta $4002
    iny
    lda (audio_sfx_ptr_lo), y
    sta $4003
    lda #4
    jsr Sfx_AdvancePtr
    jmp @loop

@apu_p2:
    iny
    lda (audio_sfx_ptr_lo), y
    sta $4004
    iny
    lda (audio_sfx_ptr_lo), y
    sta $4006
    iny
    lda (audio_sfx_ptr_lo), y
    sta $4007
    lda #4
    jsr Sfx_AdvancePtr
    jmp @loop

@tri:
    iny
    lda (audio_sfx_ptr_lo), y
    sta $4008
    iny
    lda (audio_sfx_ptr_lo), y
    sta $400A
    iny
    lda (audio_sfx_ptr_lo), y
    sta $400B
    lda #4
    jsr Sfx_AdvancePtr
    jmp @loop

@noise:
    iny
    lda (audio_sfx_ptr_lo), y
    sta $400C
    iny
    lda (audio_sfx_ptr_lo), y
    sta $400E
    iny
    lda (audio_sfx_ptr_lo), y
    sta $400F
    lda #4
    jsr Sfx_AdvancePtr
    jmp @loop

@v6p1:
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_P1_CTRL
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_P1_LO
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_P1_HI
    lda #4
    jsr Sfx_AdvancePtr
    jmp @loop

@v6p2:
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_P2_CTRL
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_P2_LO
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_P2_HI
    lda #4
    jsr Sfx_AdvancePtr
    jmp @loop

@v6saw:
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_SAW_CTRL
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_SAW_LO
    iny
    lda (audio_sfx_ptr_lo), y
    sta VRC6_SAW_HI
    lda #4
    jsr Sfx_AdvancePtr
    jmp @loop

@wait:
    iny
    lda (audio_sfx_ptr_lo), y
    sta audio_sfx_wait
    lda #2
    jsr Sfx_AdvancePtr
    rts

@end:
    jmp Sfx_Stop
.endproc

.proc Music_LoadTrack
    jsr Music_IdToOffsetY
    lda MusicTable, y
    sta audio_ptr_tmp_lo
    iny
    lda MusicTable, y
    sta audio_ptr_tmp_hi

    ldy #$00
    lda (audio_ptr_tmp_lo), y
    sta audio_music_flags

    iny
    lda (audio_ptr_tmp_lo), y
    sta music_v6p1_ptr_lo
    sta music_v6p1_start_lo
    iny
    lda (audio_ptr_tmp_lo), y
    sta music_v6p1_ptr_hi
    sta music_v6p1_start_hi

    iny
    lda (audio_ptr_tmp_lo), y
    sta music_v6p2_ptr_lo
    sta music_v6p2_start_lo
    iny
    lda (audio_ptr_tmp_lo), y
    sta music_v6p2_ptr_hi
    sta music_v6p2_start_hi

    iny
    lda (audio_ptr_tmp_lo), y
    sta music_v6saw_ptr_lo
    sta music_v6saw_start_lo
    iny
    lda (audio_ptr_tmp_lo), y
    sta music_v6saw_ptr_hi
    sta music_v6saw_start_hi

    iny
    lda (audio_ptr_tmp_lo), y
    sta music_tri_ptr_lo
    sta music_tri_start_lo
    iny
    lda (audio_ptr_tmp_lo), y
    sta music_tri_ptr_hi
    sta music_tri_start_hi

    iny
    lda (audio_ptr_tmp_lo), y
    sta music_noise_ptr_lo
    sta music_noise_start_lo
    iny
    lda (audio_ptr_tmp_lo), y
    sta music_noise_ptr_hi
    sta music_noise_start_hi

    lda #$00
    sta music_v6p1_wait
    sta music_v6p2_wait
    sta music_v6saw_wait
    sta music_tri_wait
    sta music_noise_wait

    lda #$01
    sta audio_music_active
    rts
.endproc

.proc Music_Update
    lda audio_music_active
    bne :+
    rts
:
    jsr Music_UpdateV6P1
    jsr Music_UpdateV6P2
    jsr Music_UpdateV6Saw
    jsr Music_UpdateTri
    jsr Music_UpdateNoise

    lda audio_music_flags
    and #MUSF_LOOP
    bne @done

    lda music_v6p1_ptr_lo
    ora music_v6p1_ptr_hi
    ora music_v6p2_ptr_lo
    ora music_v6p2_ptr_hi
    ora music_v6saw_ptr_lo
    ora music_v6saw_ptr_hi
    ora music_tri_ptr_lo
    ora music_tri_ptr_hi
    ora music_noise_ptr_lo
    ora music_noise_ptr_hi
    bne @done
    jmp Music_Stop
@done:
    rts
.endproc

.proc Music_SetPtrToStart
    ; input:
    ;   audio_ptr_tmp_lo/hi = address of ptr_lo variable
    ; variable layout: ptr_lo, ptr_hi, start_lo, start_hi, wait
    ldy #2
    lda (audio_ptr_tmp_lo), y
    ldy #0
    sta (audio_ptr_tmp_lo), y
    ldy #3
    lda (audio_ptr_tmp_lo), y
    ldy #1
    sta (audio_ptr_tmp_lo), y
    rts
.endproc

.proc Music_ClearPtr
    ldy #0
    lda #$00
    sta (audio_ptr_tmp_lo), y
    iny
    sta (audio_ptr_tmp_lo), y
    iny
    iny
    iny
    sta (audio_ptr_tmp_lo), y ; wait = 0
    rts
.endproc

.proc Music_HandleEnd
    lda audio_music_flags
    and #MUSF_LOOP
    beq @clear
    jmp Music_SetPtrToStart
@clear:
    jmp Music_ClearPtr
.endproc

.proc Music_SetWaitMinusOne
    ; A = duration
    beq @zero
    sec
    sbc #1
@zero:
    ldy #4
    sta (audio_ptr_tmp_lo), y
    rts
.endproc

.proc Music_LoadCurrentWait
    ldy #4
    lda (audio_ptr_tmp_lo), y
    rts
.endproc

.proc Music_DecCurrentWait
    ldy #4
    lda (audio_ptr_tmp_lo), y
    beq @done
    sec
    sbc #1
    sta (audio_ptr_tmp_lo), y
@done:
    rts
.endproc

.proc Music_UpdateV6P1
    lda audio_sfx_active
    beq :+
    lda audio_sfx_channels
    and #CH_V6P1
    bne @done
:
    lda music_v6p1_ptr_lo
    ora music_v6p1_ptr_hi
    beq @done

    lda #<music_v6p1_ptr_lo
    sta audio_ptr_tmp_lo
    lda #>music_v6p1_ptr_lo
    sta audio_ptr_tmp_hi

    jsr Music_LoadCurrentWait
    beq @parse
    jsr Music_DecCurrentWait
    rts

@parse:
    ldy #0
    lda (music_v6p1_ptr_lo), y
    beq @end
    sta audio_tmp               ; duration
    iny
    lda (music_v6p1_ptr_lo), y
    cmp #MUS_REST_CTRL
    beq @rest
    sta VRC6_P1_CTRL
    iny
    lda (music_v6p1_ptr_lo), y
    sta VRC6_P1_LO
    iny
    lda (music_v6p1_ptr_lo), y
    sta VRC6_P1_HI
    jmp @advance
@rest:
    jsr Silence_V6P1
@advance:
    lda #4
    jsr Music_AdvanceV6P1Ptr
    lda audio_tmp
    jsr Music_SetWaitMinusOne
    rts
@end:
    jmp Music_HandleEnd
@done:
    rts
.endproc

.proc Music_AdvanceV6P1Ptr
    clc
    lda music_v6p1_ptr_lo
    adc #4
    sta music_v6p1_ptr_lo
    bcc :+
    inc music_v6p1_ptr_hi
:
    rts
.endproc

.proc Music_UpdateV6P2
    lda audio_sfx_active
    beq :+
    lda audio_sfx_channels
    and #CH_V6P2
    bne @done
:
    lda music_v6p2_ptr_lo
    ora music_v6p2_ptr_hi
    beq @done

    lda #<music_v6p2_ptr_lo
    sta audio_ptr_tmp_lo
    lda #>music_v6p2_ptr_lo
    sta audio_ptr_tmp_hi

    jsr Music_LoadCurrentWait
    beq @parse
    jsr Music_DecCurrentWait
    rts

@parse:
    ldy #0
    lda (music_v6p2_ptr_lo), y
    beq @end
    sta audio_tmp
    iny
    lda (music_v6p2_ptr_lo), y
    cmp #MUS_REST_CTRL
    beq @rest
    sta VRC6_P2_CTRL
    iny
    lda (music_v6p2_ptr_lo), y
    sta VRC6_P2_LO
    iny
    lda (music_v6p2_ptr_lo), y
    sta VRC6_P2_HI
    jmp @advance
@rest:
    jsr Silence_V6P2
@advance:
    lda #4
    jsr Music_AdvanceV6P2Ptr
    lda audio_tmp
    jsr Music_SetWaitMinusOne
    rts
@end:
    jmp Music_HandleEnd
@done:
    rts
.endproc

.proc Music_AdvanceV6P2Ptr
    clc
    lda music_v6p2_ptr_lo
    adc #4
    sta music_v6p2_ptr_lo
    bcc :+
    inc music_v6p2_ptr_hi
:
    rts
.endproc

.proc Music_UpdateV6Saw
    lda audio_sfx_active
    beq :+
    lda audio_sfx_channels
    and #CH_V6SAW
    bne @done
:
    lda music_v6saw_ptr_lo
    ora music_v6saw_ptr_hi
    beq @done

    lda #<music_v6saw_ptr_lo
    sta audio_ptr_tmp_lo
    lda #>music_v6saw_ptr_lo
    sta audio_ptr_tmp_hi

    jsr Music_LoadCurrentWait
    beq @parse
    jsr Music_DecCurrentWait
    rts

@parse:
    ldy #0
    lda (music_v6saw_ptr_lo), y
    beq @end
    sta audio_tmp
    iny
    lda (music_v6saw_ptr_lo), y
    cmp #MUS_REST_CTRL
    beq @rest
    sta VRC6_SAW_CTRL
    iny
    lda (music_v6saw_ptr_lo), y
    sta VRC6_SAW_LO
    iny
    lda (music_v6saw_ptr_lo), y
    sta VRC6_SAW_HI
    jmp @advance
@rest:
    jsr Silence_V6Saw
@advance:
    lda #4
    jsr Music_AdvanceV6SawPtr
    lda audio_tmp
    jsr Music_SetWaitMinusOne
    rts
@end:
    jmp Music_HandleEnd
@done:
    rts
.endproc

.proc Music_AdvanceV6SawPtr
    clc
    lda music_v6saw_ptr_lo
    adc #4
    sta music_v6saw_ptr_lo
    bcc :+
    inc music_v6saw_ptr_hi
:
    rts
.endproc

.proc Music_UpdateTri
    lda audio_sfx_active
    beq :+
    lda audio_sfx_channels
    and #CH_TRI
    bne @done
:
    lda music_tri_ptr_lo
    ora music_tri_ptr_hi
    beq @done

    lda #<music_tri_ptr_lo
    sta audio_ptr_tmp_lo
    lda #>music_tri_ptr_lo
    sta audio_ptr_tmp_hi

    jsr Music_LoadCurrentWait
    beq @parse
    jsr Music_DecCurrentWait
    rts

@parse:
    ldy #0
    lda (music_tri_ptr_lo), y
    beq @end
    sta audio_tmp
    iny
    lda (music_tri_ptr_lo), y
    cmp #MUS_REST_CTRL
    beq @rest
    sta $4008
    iny
    lda (music_tri_ptr_lo), y
    sta $400A
    iny
    lda (music_tri_ptr_lo), y
    sta $400B
    jmp @advance
@rest:
    jsr Silence_Tri
@advance:
    lda #4
    jsr Music_AdvanceTriPtr
    lda audio_tmp
    jsr Music_SetWaitMinusOne
    rts
@end:
    jmp Music_HandleEnd
@done:
    rts
.endproc

.proc Music_AdvanceTriPtr
    clc
    lda music_tri_ptr_lo
    adc #4
    sta music_tri_ptr_lo
    bcc :+
    inc music_tri_ptr_hi
:
    rts
.endproc

.proc Music_UpdateNoise
    lda audio_sfx_active
    beq :+
    lda audio_sfx_channels
    and #CH_NOISE
    bne @done
:
    lda music_noise_ptr_lo
    ora music_noise_ptr_hi
    beq @done

    lda #<music_noise_ptr_lo
    sta audio_ptr_tmp_lo
    lda #>music_noise_ptr_lo
    sta audio_ptr_tmp_hi

    jsr Music_LoadCurrentWait
    beq @parse
    jsr Music_DecCurrentWait
    rts

@parse:
    ldy #0
    lda (music_noise_ptr_lo), y
    beq @end
    sta audio_tmp
    iny
    lda (music_noise_ptr_lo), y
    cmp #MUS_REST_CTRL
    beq @rest
    sta $400C
    iny
    lda (music_noise_ptr_lo), y
    sta $400E
    iny
    lda (music_noise_ptr_lo), y
    sta $400F
    jmp @advance
@rest:
    jsr Silence_Noise
@advance:
    lda #4
    jsr Music_AdvanceNoisePtr
    lda audio_tmp
    jsr Music_SetWaitMinusOne
    rts
@end:
    jmp Music_HandleEnd
@done:
    rts
.endproc

.proc Music_AdvanceNoisePtr
    clc
    lda music_noise_ptr_lo
    adc #4
    sta music_noise_ptr_lo
    bcc :+
    inc music_noise_ptr_hi
:
    rts
.endproc
