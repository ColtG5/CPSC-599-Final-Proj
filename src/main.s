    processor 6502

; Memory Locations and Constants
CUSTOM_CHAR_MEM      = $1C00                  ; Custom character table start
SCREEN_MEM_1         = $1E00                  ; Screen memory start
SCREEN_MEM_2         = $1F00                  ; Additional screen memory
COLOUR_MEM_1         = $9600                  ; Color memory start
COLOUR_MEM_2         = $9700                  ; Additional color memory
CHARSET_POINTER      = $9005                  ; Custom char table VIC chip address
GETIN                = $FFE4                  ; Get input routine
PLOT                 = $FFF0                  ; Plot character at X, Y coordinates
CHROUT               = $FFD2                  ; Output character

; Control Codes
KEY_W                = 87                     ; W key for moving up
KEY_A                = 65                     ; A key for moving left
KEY_S                = 83                     ; S key for moving down
KEY_D                = 68                     ; D key for moving right
KEY_E                = 69                     ; E key to toggle portal
KEY_SPACE            = $20                    ; Spacebar for level transition
CURSOR_CHAR          = 50                     ; Character code for cursor
PORTAL_CHAR          = 87                     ; Character code for portal
MAX_LEVEL            = 3                      ; Maximum level count

; Zero-page Variables
DATA_ADDR_LOW        = $00                    ; Address for loading data (low byte)
DATA_ADDR_HIGH       = $01                    ; Address for loading data (high byte)
LOAD_ADDR_LOW        = $02
LOAD_ADDR_HIGH       = $03
current_byte_from_data = $04
count                = $05
value                = $06
what_level_tracker   = $07                    ; Current level tracker
level_data_addr_low  = $08                    ; Low byte of level data address
level_data_addr_high = $09                    ; High byte of level data address
cursor_x             = $0A                    ; Cursor X position
cursor_y             = $0B                    ; Cursor Y position
portal_x             = $0C                    ; Portal X position
portal_y             = $0D                    ; Portal Y position
portal_placed        = $0E                    ; 1 if portal is placed, 0 if not
previous_cursor_x    = $0F                    ; Previous cursor X position
previous_cursor_y    = $10                    ; Previous cursor Y position
blank_tile           = $11                    ; Blank tile for erasing
curr_char_code       = $12                    ; Current character code

    org $1001, 0
    include "./src/extras/stub.s"

    ; Initialize character set and display titlescreen
    lda #255
    sta CHARSET_POINTER

    ; Initialize variables and start titlescreen
    lda #1
    sta what_level_tracker
    jsr f_set_color_mem_black
    jsr f_draw_titlescreen

    lda SCREEN_MEM_1
    sta blank_tile

.starting_loop:
    jsr GETIN
    cmp #0
    beq .play_music_and_wait_input               ; Wait if no input detected

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

    lda cursor_x                              ; Store initial cursor position
    sta previous_cursor_x
    lda cursor_y
    sta previous_cursor_y
    jmp .game_loop

.play_music_and_wait_input:
    jsr f_play_melody                         ; Play titlescreen melody
    jmp .starting_loop                         ; Return to input loop

; Main Game Loop
.game_loop:
    jsr f_plot_portal                         ; Draw portal at current position

    jsr GETIN                                 ; Get player input
    cmp #0
    beq .game_loop                             ; Continue loop if no input

    cmp #KEY_SPACE                            ; Check for spacebar input for level change
    beq .next_level                          ; If spacebar pressed, go to next level

    sta current_byte_from_data                ; Store input temporarily
    jsr .f_handle_input                        ; Handle other inputs
    jmp .game_loop                             ; Repeat loop

; Level Transition Function
.next_level:
    lda what_level_tracker

    cmp #MAX_LEVEL                            ; Check if at the last level
    bne .increment_level
    lda #1                                    ; Reset to the first level if at max

    sta what_level_tracker
    jsr f_set_color_mem_black
    jsr f_draw_titlescreen
    jmp .starting_loop

.increment_level:
    inc what_level_tracker                    ; Move to next level
    jsr f_set_color_mem_black
    jsr f_clear_screen
    jsr f_draw_level
    jmp .game_loop

; Input Handling Subroutine
.f_handle_input:
    lda current_byte_from_data
    cmp #KEY_W                                ; W key for up
    beq f_move_up
    cmp #KEY_A                                ; A key for left
    beq f_move_left
    cmp #KEY_S                                ; S key for down
    beq f_move_down
    cmp #KEY_D                                ; D key for right
    beq f_move_right
    cmp #KEY_E                                ; E key to pick/place portal
    beq f_toggle_portal
    rts

; Movement Functions
f_move_up:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    dec cursor_y
    jsr f_draw_cursor
    rts

f_move_left:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    dec cursor_x
    jsr f_draw_cursor
    rts

f_move_down:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    inc cursor_y
    jsr f_draw_cursor
    rts

f_move_right:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    inc cursor_x
    jsr f_draw_cursor
    rts

; Portal Placement Toggle Function
f_toggle_portal:
    lda portal_placed
    beq _place_portal                          ; Place portal if not already placed
    jsr f_pickup_portal                        ; Otherwise, pick it up
    rts

_place_portal:
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
    bne _end_toggle
    lda portal_y
    cmp cursor_y
    bne _end_toggle
    lda #0
    sta portal_placed                          ; Unset portal if picked up
_end_toggle:
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
    lda #CURSOR_CHAR                           ; Custom cursor character code
    jsr CHROUT

    ; Update previous cursor position
    lda cursor_x
    sta previous_cursor_x
    lda cursor_y
    sta previous_cursor_y
    rts

f_plot_portal:
    lda portal_placed
    beq _skip_plot_portal                      ; Skip if portal not placed
    ldx portal_y
    ldy portal_x
    clc
    jsr PLOT
    lda #PORTAL_CHAR                           ; Custom portal character code
    jsr CHROUT
_skip_plot_portal:
    rts

f_erase_cursor:
    ; Erase previous cursor position with blank tile
    ldx previous_cursor_y
    ldy previous_cursor_x
    clc
    jsr PLOT
    lda blank_tile                             ; Load the blank tile character
    jsr CHROUT                                 ; Write blank tile to previous cursor position
    rts

; Include supporting files as per conventions
    include "./src/extras/util.s"                  ; Utility functions
    include "./src/compression/rle_decode.s"       ; RLE decoder for titlescreen
    include "./src/titlescreen/titlescreen.s"      ; Titlescreen logic
    include "./src/levels/levels.s"                ; Level drawing functions
    include "./src/music/titlescreen_music.s"      ; Titlescreen music functions

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
