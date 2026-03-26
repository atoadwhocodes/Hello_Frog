; Hello World - Welcome to the Pond, Frog!
; Complete working version with correct font mapping
; Assemble with: ca65 hello-pond.asm -o hello-pond.o
;                ld65 hello-pond.o -C nes.cfg -o hello-pond.nes

.segment "HEADER"
    .byte "NES", $1A    ; iNES header identifier
    .byte $02           ; 2x 16KB PRG-ROM
    .byte $01           ; 1x 8KB CHR-ROM
    .byte $01           ; Mapper 0, vertical mirroring
    .byte $00           ; Mapper 0 upper bits
    .byte $00           ; No PRG-RAM
    .byte $00           ; NTSC
    .byte $00
    .byte $00, $00, $00, $00, $00

.segment "ZEROPAGE"
frog_x:       .res 1
frog_y:       .res 1
frog_vx:      .res 1
frog_vy:      .res 1
frog_on_ground: .res 1
frog_facing:  .res 1
frog_state:   .res 1
frog_anim_timer: .res 1
frog_splash_timer: .res 1
buttons_cur:  .res 1
buttons_prev: .res 1
buttons_pressed: .res 1
frame_counter: .res 1
bg_anim_tick: .res 1
water_anim_frame: .res 1
horizon_phase: .res 1
horizon_dir: .res 1
panel_shimmer: .res 1
bg_update_flags: .res 1
tmp_row_addr_lo: .res 1
tmp_row_addr_hi: .res 1
frog_draw_y:   .res 1
frog_tile_tl:  .res 1
frog_tile_tr:  .res 1
frog_tile_bl:  .res 1
frog_tile_br:  .res 1

.segment "VECTORS"
    .word nmi_handler
    .word reset_handler
    .word irq_handler

.segment "STARTUP"

.segment "CODE"

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

JOYPAD1   = $4016
JOYPAD2   = $4017

BUTTON_A      = $80
BUTTON_B      = $40
BUTTON_SELECT = $20
BUTTON_START  = $10
BUTTON_UP     = $08
BUTTON_DOWN   = $04
BUTTON_LEFT   = $02
BUTTON_RIGHT  = $01

STATE_IDLE   = $00
STATE_WALK   = $01
STATE_JUMP   = $02
STATE_FALL   = $03
STATE_SPLASH = $04

DOCK_LEFT   = $68
DOCK_RIGHT  = $90
DOCK_TOP    = $B0
WATER_Y     = $C0
SPAWN_X     = $78
SPAWN_Y     = $B0
GRAVITY     = $01
JUMP_VEL    = $F8
MOVE_SPEED   = $01
SPLASH_TIME  = $18

HORIZON_ROW_START = $00
HORIZON_ROW_COUNT = $04
PANEL_ROW_START   = $04
PANEL_ROW_COUNT   = $08
WATER_ROW_START   = $10
WATER_ROW_COUNT   = $06
DOCK_ROW_START    = $16
DOCK_ROW_COUNT    = $02
SUPPORT_ROW_START = $18
SUPPORT_ROW_COUNT = $06

WATER_ANIM_MASK   = $03
HORIZON_ANIM_MASK = $07
PANEL_ANIM_MASK   = $0F

BGUPD_HORIZON = %00000001
BGUPD_PANEL   = %00000010
BGUPD_WATER   = %00000100

