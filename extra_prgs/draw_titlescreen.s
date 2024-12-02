
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
    
    
	lda #laser_receptor_code
	sta $1e0d
	lda #laser_vertical_code
	sta $1e23
	lda #portal_code
	sta $1e2d
	lda #laser_horizontal_code
	sta $1e2e
	lda #laser_horizontal_code
	sta $1e2f
	lda #laser_horizontal_code
	sta $1e30
	lda #laser_horizontal_code
	sta $1e31
	lda #laser_horizontal_code
	sta $1e32
	lda #laser_horizontal_code
	sta $1e33
	lda #laser_horizontal_code
	sta $1e34
	lda #laser_horizontal_code
	sta $1e35
	lda #laser_horizontal_code
	sta $1e36
	lda #laser_horizontal_code
	sta $1e37
	lda #laser_horizontal_code
	sta $1e38
	lda #reflector_2_code
	sta $1e39
	lda #goob_1_code
	sta $1e7b
	lda #goob_2_code
	sta $1e7c
	lda #goob_3_code
	sta $1e7d
	lda #goob_4_code
	sta $1e7e
	lda #goob_5_code
	sta $1e7f
	lda #G_code
	sta $1e85
	lda #O_code
	sta $1e86
	lda #O_code
	sta $1e87
	lda #B_code
	sta $1e88
	lda #colon_code
	sta $1e89
	lda #goob_6_code
	sta $1e91
	lda #goob_7_code
	sta $1e92
	lda #goob_8_code
	sta $1e93
	lda #goob_9_code
	sta $1e94
	lda #goob_10_code
	sta $1e95
	lda #goob_11_code
	sta $1ea7
	lda #goob_12_code
	sta $1ea8
	lda #goob_13_code
	sta $1ea9
	lda #goob_14_code
	sta $1eaa
	lda #goob_15_code
	sta $1eab
	lda #M_code
	sta $1eb1
	lda #E_code
	sta $1eb2
	lda #C_code
	sta $1eb3
	lda #H_code
	sta $1eb4
	lda #A_code
	sta $1eb5
	lda #N_code
	sta $1eb6
	lda #I_code
	sta $1eb7
	lda #C_code
	sta $1eb8
	lda #goob_17_code
	sta $1ebe
	lda #goob_18_code
	sta $1ebf
	lda #goob_19_code
	sta $1ec0
	lda #goob_20_code
	sta $1ec1
	lda #M_code
	sta $1ec7
	lda #A_code
	sta $1ec8
	lda #Y_code
	sta $1ec9
	lda #D_code
	sta $1eca
	lda #A_code
	sta $1ecb
	lda #Y_code
	sta $1ecc
	lda #C_code
	sta $1f1f
	lda #O_code
	sta $1f20
	lda #L_code
	sta $1f21
	lda #T_code
	sta $1f22
	lda #O_code
	sta $1f23
	lda #N_code
	sta $1f24
	lda #G_code
	sta $1f26
	lda #O_code
	sta $1f27
	lda #W_code
	sta $1f28
	lda #A_code
	sta $1f29
	lda #N_code
	sta $1f2a
	lda #S_code
	sta $1f2b
	lda #F_code
	sta $1f35
	lda #A_code
	sta $1f36
	lda #M_code
	sta $1f37
	lda #G_code
	sta $1f39
	lda #H_code
	sta $1f3a
	lda #A_code
	sta $1f3b
	lda #L_code
	sta $1f3c
	lda #Y_code
	sta $1f3d
	lda #num_2_code
	sta $1f61
	lda #num_0_code
	sta $1f62
	lda #num_2_code
	sta $1f63
	lda #num_4_code
	sta $1f64
	lda #wall_code
	sta $1f72
	lda #wall_code
	sta $1f73
	lda #wall_code
	sta $1f74
	lda #wall_code
	sta $1f88
	lda #wall_code
	sta $1f89
	lda #wall_code
	sta $1f8a
	lda #portal_code
	sta $1fa4
	lda #laser_horizontal_code
	sta $1fa5
	lda #laser_horizontal_code
	sta $1fa6
	lda #laser_horizontal_code
	sta $1fa7
	lda #laser_horizontal_code
	sta $1fa8
	lda #laser_horizontal_code
	sta $1fa9
	lda #laser_horizontal_code
	sta $1faa
	lda #laser_horizontal_code
	sta $1fab
	lda #laser_horizontal_code
	sta $1fac
	lda #laser_horizontal_code
	sta $1fad
	lda #laser_horizontal_code
	sta $1fae
	lda #laser_horizontal_code
	sta $1faf
	lda #laser_horizontal_code
	sta $1fb0
	lda #laser_horizontal_code
	sta $1fb1
	lda #laser_horizontal_code
	sta $1fb2
	lda #laser_horizontal_code
	sta $1fb3
	lda #laser_horizontal_code
	sta $1fb4
	lda #reflector_1_code
	sta $1fb5
	lda #laser_vertical_code
	sta $1fcb
	lda #laser_vertical_code
	sta $1fe1
	lda #laser_shooter_code
	sta $1ff7

loop:
	jmp loop

	org CUSTOM_CHAR_MEM
	include "local_character_table.s"
