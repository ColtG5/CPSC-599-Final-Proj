
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
    cmp #3
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
    stx tmp_char_code_z
    sty laser_direction_z                   ; set the new laser direction

    ; if reflector sprite already a laser variant, make it the full variant!
    lda func_output_low_z
    ldx #reflector_1_hit_all_code
    cmp #2
    beq .draw_full_reflector
    ldx #reflector_2_hit_all_code
    cmp #4
    beq .draw_full_reflector
    jmp .draw_reflector

.draw_full_reflector:
    stx tmp_char_code_z

.draw_reflector
    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z
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
    ldx #0
    ldy #1
    cmp #2                  ; checks for right
    beq .add_dir
    ldy #$ff
    cmp #4                  ; checks for left
    beq .add_dir

    ldx #1
    ldy #$ff
    cmp #1                  ; checks for up
    beq .add_dir
    ldy #1
    cmp #3                  ; checks for down
    beq .add_dir

.add_dir:
    tya
    clc
    adc laser_head_x_z,x        ; use x reg to offset from base addr of laser_head_x_z
    sta laser_head_x_z,x
    rts


; Clears all laser characters from the screen, and reset all characters that are in their "laser form" back to default
    subroutine
f_clear_all_laser_stuff:
    ldy #0
    lda #<SCREEN_MEM_1
    sta load_addr_low_z
    lda #>SCREEN_MEM_1
    sta load_addr_high_z

.loop_screen_mem_1:
    lda (load_addr_low_z),y
    ldx #empty_character_code
    cmp #laser_vertical_code
    beq .reset_char
    cmp #laser_horizontal_code
    beq .reset_char
    cmp #laser_both_code
    beq .reset_char

    ldx #reflector_1_code
    cmp #reflector_1_hit_tr_code
    beq .reset_char
    cmp #reflector_1_hit_bl_code
    beq .reset_char
    cmp #reflector_1_hit_all_code
    beq .reset_char
    ldx #reflector_2_code
    cmp #reflector_2_hit_tl_code
    beq .reset_char
    cmp #reflector_2_hit_br_code
    beq .reset_char
    cmp #reflector_2_hit_all_code
    beq .reset_char

    ldx #laser_receptor_t_code
    cmp #laser_receptor_t_hit_code
    beq .reset_char
    ldx #laser_receptor_b_code
    cmp #laser_receptor_b_hit_code
    beq .reset_char

    ldx #portal_code
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
    txa
    sta (load_addr_low_z),y
    jmp .next_char_1

.next_char_1:
    iny
    bne .loop_screen_mem_1

    inc load_addr_high_z
    lda #$20
    cmp load_addr_high_z
    bne .loop_screen_mem_1

.done:
    rts