FROG_IDLE_TL   = $7F
FROG_IDLE_TR   = $80
FROG_IDLE_BL   = $81
FROG_IDLE_BR   = $82
FROG_WALK1_TL  = $83
FROG_WALK1_TR  = $84
FROG_WALK1_BL  = $85
FROG_WALK1_BR  = $86
FROG_WALK2_TL  = $87
FROG_WALK2_TR  = $88
FROG_WALK2_BL  = $89
FROG_WALK2_BR  = $8A
FROG_WALK3_TL  = $8B
FROG_WALK3_TR  = $8C
FROG_WALK3_BL  = $8D
FROG_WALK3_BR  = $8E
FROG_WALK4_TL  = $8F
FROG_WALK4_TR  = $90
FROG_WALK4_BL  = $91
FROG_WALK4_BR  = $92
FROG_CROUCH_TL = $93
FROG_CROUCH_TR = $94
FROG_CROUCH_BL = $95
FROG_CROUCH_BR = $96
FROG_JUMP_TL   = $97
FROG_JUMP_TR   = $98
FROG_JUMP_BL   = $99
FROG_JUMP_BR   = $9A
FROG_LAND_TL   = $9B
FROG_LAND_TR   = $9C
FROG_LAND_BL   = $9D
FROG_LAND_BR   = $9E

TILE_BLANK           = $00
TILE_HORIZON_A       = $E0
TILE_HORIZON_B       = $E1
TILE_HORIZON_C       = $E2
TILE_HORIZON_D       = $E3
TILE_PANEL_DARK      = $E4
TILE_PANEL_LIGHT     = $E5
TILE_WATER_A         = $E6
TILE_WATER_B         = $E7
TILE_WATER_C         = $E8
TILE_DOCK            = $E9
TILE_DOCK_SUPPORT    = $EA

reset_handler:
    sei
    cld

    ; disable APU frame IRQ
    ldx #$40
    stx $4017

    ; init stack
    ldx #$FF
    txs

    ; disable NMI, rendering
    ldx #$00
    stx PPUCTRL
    stx PPUMASK
    stx $4010

; wait for vblank
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; clear RAM
    lda #$00
    ldx #$00
@clr:
    sta $0000,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne @clr

    ; clear OAM
    lda #$FF
    ldx #$00
@clr_oam:
    sta $0200,x
    inx
    bne @clr_oam

    ; wait for second vblank
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    jsr init_frog
    jsr init_bg_anim

    ; load palettes
    lda PPUSTATUS
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ldx #$00
@pal_loop:
    lda palette,x
    sta PPUDATA
    inx
    cpx #$20
    bne @pal_loop

    jsr draw_pondstation_bg

    ; write text line 1: "HELLO POND!"
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$CA
    sta PPUADDR

    ldx #$00
@msg1:
    lda message1,x
    cmp #$FF
    beq @msg1_done
    sta PPUDATA
    inx
    jmp @msg1

@msg1_done:
    ; write text line 2: "WELCOME TO THE POND."
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$E5
    sta PPUADDR

    ldx #$00
@msg2:
    lda message2,x
    cmp #$FF
    beq @msg2_done
    sta PPUDATA
    inx
    jmp @msg2

@msg2_done:
    ; write text line 3: "USE D-PAD & A TO JUMP!"
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$05
    sta PPUADDR

    ldx #$00
@msg3:
    lda message3,x
    cmp #$FF
    beq @msg3_done
    sta PPUDATA
    inx
    jmp @msg3

@msg3_done:
    ; enable NMI and rendering
    lda #%10000000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

main_loop:
    jmp main_loop

; ------- NMI -------

nmi_handler:
    pha
    txa
    pha
    tya
    pha

    inc frame_counter

    jsr read_controller
    jsr update_frog
    jsr draw_frog

    lda #$00
    sta OAMADDR
    lda #$02
    sta OAMDMA

    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    pla
    tay
    pla
    tax
    pla
    rti

irq_handler:
    rti

; ------- Background Scene -------

draw_pondstation_bg:
    ldx #$00
@horizon_rows:
    txa
    jsr set_ppu_addr_for_row
    txa
    and #$01
    jsr write_horizon_row_pattern
    inx
    cpx #HORIZON_ROW_COUNT
    bne @horizon_rows

    ldx #$00
@panel_rows:
    txa
    clc
    adc #PANEL_ROW_START
    jsr set_ppu_addr_for_row
    txa
    and #$01
    jsr write_panel_row_pattern
    inx
    cpx #PANEL_ROW_COUNT
    bne @panel_rows

    ldx #$00
