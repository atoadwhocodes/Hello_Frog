; Hello World - Welcome to the Pond, Frog!
; Complete working version with correct font mapping
; Assemble with: ca65 hello-pond.asm -o hello-pond.o
;                ld65 hello-pond.o -C nes.cfg -o hello-pond.nes

.segment "HEADER"
    .byte "NES", $1A    ; iNES header identifier
    .byte $04           ; 4x 16KB PRG-ROM
    .byte $04           ; 4x 8KB CHR-ROM
    .byte $80           ; Mapper 24 (VRC6a), mapper-controlled mirroring
    .byte $10           ; Mapper upper bits
    .byte $00           ; No PRG-RAM
    .byte $00           ; NTSC
    .byte $00
    .byte $00, $00, $00, $00, $00

.segment "ZEROPAGE"
frog_x:       .res 1
frog_y:       .res 1
frog_prev_y:  .res 1
frog_vx:      .res 1
frog_vy:      .res 1
frog_on_ground: .res 1
frog_facing:  .res 1
frog_state:   .res 1
frog_anim_timer: .res 1
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
frog_tile_base: .res 1
frog_oam_attr:  .res 1
frog_oam_index: .res 1
frog_row_index: .res 1
frog_col_index: .res 1
frog_draw_x:    .res 1
surface_probe_x: .res 1
move_sfx_cooldown: .res 1
move_sfx_phase: .res 1
idle_sfx_cooldown: .res 1

.segment "BSS"
frog_style:   .res 1
frog_palette: .res 1
frog_mode:    .res 1

.segment "VECTORS"
    .word nmi_handler
    .word reset_handler
    .word irq_handler

.segment "STARTUP"

.segment "CODE"

.include "audio/audio_ids.inc"

.import Audio_Init
.import Audio_Update
.import Sfx_Play
.import Music_Play

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014
VRC6_PRG_BANK_16K = $8000
VRC6_CHR_BANK_MODE = $B003
VRC6_PRG_BANK_8K = $C000
VRC6_CHR_R0 = $D000
VRC6_CHR_R1 = $D001
VRC6_CHR_R2 = $D002
VRC6_CHR_R3 = $D003
VRC6_CHR_R4 = $E000
VRC6_CHR_R5 = $E001
VRC6_CHR_R6 = $E002
VRC6_CHR_R7 = $E003
VRC6_IRQ_LATCH = $F000
VRC6_IRQ_CTRL = $F001
VRC6_IRQ_ACK = $F002

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
STATE_SWIM   = $04

MODE_TITLE    = $00
MODE_SELECT   = $01
MODE_PLAY     = $02

STYLE_GREEN    = $00
STYLE_TOPHAT   = $01
STYLE_COWBOY   = $02
STYLE_VIKING   = $03
STYLE_PIRATE   = $04
STYLE_CLOWN    = $05
STYLE_GLASSES  = $06
STYLE_COUNT    = $07

PALETTE_GREEN  = $00
PALETTE_BLUE   = $01
PALETTE_BROWN  = $02
PALETTE_PURPLE = $03
PALETTE_COUNT  = $04

SCREEN_LEFT  = $08
SCREEN_RIGHT = $E8
FROG_FEET_OFFSET = $0C
FROG_DRAW_Y_OFFSET = $10
SWIM_MOVE_SPEED = $01
SHORE_LEFT   = $C0
SHORE_ACCESS_LEFT = $B8
SHORE_RIGHT  = $F0
BANK_Y       = $68
SHORE_Y      = $B0
POND_WATER_Y = $C0
POND_SWIM_Y  = $B8
POND_SWIM_TOP_Y = $70
POND_SWIM_BOTTOM_Y = $D8
PLATFORM_Y   = $98
SPAWN_X     = $D8
SPAWN_Y     = SHORE_Y
GRAVITY     = $01
JUMP_VEL    = $F9
SWIM_JUMP_VEL = $F8
MOVE_SPEED   = $01

HORIZON_ROW_START = $00
HORIZON_ROW_COUNT = $04
PANEL_ROW_START   = $04
PANEL_ROW_COUNT   = $08
POND_ROW_START    = $10
POND_ROW_COUNT    = $08
FOLIAGE_ROW_START = $09
FOLIAGE_ROW_COUNT = $06
BANK_ROW          = $0F
PLATFORM_TOP_ROW  = $14
PLATFORM_ROW      = $15
SHORE_ROW_START   = $18
SHORE_ROW_COUNT   = $06

WATER_ANIM_MASK   = $03
HORIZON_ANIM_MASK = $07
PANEL_ANIM_MASK   = $0F

BGUPD_HORIZON = %00000001
BGUPD_PANEL   = %00000010
BGUPD_WATER   = %00000100
LILY_PAD_COUNT = $04

MOVE_SFX_COOLDOWN_FRAMES = $0A
IDLE_SFX_COOLDOWN_FRAMES = $30

SPRITE_BANK_BASE_START = $04

