
; If the laser collides with the wall, it should stop drawing more lasers afterwards
    subroutine
f_handle_laser_collision_with_wall:


    rts

; If the laser collides wiht a receptor, check if it hit the receptor from the right side. if so, set that this receptor was hit! otherwise, its like a wall
; Input:
;   func_output_high_z: which receptor orientation was hit (1 through 4)
    subroutine
f_handle_laser_collision_with_receptor:
    ; Load the receptor's coordinates (already set in `laser_head_x_z` and `laser_head_y_z`).
    lda laser_head_x_z              ; Get X coordinate of the receptor
    sta tmp_x_z
    lda laser_head_y_z              ; Get Y coordinate of the receptor
    sta tmp_y_z

    jsr f_convert_xy_to_screen_mem_addr ; Convert to screen memory address.

    ; Change the sprite
    lda func_output_high_z
    ldx #laser_receptor_b_hit_code
    cmp #1
    beq .draw_new_receptor
    ldx #laser_receptor_t_hit_code
    cmp #3
    beq .draw_new_receptor

.draw_new_receptor:
    stx tmp_char_code_z
    jsr f_draw_char_to_screen_mem

    lda #5                               ; green
    sta func_arg_1_z
    jsr f_colour_a_character
    rts

; If the laser collides with a reflector, update reflector sprite, calculate the new direction of the laser, and update laser head to new location
    subroutine
f_handle_laser_collision_with_reflector:
    lda func_output_low_z
    cmp #1
    beq .handle_reflector_1
    cmp #2
    beq .handle_reflector_2

.handle_reflector_1:    
    lda laser_direction_z
    ldx #reflector_1_hit_tr_code            ; reflector 1 character for hit from the top or the right
    ldy #2                                  ; tenative new direction (right) if hit from top
    cmp #3
    beq .hit
    ldy #1                                  ; tenative new direction (up) if hit from right
    cmp #4
    beq .hit
    ldx #reflector_1_hit_bl_code
    ldy #4                                  ; tenative new direction (left) if hit from bottom
    cmp #1
    beq .hit
    ldy #3                                  ; tenative new direction (down) if hit from left
    cmp #2
    beq .hit

.handle_reflector_2:
    lda laser_direction_z
    ldx #reflector_2_hit_tl_code            ; reflector 2 character for hit from the top or the left
    ldy #4                                  ; tenative new direction (left) if hit from top
    cmp #3
    beq .hit
    ldy #1                                  ; tenative new direction (up) if hit from left
    cmp #2
    beq .hit
    ldx #reflector_2_hit_br_code
    ldy #2                                  ; tenative new direction (right) if hit from bottom
    cmp #1
    beq .hit
    ldy #3                                  ; tenative new direction (down) if hit from right
    cmp #4
    beq .hit

.hit:
    sty laser_direction_z                   ; set the new laser direction

    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z
    txa
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem           ; draw the updated reflector sprite

    rts

; If the laser collides with a portal, update portal sprite, and update the laser head to the new location of the portal
    subroutine
f_handle_laser_collision_with_portal:
    ; before moving laser head, change this portal sprite + colour it
    lda laser_direction_z
    ldx #portal_hit_down_code
    cmp #1
    beq .draw_portal_1
    ldx #portal_hit_left_code
    cmp #2
    beq .draw_portal_1
    ldx #portal_hit_up_code
    cmp #3
    beq .draw_portal_1
    ldx #portal_hit_right_code
    cmp #4
    beq .draw_portal_1

.draw_portal_1:
    stx tmp_char_code_z
    jsr f_draw_char_to_screen_mem

    lda #2                          ; red
    sta func_arg_1_z
    jsr f_colour_a_character

    ; now deal with second portal

    lda laser_head_x_z
    cmp portal_1_x_z
    bne .not_portal_1
    lda laser_head_y_z
    cmp portal_1_y_z
    bne .not_portal_1

    ; this portal is portal 1, so move the laser head to portal 2
    lda portal_2_x_z
    sta laser_head_x_z
    lda portal_2_y_z
    sta laser_head_y_z
    jmp .now_draw_portal

.not_portal_1:
    ; this protal is portal 2, so move the laser head to portal 1
    lda portal_1_x_z
    sta laser_head_x_z
    lda portal_1_y_z
    sta laser_head_y_z