@blank_rows:
    txa
    clc
    adc #$0C
    jsr set_ppu_addr_for_row
    jsr write_blank_row
    inx
    cpx #$04
    bne @blank_rows

    ldx #$00
@water_rows:
    txa
    clc
    adc #WATER_ROW_START
    jsr set_ppu_addr_for_row
    jsr write_water_row
    inx
    cpx #WATER_ROW_COUNT
    bne @water_rows

    ldx #$00
@dock_rows:
    txa
    clc
    adc #DOCK_ROW_START
    jsr set_ppu_addr_for_row
    jsr write_dock_row
    inx
    cpx #DOCK_ROW_COUNT
    bne @dock_rows

    ldx #$00
@dock_support_rows:
    txa
    clc
    adc #SUPPORT_ROW_START
    jsr set_ppu_addr_for_row
    jsr write_dock_support_row
    inx
    cpx #SUPPORT_ROW_COUNT
    bne @dock_support_rows

    ; Attribute layout: top, text, panel, water, dock.
    lda PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR

    ldx #$00
@attr_loop:
    lda attr_table,x
    sta PPUDATA
    inx
    cpx #$40
    bne @attr_loop
    rts

write_blank_row:
    ldy #$00
@blank_loop:
    lda blank_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @blank_loop
    rts

write_horizon_row_pattern:
    and #$03
    beq @row0
    cmp #$01
    beq @row1
    cmp #$02
    beq @row2
    jmp @row3

@row0:
    ldy #$00
@loop0:
    lda horizon_row_0,y
    sta PPUDATA
    iny
    cpy #$20
    bne @loop0
    rts

@row1:
    ldy #$00
@loop1:
    lda horizon_row_1,y
    sta PPUDATA
    iny
    cpy #$20
    bne @loop1
    rts

@row2:
    ldy #$00
@loop2:
    lda horizon_row_2,y
    sta PPUDATA
    iny
    cpy #$20
    bne @loop2
    rts

@row3:
    ldy #$00
@loop3:
    lda horizon_row_3,y
    sta PPUDATA
    iny
    cpy #$20
    bne @loop3
    rts

write_panel_row_pattern:
    and #$01
    beq @dark
    ldy #$00
@light_loop:
    lda panel_row_light,y
    sta PPUDATA
    iny
    cpy #$20
    bne @light_loop
    rts

@dark:
    ldy #$00
@dark_loop:
    lda panel_row_dark,y
    sta PPUDATA
    iny
    cpy #$20
    bne @dark_loop
    rts

write_water_row_pattern:
    and #$03
    beq @row0
    cmp #$01
    beq @row1
    cmp #$02
    beq @row2
    jmp @row0

@row0:
    ldy #$00
@water0_loop:
    lda water_row_0,y
    sta PPUDATA
    iny
    cpy #$20
    bne @water0_loop
    rts

@row1:
    ldy #$00
@water1_loop:
    lda water_row_1,y
    sta PPUDATA
    iny
    cpy #$20
    bne @water1_loop
    rts

@row2:
    ldy #$00
@water2_loop:
    lda water_row_2,y
    sta PPUDATA
    iny
    cpy #$20
    bne @water2_loop
    rts

write_dock_row:
    ldy #$00
@dock_loop:
    lda dock_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @dock_loop
    rts

write_dock_support_row:
    ldy #$00
@dock_support_loop:
    lda dock_support_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @dock_support_loop
    rts

set_ppu_addr_for_row:
    tay
    lda #$20
    sta tmp_row_addr_hi
    tya
    asl a
    asl a
    asl a
    asl a
    asl a
    sta tmp_row_addr_lo
    tya
    cmp #$08
    bcc @addr_done
    inc tmp_row_addr_hi
    cmp #$10
    bcc @addr_done
    inc tmp_row_addr_hi
    cmp #$18
    bcc @addr_done
    inc tmp_row_addr_hi
