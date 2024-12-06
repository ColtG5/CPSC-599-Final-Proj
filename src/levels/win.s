; f_win_screen: Display a simple win message, recolor lasers green, and wait for E press
; Assumes lasers and other objects remain on screen.


; Just recolor lasers and display text, then wait for E.
    subroutine
f_win_screen:
    ; Step 1: Recolor all lasers to green to signify victory
    jsr f_recolor_stuff_green
    lda #$1D
    sta $900F       ; Store the updated value, now the background is green, border unchanged


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
    lda #24    ; Border = 0 (black), Background = 0 (black)
    sta $900F
    rts
 
    subroutine
f_recolor_stuff_green:
    ldy #0
    lda #<SCREEN_MEM_1
    sta load_addr_low_z
    lda #>SCREEN_MEM_1
    sta load_addr_high_z
    lda #<COLOUR_MEM_1
    sta tmp_addr_lo_z
    lda #>COLOUR_MEM_1
    sta tmp_addr_hi_z

.loop_screen_mem_1:
    lda (load_addr_low_z),y
    cmp #laser_vertical_code
    beq .recolor_char
    cmp #laser_horizontal_code
    beq .recolor_char
    cmp #laser_both_code
    beq .recolor_char
    cmp #reflector_1_hit_tr_code
    beq .recolor_char
    cmp #reflector_1_hit_bl_code
    beq .recolor_char
    cmp #reflector_1_hit_all_code
    beq .recolor_char
    cmp #reflector_2_hit_tl_code
    beq .recolor_char
    cmp #reflector_2_hit_br_code
    beq .recolor_char
    cmp #reflector_2_hit_all_code
    beq .recolor_char
    cmp #portal_hit_up_code
    beq .recolor_char
    cmp #portal_hit_right_code
    beq .recolor_char
    cmp #portal_hit_down_code
    beq .recolor_char
    cmp #portal_hit_left_code
    beq .recolor_char

    jmp .next_char_1

.recolor_char:

    ; sty tmp_index                         ; Use Y for indexing 
    lda #5
    sta (tmp_addr_lo_z),y                 ; Set color to green

    jmp .next_char_1

.next_char_1:
    iny
    bne .loop_screen_mem_1

    inc tmp_addr_hi_z
    inc load_addr_high_z
    lda #$20
    cmp load_addr_high_z
    bne .loop_screen_mem_1

.done:
    rts
