; File: levels/win.s
; Contains logic for the win screen animation and transitioning to the next level.


; Subroutine: f_win_screen
; Displays a win animation and transitions to the next level.
    subroutine
f_win_screen:
    ; Step 1: Fill the middle band with Goob characters.
    ;jsr f_fill_middle_band_with_goob

    ; Step 2: Highlight receptors in green.
    jsr f_highlight_receptors

    ; Step 3: Display "YOU WIN!" message.
    ;jsr f_display_win_message

    ; Step 4: Pause for a moment.
    lda #$FF                    ; Pause duration
    sta tmp_pause_duration_z
    jsr f_pause

    ; Step 5: Clear the screen.
    jsr f_clear_screen_win

    ; Step 6: Transition to the next level.
    jsr f_draw_next_level
    rts

; Subroutine: f_fill_middle_band_with_goob
; Fills a middle section of the screen (rows 10 to 14) with Goob characters.
    subroutine
f_fill_middle_band_with_goob:
    ldy #10                    ; Starting row (Y coordinate)
.loop_band_rows:
    ldx #0                     ; Reset X coordinate for each row
.loop_band_columns:
    jsr f_convert_xy_to_screen_mem_addr ; Convert X, Y to screen memory address
    ldy #0

    lda #goob_facing_left_code
    sta (screen_mem_addr_coord_z),y   ; Write to screen memory
    lda #goob_facing_right_code
    sta (screen_mem_addr_coord_z),y   ; Alternate Goob

    inx                        ; Move to the next column
    cpx #22                    ; Screen width (adjust as needed)
    bne .loop_band_columns     ; Continue until end of the row

    iny                        ; Move to the next row
    cpy #15                    ; End row (adjust as needed)
    bne .loop_band_rows        ; Repeat for rows 10 to 14

    rts

; Subroutine: f_highlight_receptors
; Highlights all receptor characters in green.
    subroutine
f_highlight_receptors:
    ldx #0
.loop_highlight:
    lda SCREEN_MEM_1,x
    cmp #laser_receptor_t_code
    beq .set_green
    cmp #laser_receptor_b_code
    beq .set_green
    jmp .next_char

.set_green:
    lda #4                    ; Green color code
    sta COLOUR_MEM_1,x        ; Set color memory
    jmp .next_char

.next_char:
    inx
    bne .loop_highlight       ; Loop until the entire screen is processed
    rts

; Subroutine: f_display_win_message
; Displays "YOU WIN!" in the center of the screen.
    subroutine
f_display_win_message:
    lda #10                   ; X position for the message
    sta tmp_x_z
    lda #12                   ; Y position for the message
    sta tmp_y_z
    lda #<you_win_message_addr
    sta data_addr_low_z
    lda #>you_win_message_addr
    sta data_addr_high_z
    jsr f_print_message_to_screen
    rts

; Subroutine: f_clear_screen
; Clears all characters and colors from the screen.
    subroutine
f_clear_screen_win:
    ldx #0
.loop_clear:
    lda #empty_character_code
    sta SCREEN_MEM_1,x
    sta SCREEN_MEM_2,x
    lda #0                    ; Black color
    sta COLOUR_MEM_1,x
    sta COLOUR_MEM_2,x
    inx
    bne .loop_clear           ; Continue until the entire screen is cleared
    rts

; Subroutine: f_pause
; Simple pause subroutine.
    subroutine
f_pause:
    ldy tmp_pause_duration_z
.pause_loop:
    dey
    bne .pause_loop
    rts

; Subroutine: f_print_message_to_screen
; Prints a null-terminated message at the given coordinates (tmp_x_z, tmp_y_z).
    subroutine
f_print_message_to_screen:
    ldx #0                    ; Index for the message string.
.loop_print_message:
    lda data_addr_low_z,x     ; Load character from the message string.
    cmp #$00                  ; Check for null terminator.
    beq .done
    sta tmp_char_code_z       ; Store the character code.
    jsr f_draw_char_to_screen_mem ; Print the character.
    inc tmp_x_z               ; Move cursor to the next position.
    inx                       ; Increment index for the message string.
    jmp .loop_print_message
.done:
    rts

; Data: "YOU WIN!" message
you_win_message_addr:
    .byte "YOU WIN!", $00      ; Null-terminated message