@addr_done:
    lda PPUSTATUS
    lda tmp_row_addr_hi
    sta PPUADDR
    lda tmp_row_addr_lo
    sta PPUADDR
    rts

set_ppu_addr_for_attr_row:
    tay
    lda #$23
    sta tmp_row_addr_hi
    tya
    asl a
    asl a
    asl a
    clc
    adc #$C0
    sta tmp_row_addr_lo
    lda PPUSTATUS
    lda tmp_row_addr_hi
    sta PPUADDR
    lda tmp_row_addr_lo
    sta PPUADDR
    rts

init_bg_anim:
    lda #$00
    sta bg_anim_tick
    sta water_anim_frame
    sta horizon_phase
    sta panel_shimmer
    sta bg_update_flags
    sta horizon_dir
    rts

update_bg_anim_state:
    inc bg_anim_tick

    lda bg_anim_tick
    and #WATER_ANIM_MASK
    bne @skip_water
    inc water_anim_frame
    lda bg_update_flags
    ora #BGUPD_WATER
    sta bg_update_flags
@skip_water:

    lda bg_anim_tick
    and #HORIZON_ANIM_MASK
    bne @skip_horizon

    lda horizon_dir
    beq @horizon_left
    inc horizon_phase
    jmp @flag_horizon

@horizon_left:
    dec horizon_phase

@flag_horizon:
    lda bg_update_flags
    ora #BGUPD_HORIZON
    sta bg_update_flags
@skip_horizon:

    lda bg_anim_tick
    and #PANEL_ANIM_MASK
    bne @done
    inc panel_shimmer
    lda bg_update_flags
    ora #BGUPD_PANEL
    sta bg_update_flags

@done:
    rts

run_bg_updates:
    lda bg_update_flags
    and #BGUPD_WATER
    beq @check_horizon
    lda bg_update_flags
    and #($FF ^ BGUPD_WATER)
    sta bg_update_flags
    jsr update_water_rows
    rts

@check_horizon:
    lda bg_update_flags
    and #BGUPD_HORIZON
    beq @check_panel
    lda bg_update_flags
    and #($FF ^ BGUPD_HORIZON)
    sta bg_update_flags
    jsr update_horizon_rows
    rts

@check_panel:
    lda bg_update_flags
    and #BGUPD_PANEL
    beq @done
    lda bg_update_flags
    and #($FF ^ BGUPD_PANEL)
    sta bg_update_flags
    jsr update_panel_rows

@done:
    rts

update_horizon_rows:
    ldx #$00
@row_loop:
    txa
    clc
    adc #HORIZON_ROW_START
    jsr set_ppu_addr_for_row
    txa
    clc
    adc horizon_phase
    and #$03
    jsr write_horizon_row_pattern
    inx
    cpx #HORIZON_ROW_COUNT
    bne @row_loop
    rts

update_panel_rows:
    ldx #$00
@row_loop:
    txa
    clc
    adc #PANEL_ROW_START
    jsr set_ppu_addr_for_row
    txa
    clc
    adc panel_shimmer
    and #$01
    jsr write_panel_row_pattern
    inx
    cpx #PANEL_ROW_COUNT
    bne @row_loop
    rts

update_water_rows:
    ldx #$00
@row_loop:
    txa
    clc
    adc #WATER_ROW_START
    jsr set_ppu_addr_for_row
    txa
    clc
    adc water_anim_frame
    and #$03
    jsr write_water_row_pattern
    inx
    cpx #WATER_ROW_COUNT
    bne @row_loop
    rts

write_panel_row:
    ldy #$00
@panel_loop:
    lda panel_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @panel_loop
    rts

write_water_row:
    ldy #$00
@water_loop:
    lda water_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @water_loop
    rts

blank_row:
    .repeat 32
        .byte TILE_BLANK
    .endrepeat

panel_row:
    .repeat 32
        .byte TILE_PANEL_DARK
    .endrepeat