TILE_BLANK           = $00
TILE_WATER_A         = $01
TILE_WATER_B         = $02
TILE_LILY_TOP_L      = $03
TILE_LILY_TOP_R      = $04
TILE_LILY_BOTTOM_L   = $05
TILE_LILY_BOTTOM_R   = $06
; Imported shore art lives in $07-$0B.
TILE_SHORE_TOP_L     = $07
TILE_SHORE_TOP_R     = $08
TILE_SHORE_FILL_L    = $09
TILE_SHORE_FILL_R    = $0A
TILE_SHORE_EDGE      = $0B
TILE_CANOPY_TOP_L    = $0C
TILE_CANOPY_TOP_R    = $0D
TILE_CANOPY_FILL_L   = $0E
TILE_CANOPY_FILL_R   = $0F
TILE_TRUNK_L         = $10
TILE_TRUNK_R         = $11
TILE_BUSH_TOP_L      = $12
TILE_BUSH_TOP_R      = $13
TILE_BUSH_FILL_L     = $14
TILE_BUSH_FILL_R     = $15
TILE_BANK_TOP        = $16
TILE_LILY_TOP_MID    = $17
TILE_LILY_BOTTOM_MID = $18

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

    jsr init_vrc6_mapper
    lda #MODE_TITLE
    sta frog_mode
    lda #STYLE_GREEN
    sta frog_style
    lda #PALETTE_GREEN
    sta frog_palette
    jsr init_frog
    jsr init_bg_anim
    jsr Audio_Init

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
    jsr render_title_screen
    lda #MUS_TITLE
    jsr Music_Play

    ; enable NMI and use the second pattern table for sprites
    lda #%10001000
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
    inc frog_anim_timer

    jsr read_controller
    lda frog_mode
    cmp #MODE_TITLE
    beq @title_mode
    cmp #MODE_SELECT
    beq @select_mode
    jsr update_frog
    jsr draw_frog
    jmp @after_frog

@title_mode:
    jsr update_title_screen
    jsr draw_frog
    jmp @after_frog

@select_mode:
    jsr update_select_screen
    jsr draw_frog

@after_frog:
    jsr update_audio

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

render_game_text:
    ; write text line 1
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$87
    sta PPUADDR

    ldx #$00
@game_msg1:
    lda message1,x
    cmp #$FF
    beq @game_msg1_done
    sta PPUDATA
    inx
    jmp @game_msg1

@game_msg1_done:
    ; write text line 2
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$AB
    sta PPUADDR

    ldx #$00
@game_msg2:
    lda message2,x
    cmp #$FF
    beq @game_msg2_done
    sta PPUDATA
    inx
    jmp @game_msg2

@game_msg2_done:
    ; write text line 3
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$CA
    sta PPUADDR

    ldx #$00
@game_msg3:
    lda message3,x
    cmp #$FF
    beq @game_msg3_done
    sta PPUDATA
    inx
    jmp @game_msg3

@game_msg3_done:
    ; write text line 4
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$E6
    sta PPUADDR

    ldx #$00
@game_msg4:
    lda message4,x
    cmp #$FF
    beq @game_msg4_done
    sta PPUDATA
    inx
    jmp @game_msg4

@game_msg4_done:
    rts

render_title_screen:
    ; write text line 1: "HELLO FROG"
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$87
    sta PPUADDR

    ldx #$00
@title_msg1:
    lda title_message1,x
    cmp #$FF
    beq @title_msg1_done
    sta PPUDATA
    inx
    jmp @title_msg1

@title_msg1_done:
    ; write text line 2: "PRESS START"
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$A9
    sta PPUADDR

    ldx #$00
@title_msg2:
    lda title_message2,x
    cmp #$FF
    beq @title_msg2_done
    sta PPUDATA
    inx
    jmp @title_msg2

@title_msg2_done:
    ; write text line 3: "TO CHOOSE"
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$C6
    sta PPUADDR

    ldx #$00
@title_msg3:
    lda title_message3,x
    cmp #$FF
    beq @title_msg3_done
    sta PPUDATA
    inx
    jmp @title_msg3

@title_msg3_done:
    ; write text line 4: "OLD OR NEW"
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$E9
    sta PPUADDR

    ldx #$00
@title_msg4:
    lda title_message4,x
    cmp #$FF
    beq @title_msg4_done
    sta PPUDATA
    inx
    jmp @title_msg4

@title_msg4_done:
    rts

render_select_screen:
    ; write text line 1
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$87
    sta PPUADDR

    ldx #$00
@select_title:
    lda select_message1,x
    cmp #$FF
    beq @select_title_done
    sta PPUDATA
    inx
    jmp @select_title

@select_title_done:
    ; write text line 2
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$A9
    sta PPUADDR

    ldx #$00
@select_msg2:
    lda select_message2,x
    cmp #$FF
    beq @select_line2_done
    sta PPUDATA
    inx
    jmp @select_msg2

@select_line2_done:
    ; write selected hat line 3
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$C6
    sta PPUADDR

    jsr load_select_style_text
    jsr write_text_ptr

    ; write selected tint line 4
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$E9
    sta PPUADDR

    jsr load_select_tint_text
    jsr write_text_ptr

    rts

write_text_ptr:
    ldy #$00
@text_loop:
    lda (tmp_row_addr_lo),y
    cmp #$FF
    beq @done
    sta PPUDATA
    iny
    jmp @text_loop
@done:
    rts

load_select_style_text:
    lda frog_style
    asl a
    tax
    lda select_style_text_ptrs,x
    sta tmp_row_addr_lo
    lda select_style_text_ptrs+1,x
    sta tmp_row_addr_hi
    rts

load_select_tint_text:
    lda frog_palette
    asl a
    tax
    lda select_tint_text_ptrs,x
    sta tmp_row_addr_lo
    lda select_tint_text_ptrs+1,x
    sta tmp_row_addr_hi
    rts

draw_pondstation_bg:
    ldx #$00
