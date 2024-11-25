; Movement Functions

    subroutine
f_handle_cursor_movement:
    lda curr_char_pressed_z
    cmp #KEY_W
    beq .move_cursor_up
    cmp #KEY_A
    beq .move_cursor_left
    cmp #KEY_S
    beq .move_cursor_down
    cmp #KEY_D
    beq .move_cursor_right
    rts
.move_cursor_up
    jsr f_erase_cursor                        ; Erase cursor at previous position
    dec cursor_y_z
    jsr f_draw_cursor
    rts
.move_cursor_left:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    dec cursor_x_z
    jsr f_draw_cursor
    rts
.move_cursor_down:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    inc cursor_y_z
    jsr f_draw_cursor
    rts
.move_cursor_right:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    inc cursor_x_z
    jsr f_draw_cursor
    rts

; Reests cursor positiont to a hardcoded x,y
    subroutine
f_reset_cursor_position:
    lda #10
    sta cursor_x_z
    lda #10
    sta cursor_y_z
    rts

f_erase_cursor:
    lda cursor_x_z
    sta tmp_x_z
    lda cursor_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda #empty_character_code
    ldy #0
    sta (screen_mem_addr_coord_z),y
    rts

f_draw_cursor:
    lda cursor_x_z
    sta tmp_x_z
    lda cursor_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda #cursor_code
    ldy #0
    sta (screen_mem_addr_coord_z),y
    rts