water_row:
    .repeat 32
        .byte TILE_WATER_A
    .endrepeat

dock_row:
    .repeat 12
        .byte TILE_WATER_A
    .endrepeat
    .repeat 8
        .byte TILE_DOCK
    .endrepeat
    .repeat 12
        .byte TILE_WATER_B
    .endrepeat

dock_support_row:
    .repeat 12
        .byte TILE_WATER_B
    .endrepeat
    .repeat 8
        .byte TILE_DOCK_SUPPORT
    .endrepeat
    .repeat 12
        .byte TILE_WATER_C
    .endrepeat

horizon_row_0:
    .repeat 8
        .byte TILE_HORIZON_A,TILE_HORIZON_B,TILE_HORIZON_C,TILE_HORIZON_D
    .endrepeat

horizon_row_1:
    .repeat 8
        .byte TILE_HORIZON_B,TILE_HORIZON_C,TILE_HORIZON_D,TILE_HORIZON_A
    .endrepeat

horizon_row_2:
    .repeat 8
        .byte TILE_HORIZON_C,TILE_HORIZON_D,TILE_HORIZON_A,TILE_HORIZON_B
    .endrepeat

horizon_row_3:
    .repeat 8
        .byte TILE_HORIZON_D,TILE_HORIZON_A,TILE_HORIZON_B,TILE_HORIZON_C
    .endrepeat

panel_row_dark:
    .repeat 8
        .byte TILE_PANEL_DARK,TILE_PANEL_DARK,TILE_PANEL_LIGHT,TILE_PANEL_DARK
    .endrepeat

panel_row_light:
    .repeat 8
        .byte TILE_PANEL_LIGHT,TILE_PANEL_LIGHT,TILE_PANEL_DARK,TILE_PANEL_LIGHT
    .endrepeat

water_row_0:
    .repeat 8
        .byte TILE_WATER_A,TILE_WATER_B,TILE_WATER_A,TILE_WATER_B
    .endrepeat

water_row_1:
    .repeat 8
        .byte TILE_WATER_B,TILE_WATER_C,TILE_WATER_B,TILE_WATER_C
    .endrepeat

water_row_2:
    .repeat 8
        .byte TILE_WATER_C,TILE_WATER_A,TILE_WATER_C,TILE_WATER_A
    .endrepeat

attr_table:
    .repeat 32
        .byte $00
    .endrepeat
    .repeat 16
        .byte $AA
    .endrepeat
    .repeat 16
        .byte $FF
    .endrepeat

init_frog:
    lda #SPAWN_X
    sta frog_x
    lda #SPAWN_Y
    sta frog_y
    lda #$00
    sta frog_vx
    sta frog_vy
    sta frog_anim_timer
    sta frog_splash_timer
    lda #$01
    sta frog_facing
    lda #$01
    sta frog_on_ground
    lda #STATE_IDLE
    sta frog_state
    rts

start_splash:
    lda #STATE_SPLASH
    sta frog_state
    lda #SPLASH_TIME
    sta frog_splash_timer
    lda #$F8
    sta frog_y
    lda #$00
    sta frog_vx
    sta frog_vy
    sta frog_on_ground
    rts

; ------- Controller -------

read_controller:
    lda buttons_cur
    sta buttons_prev

    lda #$01
    sta JOYPAD1
    lda #$00
    sta JOYPAD1

    lda #$00
    sta buttons_cur
    ldx #$08
@loop:
    lda JOYPAD1
    lsr
    rol buttons_cur
    dex
    bne @loop

    lda buttons_prev
    eor #$FF
    and buttons_cur
    sta buttons_pressed
    rts

; ------- Frog Physics -------

update_frog:
    inc frog_anim_timer

    lda frog_state
    cmp #STATE_SPLASH
    bne @active

    lda frog_splash_timer
    beq @respawn
    dec frog_splash_timer
    beq @respawn
    jmp @done

@respawn:
    jsr init_frog
    rts

