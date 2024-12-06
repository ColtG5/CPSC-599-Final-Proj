
CHARSET_POINTER = $9005
CUSTOM_CHAR_MEM = $1c00
SCREEN_MEM = $1e00
SCREEN_MEM_1 = $1e00
SCREEN_MEM_2 = $1f00
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
	sta CHARSET_POINTER

	; set colour mem to all black
    ldx #0
.color_stuff_1:
    lda #0
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
    
    ldx #0
.clear_screen_mem_1:
    lda #empty_character_code
    sta SCREEN_MEM_1,x
    inx
    txa
    bne .clear_screen_mem_1

.clear_screen_mem_2:
    lda #empty_character_code
    sta SCREEN_MEM_2,x
    inx
    txa
    bne .clear_screen_mem_2
    
    
	lda #P_code
	sta $1e18
	lda #R_code
	sta $1e19
	lda #E_code
	sta $1e1a
	lda #S_code
	sta $1e1b
	lda #S_code
	sta $1e1c
	lda #E_code
	sta $1e1e
	lda #T_code
	sta $1e20
	lda #O_code
	sta $1e21
	lda #C_code
	sta $1e23
	lda #O_code
	sta $1e24
	lda #N_code
	sta $1e25
	lda #T_code
	sta $1e26
	lda #I_code
	sta $1e27
	lda #N_code
	sta $1e28
	lda #U_code
	sta $1e29
	lda #E_code
	sta $1e2a

loop:
	jmp loop

	org CUSTOM_CHAR_MEM
	include "local_character_table.s"
