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
    jsr GETIN                                 ; Get player input
    cmp #0
    beq .game_loop                             ; Continue loop if no input

    cmp #KEY_SPACE                            ; Check for spacebar input for level change
    beq .next_level                          ; If spacebar pressed, go to next level

    sta curr_char_pressed_z                     ; Store input from player
    jsr .f_handle_input                        ; Handle other inputs
    jmp .game_loop                             ; Repeat loop

; Transition to the next level
.next_level:
    lda what_level_tracker_z

    cmp #MAX_LEVEL                            ; Check if at the last level
    bne .increment_level

; Reset to the first level if at max
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


; Include supporting files
    include "./extras/util.s"                  ; Utility functions
    include "./compression/rle_decode.s"       ; RLE decoder for titlescreen
    include "./titlescreen/titlescreen.s"      ; Titlescreen logic
    include "./levels/levels.s"                ; Level drawing functions
    include "./music/titlescreen_music.s"      ; Titlescreen music functions
    include "./cursor/cursor.s"                ; Cursor movement functions

level_pointers_p:
    dc.w $0000
    dc.w level_1_data_start_p
    dc.w level_2_data_start_p
    dc.w level_3_data_start_p
    dc.w level_4_data_start_p

encoded_title_screen_data_start_p:
    incbin "./titlescreen/titlescreen_rle_encoded.bin"

level_template_data_start_p:
    ; incbin "./levels/level_template_rle_encoded.bin"
    incbin "./levels/level_template_game_walls-rle-encoded.bin"

level_1_data_start_p:
    incbin "./levels/level_1.bin"
    ; incbin "./levels/test_level.bin"

level_2_data_start_p:
    incbin "./levels/level_2.bin"

level_3_data_start_p:
    incbin "./levels/level_3.bin"

level_4_data_start_p:
    incbin "./levels/level_4.bin"

    org CUSTOM_CHAR_MEM
    include "./extras/character_table.s"
