
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