@blank_all_rows:
    txa
    jsr set_ppu_addr_for_row
    jsr write_blank_row
    inx
    cpx #$1E
    bne @blank_all_rows

    ; Seed a simple playfield: blank backdrop, a floating platform, and a floor band.
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

    ; Build a playfield: foliage bank, pond water, four lily pads, and a safe shore on the right.
    lda #FOLIAGE_ROW_START
    jsr set_ppu_addr_for_row
    jsr write_foliage_canopy_top_row

    lda #(FOLIAGE_ROW_START + 1)
    jsr set_ppu_addr_for_row
    jsr write_foliage_canopy_fill_row

    lda #(FOLIAGE_ROW_START + 2)
    jsr set_ppu_addr_for_row
    jsr write_foliage_trunk_row

    lda #(FOLIAGE_ROW_START + 3)
    jsr set_ppu_addr_for_row
    jsr write_bush_top_row

    lda #(FOLIAGE_ROW_START + 4)
    jsr set_ppu_addr_for_row
    jsr write_bush_fill_row_a

    lda #(FOLIAGE_ROW_START + 5)
    jsr set_ppu_addr_for_row
    jsr write_bush_fill_row_b

    lda #BANK_ROW
    jsr set_ppu_addr_for_row
    jsr write_bank_row

    ldx #$00
@pond_rows:
    txa
    clc
    adc #POND_ROW_START
    jsr set_ppu_addr_for_row
    txa
    jsr write_water_row_pattern
    inx
    cpx #POND_ROW_COUNT
    bne @pond_rows

    lda #PLATFORM_TOP_ROW
    jsr set_ppu_addr_for_row
    jsr write_lily_pad_top_row

    lda #PLATFORM_ROW
    jsr set_ppu_addr_for_row
    jsr write_lily_pad_row

    lda #SHORE_ROW_START
    jsr set_ppu_addr_for_row
    jsr write_shore_top_row

    ldx #$01
@shore_rows:
    txa
    clc
    adc #SHORE_ROW_START
    jsr set_ppu_addr_for_row
    jsr write_shore_fill_row
    inx
    cpx #SHORE_ROW_COUNT
    bne @shore_rows
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
    jmp write_blank_row

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
    and #$01
    beq @water_a
    ldy #$00
@water_b_loop:
    lda pond_row_alt,y
    sta PPUDATA
    iny
    cpy #$20
    bne @water_b_loop
    rts

@water_a:
    jmp write_pond_row

write_pond_row:
    ldy #$00
@pond_loop:
    lda pond_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @pond_loop
    rts

write_lily_pad_top_row:
    ldy #$00
@lily_pad_top_loop:
    lda lily_pad_top_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @lily_pad_top_loop
    rts

write_lily_pad_row:
    ldy #$00
@lily_pad_loop:
    lda lily_pad_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @lily_pad_loop
    rts

write_foliage_canopy_top_row:
    ldy #$00
@foliage_canopy_top_loop:
    lda foliage_canopy_top_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @foliage_canopy_top_loop
    rts

write_foliage_canopy_fill_row:
    ldy #$00
@foliage_canopy_fill_loop:
    lda foliage_canopy_fill_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @foliage_canopy_fill_loop
    rts

write_foliage_trunk_row:
    ldy #$00
@foliage_trunk_loop:
    lda foliage_trunk_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @foliage_trunk_loop
    rts

write_bush_top_row:
    ldy #$00
@bush_top_loop:
    lda bush_top_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @bush_top_loop
    rts

write_bush_fill_row_a:
    ldy #$00
@bush_fill_a_loop:
    lda bush_fill_row_a,y
    sta PPUDATA
    iny
    cpy #$20
    bne @bush_fill_a_loop
    rts

write_bush_fill_row_b:
    ldy #$00
@bush_fill_b_loop:
    lda bush_fill_row_b,y
    sta PPUDATA
    iny
    cpy #$20
    bne @bush_fill_b_loop
    rts

write_bank_row:
    ldy #$00
@bank_loop:
    lda bank_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @bank_loop
    rts

write_shore_top_row:
    ldy #$00
@shore_top_loop:
    lda shore_top_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @shore_top_loop
    rts

write_shore_fill_row:
    ldy #$00
@shore_fill_loop:
    lda shore_fill_row,y
    sta PPUDATA
    iny
    cpy #$20
    bne @shore_fill_loop
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
    adc #POND_ROW_START
    cmp #PLATFORM_TOP_ROW
    beq @top_pad_row
    cmp #PLATFORM_ROW
    beq @bottom_pad_row
    jsr set_ppu_addr_for_row
    txa
    clc
    adc water_anim_frame
    and #$03
    jsr write_water_row_pattern
    jmp @next_row

@top_pad_row:
    jsr set_ppu_addr_for_row
    jsr write_lily_pad_top_row
    jmp @next_row

@bottom_pad_row:
    jsr set_ppu_addr_for_row
    jsr write_lily_pad_row

@next_row:
    inx
    cpx #POND_ROW_COUNT
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
    jmp write_pond_row

blank_row:
    .repeat 32
        .byte TILE_BLANK
    .endrepeat

pond_row:
    .repeat 16
        .byte TILE_WATER_A, TILE_WATER_B
    .endrepeat

pond_row_alt:
    .repeat 16
        .byte TILE_WATER_B, TILE_WATER_A
    .endrepeat

foliage_canopy_top_row:
    .repeat 16
        .byte TILE_CANOPY_TOP_L, TILE_CANOPY_TOP_R
    .endrepeat

foliage_canopy_fill_row:
    .repeat 16
        .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .endrepeat

foliage_trunk_row:
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_TRUNK_L, TILE_TRUNK_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_TRUNK_L, TILE_TRUNK_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R
    .byte TILE_CANOPY_FILL_L, TILE_CANOPY_FILL_R

