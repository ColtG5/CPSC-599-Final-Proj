
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
	sta CHARSET_POINTER

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
	lda #wall_left_code
	sta $1e42
	lda #wall_right_code
	sta $1e57
	lda #wall_left_code
	sta $1e58
	lda #wall_right_code
	sta $1e6d
	lda #wall_left_code
	sta $1e6e
	lda #wall_right_code
	sta $1e83
	lda #wall_left_code
	sta $1e84
	lda #wall_right_code
	sta $1e99
	lda #wall_left_code
	sta $1e9a
	lda #wall_right_code
	sta $1eaf
	lda #wall_left_code
	sta $1eb0
	lda #wall_right_code
	sta $1ec5
	lda #wall_left_code
	sta $1ec6
	lda #wall_right_code
	sta $1edb
	lda #wall_left_code
	sta $1edc
	lda #wall_right_code
	sta $1ef1
	lda #wall_left_code
	sta $1ef2
	lda #wall_right_code
	sta $1f07
	lda #wall_left_code
	sta $1f08
	lda #wall_right_code
	sta $1f1d
	lda #wall_left_code
	sta $1f1e
	lda #wall_right_code
	sta $1f33
	lda #wall_left_code
	sta $1f34
	lda #wall_right_code
	sta $1f49
	lda #wall_left_code
	sta $1f4a
	lda #wall_right_code
	sta $1f5f
	lda #wall_left_code
	sta $1f60
	lda #wall_right_code
	sta $1f75
	lda #wall_left_code
	sta $1f76
	lda #wall_right_code
	sta $1f8b
	lda #wall_left_code
	sta $1f8c
	lda #wall_right_code
	sta $1fa1
	lda #wall_left_code
	sta $1fa2
	lda #wall_right_code
	sta $1fb7
	lda #wall_left_code
	sta $1fb8
	lda #wall_right_code
	sta $1fcd
	lda #wall_left_code
	sta $1fce
	lda #wall_right_code
	sta $1fe3
	lda #wall_bottom_code
	sta $1fe5
	lda #wall_bottom_code
	sta $1fe6
	lda #wall_bottom_code
	sta $1fe7
	lda #wall_bottom_code
	sta $1fe8
	lda #wall_bottom_code
	sta $1fe9
	lda #wall_bottom_code
	sta $1fea
	lda #wall_bottom_code
	sta $1feb
	lda #wall_bottom_code
	sta $1fec
	lda #wall_bottom_code
	sta $1fed
	lda #wall_bottom_code
	sta $1fee
	lda #wall_bottom_code
	sta $1fef
	lda #wall_bottom_code
	sta $1ff0
	lda #wall_bottom_code
	sta $1ff1
	lda #wall_bottom_code
	sta $1ff2
	lda #wall_bottom_code
	sta $1ff3
	lda #wall_bottom_code
	sta $1ff4
	lda #wall_bottom_code
	sta $1ff5
	lda #wall_bottom_code
	sta $1ff6
	lda #wall_bottom_code
	sta $1ff7
	lda #wall_bottom_code
	sta $1ff8

loop:
	jmp loop

	org CUSTOM_CHAR_MEM
	include "local_character_table.s"