@active:
    lda #$00
    sta frog_vx

    lda buttons_cur
    and #BUTTON_LEFT
    beq @check_right
    lda #$00
    sta frog_facing
    sta horizon_dir
    lda #$FF
    sta frog_vx

@check_right:
    lda buttons_cur
    and #BUTTON_RIGHT
    beq @apply_move
    lda #$01
    sta frog_facing
    sta horizon_dir
    lda #$01
    sta frog_vx

@apply_move:
    lda frog_vx
    beq @jump_check
    bmi @move_left

@move_right:
    lda frog_x
    clc
    adc #MOVE_SPEED
    cmp #$F0
    bcs @jump_check
    sta frog_x
    jmp @jump_check

@move_left:
    lda frog_x
    sec
    sbc #MOVE_SPEED
    cmp #$08
    bcc @jump_check
    sta frog_x

@jump_check:
    lda buttons_pressed
    and #BUTTON_A
    beq @ground_check
    lda frog_on_ground
    beq @ground_check
    lda #JUMP_VEL
    sta frog_vy
    lda #$00
    sta frog_on_ground
    lda #STATE_JUMP
    sta frog_state

@ground_check:
    lda frog_on_ground
    beq @airborne

    lda frog_x
    cmp #DOCK_LEFT
    bcc @start_fall
    cmp #DOCK_RIGHT
    bcs @start_fall

    lda #DOCK_TOP
    sta frog_y
    lda #$00
    sta frog_vy

    lda buttons_cur
    and #$C0
    beq @idle
    lda #STATE_WALK
    sta frog_state
    rts

@idle:
    lda #STATE_IDLE
    sta frog_state
    rts

@start_fall:
    lda #$00
    sta frog_on_ground
    lda #STATE_FALL
    sta frog_state
    lda #$00
    sta frog_vy

@airborne:
    lda frog_vy
    clc
    adc #GRAVITY
    sta frog_vy

    lda frog_y
    clc
    adc frog_vy
    sta frog_y

    lda frog_vy
    bmi @air_jump
    lda #STATE_FALL
    sta frog_state
    jmp @landing_check

@air_jump:
    lda #STATE_JUMP
    sta frog_state

@landing_check:
    lda frog_x
    cmp #DOCK_LEFT
    bcc @water_check
    cmp #DOCK_RIGHT
    bcs @water_check
    lda frog_y
    cmp #DOCK_TOP
    bcc @water_check

    lda #DOCK_TOP
    sta frog_y
    lda #$00
    sta frog_vy
    lda #$01
    sta frog_on_ground

    lda buttons_cur
    and #$C0
    beq @land_idle
    lda #STATE_WALK
    sta frog_state
    rts

@land_idle:
    lda #STATE_IDLE
    sta frog_state
    rts

@water_check:
    lda frog_y
    cmp #WATER_Y
    bcc @done

    lda frog_x
    cmp #DOCK_LEFT
    bcc @splash
    cmp #DOCK_RIGHT
    bcs @splash
    jmp @done

@splash:
    jsr start_splash

@done:
    rts

; ------- Draw Frog -------

draw_frog:
    lda frog_y
    sta frog_draw_y

    jsr select_frog_pose

    lda frog_facing
    beq @face_right
    jmp @face_left

@face_left:
    ldy #$00

    ; mirrored top-left
    lda frog_draw_y
    sta $0200,y
    iny
    lda frog_tile_tr
    sta $0200,y
    iny
    lda #%01000001
    sta $0200,y
    iny
    lda frog_x
    sta $0200,y
    iny

    ; mirrored top-right
    lda frog_draw_y
    sta $0200,y
    iny
    lda frog_tile_tl
    sta $0200,y
    iny
    lda #%01000001
    sta $0200,y
    iny
    lda frog_x
    clc
    adc #8
    sta $0200,y
    iny

    ; mirrored bottom-left
    lda frog_draw_y
    clc
    adc #8
    sta $0200,y
    iny
    lda frog_tile_br
    sta $0200,y
    iny
    lda #%01000001
    sta $0200,y
    iny
    lda frog_x
    sta $0200,y
    iny

    ; mirrored bottom-right
    lda frog_draw_y
    clc
    adc #8
    sta $0200,y
    iny
    lda frog_tile_bl
    sta $0200,y
    iny
    lda #%01000001
    sta $0200,y
    iny
    lda frog_x
    clc
    adc #8
    sta $0200,y
    rts

