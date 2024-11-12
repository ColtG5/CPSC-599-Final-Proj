CUSTOM_CHAR_MEM = $1c00
SCREEN_MEM = $1e00
CHROUT = $ffd2

	processor 6502
	org $1001, 0

	include "./setup/stub.s"

    lda #147
    jsr CHROUT

	lda #255
	sta CHARSET_POINTER	; use outputted code from level_editor.py to draw the title screen

	lda #0
	sta $1e5c
	lda #0
	sta $1e61
	lda #2
	sta $1e94
	lda #2
	sta $1eb7
	lda #0
	sta $1ed6
	lda #0
	sta $1ee7
	lda #0
	sta $1ef8
	lda #2
	sta $1f42

loop:
	jmp loop

	org CUSTOM_CHAR_MEM
	include "local_character_table.s"
