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
    ; first, check collision with immovable objects (cursor shouldn't move)
    jsr f_check_cursor_collision_with_walls
    lda func_output_low_z
    cmp #0                          ; 0 means no collision! move cursor
    beq .move_cursor_up_no_collision
    inc cursor_y_z                  ; otherwise, don't move cursor
.move_cursor_up_no_collision:
    ; finally, check collision with interactable objects
    jmp .level_object_collision_check

.move_cursor_left:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    dec cursor_x_z
    ; first, check collision with immovable objects (cursor shouldn't move)
    jsr f_check_cursor_collision_with_walls
    lda func_output_low_z
    cmp #0                          ; 0 means no collision! move cursor
    beq .move_cursor_left_no_collision
    inc cursor_x_z                  ; otherwise, don't move cursor
.move_cursor_left_no_collision:
    ; finally, check collision with interactable objects
    jmp .level_object_collision_check

.move_cursor_down:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    inc cursor_y_z

    ; first, check collision with immovable objects (cursor shouldn't move)
    jsr f_check_cursor_collision_with_walls
    lda func_output_low_z
    cmp #0                          ; 0 means no collision! move cursor
    beq .move_cursor_down_no_collision
    dec cursor_y_z                  ; otherwise, don't move cursor
.move_cursor_down_no_collision:
    ; finally, check collision with interactable objects
    jmp .level_object_collision_check

.move_cursor_right:
    jsr f_erase_cursor                        ; Erase cursor at previous position
    inc cursor_x_z

    ; first, check collision with immovable objects (cursor shouldn't move)
    jsr f_check_cursor_collision_with_walls
    lda func_output_low_z
    cmp #0                          ; 0 means no collision! move cursor
    beq .move_cursor_right_no_collision
    dec cursor_x_z                  ; otherwise, don't move cursor
.move_cursor_right_no_collision:
    ; finally, check collision with interactable objects
    jmp .level_object_collision_check

; Check collision between cursor and objects the player can pick-up and hold
.level_object_collision_check:
    jsr f_check_cursor_collision_with_level_objects
    lda func_output_low_z
    cmp #0                          ; 0 means we didnt collide with any interactable objects!!
    beq .draw_cursor
    ; otherwise, we collided with an interactable object
    jsr f_handle_collision_with_interactable_object

.draw_cursor:
    jsr f_draw_cursor
    rts

; We collided with an interactable object! Store that in the object_overlayed
    subroutine
f_handle_collision_with_interactable_object:

    rts

    subroutine
f_handle_collision_with_laser:

    rts

; Reests cursor positiont to a hardcoded x,y
    subroutine
f_reset_cursor_position:
    lda #10
    sta cursor_x_z
    lda #10
    sta cursor_y_z
    rts

    subroutine
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

    subroutine
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

