    processor 6502
    org $1001, 0
    incdir "./src"
    include "./setup/zero_page.s"
    include "./setup/stub.s"
    include "./setup/constants.s"

    ; use custom character set
    lda #255
    sta CHARSET_POINTER

    ; Initialize variables and start titlescreen
    lda #1
    sta what_level_tracker_z
    jsr f_set_color_mem_black
    jsr f_draw_titlescreen

.starting_loop:
    jsr GETIN
    cmp #0
    beq .play_music_and_wait_input               ; Wait if no input detected

    jsr f_clear_screen
    jsr f_draw_next_level                            ; Draw first level on input and start the game

    jmp .game_loop

.play_music_and_wait_input:
    jsr f_play_melody                         ; Play titlescreen melody
    jmp .starting_loop                         ; Return to input loop

; Main Game Loop
.game_loop:
    ; jsr f_plot_portal                         ; Draw portal at current position

    jsr GETIN                                 ; Get player input
    cmp #0
    beq .game_loop                             ; Continue loop if no input

    cmp #KEY_SPACE                            ; Check for spacebar input for level change
    beq .next_level                          ; If spacebar pressed, go to next level

    sta current_byte_from_data_z                ; Store input temporarily
    ; jsr .f_handle_input                        ; Handle other inputs
    jmp .game_loop                             ; Repeat loop

; Level Transition Function
.next_level:
    lda what_level_tracker_z

    cmp #MAX_LEVEL                            ; Check if at the last level
    bne .increment_level

    lda #1                                    ; Reset to the first level if at max
    sta what_level_tracker_z
    jsr f_set_color_mem_black
    jsr f_draw_titlescreen
    jmp .starting_loop

.increment_level:
    inc what_level_tracker_z                    ; Move to next level
    jsr f_set_color_mem_black
    jsr f_clear_screen
    jsr f_draw_next_level
    jmp .game_loop

; ; Input Handling Subroutine
; .f_handle_input:
;     lda current_byte_from_data_z
;     cmp #KEY_W                                ; W key for up
;     beq f_move_up
;     cmp #KEY_A                                ; A key for left
;     beq f_move_left
;     cmp #KEY_S                                ; S key for down
;     beq f_move_down
;     cmp #KEY_D                                ; D key for right
;     beq f_move_right
;     cmp #KEY_E                                ; E key to pick/place portal
;     beq f_toggle_portal
;     rts

; ; Movement Functions
; f_move_up:
;     jsr f_erase_cursor                        ; Erase cursor at previous position
;     dec cursor_y_z
;     jsr f_draw_cursor
;     rts

; f_move_left:
;     jsr f_erase_cursor                        ; Erase cursor at previous position
;     dec cursor_x_z
;     jsr f_draw_cursor
;     rts

; f_move_down:
;     jsr f_erase_cursor                        ; Erase cursor at previous position
;     inc cursor_y_z
;     jsr f_draw_cursor
;     rts

; f_move_right:
;     jsr f_erase_cursor                        ; Erase cursor at previous position
;     inc cursor_x_z
;     jsr f_draw_cursor
;     rts

; Include supporting files
    include "./extras/util.s"                  ; Utility functions
    include "./compression/rle_decode.s"       ; RLE decoder for titlescreen
    include "./titlescreen/titlescreen.s"      ; Titlescreen logic
    include "./levels/levels.s"                ; Level drawing functions
    include "./music/titlescreen_music.s"      ; Titlescreen music functions

level_pointers:
    dc.w $0000
    dc.w level_1_data_start
    dc.w level_2_data_start
    dc.w level_3_data_start

encoded_title_screen_data_start:
    incbin "./titlescreen/titlescreen_rle_encoded.bin"

level_template_data_start:
    incbin "./levels/level_template_rle_encoded.bin"

level_1_data_start:
    incbin "./levels/level1.bin"

level_2_data_start:
    incbin "./levels/level2.bin"

level_3_data_start:
    incbin "./levels/level3.bin"

    org CUSTOM_CHAR_MEM
    include "./extras/character_table.s"