@face_right:
    ldy #$00

    ; top-left
    lda frog_draw_y
    sta $0200,y
    iny
    lda frog_tile_tl
    sta $0200,y
    iny
    lda #%00000001
    sta $0200,y
    iny
    lda frog_x
    sta $0200,y
    iny

    ; top-right
    lda frog_draw_y
    sta $0200,y
    iny
    lda frog_tile_tr
    sta $0200,y
    iny
    lda #%00000001
    sta $0200,y
    iny
    lda frog_x
    clc
    adc #8
    sta $0200,y
    iny

    ; bottom-left
    lda frog_draw_y
    clc
    adc #8
    sta $0200,y
    iny
    lda frog_tile_bl
    sta $0200,y
    iny
    lda #%00000001
    sta $0200,y
    iny
    lda frog_x
    sta $0200,y
    iny

    ; bottom-right
    lda frog_draw_y
    clc
    adc #8
    sta $0200,y
    iny
    lda frog_tile_br
    sta $0200,y
    iny
    lda #%00000001
    sta $0200,y
    iny
    lda frog_x
    clc
    adc #8
    sta $0200,y

    rts

select_frog_pose:
    lda frog_state
    cmp #STATE_WALK
    beq @walk
    cmp #STATE_JUMP
    beq @jump
    cmp #STATE_FALL
    beq @fall
    cmp #STATE_SPLASH
    beq @splash

@idle:
    lda #FROG_IDLE_TL
    jsr set_frog_pose
    rts

@walk:
    lda frog_anim_timer
    lsr
    and #$03
    tax
    lda walk_pose_table,x
    jsr set_frog_pose
    rts

@jump:
    lda #FROG_JUMP_TL
    jsr set_frog_pose
    rts

@fall:
    lda #FROG_LAND_TL
    jsr set_frog_pose
    rts

@splash:
    lda #FROG_CROUCH_TL
    jsr set_frog_pose
    rts

set_frog_pose:
    sta frog_tile_tl
    clc
    adc #$01
    sta frog_tile_tr
    clc
    adc #$01
    sta frog_tile_bl
    clc
    adc #$01
    sta frog_tile_br
    rts

walk_pose_table:
    .byte FROG_WALK1_TL, FROG_WALK2_TL, FROG_WALK3_TL, FROG_WALK4_TL

; ------- Messages -------
; ASCII tile mapping: space=$20, !=$21, &= $26, ,=$2C, -=$2D

message1:
    .byte "HELLO POND!"
    .byte $FF

message2:
    .byte "WELCOME TO THE POND."
    .byte $FF

message3:
    .byte "USE D-PAD & A TO JUMP!"
    .byte $FF

; ------- Palettes -------

palette:
    ; Background palettes
    .byte $0F,$19,$29,$39   ; BG0: terminal green text
    .byte $0F,$09,$19,$29   ; BG1: horizon / panel green
    .byte $0F,$11,$21,$31   ; BG2: water blue
    .byte $0F,$06,$16,$26   ; BG3: dock brown

    ; Sprite palettes
    .byte $0F,$1A,$29,$39   ; SP0
    .byte $0F,$16,$27,$38   ; SP1: green frog
    .byte $0F,$00,$10,$20   ; SP2
    .byte $0F,$00,$10,$20   ; SP3

bob_table:
    .byte $00,$01,$02,$01

.segment "CHARS"
    .incbin "pond-font.chr"
