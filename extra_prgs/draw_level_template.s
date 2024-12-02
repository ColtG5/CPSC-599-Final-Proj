
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
    
    
	lda #L_code
	sta $1e23
	lda #E_code
	sta $1e24
	lda #V_code
	sta $1e25
	lda #E_code
	sta $1e26
	lda #L_code
	sta $1e27
	lda #num_0_code
	sta $1e29
	lda #num_0_code
	sta $1e2a
	lda #game_wall_top_code
	sta $1e2d
	lda #game_wall_top_code
	sta $1e2e
	lda #game_wall_top_code
	sta $1e2f
	lda #game_wall_top_code
	sta $1e30
	lda #game_wall_top_code
	sta $1e31
	lda #game_wall_top_code
	sta $1e32
	lda #game_wall_top_code
	sta $1e33
	lda #game_wall_top_code
	sta $1e34
	lda #game_wall_top_code
	sta $1e35
	lda #game_wall_top_code
	sta $1e36
	lda #game_wall_top_code
	sta $1e37
	lda #game_wall_top_code
	sta $1e38
	lda #game_wall_top_code
	sta $1e39
	lda #game_wall_top_code
	sta $1e3a
	lda #game_wall_top_code
	sta $1e3b
	lda #game_wall_top_code
	sta $1e3c
	lda #game_wall_top_code
	sta $1e3d
	lda #game_wall_top_code
	sta $1e3e
	lda #game_wall_top_code
	sta $1e3f
	lda #game_wall_top_code
	sta $1e40
	lda #game_wall_left_code
	sta $1e42
	lda #game_wall_right_code
	sta $1e57
	lda #game_wall_left_code
	sta $1e58
	lda #game_wall_right_code
	sta $1e6d
	lda #game_wall_left_code
	sta $1e6e
	lda #game_wall_right_code
	sta $1e83
	lda #game_wall_left_code
	sta $1e84
	lda #game_wall_right_code
	sta $1e99
	lda #game_wall_left_code
	sta $1e9a
	lda #game_wall_right_code
	sta $1eaf
	lda #game_wall_left_code
	sta $1eb0
	lda #game_wall_right_code
	sta $1ec5
	lda #game_wall_left_code
	sta $1ec6
	lda #game_wall_right_code
	sta $1edb
	lda #game_wall_left_code
	sta $1edc
	lda #game_wall_right_code
	sta $1ef1
	lda #game_wall_left_code
	sta $1ef2
	lda #game_wall_right_code
	sta $1f07
	lda #game_wall_left_code
	sta $1f08
	lda #game_wall_right_code
	sta $1f1d
	lda #game_wall_left_code
	sta $1f1e
	lda #game_wall_right_code
	sta $1f33
	lda #game_wall_left_code
	sta $1f34
	lda #game_wall_right_code
	sta $1f49
	lda #game_wall_left_code
	sta $1f4a
	lda #game_wall_right_code
	sta $1f5f
	lda #game_wall_left_code
	sta $1f60
	lda #game_wall_right_code
	sta $1f75
	lda #game_wall_left_code
	sta $1f76
	lda #game_wall_right_code
	sta $1f8b
	lda #game_wall_left_code
	sta $1f8c
	lda #game_wall_right_code
	sta $1fa1
	lda #game_wall_left_code
	sta $1fa2
	lda #game_wall_right_code
	sta $1fb7
	lda #game_wall_left_code
	sta $1fb8
	lda #game_wall_right_code
	sta $1fcd
	lda #game_wall_left_code
	sta $1fce
	lda #game_wall_right_code
	sta $1fe3
	lda #game_wall_bottom_code
	sta $1fe5
	lda #game_wall_bottom_code
	sta $1fe6
	lda #game_wall_bottom_code
	sta $1fe7
	lda #game_wall_bottom_code
	sta $1fe8
	lda #game_wall_bottom_code
	sta $1fe9
	lda #game_wall_bottom_code
	sta $1fea
	lda #game_wall_bottom_code
	sta $1feb
	lda #game_wall_bottom_code
	sta $1fec
	lda #game_wall_bottom_code
	sta $1fed
	lda #game_wall_bottom_code
	sta $1fee
	lda #game_wall_bottom_code
	sta $1fef
	lda #game_wall_bottom_code
	sta $1ff0
	lda #game_wall_bottom_code
	sta $1ff1
	lda #game_wall_bottom_code
	sta $1ff2
	lda #game_wall_bottom_code
	sta $1ff3
	lda #game_wall_bottom_code
	sta $1ff4
	lda #game_wall_bottom_code
	sta $1ff5
	lda #game_wall_bottom_code
	sta $1ff6
	lda #game_wall_bottom_code
	sta $1ff7
	lda #game_wall_bottom_code
	sta $1ff8

loop:
	jmp loop

	org CUSTOM_CHAR_MEM
	include "local_character_table.s"
