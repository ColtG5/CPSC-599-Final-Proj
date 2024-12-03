; function that draws the next level
    subroutine
f_draw_next_level:
    ; draw level template first
    jsr f_draw_level_template

    ; then draw specific level data (+ level num in top right)
    jsr f_draw_level_data


    rts


; function that draws the template for a level (top score, game border, etc.)
    subroutine
f_draw_level_template:
.set_data_addrs:                            ; set addrs for where the binary data exists in our prog
    lda #<level_template_data_start_p
    sta data_addr_low_z
    lda #>level_template_data_start_p
    sta data_addr_high_z

.set_load_addrs:                            ; set adds for where the data will load into (first 2 bytes of encoded data are the load address)
    lda level_template_data_start_p
    sta load_addr_low_z
    lda level_template_data_start_p+1
    sta load_addr_high_z

    jsr f_rle_decoder                       ; decode the level template data and write it to screen mem

    rts



; function that draws all the dynamic level data
    subroutine
f_draw_level_data:
    ; put the correct num in the top right for level indicator

    ; draw the dynamic level data from the appropriate level bin

    lda what_level_tracker_z
    asl                      ; level_tracker * 2 (level pointers are 2 bytes big)
    tax                      ; store in x to offset with below

    lda level_pointers_p,x     ; get the correct level data start addr
    sta data_addr_low_z        ; Store low byte of level data address
    lda level_pointers_p+1,x   ; get the correct level data start addr
    sta data_addr_high_z       ; Store high byte of level data address

    ldy #0
    sty level_data_tracker_z  ; Initialize level data tracker
.loop_draw_level_data:
    ldy level_data_tracker_z  ; Load level data tracker
    lda (data_addr_low_z),y    ; Read byte from level data
    cmp #$FF                    ; Check if end of data 
    beq .end_of_data         ; Stop if end of data (0 byte)

    sta tmp_char_code_z        ; Temporarily store character code
    iny                      ; Increment index

    lda (data_addr_low_z),y    ; Read X coordinate
    sta tmp_x_z
    iny

    lda (data_addr_low_z),y    ; Read Y coordinate
    ; sec
    ; sbc #LEVEL_TEMP_ROWS
    sta tmp_y_z
    iny
    sty level_data_tracker_z  ; remember where we are in the level data

    jsr f_draw_char_to_screen_mem          ; Draw the character at (tmp_x_z, tmp_y_z)
    jmp .loop_draw_level_data

.end_of_data:
    rts

; draws a character to the screen mem at the given x,y
; Input:
;    tmp_x_z: X coordinate
;    tmp_y_z: Y coordinate
;    tmp_char_code_z: character code
    subroutine
f_draw_char_to_screen_mem:
    ; get the screen mem addr for the char, and draw it 
    jsr f_convert_xy_to_screen_mem_addr

    lda tmp_char_code_z
    ldy #0
    sta (screen_mem_addr_coord_z),y     ; Draw the character to screen mem

    rts

; Draws the covered char back on to the screen when moved off of its location
    subroutine
f_draw_covered_char_back_into_place:
    lda covered_char_x_z
    sta tmp_x_z
    lda covered_char_y_z
    sta tmp_y_z
    lda covered_char_code_z
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    rts

; Calculates the path that each laser will take from each laser shooter, and correctly draws that path to the screen
    subroutine
f_redraw_lasers:
    ; pseudocode:
    ; for each laser shooter:
    ;   set starting loc, and figure out what direction the laser emits from
    ;   (if this shooter is a laser_shooter_t, then start loc is 1 below this since it is an shooter on the top, and the direction is down)
    ;   then, **while the laser is not hitting a wall or a reflector**, draw the laser path
    ;       from current *head* of laser path, check the next location in the direction of the laser
    ;       if the next location is a wall/immovable object, break out of this loop to stop drawing the laser path, and set head to none
    ;       if the next location is a receptor, check that we are approaching this receptor from the correct direction (a laser_receptor_t can only be approached from the bottom, etc.)
    ;           if we are, then break loop and set a variable or smthn to say that this receptor was hit, and counts towards the level win condition
    ;           if we aren't, then do same logic as essentially hitting a wall
    ;       if the next location is a reflector, update the direction of the laser path and update the reflector to the new appropriate reflector sprite
    ;       if the next location is a portal, update the head of the laser path to the other portal location. Change this portals sprite to the appropriate sprite
    ;       if the next location is empty space, draw the laser path to this location and update the head of the laser path to this location

    ; reset the win condition for the level back to the total number of receptors in the level
    ; whenever we find a receptor being hit by a laser, we decrement this variable
    lda num_of_receptors_in_level_z
    sta receptors_not_hit_z

    jsr f_reset_find_next_laser_shooter                 ; reset trackers and counters for finding laser shooters
.loop_find_next_laser_shooter:
    jsr f_find_next_laser_shooter
    cmp #$FF
    beq .no_more_shooters

    ; set laser shooter position to laser_head, setting it as the start of the laser
    lda tmp_x_z
    sta laser_head_x_z
    lda tmp_y_z
    sta laser_head_y_z


.loop_draw_laser_path:
    ; each iter of the laser path loop, we get the next location of the laser path, and check if it collides with anything

    ; add the direction of the laser to the current laser head location, to get our next location along the laser path!
    jsr f_add_direction_to_laser_location

    ; figure out if the next location of the laser path will collide with something, or if we can continue drawing the path

