    processor 6502

CUSTOM_CHAR_MEM = $1c00                         ; custom char table start
SCREEN_MEM = $1e00                              ; screen mem start!
CHARSET_POINTER = $9005                         ; custom char table vic chip mem address place
CHROUT = $ffd2

DATA_ADDR_LOW = $00
DATA_ADDR_HIGH = $01
LOAD_ADDR_LOW = $02
LOAD_ADDR_HIGH = $03
current_byte_from_data = $04
count = $05
value = $06

    org $1001, 0
    include "./src/extras/stub.s"

    lda #255
    sta CHARSET_POINTER
    jsr f_set_color_mem_black

    jsr f_draw_titlescreen


inf_loop:
    jmp inf_loop

    include "./src/extras/util.s"               ; util funcs
    include "./src/compression/rle_decode.s"    ; rle decoder code
    include "./src/titlescreen/titlescreen.s"   ; titlescreen

encoded_title_screen_data_start
    incbin "./src/compression/titlescreen-rle-encoded.bin"

    org CUSTOM_CHAR_MEM
    include "./src/extras/character-table.s"