bush_top_row:
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_TRUNK_L, TILE_TRUNK_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_TRUNK_L, TILE_TRUNK_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R
    .byte TILE_BUSH_TOP_L, TILE_BUSH_TOP_R

bush_fill_row_a:
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_TRUNK_L, TILE_TRUNK_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_TRUNK_L, TILE_TRUNK_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R
    .byte TILE_BUSH_FILL_L, TILE_BUSH_FILL_R

bush_fill_row_b:
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_TRUNK_L, TILE_TRUNK_R
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_TRUNK_L, TILE_TRUNK_R
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L
    .byte TILE_BUSH_FILL_R, TILE_BUSH_FILL_L

bank_row:
    .repeat 32
        .byte TILE_BANK_TOP
    .endrepeat

lily_pad_top_row:
    .repeat 4
        .byte TILE_WATER_A
    .endrepeat
    .byte TILE_LILY_TOP_L, TILE_LILY_TOP_MID, TILE_LILY_TOP_R
    .repeat 2
        .byte TILE_WATER_B
    .endrepeat
    .byte TILE_LILY_TOP_L, TILE_LILY_TOP_MID, TILE_LILY_TOP_R
    .repeat 2
        .byte TILE_WATER_A
    .endrepeat
    .byte TILE_LILY_TOP_L, TILE_LILY_TOP_MID, TILE_LILY_TOP_R
    .repeat 3
        .byte TILE_WATER_B
    .endrepeat
    .byte TILE_LILY_TOP_L, TILE_LILY_TOP_MID, TILE_LILY_TOP_R
    .repeat 9
        .byte TILE_WATER_A
    .endrepeat

lily_pad_row:
    .repeat 4
        .byte TILE_WATER_B
    .endrepeat
    .byte TILE_LILY_BOTTOM_L, TILE_LILY_BOTTOM_MID, TILE_LILY_BOTTOM_R
    .repeat 2
        .byte TILE_WATER_A
    .endrepeat
    .byte TILE_LILY_BOTTOM_L, TILE_LILY_BOTTOM_MID, TILE_LILY_BOTTOM_R
    .repeat 2
        .byte TILE_WATER_B
    .endrepeat
    .byte TILE_LILY_BOTTOM_L, TILE_LILY_BOTTOM_MID, TILE_LILY_BOTTOM_R
    .repeat 3
        .byte TILE_WATER_A
    .endrepeat
    .byte TILE_LILY_BOTTOM_L, TILE_LILY_BOTTOM_MID, TILE_LILY_BOTTOM_R
    .repeat 9
        .byte TILE_WATER_B
    .endrepeat

lily_pad_left_bounds:
    .byte $20,$48,$70,$A0

lily_pad_right_bounds:
    .byte $38,$60,$88,$B8

shore_top_row:
    .repeat 12
        .byte TILE_WATER_A, TILE_WATER_B
    .endrepeat
    .byte TILE_SHORE_EDGE
    .byte TILE_SHORE_TOP_L, TILE_SHORE_TOP_R
    .byte TILE_SHORE_TOP_L, TILE_SHORE_TOP_R
    .byte TILE_SHORE_TOP_L, TILE_SHORE_TOP_R
    .byte TILE_SHORE_TOP_L

shore_fill_row:
    .repeat 12
        .byte TILE_WATER_B, TILE_WATER_A
    .endrepeat
    .byte TILE_SHORE_EDGE
    .byte TILE_SHORE_FILL_L, TILE_SHORE_FILL_R
    .byte TILE_SHORE_FILL_L, TILE_SHORE_FILL_R
    .byte TILE_SHORE_FILL_L, TILE_SHORE_FILL_R
    .byte TILE_SHORE_FILL_L

panel_row:
    .repeat 32
        .byte TILE_BLANK
    .endrepeat

panel_row_dark:
    .repeat 32
        .byte TILE_BLANK
    .endrepeat

panel_row_light:
    .repeat 32
        .byte TILE_BLANK
    .endrepeat

attr_table:
    .repeat 16
        .byte $00
    .endrepeat
    .repeat 16
        .byte $AA
    .endrepeat
    .repeat 8
        .byte $55
    .endrepeat
    .repeat 6
        .byte $55
    .endrepeat
    .repeat 2
        .byte $FF
    .endrepeat
    .repeat 6
        .byte $55
    .endrepeat
    .repeat 2
        .byte $FF
    .endrepeat
    .repeat 6
        .byte $55
    .endrepeat
    .repeat 2
        .byte $FF
    .endrepeat

init_frog:
    jsr apply_frog_style_banks
    lda #SPAWN_X
    sta frog_x
    lda #SPAWN_Y
    sta frog_y
    sta frog_prev_y
    lda #$00
    sta frog_vx
    sta frog_vy
    sta frog_anim_timer
    sta move_sfx_cooldown
    sta move_sfx_phase
    sta idle_sfx_cooldown
    lda #$01
    sta frog_facing
    lda #$01
    sta frog_on_ground
    lda #STATE_IDLE
    sta frog_state
    rts

enter_swim_mode:
    lda #STATE_SWIM
    sta frog_state
    lda #$00
    sta frog_vx
    sta frog_vy
    sta frog_on_ground
    rts

start_swim:
    jsr enter_swim_mode
    lda #POND_SWIM_Y
    sta frog_y
    sta frog_prev_y
    jsr play_splash_sfx
    rts

update_select_screen:
    lda #STATE_IDLE
    sta frog_state

    lda buttons_pressed
    and #BUTTON_LEFT
    beq @check_right
    lda frog_style
    bne @style_left_wrap_done
    lda #STYLE_COUNT
