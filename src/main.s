    processor 6502

CUSTOM_CHAR_MEM = $1c00                         ; custom char table start
SCREEN_MEM = $1e00                              ; screen mem start!
CHARSET_POINTER = $9005                         ; custom char table vic chip mem address place
GETIN = $ffe4

DATA_ADDR_LOW = $00
DATA_ADDR_HIGH = $01
LOAD_ADDR_LOW = $02
LOAD_ADDR_HIGH = $03
current_byte_from_data = $04
count = $05
value = $06

what_level_tracker = $07
level_data_addr_low = $08
level_data_addr_high = $09

    org $1001, 0
    include "./src/extras/stub.s"

    lda #255
    sta CHARSET_POINTER

    ; initializing stuff
    lda #1
    sta what_level_tracker

    jsr f_set_color_mem_black

    jsr f_draw_titlescreen

starting_loop:
    jsr GETIN
    cmp #0
    beq starting_loop

    jsr f_draw_level                            ; on any input, draw the first level, and start the game
    jmp game_loop

game_loop:
    jsr f_clear_screen
    jmp game_loop
    
    rts



    include "./src/extras/util.s"               ; util funcs
    include "./src/compression/rle_decode.s"    ; rle decoder code
    include "./src/titlescreen/titlescreen.s"   ; titlescreen
    include "./src/levels/levels.s"             ; code to draw levles

encoded_title_screen_data_start
    incbin "./src/compression/titlescreen-rle-encoded.bin"

level_1_data_start

level_2_data_start

    org CUSTOM_CHAR_MEM
    include "./src/extras/character-table.s"