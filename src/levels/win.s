; File: levels/win.s
; Refactored win logic with timer using jiffy clock ticks.

; Subroutine: f_win_screen
; Handles the win animation and transition to the next level.
    subroutine
f_win_screen:
    ; Step 1: Highlight receptors in purple
    jsr f_highlight_receptors

    ; Step 2: Play Goob animation in the top-left corner
    jsr f_animate_goob_top_left

    ; Step 3: Wait for 5 seconds
    lda #5                    ; Duration in seconds
    jsr f_set_timer

.wait_for_timer:
    jsr f_increment_custom_clock ; Update custom clock
    jsr f_check_timer
    bcs .timer_done            ; Exit loop when timer expires
    jmp .wait_for_timer

.timer_done:
    ; Step 4: Clear the screen
    jsr f_clear_screen_win

    ; Step 5: Move to the next level
    jsr f_draw_next_level
    rts

; Subroutine: f_highlight_receptors
; Highlights all receptor characters in purple.
    subroutine
f_highlight_receptors:
    ldx #0
.loop_highlight:
    lda SCREEN_MEM_1,x
    cmp #laser_receptor_t_code
    beq .set_purple
    cmp #laser_receptor_b_code
    beq .set_purple
    jmp .next_char

.set_purple:
    lda #5                    ; Purple color code
    sta COLOUR_MEM_1,x        ; Set color memory
    jmp .next_char

.next_char:
    inx
    bne .loop_highlight       ; Loop until the entire screen is processed
    rts

; Subroutine: f_animate_goob_top_left
; Animates a Goob in the top-left corner of the screen for the win animation.
    subroutine
f_animate_goob_top_left:
    ldx #0                    ; Animation frame toggle
.loop_animation:
    ; Toggle between Goob facing left and right
    lda #5                    ; X position
    sta tmp_x_z
    lda #5                    ; Y position
    sta tmp_y_z
    lda #goob_facing_left_code
    cpx #0                    ; Check toggle
    beq .draw_goob
    lda #goob_facing_right_code

.draw_goob:
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem

    ; Toggle frame
    eor #1
    tax

    ; Pause for 0.5 seconds
    lda #1                    ; 1 second for 2 frames (toggle every half-second)
    jsr f_set_timer

.wait_for_frame:
    jsr f_increment_custom_clock
    jsr f_check_timer
    bcc .wait_for_frame       ; Wait until frame timer expires

    lda tmp_timer_low_z
    cmp #5                    ; Stop after 5 seconds of animation
    bcc .loop_animation

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