.laser_walls_check:
    ; check the millions of types of collisions that can happen with a laser
    jsr f_check_laser_collision_with_walls          ; a collision with "walls" means just stop drawing the laser path since it hit an immovable object
    lda func_output_low_z
    cmp #0                                  ; if we didnt hit a wall, then check next laser collision check
    beq .laser_receptors_check
    ; otherwise, handle the collision with the wall
    jsr f_handle_laser_collision_with_wall
    jmp .loop_draw_laser_path_done

.laser_receptors_check:
    jsr f_check_laser_collision_with_receptors      ; a collision with a receptor means we hit a receptor, and we need to check if we hit it from the correct direction
    lda func_output_low_z
    cmp #0                                  ; if we didn't hit a receptor, go to next laser collision check
    beq .laser_reflectors_check
    ; otherwise, we hit a receptor, and we need to check if we hit it from the correct direction
    lda func_output_low_z
    cmp #1                              ; if we hit a receptor (in the wrong direction), then stop drawing the laser path
    beq .receptor_hit_wrong
    ; otherwise, we hit a receptor (in the correct direction), then stop drawing the laser path, and say we have one less receptor being hit!
    dec receptors_not_hit_z
    cmp #0                              ; if we hit the last receptor, early exit outta here since level is done fr
    beq .no_more_shooters               ; i mean this should be fine right? we only ever hit the last receptor on calcuating the last laser shooter line anyways right!
    ; otherwise, check next condition that could stop our laser
    jmp .laser_reflectors_check

.receptor_hit_wrong:
    jsr f_handle_laser_collision_with_wall
    jmp .loop_draw_laser_path_done

.laser_reflectors_check:
    jsr f_check_laser_collision_with_reflectors         ; a collision with a reflector means we need to update the direction of the laser path (and change reflector sprite!)
    lda func_output_low_z
    cmp #0                                              ; if we didn't hit a reflector, then check next laser collision check
    beq .laser_portals_check
    ; otherwise, we hit a reflector, and we need to handle that!
    jsr f_handle_laser_collision_with_reflector
    jmp .loop_draw_laser_path_done

.laser_portals_check:
    jsr f_check_laser_collision_with_portals            ; a collision with a portal means we need to update the head of the laser path to the other portal location
    lda func_output_low_z
    cmp #0                                              ; if we didn't hit a portal, then theres no more laser collisions to check!!
    beq .draw_laser
    ; otherwise, we hit a portal, and we need to handle that!
    jsr f_handle_laser_collision_with_portal
    jmp .loop_draw_laser_path_done

; if we made it here, then we avoided every collision check, so we can draw a regular laser character at this location!
.draw_laser:
    ; draw a laser chartacter at this location
    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z

    ; if the laser direction is 1 or 3 (vertical), then it should be a vertical laser character, and vice-versa
    lda laser_direction_z
    cmp #1
    beq .draw_vertical_laser
    cmp #3
    beq .draw_vertical_laser
    ; otherwise, draw a horizontal laser character
.draw_horizontal_laser:
    lda #laser_horizontal_code
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    jmp .loop_draw_laser_path               ; continue drawing the laser path

.draw_vertical_laser:
    lda #laser_vertical_code
    sta tmp_char_code_z
    jsr f_draw_char_to_screen_mem
    jmp .loop_draw_laser_path               ; continue drawing the laser path

.loop_draw_laser_path_done:
    ; done drawing this laser path
    jmp .loop_find_next_laser_shooter

.no_more_shooters:
    rts

; Loops through the level data for the current level and finds the x,y of the starting spot for a laser from a laser emitter
; Make sure the data_addr_low_z and data_addr_high_z are set to the correct level data address before calling this (done in reset func!)
; Output:
;    tmp_x_z: x coord of a laser emitter
;    tmp_y_z: y coord of a laser emitter
;    laser_direction_z: the direction that this laser shooter
    subroutine
f_find_next_laser_shooter:
.loop_find_next_laser_shooter:
    ldy level_data_tracker_z                    ; load level data tracker into Y
    lda (level_data_addr_low_z),y                 ; read byte from level data
    cmp #$FF                               ; check if end of data
    beq .no_more_laser_shooters             ; stop if end of data (0 byte)

    lda #3                                  ; if branch below taken, laser is shot in direction down (3)
    sta laser_direction_z
    cmp #laser_shooter_t_code
    beq .found_laser_shooter
    lda #1                                  ; if branch below taken, laser is shot in direction up (1)
    sta laser_direction_z
    cmp #laser_shooter_b_code
    beq .found_laser_shooter

    lda #0                                  ; no laser shooter found, discard next x,y, and move on to next char code
    iny
    iny
    iny
    sty level_data_tracker_z                ; update pointer for level data traversal
    jmp .loop_find_next_laser_shooter


.found_laser_shooter:
    iny
    lda (data_addr_low_z),y                 ; read x coord
    sta tmp_x_z
    iny
    lda (data_addr_low_z),y                 ; read y coord
    sta tmp_y_z
    iny
    sty level_data_tracker_z                ; update pointer for level data traversal
    rts

.no_more_laser_shooters:
    lda #$FF
    sta tmp_x_z
    sta tmp_y_z
    sta laser_direction_z

    rts

; Resets all the variables and pointers for find_next_laser_shooter
; Call this when you are starting the loop again to iteratively get each laser shooter from the level data
    subroutine
f_reset_find_next_laser_shooter:
    ; set the level data tracker to the beginning of the level data of the current level
    lda what_level_tracker_z
    asl
    tax

    lda level_pointers_p,x
    sta level_data_addr_low_z
    lda level_pointers_p+1,x
    sta level_data_addr_high_z

    ; reset zero page addresses we use
    lda #0
    sta level_data_tracker_z
    rts