.now_draw_portal:
    ; moved the laser head, now draw proper portal sprite at destination portal
    lda laser_direction_z
    ldx #portal_hit_up_code
    cmp #1
    beq .draw_portal_2
    ldx #portal_hit_right_code
    cmp #2
    beq .draw_portal_2
    ldx #portal_hit_down_code
    cmp #3
    beq .draw_portal_2
    ldx #portal_hit_left_code
    cmp #4
    beq .draw_portal_2

.draw_portal_2:
    stx tmp_char_code_z
    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z
    jsr f_draw_char_to_screen_mem

    ; colour the portal red
    lda #2                          ; red
    sta func_arg_1_z
    jsr f_colour_a_character

    rts

; Adds the direction of the laser to the current laser head location
; Requires laser_head_x_z, laser_head_y_z, laser_direction_z to be set prior to calling this
; Changes laser_head_x_z, laser_head_y_z
    subroutine
f_add_direction_to_laser_location:
    lda laser_direction_z
    cmp #1
    beq .add_up
    cmp #2
    beq .add_right
    cmp #3
    beq .add_down
    cmp #4
    beq .add_left

.add_up:
    lda laser_head_y_z
    sec
    sbc #1
    sta laser_head_y_z
    rts

.add_right:
    lda laser_head_x_z
    clc
    adc #1
    sta laser_head_x_z
    rts

.add_down:
    lda laser_head_y_z
    clc
    adc #1
    sta laser_head_y_z
    rts

.add_left:
    lda laser_head_x_z
    sec
    sbc #1
    sta laser_head_x_z
    rts


; Clears all laser characters from the screen, and reset all characters that are in their "laser form" back to default
    subroutine
f_clear_all_laser_stuff:
    ldx #0

.loop_screen_mem_1:
    lda SCREEN_MEM_1,x 
    ldy #empty_character_code
    cmp #laser_vertical_code
    beq .reset_char
    cmp #laser_horizontal_code
    beq .reset_char

    ldy #reflector_1_code
    cmp #reflector_1_hit_tr_code
    beq .reset_char
    cmp #reflector_1_hit_bl_code
    beq .reset_char
    cmp #reflector_1_hit_all_code
    beq .reset_char
    ldy #reflector_2_code
    cmp #reflector_2_hit_tl_code
    beq .reset_char
    cmp #reflector_2_hit_br_code
    beq .reset_char
    cmp #reflector_2_hit_all_code
    beq .reset_char

    ldy #laser_receptor_t_code
    cmp #laser_receptor_t_hit_code
    beq .reset_char
    ldy #laser_receptor_b_code
    cmp #laser_receptor_b_hit_code
    beq .reset_char

    ldy #portal_code
    cmp #portal_hit_up_code
    beq .reset_char
    cmp #portal_hit_right_code
    beq .reset_char
    cmp #portal_hit_down_code
    beq .reset_char
    cmp #portal_hit_left_code
    beq .reset_char

    jmp .next_char_1

.reset_char:
    tya
    sta SCREEN_MEM_1,x
    jmp .next_char_1

.next_char_1:
    inx
    bne .loop_screen_mem_1

.loop_screen_mem_2:
    lda SCREEN_MEM_2,x 
    ldy #empty_character_code
    cmp #laser_vertical_code
    beq .reset_char_2
    cmp #laser_horizontal_code
    beq .reset_char_2

    ldy #reflector_1_code
    cmp #reflector_1_hit_tr_code
    beq .reset_char_2
    cmp #reflector_1_hit_bl_code
    beq .reset_char_2
    cmp #reflector_1_hit_all_code
    beq .reset_char_2
    ldy #reflector_2_code
    cmp #reflector_2_hit_tl_code
    beq .reset_char_2
    cmp #reflector_2_hit_br_code
    beq .reset_char_2
    cmp #reflector_2_hit_all_code
    beq .reset_char_2

    ldy #laser_receptor_t_code
    cmp #laser_receptor_t_hit_code
    beq .reset_char_2
    ldy #laser_receptor_b_code
    cmp #laser_receptor_b_hit_code
    beq .reset_char_2

    ldy #portal_code
    cmp #portal_hit_up_code
    beq .reset_char_2
    cmp #portal_hit_right_code
    beq .reset_char_2
    cmp #portal_hit_down_code
    beq .reset_char_2
    cmp #portal_hit_left_code
    beq .reset_char_2

    jmp .next_char_2

.reset_char_2:
    tya
    sta SCREEN_MEM_2,x
    jmp .next_char_2

.next_char_2:
    inx
    bne .loop_screen_mem_2
    rts