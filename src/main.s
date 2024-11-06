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
    beq play_music_and_wait_input     ; Wait if no input detected

    jsr f_clear_screen
    jsr f_draw_level                            ; on any input, draw the first level, and start the game
    jmp game_loop

play_music_and_wait_input:
    jsr f_play_melody                  ; Play titlescreen melody
    jmp starting_loop                 ; Return to input loop

game_loop:




    ; for testing purposes: if spacebar is hit, advance to next level
    jsr GETIN
    cmp #$20                    ; code for spacebar
    bne game_loop

    ; move to next level! if trying to move from level 3 to level 4, "restart" the game by going back to starting loop
    lda what_level_tracker
    cmp #3
    bne dont_start_over
    lda #1
    sta what_level_tracker
    jsr f_draw_titlescreen

dont_start_over:
    inc what_level_tracker
    jsr f_clear_screen
    jsr f_draw_level
    jmp game_loop
    
    rts



    include "./src/extras/util.s"               ; util funcs
    include "./src/compression/rle_decode.s"    ; rle decoder code
    include "./src/titlescreen/titlescreen.s"   ; titlescreen
    include "./src/levels/levels.s"             ; code to draw levles
    include "./src/music/titlescreen_music.s"   ; Titlescreen music functions


encoded_title_screen_data_start
    incbin "./src/titlescreen/titlescreen-rle-encoded.bin"

level_1_data_start
    incbin "./src/levels/level1.bin"

level_2_data_start

    org CUSTOM_CHAR_MEM
    include "./src/extras/character-table.s"