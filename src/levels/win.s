; File: levels/win.s
; Simplified win logic: Display 4 Goobs, wait, then transition to the next level.

; Subroutine: f_win_screen
; Displays a simple win screen with 4 Goobs and transitions to the next level.
    subroutine
f_win_screen:
    ; Step 1: Clear the screen
    jsr f_clear_screen_win

    ; Step 2: Display 4 Goobs
    jsr f_display_4_goobs

    ; Step 3: Wait for 2 seconds (120 jiffies)
    lda #120                 ; 2 seconds at 60Hz
    sta tmp_pause_duration_z
    jsr f_jiffy_pause

    ; Step 4: Clear the screen
    jsr f_clear_screen_win

    ; Step 5: Move to the next level
    jsr f_draw_next_level
    rts

; Subroutine: f_display_4_goobs
; Prints 4 Goobs at fixed positions.
    subroutine
f_display_4_goobs:
    ; Goob 1 (top-left)
    lda #5                  ; X coordinate
    sta tmp_x_z
    lda #5                  ; Y coordinate
    sta tmp_y_z
    lda #goob_facing_left_code
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem

    ; Goob 2 (top-right)
    lda #15                 ; X coordinate
    sta tmp_x_z
    lda #5                  ; Y coordinate
    sta tmp_y_z
    lda #goob_facing_right_code
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem

    ; Goob 3 (bottom-left)
    lda #5                  ; X coordinate
    sta tmp_x_z
    lda #10                 ; Y coordinate
    sta tmp_y_z
    lda #goob_facing_left_code
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem

    ; Goob 4 (bottom-right)
    lda #15                 ; X coordinate
    sta tmp_x_z
    lda #10                 ; Y coordinate
    sta tmp_y_z
    lda #goob_facing_right_code
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem

    rts

; Subroutine: f_clear_screen_win
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

; Subroutine: f_jiffy_pause
; Pauses execution for a specified number of jiffies.
; Input: tmp_pause_duration_z (number of jiffies to pause)
; Uses: tmp_timer_low_z, tmp_timer_high_z
    subroutine
f_jiffy_pause:
    lda $A0               ; Read current jiffy clock low byte
    sta tmp_timer_low_z
    lda $A1               ; Read current jiffy clock middle byte
    sta tmp_timer_high_z

.wait_loop:
    lda $A0               ; Read current jiffy clock low byte
    sec                   ; Calculate elapsed time
    sbc tmp_timer_low_z
    lda $A1               ; Read current jiffy clock middle byte
    sbc tmp_timer_high_z
    cmp tmp_pause_duration_z ; Compare elapsed time with duration
    bcc .wait_loop        ; Wait until the specified duration has passed
    rts
