
; If the laser collides with the wall, it should stop drawing more lasers afterwards, by setting laser head to none
    subroutine
f_handle_laser_collision_with_wall:


    rts

; If the laser collides wiht a receptor, check if it hit the receptor from the right side. if so, set that this receptor was hit! otherwise, its like a wall
    subroutine
f_handle_laser_collision_with_receptor:


    rts

; If the laser collides with a reflector, update reflector sprite, calculate the new direction of the laser, and update laser head to new location
    subroutine
f_handle_laser_collision_with_reflector:
    lda func_output_low_z
    cmp #1
    beq .handle_reflector_1
    cmp #2
    beq .handle_reflector_2
    rts                                     ; should never happen, if we call handle, we should've collided with a refector

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

; Clears all laser characters from the screen
    subroutine
f_clear_all_lasers:
    ldx #0

.loop_screen_mem_1:
    lda SCREEN_MEM_1,x 
    cmp #laser_vertical_code
    beq .clear_laser
    cmp #laser_horizontal_code
    beq .clear_laser
    jmp .next_char_1

.clear_laser:
    lda #empty_character_code
    sta SCREEN_MEM_1,x

.next_char_1:
    inx
    bne .loop_screen_mem_1

.loop_screen_mem_2:
    lda SCREEN_MEM_2,x 
    cmp #laser_vertical_code
    beq .clear_laser_2
    cmp #laser_horizontal_code
    beq .clear_laser_2
    jmp .next_char_2

.clear_laser_2:
    lda #empty_character_code
    sta SCREEN_MEM_2,x

.next_char_2:
    inx
    bne .loop_screen_mem_2

    rts