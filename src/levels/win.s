; f_win_screen: Display a simple win message, recolor lasers green, and wait for E press
; Assumes lasers and other objects remain on screen.


; Just recolor lasers and display text, then wait for E.
    subroutine
f_win_screen:
    ; Step 1: Recolor all lasers to green to signify victory
    jsr f_recolor_lasers_green

    ; Step 2: Print "Level Complete! Press E to continue" on screen
    lda #0
    sta tmp_x_z
    lda #0
    sta tmp_y_z
    ; "LEVEL COMPLETE!"
    ldx #0
    ; Set cursor to top-left corner (0,0)
    lda #0
    sta tmp_x_z
    lda #0
    sta tmp_y_z

    ; Print "PRESS"
    lda #144    ; 'P'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #146    ; 'R'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #133    ; 'E'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #147    ; 'S'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #147    ; 'S'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #160    ; ' ' (space)
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    ; Print "E"
    lda #133    ; 'E'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #160    ; ' ' (space)
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    ; Print "TO"
    lda #148    ; 'T'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #143    ; 'O'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #160    ; ' '
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    ; Print "CONTINUE"
    lda #131    ; 'C'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #143    ; 'O'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #142    ; 'N'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #148    ; 'T'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #137    ; 'I'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #142    ; 'N'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #149    ; 'U'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    lda #133    ; 'E'
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    inc tmp_x_z

    ; Step 3: Wait for E key press
.wait_for_e:
    jsr GETIN
    cmp #KEY_E
    bne .wait_for_e

    ; E pressed, return to caller (which should move to next level)
    rts


; f_recolor_lasers_green:
; Iterate over screen mem and wherever we see vertical/horizontal laser chars,
; set their color to green (5).
    subroutine
f_recolor_lasers_green:
    ldx #0
.loop_mem_1:
    lda SCREEN_MEM_1,x
    cmp #laser_vertical_code
    beq .recolor_1
    cmp #laser_horizontal_code
    beq .recolor_1
    jmp .next_1

.recolor_1:
    lda #5       ; green
    sta COLOUR_MEM_1,x
.next_1:
    inx
    bne .loop_mem_1

    ldx #0
.loop_mem_2:
    lda SCREEN_MEM_2,x
    cmp #laser_vertical_code
    beq .recolor_2
    cmp #laser_horizontal_code
    beq .recolor_2
    jmp .next_2

.recolor_2:
    lda #5       ; green
    sta COLOUR_MEM_2,x
.next_2:
    inx
    bne .loop_mem_2

    rts
