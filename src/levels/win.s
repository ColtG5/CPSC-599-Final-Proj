; f_win_screen: Display a simple win message, recolor lasers green, and wait for E press
; Assumes lasers and other objects remain on screen.


; Just recolor lasers and display text, then wait for E.
    subroutine
f_win_screen:
    ; Step 1: Recolor all lasers to green to signify victory
    jsr f_recolor_stuff_green
    lda #$1D
    sta $900F       ; Store the updated value, now the background is green, border unchanged

    lda #<continue_text_data_start_p
    sta data_addr_low_z
    lda #>continue_text_data_start_p
    sta data_addr_high_z
    lda continue_text_data_start_p
    sta load_addr_low_z
    lda continue_text_data_start_p+1
    sta load_addr_high_z
    jsr f_rle_decoder

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