@style_left_wrap_done:
    sec
    sbc #$01
    sta frog_style
    jsr init_frog
    jsr render_select_screen
    jsr play_ui_move_sfx
    rts

@check_right:
    lda buttons_pressed
    and #BUTTON_RIGHT
    beq @check_up
    lda frog_style
    clc
    adc #$01
    cmp #STYLE_COUNT
    bcc @style_right_store
    lda #STYLE_GREEN
@style_right_store:
    sta frog_style
    jsr init_frog
    jsr render_select_screen
    jsr play_ui_move_sfx
    rts

@check_up:
    lda buttons_pressed
    and #BUTTON_UP
    beq @check_down
    lda frog_palette
    bne @tint_up_wrap_done
    lda #PALETTE_COUNT
@tint_up_wrap_done:
    sec
    sbc #$01
    sta frog_palette
    jsr render_select_screen
    jsr play_ui_move_sfx
    rts

@check_down:
    lda buttons_pressed
    and #BUTTON_DOWN
    beq @check_start
    lda frog_palette
    clc
    adc #$01
    cmp #PALETTE_COUNT
    bcc @tint_down_store
    lda #PALETTE_GREEN
@tint_down_store:
    sta frog_palette
    jsr render_select_screen
    jsr play_ui_move_sfx
    rts

@check_start:
    lda buttons_pressed
    and #BUTTON_START
    beq @done
    lda #MODE_PLAY
    sta frog_mode
    jsr init_frog
    jsr render_game_text
    lda #MUS_PLAY_A
    jsr Music_Play
    jsr play_ui_confirm_sfx

@done:
    rts

update_title_screen:
    lda #STATE_IDLE
    sta frog_state

    lda buttons_pressed
    and #BUTTON_START
    beq @done
    lda #MODE_SELECT
    sta frog_mode
    jsr init_frog
    jsr render_select_screen
    lda #MUS_SELECT
    jsr Music_Play
    jsr play_ui_start_sfx

@done:
    rts

; ------- Audio -------

init_vrc6_mapper:
    lda #$00
    sta VRC6_IRQ_CTRL
    sta VRC6_IRQ_ACK
    sta VRC6_IRQ_LATCH
    sta VRC6_PRG_BANK_16K
    lda #$06
    sta VRC6_PRG_BANK_8K

    ; Mode 0 with vertical mirroring and direct 1 KB CHR banking.
    lda #$20
    sta VRC6_CHR_BANK_MODE

    lda #$00
    sta VRC6_CHR_R0
    lda #$01
    sta VRC6_CHR_R1
    lda #$02
    sta VRC6_CHR_R2
    lda #$03
    sta VRC6_CHR_R3
    rts

apply_frog_style_banks:
    lda frog_style
    asl a
    asl a
    clc
    adc #SPRITE_BANK_BASE_START
    sta VRC6_CHR_R4
    clc
    adc #$01
    sta VRC6_CHR_R5
    clc
    adc #$01
    sta VRC6_CHR_R6
    clc
    adc #$01
    sta VRC6_CHR_R7
    rts

update_audio:
    lda move_sfx_cooldown
    beq @skip_move_cd
    dec move_sfx_cooldown
@skip_move_cd:
    lda idle_sfx_cooldown
    beq @skip_idle_cd
    dec idle_sfx_cooldown
@skip_idle_cd:
    jsr Audio_Update
    rts

play_ui_move_sfx:
    lda #SFX_UI_MOVE
    jsr Sfx_Play
    rts

play_ui_confirm_sfx:
    lda #SFX_UI_CONFIRM
    jsr Sfx_Play
    rts

play_ui_start_sfx:
    lda #SFX_UI_START
    jsr Sfx_Play
    rts

play_ribbit_sfx:
    lda #SFX_FROG_RIBBIT_SHORT
    jsr Sfx_Play
    rts

play_jump_sfx:
    lda #SFX_FROG_JUMP_SHORT
    jsr Sfx_Play
    rts

play_land_sfx:
    lda #SFX_FROG_LAND_SOFT
    jsr Sfx_Play
    rts

play_pad_land_sfx:
    lda #SFX_FROG_PAD_LAND
    jsr Sfx_Play
    rts

play_shore_up_sfx:
    lda #SFX_FROG_SHORE_UP
    jsr Sfx_Play
    rts

play_splash_sfx:
    lda #SFX_FROG_SPLASH_IN
    jsr Sfx_Play
    rts

play_walk_sfx:
    lda move_sfx_cooldown
    bne @done
    lda #MOVE_SFX_COOLDOWN_FRAMES
    sta move_sfx_cooldown

    lda move_sfx_phase
    and #$03
    beq @walk1
    cmp #$01
    beq @walk2
    cmp #$02
    beq @walk3

@walk2_again:
    lda #SFX_FROG_WALK_2
    bne @play

@walk1:
    lda #SFX_FROG_WALK_1
    bne @play

@walk2:
    lda #SFX_FROG_WALK_2
    bne @play

@walk3:
    lda #SFX_FROG_WALK_3

@play:
    jsr Sfx_Play
    inc move_sfx_phase

@done:
    rts

play_swim_sfx:
    lda move_sfx_cooldown
    bne @done
    lda #MOVE_SFX_COOLDOWN_FRAMES
    sta move_sfx_cooldown

    lda move_sfx_phase
    and #$01
    beq @swim1
    lda #SFX_FROG_SWIM_2
    bne @play

