    processor 6502
    org $1001
    incdir "./src"
    include "./setup/zero_page.s"
    include "./setup/stub.s"
    include "./setup/constants.s"

start:
    ; use custom character set
    lda #255
    sta CHARSET_POINTER

    ; Initialize variables and start titlescreen
    lda #0
    sta what_level_tracker_z
    jsr f_set_color_mem_black
    lda #24    ; Border = 0 (black), Background = 0 (black)
    sta $900F
    jsr f_draw_titlescreen

.starting_loop:
    jsr GETIN
    cmp #0
    beq .play_music_and_wait_input               ; Wait if no input detected

    jmp .next_level

.play_music_and_wait_input:
    jsr f_play_melody                         ; Play titlescreen melody
    jmp .starting_loop                         ; Return to input loop

; Main Game Loop
.game_loop:
    jsr GETIN                                   ; Get player input
    cmp #0
    beq .game_loop                              ; Continue loop if no input

    cmp #KEY_SPACE                              ; Check for spacebar input for level change
    beq .next_level                             ; If spacebar pressed, go to next level
    sta curr_char_pressed_z                     ; Store input from player


; stuff that happens every "tick" of the game!!

    jsr f_clear_all_laser_stuff                  ; Clear all lasers and reset objects that were in a "laser" state
    jsr f_set_color_mem_black
    jsr f_handle_input                          ; Handle player inputs (also handles collision after the player input)
    jsr f_redraw_lasers                         ; calculate and draw the paths for each laser beam for each laser shooter
    jsr f_draw_cursor                           ; Draw cursor

; check for level win condition
    lda receptors_hit_z                         ; Check if all receptors are hit
    cmp num_of_receptors_in_level_z
    bne .game_loop                             ; If all receptors are hit, the player beat the level!!!!! :D otherwise continue game loop

    ; All receptors hit, player won the level
    jsr f_win_screen   ; Display win message and wait for 'E'
    jmp .next_level    ; After returning from f_win_screen, proceed to the next level




; Transition to the next level
.next_level:
    lda what_level_tracker_z

    cmp #MAX_LEVEL                              ; Check if at the last level
    bne .increment_level

; Reset to the start
    lda #0
    sta what_level_tracker_z
    jsr f_set_color_mem_black
    jsr f_draw_titlescreen
    jmp .starting_loop

; Otherwise increment the level
.increment_level:
    inc what_level_tracker_z                    ; Move to next level
    jsr f_set_color_mem_black
    jsr f_clear_covered_char_in_mem             ; clear covered char
    jsr f_clear_inventory                       ; clear inventory
    jsr f_clear_screen                          ; clear screen

    lda #10
    sta cursor_x_z
    sta last_cursor_x_z
    sta cursor_y_z
    sta last_cursor_y_z                 ; reset cursor pos to hardcoded spot

    jsr f_draw_next_level
    jsr f_redraw_lasers
    jsr f_draw_cursor
    jmp .game_loop


; Include supporting files
    include "./extras/util.s"                  ; Utility functions
    include "./compression/rle_decode.s"       ; RLE decoder for titlescreen
    include "./titlescreen/titlescreen.s"      ; Titlescreen logic
    include "./levels/levels.s"                ; Level drawing functions
    include "./laser/laser.s"                  ; Laser functions
    include "./music/titlescreen_music.s"      ; Titlescreen music functions
    include "./player/cursor.s"                ; Cursor movement functions
    include "./player/inventory.s"             ; Player inventory functions
    include "./levels/win.s"                   ; Winscreen functions\

level_pointers_p:
    dc.w $0000 ; pretend this is NOT here
    dc.w level_1_data_start_p
    dc.w level_2_data_start_p
    dc.w level_3_data_start_p
    dc.w level_4_data_start_p
    dc.w level_5_data_start_p

encoded_title_screen_data_start_p:
    incbin "./titlescreen/titlescreen-rle-encoded.bin"

level_template_data_start_p:
    incbin "./levels/level_template-rle-encoded.bin"

level_1_data_start_p:
    incbin "./levels/level_1.bin"

level_2_data_start_p:
    incbin "./levels/level_2.bin"

level_3_data_start_p:
    incbin "./levels/level_3.bin"

level_4_data_start_p:
    incbin "./levels/level_4.bin"

level_5_data_start_p:
    incbin "./levels/level_5.bin"

continue_text_data_start_p:
    incbin "./extras/continue_text-rle-encoded.bin"

    org CUSTOM_CHAR_MEM
    include "./extras/character_table.s"
