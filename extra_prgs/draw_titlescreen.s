
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
    
    
	lda #goob_facing_left_code
	sta $1e4d
	lda #goob_facing_right_code
	sta $1e68
	lda #goob_facing_right_code
	sta $1e73
	lda #goob_facing_right_code
	sta $1e8f
	lda #goob_facing_left_code
	sta $1ead
	lda #goob_facing_left_code
	sta $1eb6
	lda #goob_facing_left_code
	sta $1ed3
	lda #goob_facing_right_code
	sta $1ed6
	lda #goob_facing_left_code
	sta $1edd
	lda #reflector_2_code
	sta $1efa
	lda #reflector_1_code
	sta $1efb
	lda #reflector_1_code
	sta $1f10
	lda #reflector_2_code
	sta $1f11
	lda #goob_facing_right_code
	sta $1f25
	lda #goob_facing_left_code
	sta $1f85

loop:
	jmp loop

	org CUSTOM_CHAR_MEM
	include "local_character_table.s"