@swim1:
    lda #SFX_FROG_SWIM_1

@play:
    jsr Sfx_Play
    inc move_sfx_phase

@done:
    rts

play_idle_sfx:
    lda idle_sfx_cooldown
    bne @done
    lda #IDLE_SFX_COOLDOWN_FRAMES
    sta idle_sfx_cooldown
    lda #SFX_FROG_IDLE_SHUFFLE
    jsr Sfx_Play

@done:
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

cache_frog_feet_x:
    lda frog_x
    clc
    adc #FROG_FEET_OFFSET
    sta surface_probe_x
    rts

is_over_lily_pad:
    ldy #$00
@pad_loop:
    lda surface_probe_x
    cmp lily_pad_left_bounds,y
    bcc @next_pad
    cmp lily_pad_right_bounds,y
    bcc @hit

@next_pad:
    iny
    cpy #LILY_PAD_COUNT
    bne @pad_loop
    clc
    rts

@hit:
    sec
    rts

update_swim:
    lda buttons_pressed
    and #BUTTON_B
    beq @clear_motion
    jsr play_ribbit_sfx

@clear_motion:
    lda #$00
    sta frog_vx
    sta frog_vy
    sta frog_on_ground

    lda buttons_cur
    and #BUTTON_LEFT
    beq @check_right
    lda #$00
    sta frog_facing
    lda frog_x
    sec
    sbc #SWIM_MOVE_SPEED
    cmp #SCREEN_LEFT
    bcc @clamp_left
    sta frog_x
    jmp @check_right

@clamp_left:
    lda #SCREEN_LEFT
    sta frog_x

@check_right:
    lda buttons_cur
    and #BUTTON_RIGHT
    beq @check_up
    lda #$01
    sta frog_facing
    lda frog_x
    clc
    adc #SWIM_MOVE_SPEED
    cmp #SCREEN_RIGHT
    bcc @store_right
    lda #SCREEN_RIGHT

@store_right:
    sta frog_x

@check_up:
    lda buttons_cur
    and #BUTTON_UP
    beq @check_down
    lda frog_y
    sec
    sbc #SWIM_MOVE_SPEED
    cmp #POND_SWIM_TOP_Y
    bcs @store_up
    lda #POND_SWIM_TOP_Y

@store_up:
    sta frog_y

@check_down:
    lda buttons_cur
    and #BUTTON_DOWN
    beq @check_shore
    lda frog_y
    clc
    adc #SWIM_MOVE_SPEED
    cmp #POND_SWIM_BOTTOM_Y
    bcc @store_down
    lda #POND_SWIM_BOTTOM_Y

@store_down:
    sta frog_y

@check_shore:
    jsr cache_frog_feet_x
    lda surface_probe_x
    cmp #SHORE_ACCESS_LEFT
    bcc @check_bank
    lda buttons_cur
    and #(BUTTON_RIGHT | BUTTON_UP)
    beq @check_bank

    lda #SHORE_Y
    sta frog_y
    sta frog_prev_y
    lda #$00
    sta frog_vy
    lda #$01
    sta frog_on_ground
    jsr play_shore_up_sfx

    lda buttons_cur
    and #(BUTTON_LEFT | BUTTON_RIGHT)
    beq @shore_idle
    lda #STATE_WALK
    sta frog_state
    rts

@shore_idle:
    lda #STATE_IDLE
    sta frog_state
    jsr play_idle_sfx
    rts

@check_bank:
    lda buttons_cur
    and #BUTTON_UP
    beq @jump_check
    lda frog_y
    cmp #POND_SWIM_TOP_Y
    bne @jump_check

    lda #BANK_Y
    sta frog_y
    sta frog_prev_y
    lda #$00
    sta frog_vy
    lda #$01
    sta frog_on_ground
    jsr play_shore_up_sfx

    lda buttons_cur
    and #(BUTTON_LEFT | BUTTON_RIGHT)
    beq @bank_idle
    lda #STATE_WALK
    sta frog_state
    rts

@bank_idle:
    lda #STATE_IDLE
    sta frog_state
    jsr play_idle_sfx
    rts

@jump_check:
    lda frog_y
    sta frog_prev_y
    lda buttons_pressed
    and #BUTTON_A
    beq @move_check
    lda #SWIM_JUMP_VEL
    sta frog_vy
    lda #STATE_JUMP
    sta frog_state
    jsr play_jump_sfx
    rts

@move_check:
    lda buttons_cur
    and #(BUTTON_LEFT | BUTTON_RIGHT | BUTTON_UP | BUTTON_DOWN)
    beq @done
    jsr play_swim_sfx

@done:
    rts

; ------- Frog Physics -------

update_frog:
    lda frog_state
    cmp #STATE_SWIM
    bne @active

    jsr update_swim
    rts

@active:
    lda buttons_pressed
    and #BUTTON_B
    beq @clear_vx
    jsr play_ribbit_sfx

@clear_vx:
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
    cmp #SCREEN_RIGHT
    bcs @jump_check
    sta frog_x
    jmp @jump_check

@move_left:
    lda frog_x
    sec
    sbc #MOVE_SPEED
    cmp #SCREEN_LEFT
    bcc @jump_check
    sta frog_x

@jump_check:
    lda buttons_pressed
    and #BUTTON_A
    beq @ground_check
    lda frog_on_ground
    beq @ground_check
    lda frog_y
    cmp #PLATFORM_Y
    bne @start_jump
    lda buttons_cur
    and #BUTTON_DOWN
    beq @start_jump
    lda #$00
    sta frog_on_ground
    lda #STATE_FALL
    sta frog_state
    lda #$00
    sta frog_vy
    lda #SFX_FROG_DROP_THROUGH
    jsr Sfx_Play
    inc frog_y
    jmp @ground_check

