    processor 6502

CUSTOM_CHAR_MEM = $1c00                         ; custom char table start
SCREEN_MEM = $1e00                              ; screen mem start
CHARSET_POINTER = $9005                         ; custom char table vic chip mem address place
GETIN = $ffe4
PLOT = $fff0
CHROUT = $FFD2

; Zero-page variable declarations
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

cursor_x = $0A                                  ; Cursor X position
cursor_y = $0B                                  ; Cursor Y position
portal_x = $0C                                  ; Portal X position
portal_y = $0D                                  ; Portal Y position
portal_placed = $0E                             ; 1 if portal is placed, 0 if not

previous_cursor_x = $0F                         ; Previous cursor X position
previous_cursor_y = $10                         ; Previous cursor Y position
blank_tile = $11                                ; Stored blank tile from the top-left corner

    org $1001, 0
    include "./src/extras/stub.s"

    lda #255
    sta CHARSET_POINTER

    ; Initialize variables and start titlescreen
    lda #1
    sta what_level_tracker
    jsr f_set_color_mem_black
    jsr f_draw_titlescreen

    ; Read top-left corner tile as the blank tile for erasing
    lda SCREEN_MEM
    sta blank_tile

starting_loop:
    jsr GETIN
    cmp #0
    beq play_music_and_wait_input               ; Wait if no input detected

    jsr f_clear_screen
    jsr f_draw_level                            ; Draw first level on input and start the game
    lda #8                                      ; Initialize cursor and portal positions
    sta cursor_x
    lda #5
    sta cursor_y
    lda #8
    sta portal_x
    lda #8
    sta portal_y
    lda #1
    sta portal_placed

    lda cursor_x                                ; Set initial previous position for erasing
    sta previous_cursor_x
    lda cursor_y
    sta previous_cursor_y
    jmp game_loop

play_music_and_wait_input:
    jsr f_play_melody                           ; Play titlescreen melody
    jmp starting_loop                           ; Return to input loop

; Main Game Loop
game_loop:
    jsr f_plot_portal                           ; Draw portal at current position

    jsr GETIN                                   ; Get player input
    cmp #0
    beq game_loop                               ; Continue loop if no input

    sta $04                                     ; Store input in temporary register
    jsr f_handle_input                          ; Handle input
    jmp game_loop                               ; Repeat loop

; Input Handling Subroutine
f_handle_input:
    lda $04
    cmp #87                                     ; W key for up
    beq f_move_up
    cmp #65                                     ; A key for left
    beq f_move_left
    cmp #83                                     ; S key for down
    beq f_move_down
    cmp #68                                     ; D key for right
    beq f_move_right
    cmp #69                                     ; E key to pick/place portal
    beq f_toggle_portal
    rts

; Movement Functions
f_move_up:
    jsr f_erase_cursor                          ; Erase cursor at old position
    dec cursor_y
    jsr f_draw_cursor
    rts

f_move_left:
    jsr f_erase_cursor                          ; Erase cursor at old position
    dec cursor_x
    jsr f_draw_cursor
    rts

f_move_down:
    jsr f_erase_cursor                          ; Erase cursor at old position
    inc cursor_y
    jsr f_draw_cursor
    rts

f_move_right:
    jsr f_erase_cursor                          ; Erase cursor at old position
    inc cursor_x
    jsr f_draw_cursor
    rts

; Portal Placement Toggle Function
f_toggle_portal:
    lda portal_placed
    beq f_place_portal                           ; If portal not placed, place it
    jsr f_pickup_portal                          ; Otherwise, pick it up
    rts

f_place_portal:
    lda cursor_x
    sta portal_x
    lda cursor_y
    sta portal_y
    lda #1
    sta portal_placed
    rts

f_pickup_portal:
    lda portal_x
    cmp cursor_x
    bne f_end_toggle
    lda portal_y
    cmp cursor_y
    bne f_end_toggle
    lda #0
    sta portal_placed                            ; Set portal as not placed
f_end_toggle:
    rts

; Drawing Functions
f_draw_cursor:
    ; Erase previous position
    jsr f_erase_cursor

    ; Draw cursor at new position
    ldx cursor_y
    ldy cursor_x
    clc
    jsr PLOT
    lda #64                                      ; Custom cursor character code
    jsr CHROUT

    ; Update previous cursor position
    lda cursor_x
    sta previous_cursor_x
    lda cursor_y
    sta previous_cursor_y
    rts

f_plot_portal:
    lda portal_placed
    beq f_skip_plot_portal                       ; Skip if portal not placed
    ldx portal_y
    ldy portal_x
    clc
    jsr PLOT
    lda #66                                      ; Custom portal character code
    jsr CHROUT
f_skip_plot_portal:
    rts

f_erase_cursor:
    ; Use blank tile to erase previous cursor position
    ldx previous_cursor_y
    ldy previous_cursor_x
    clc
    jsr PLOT
    lda blank_tile                               ; Load the blank tile character
    jsr CHROUT                                   ; Write blank tile to previous cursor location
    rts

; Include supporting files as per conventions
    include "./src/extras/util.s"                    ; Utility functions
    include "./src/compression/rle_decode.s"         ; RLE decoder for titlescreen
    include "./src/titlescreen/titlescreen.s"        ; Titlescreen logic
    include "./src/levels/levels.s"                  ; Level drawing functions
    include "./src/music/titlescreen_music.s"        ; Titlescreen music functions

encoded_title_screen_data_start:
    incbin "./src/titlescreen/titlescreen-rle-encoded.bin"

level_1_data_start:
    incbin "./src/levels/level1.bin"

level_2_data_start:
    incbin "./src/levels/level2.bin"

level_3_data_start:
    incbin "./src/levels/level3.bin"

    org CUSTOM_CHAR_MEM
    include "./src/extras/character-table.s"
