
CHARSET_POINTER = $9005
CUSTOM_CHAR_MEM = $1c00
SCREEN_MEM = $1e00
COLOUR_MEM_1 = $9600
COLOUR_MEM_2 = $9700
CHROUT = $ffd2
ADDRESS_LOW = $00
ADDRESS_HIGH = $01

	processor 6502
	org $1001, 0
	include "stub.s"

	lda #147
	jsr CHROUT

	lda #255
	sta CHARSET_POINTER	; use outputted code from level_editor.py to draw the title screen

	; set colour mem to all black
    ldx #0
.color_stuff_1:
    lda #0                          ; foreground black
    sta COLOUR_MEM_1,x
    inx
    txa
    bne .color_stuff_1

.color_stuff_2:
    lda #0
    sta COLOUR_MEM_2,x
    inx
    txa
    bne .color_stuff_2
    
    
	lda #@L_code
	sta $1e23
	lda #@E_code
	sta $1e24
	lda #@V_code
	sta $1e25
	lda #@E_code
	sta $1e26
	lda #@L_code
	sta $1e27
	lda #num_zero_code
	sta $1e29
	lda #num_zero_code
	sta $1e2a
	lda #wall_top_code
	sta $1e2c
	lda #wall_top_code
	sta $1e2d
	lda #wall_top_code
	sta $1e2e
	lda #wall_top_code
	sta $1e2f
	lda #wall_top_code
	sta $1e30
	lda #wall_top_code
	sta $1e31
	lda #wall_top_code
	sta $1e32
	lda #wall_top_code
	sta $1e33
	lda #wall_top_code
	sta $1e34
	lda #wall_top_code
	sta $1e35
	lda #wall_top_code
	sta $1e36
	lda #wall_top_code
	sta $1e37
	lda #wall_top_code
	sta $1e38
	lda #wall_top_code
	sta $1e39
	lda #wall_top_code
	sta $1e3a
	lda #wall_top_code
	sta $1e3b
	lda #wall_top_code
	sta $1e3c
	lda #wall_top_code
	sta $1e3d
	lda #wall_top_code
	sta $1e3e
	lda #wall_top_code
	sta $1e3f
	lda #wall_top_code
	sta $1e40
	lda #wall_top_code
	sta $1e41

loop:
	jmp loop

	org CUSTOM_CHAR_MEM
	include "local_character_table.s"