@start_jump:
    lda #JUMP_VEL
    sta frog_vy
    lda #$00
    sta frog_on_ground
    lda #STATE_JUMP
    sta frog_state
    jsr play_jump_sfx

@ground_check:
    lda frog_on_ground
    bne :+
    jmp @airborne
:

    lda buttons_cur
    and #BUTTON_DOWN
    beq @surface_probe
    lda frog_y
    cmp #SHORE_Y
    beq @enter_shore_swim
    cmp #BANK_Y
    bne @surface_probe
    jsr enter_swim_mode
    lda #POND_SWIM_TOP_Y
    sta frog_y
    sta frog_prev_y
    jsr play_splash_sfx
    rts

@enter_shore_swim:
    jsr enter_swim_mode
    lda #POND_SWIM_Y
    sta frog_y
    sta frog_prev_y
    jsr play_splash_sfx
    rts

@surface_probe:
    lda frog_y
    cmp #BANK_Y
    beq @bank_surface_check
    cmp #PLATFORM_Y
    beq @platform_surface_check

@shore_surface_check:
    jsr cache_frog_feet_x
    lda surface_probe_x
    cmp #SHORE_ACCESS_LEFT
    bcc @start_fall

    lda #SHORE_Y
    sta frog_y
    jmp @surface_state

@bank_surface_check:
    lda #BANK_Y
    sta frog_y
    jmp @surface_state

@platform_surface_check:
    jsr cache_frog_feet_x
    jsr is_over_lily_pad
    bcc @start_fall

    lda #PLATFORM_Y
    sta frog_y
    jmp @surface_state

@surface_state:
    lda #$00
    sta frog_vy

    lda buttons_cur
    and #(BUTTON_LEFT | BUTTON_RIGHT)
    beq @idle
    lda #STATE_WALK
    sta frog_state
    jsr play_walk_sfx
    rts

@idle:
    lda #STATE_IDLE
    sta frog_state
    jsr play_idle_sfx
    rts

@start_fall:
    lda #$00
    sta frog_on_ground
    lda #STATE_FALL
    sta frog_state
    lda #$00
    sta frog_vy

@airborne:
    lda frog_y
    sta frog_prev_y

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
    jmp @fall_limit_check

@landing_check:
    lda frog_prev_y
    cmp #BANK_Y
    bcs @pad_landing_check
    lda frog_y
    cmp #BANK_Y
    bcc @pad_landing_check

    lda #BANK_Y
    jmp @land_on_surface

@pad_landing_check:
    jsr cache_frog_feet_x
    jsr is_over_lily_pad
    bcc @ground_landing_check
    lda frog_prev_y
    cmp #PLATFORM_Y
    bcs @ground_landing_check
    lda frog_y
    cmp #PLATFORM_Y
    bcc @ground_landing_check

    lda #PLATFORM_Y
    jmp @land_on_pad

@ground_landing_check:
    lda surface_probe_x
    cmp #SHORE_ACCESS_LEFT
    bcc @fall_limit_check
    lda frog_prev_y
    cmp #SHORE_Y
    bcs @fall_limit_check
    lda frog_y
    cmp #SHORE_Y
    bcc @fall_limit_check

    lda #SHORE_Y

@land_on_surface:
    sta frog_y
    lda #$00
    sta frog_vy
    lda #$01
    sta frog_on_ground
    jsr play_land_sfx

    lda buttons_cur
    and #(BUTTON_LEFT | BUTTON_RIGHT)
    beq @land_idle
    lda #STATE_WALK
    sta frog_state
    rts

@land_idle:
    lda #STATE_IDLE
    sta frog_state
    rts

@land_on_pad:
    sta frog_y
    lda #$00
    sta frog_vy
    lda #$01
    sta frog_on_ground
    jsr play_pad_land_sfx

    lda buttons_cur
    and #(BUTTON_LEFT | BUTTON_RIGHT)
    beq @pad_idle
    lda #STATE_WALK
    sta frog_state
    rts

@pad_idle:
    lda #STATE_IDLE
    sta frog_state
    rts

@fall_limit_check:
    lda frog_y
    cmp #POND_WATER_Y
    bcc @done

    jsr start_swim

@done:
    rts

; ------- Draw Frog -------

draw_frog:
    lda frog_y
    sec
    sbc #FROG_DRAW_Y_OFFSET
    sta frog_draw_y

    jsr select_frog_pose

    lda frog_palette
    sta frog_oam_attr
    lda frog_facing
    bne @attr_ready
    lda frog_oam_attr
    ora #$40
    sta frog_oam_attr

@attr_ready:
    lda #$00
    sta frog_oam_index
    sta frog_row_index

@row_loop:
    ldx frog_row_index
    lda frog_draw_y
    clc
    adc sprite_row_pixel_offsets,x
    sta tmp_row_addr_lo

    lda #$00
    sta frog_col_index

@col_loop:
    ldx frog_col_index
    lda frog_x
    clc
    adc sprite_col_pixel_offsets,x
    sta frog_draw_x

    ldx frog_row_index
    lda frog_tile_base
    clc
    adc sprite_row_tile_offsets,x
    ldx frog_facing
    bne @right_tile
    ldx frog_col_index
    clc
    adc sprite_col_order_left,x
    jmp @tile_ready

@right_tile:
    ldx frog_col_index
    clc
    adc sprite_col_order_right,x

