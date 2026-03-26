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
frog_vel_y:   .res 1
on_ground:    .res 1
frog_facing:  .res 1
buttons:      .res 1
buttons_old:  .res 1
frame_counter: .res 1
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

    ; init frog position
    lda #120
    sta frog_x
    lda #180
    sta frog_y
    lda #$01
    sta on_ground
    lda #$00
    sta frog_facing
    lda #$00
    sta frog_vel_y

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

    ; clear attribute table so the terminal text uses the intended palette
    lda PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR

    ldx #$00
@attr_loop:
    lda #$00
    sta PPUDATA
    inx
    cpx #$40
    bne @attr_loop

    ; write text line 1: "HELLO WORLD!"
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$6A
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
    ; write text line 2: "WELCOME TO THE POND,"
    lda PPUSTATUS
    lda #$22
    sta PPUADDR
    lda #$06
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
    lda #$22
    sta PPUADDR
    lda #$65
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

; ------- Controller -------

read_controller:
    lda buttons
    sta buttons_old

    lda #$01
    sta JOYPAD1
    lda #$00
    sta JOYPAD1

    lda #$00
    sta buttons
    ldx #$08
@loop:
    lda JOYPAD1
    lsr
    rol buttons
    dex
    bne @loop
    rts

; ------- Frog Physics -------

update_frog:
    ; left
    lda buttons
    and #BUTTON_LEFT
    beq @right
    lda #$00
    sta frog_facing
    lda frog_x
    sec
    sbc #$02
    cmp #$08
    bcc @right
    sta frog_x

@right:
    lda buttons
    and #BUTTON_RIGHT
    beq @jump
    lda #$01
    sta frog_facing
    lda frog_x
    clc
    adc #$02
    cmp #240
    bcs @jump
    sta frog_x

@jump:
    lda buttons
    and #BUTTON_A
    beq @no_jump
    lda buttons_old
    and #BUTTON_A
    bne @no_jump
    lda on_ground
    beq @no_jump
    lda #$F8
    sta frog_vel_y
    lda #$00
    sta on_ground

@no_jump:
    lda on_ground
    bne @done

    ; apply velocity
    lda frog_y
    clc
    adc frog_vel_y
    sta frog_y

    ; gravity
    lda frog_vel_y
    clc
    adc #$01
    sta frog_vel_y

    ; ground collision
    lda frog_y
    cmp #180
    bcc @done
    lda #180
    sta frog_y
    lda #$00
    sta frog_vel_y
    lda #$01
    sta on_ground

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
    lda on_ground
    beq @airborne

    lda buttons
    and #$03
    beq @idle

    lda frame_counter
    lsr
    and #$03
    tax
    lda walk_pose_table,x
    jsr set_frog_pose
    rts

@idle:
    lda #FROG_IDLE_TL
    jsr set_frog_pose
    rts

@airborne:
    lda frame_counter
    and #$03
    beq @jump_prep

    cmp #$01
    beq @jump_up

    cmp #$02
    beq @land

    lda #FROG_JUMP_TL
    jsr set_frog_pose
    rts

@jump_prep:
    lda #FROG_CROUCH_TL
    jsr set_frog_pose
    rts

@jump_up:
    lda #FROG_JUMP_TL
    jsr set_frog_pose
    rts

@land:
    lda #FROG_LAND_TL
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
    .byte "HELLO WORLD!"
    .byte $FF

message2:
    .byte "WELCOME TO THE POND,"
    .byte $FF

message3:
    .byte "USE D-PAD & A TO JUMP!"
    .byte $FF

; ------- Palettes -------

palette:
    ; Background palettes
    .byte $0F,$19,$29,$39   ; BG0: terminal green text
    .byte $0F,$09,$19,$29   ; BG1: brighter title green
    .byte $0F,$00,$19,$29   ; BG2
    .byte $0F,$00,$10,$30   ; BG3

    ; Sprite palettes
    .byte $0F,$1A,$29,$39   ; SP0
    .byte $0F,$16,$27,$38   ; SP1: green frog
    .byte $0F,$00,$10,$20   ; SP2
    .byte $0F,$00,$10,$20   ; SP3

bob_table:
    .byte $00,$01,$02,$01

.segment "CHARS"
    .incbin "pond-font.chr"
