; Movement Functions

    subroutine
f_handle_cursor_movement:
; before we move cursor, store what we got now into the prev cursor spots
    jsr f_remember_cursor_position

    lda curr_char_pressed_z
    cmp #KEY_W
    beq .move_cursor_up
    cmp #KEY_A
    beq .move_cursor_left
    cmp #KEY_S
    beq .move_cursor_down
    cmp #KEY_D
    beq .move_cursor_right
    jmp .after_wall_collision_check
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
    ; then, go check the next collisions
    jmp .after_wall_collision_check

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
    ; then, go check the next collisions
    jmp .after_wall_collision_check

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
    ; then, go check the next collisions
    jmp .after_wall_collision_check

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
    ; then, go check the next collisions
    jmp .after_wall_collision_check

.after_wall_collision_check:

; secondly, not really a collision check, but check if we were covering a char, but now arent (so we can draw old char back into place)
.leaving_covered_char_check:
    jsr f_check_if_previously_covered_char      ; check if we were covering a char
    lda func_output_low_z
    cmp #0                                      ; 0 means we werent covering a char, branch to next check
    beq .level_object_collision_check
    ; otherwise, we were covering a char, but now arent! draw the char back into place
    jsr f_draw_covered_char_back_into_place
    ; also clear covered char since we aint covering one anymore
    jsr f_clear_covered_char_in_mem

    ; jsr f_clear_all_laser_stuff

; thirdly, check collision with interactable objects
.level_object_collision_check:
    jsr f_check_cursor_collision_with_level_objects
    lda func_output_low_z
    cmp #0                              ; 0 means we didnt collide with any interactable objects!!
    beq .laser_collision_check          ; move to next collision check
    ; otherwise, we collided with an interactable object
    jsr f_handle_collision_with_interactable_object

; fourthly and finally, check collision with laser beams
.laser_collision_check:
    jsr f_check_cursor_collision_with_lasers
    lda func_output_low_z
    cmp #0                          ; 0 means we didnt collide with any laser beams!!
    beq .draw_cursor_and_done
    ; otherwise, we collided with a laser beam! handle that?
    jsr f_handle_collision_with_laser

.draw_cursor_and_done:
    ; jsr f_draw_cursor
    rts

; Handle the cursor interacting with game objects
    subroutine
f_handle_cursor_interactions:
    lda curr_char_pressed_z
    cmp #KEY_E
    bne .done

; if pressing E, that means we are either placing down an object or picking up an object. 
; if inventory item is empty, then we are picking up an object
    lda inventory_item_z
    cmp #empty_character_code
    beq .try_picking_up_object                  ; inv is empty, so try to pick up a new object!
                                                ; otherwise, if something in inv, we can only place down an object.

.try_placing_down_object:
    ; if we are NOT covering a character, since our inv is NOT empty, and we pressed E, place char here!
    lda covered_char_code_z
    cmp #empty_character_code
    bne .done
    jsr f_place_char_from_inventory
    ; jsr f_clear_all_laser_stuff                          ; if we placed a level object, that may change laser path, clear the lasers!
    jmp .done

.try_picking_up_object:
    ; if we are covering a chartacter, since our inv is empty, and we pressed E, add it to our inv!
    lda covered_char_code_z
    cmp #empty_character_code
    beq .done
    jsr f_add_char_to_inventory
    ; jsr f_clear_all_laser_stuff                          ; if we picked up a level object, that may change laser path, clear the lasers!
    jmp .done

.done:
    ; draw state of inventory since it might've changed
    jsr f_draw_inventory
    rts

; Checks if the previous position of cursor was covering a char
; Inputs:
;    covered_char_x_z: this needs to be set!
;    covered_char_y_z: this too
;    last_cursor_x_z: also need to know where our cursor just was
;    last_cursor_y_z:
; Outputs:
;    func_output_low_z: 0 if we werent covering a char, 1 if we were
    subroutine
f_check_if_previously_covered_char:
; if last cursor pos is equal to the coevred char x, and thye covered char y, then we covered it last move!
    lda last_cursor_x_z
    sec
    sbc covered_char_x_z
    bne .not_covering_char
    lda last_cursor_y_z
    sec
    sbc covered_char_y_z
    bne .not_covering_char
    lda #1
    sta func_output_low_z
    sta was_covering_char_z
    rts

.not_covering_char:
    lda #0
    sta func_output_low_z
    sta was_covering_char_z
    rts

; We collided with an interactable object! Store that in the covered_char stuff
    subroutine
f_handle_collision_with_interactable_object:
    lda tmp_x_z
    sta covered_char_x_z
    lda tmp_y_z
    sta covered_char_y_z
    lda (screen_mem_addr_coord_z),y ; result in this addr should still be from the collision check we did before this, so dont need to convert x,y again

    ; if we are covering a char code that is a character to represent getting hit by a laser

    sta covered_char_code_z

    rts

    subroutine
f_handle_collision_with_laser:

    rts

; Reests cursor positiont to a hardcoded x,y
    subroutine
f_reset_cursor_position:
    lda #10
    sta cursor_x_z
    sta last_cursor_x_z
    lda #10
    sta cursor_y_z
    sta last_cursor_y_z
    rts

; Called at the end of game_loop, so the next cursor movement knows where the cursor came from
    subroutine
f_remember_cursor_position:
    lda cursor_x_z
    sta last_cursor_x_z
    lda cursor_y_z
    sta last_cursor_y_z
    rts

; Erase the cursor at its current spot (used before moving it!)
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

; Erase the covered char from our memory (we moved away from it or picked it up)
    subroutine
f_clear_covered_char_in_mem:
    lda #empty_character_code
    sta covered_char_code_z
    lda #$ff
    sta covered_char_x_z
    sta covered_char_y_z
    rts

; Draws the cursor at its current spot
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