@tile_ready:
    sta tmp_row_addr_hi

    ldy frog_oam_index
    lda tmp_row_addr_lo
    sta $0200,y
    iny
    lda tmp_row_addr_hi
    sta $0200,y
    iny
    lda frog_oam_attr
    sta $0200,y
    iny
    lda frog_draw_x
    sta $0200,y
    iny
    sty frog_oam_index

    inc frog_col_index
    lda frog_col_index
    cmp #$03
    bne @col_loop

    inc frog_row_index
    lda frog_row_index
    cmp #$04
    bne @row_loop

    rts

select_frog_pose:
    lda frog_anim_timer
    lsr
    lsr
    and #$07
    tax

    lda frog_state
    cmp #STATE_WALK
    beq @walk
    cmp #STATE_JUMP
    beq @jump
    cmp #STATE_FALL
    beq @fall
    cmp #STATE_SWIM
    beq @swim

@idle:
    lda toad_idle_frame_table,x
    jsr set_frog_pose
    rts

@walk:
    lda toad_walk_frame_table,x
    jsr set_frog_pose
    rts

@jump:
    lda toad_jump_frame_table,x
    jsr set_frog_pose
    rts

@fall:
    lda toad_fall_frame_table,x
    jsr set_frog_pose
    rts

@swim:
    lda buttons_cur
    and #(BUTTON_LEFT | BUTTON_RIGHT | BUTTON_UP | BUTTON_DOWN)
    beq @swim_idle
    lda toad_swim_frame_table,x
    jsr set_frog_pose
    rts

@swim_idle:
    lda #$C0
    jsr set_frog_pose
    rts

set_frog_pose:
    sta frog_tile_base
    rts

toad_idle_frame_table:
    .byte $00,$00,$00,$00,$00,$00,$00,$00

toad_walk_frame_table:
    .byte $48,$54,$60,$6C,$78,$6C,$60,$54

toad_jump_frame_table:
    .byte $84,$90,$9C,$9C,$9C,$9C,$90,$84

toad_fall_frame_table:
    .byte $B4,$A8,$9C,$90,$84,$90,$9C,$A8

toad_swim_frame_table:
    .byte $C0,$CC,$D8,$E4,$D8,$CC,$C0,$CC

sprite_row_pixel_offsets:
    .byte $00,$08,$10,$18

sprite_row_tile_offsets:
    .byte $00,$03,$06,$09

sprite_col_pixel_offsets:
    .byte $00,$08,$10

sprite_col_order_right:
    .byte $00,$01,$02

sprite_col_order_left:
    .byte $02,$01,$00

; ------- Messages -------
; ASCII tile mapping: space=$20, !=$21, &= $26, ,=$2C, -=$2D

select_message1:
    .byte "WELCOME TO THE POND "
    .byte $FF

select_message2:
    .byte "LR HAT UD TINT START"
    .byte $FF

select_style_text_ptrs:
    .word select_style_green
    .word select_style_tophat
    .word select_style_cowboy
    .word select_style_viking
    .word select_style_pirate
    .word select_style_clown
    .word select_style_glasses

select_tint_text_ptrs:
    .word select_tint_green
    .word select_tint_blue
    .word select_tint_brown
    .word select_tint_purple

select_style_green:
    .byte "< GREEN TOAD >      "
    .byte $FF

select_style_tophat:
    .byte "< TOP HAT TOAD >    "
    .byte $FF

select_style_cowboy:
    .byte "< COWBOY TOAD >     "
    .byte $FF

select_style_viking:
    .byte "< VIKING TOAD >     "
    .byte $FF

select_style_pirate:
    .byte "< PIRATE TOAD >     "
    .byte $FF

select_style_clown:
    .byte "< CLOWN TOAD >      "
    .byte $FF

select_style_glasses:
    .byte "< GLASSES TOAD >    "
    .byte $FF

select_tint_green:
    .byte "TINT GREEN          "
    .byte $FF

select_tint_blue:
    .byte "TINT BLUE           "
    .byte $FF

select_tint_brown:
    .byte "TINT BROWN          "
    .byte $FF

select_tint_purple:
    .byte "TINT PURPLE         "
    .byte $FF

title_message1:
    .byte "WELCOME TO THE POND "
    .byte $FF

title_message2:
    .byte "PRESS START TO PICK "
    .byte $FF

title_message3:
    .byte "A HAT AND A TINT    "
    .byte $FF

title_message4:
    .byte "FOR THE NEXT TEST   "
    .byte $FF

message1:
    .byte "WELCOME TO THE POND "
    .byte $FF

message2:
    .byte "LEFT RIGHT TO MOVE  "
    .byte $FF

message3:
    .byte "A JUMP  B RIBBIT    "
    .byte $FF

message4:
    .byte "UP DOWN TO SWIM     "
    .byte $FF

; ------- Palettes -------

palette:
    ; Background palettes
    .byte $0F,$19,$29,$30   ; BG0: panel + text
    .byte $0F,$11,$21,$2A   ; BG1: pond water + lily pad
    .byte $0F,$0A,$17,$2A   ; BG2: foliage + bank
    .byte $0F,$07,$17,$27   ; BG3: shore

    ; Sprite palettes
    .byte $0F,$16,$27,$38   ; SP0: green toad
    .byte $0F,$11,$21,$31   ; SP1: blue toad
    .byte $0F,$07,$17,$27   ; SP2: brown toad
    .byte $0F,$14,$24,$34   ; SP3: purple toad

bob_table:
    .byte $00,$01,$02,$01

.segment "CHARS"
    .incbin "frog_scene.chr"
