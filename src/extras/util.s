; Simple loop to set all of color mem to black
    subroutine
f_set_color_mem_black:
    ldx #0
.color_stuff_1:                      ; these next 15ish lines set all of color mem to black, so we can see the title screen
    lda #0                          ; foreground black
    sta COLOUR_MEM_1,x
    inx
    txa
    bne .color_stuff_1

.color_stuff_2:
    lda #0
    sta COLOUR_MEM_2,x
    inx
    txa
    bne .color_stuff_2

    rts

    subroutine
f_clear_screen:
.clear_screen_mem_1:
    lda #empty_character_code
    sta SCREEN_MEM_1,x
    inx
    txa
    bne .clear_screen_mem_1

.clear_screen_mem_2:
    lda #empty_character_code
    sta SCREEN_MEM_2,x
    inx
    txa
    bne .clear_screen_mem_2

    rts

; Input Handling Subroutine
    subroutine
f_handle_input:
    jsr f_handle_cursor_movement            ; inputs like WASD, and their possible resulting collisions
    jsr f_handle_cursor_interactions        ; inputs like E and handling the interaction with game objects
    jsr f_clear_all_lasers                  ; clear all lasers from the screen
    jsr f_redraw_lasers                     ; on any input, redraw the lasers being emitted, as the path they take may have changed
    jsr f_draw_cursor                       ; draw the cursor at its new position

    rts

; Checks if the laser didnt collide with anything
; Input:
;    laser_head_x_z: X coordinate
;    laser_head_y_z: Y coordinate
; Output:
;    func_output_low_z: 0 if no collision, 1 if collision
    subroutine
f_check_laser_collision_with_nothing_important:
    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda (screen_mem_addr_coord_z),y
    cmp #empty_character_code
    beq .no_collision
    cmp #laser_horizontal_code
    beq .no_collision
    cmp #laser_vertical_code
    beq .no_collision
    ; cmp #cursor_code
    ; beq .no_collision

    lda #1                          ; we probably collided with something
    sta func_output_low_z
    rts

.no_collision:
    lda #0                          ; we collided with nothing!!!
    sta func_output_low_z
    rts

; Check collision between cursor and walls (game walls + walls inside level)
; This means check collision between the character codes of wall_code, wall_top_code,
; wall_right_code, wall_bottom_code, and wall_left_code, as well as laser shooter and receptor.
; Input:
;    cursor_x_z: cursor x position
;    cursor_y_z: cursor y position
; Output:
;    func_output_low_z: 0 if no collision, 1 if collision
    subroutine
f_check_cursor_collision_with_walls:
    lda cursor_x_z
    sta tmp_x_z
    lda cursor_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda (screen_mem_addr_coord_z),y
    cmp #wall_code
    beq .collision
    cmp #game_wall_top_code
    beq .collision
    cmp #game_wall_right_code
    beq .collision
    cmp #game_wall_bottom_code
    beq .collision
    cmp #game_wall_left_code
    beq .collision
    cmp #laser_shooter_t_code
    beq .collision
    cmp #laser_shooter_b_code
    beq .collision
    cmp #laser_receptor_t_code
    beq .collision
    cmp #laser_receptor_b_code
    beq .collision

    lda #0
    sta wall_collision_flag_z
    sta func_output_low_z

    rts
.collision:
    lda #1
    sta wall_collision_flag_z
    sta func_output_low_z
    rts

; Check collision between cursor and objects the player can pick-up and grab
    subroutine
f_check_cursor_collision_with_level_objects:
    lda cursor_x_z
    sta tmp_x_z
    lda cursor_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda (screen_mem_addr_coord_z),y
    cmp #reflector_1_code
    beq .collision
    cmp #reflector_2_code
    beq .collision
    cmp #portal_code
    beq .collision

    lda #0
    sta obj_collision_flag_z
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta obj_collision_flag_z
    sta func_output_low_z
    rts

; Check collision between cursor and laser beams
    subroutine
f_check_cursor_collision_with_lasers:
    lda cursor_x_z
    sta tmp_x_z
    lda cursor_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda (screen_mem_addr_coord_z),y
    cmp #laser_horizontal_code
    beq .collision
    cmp #laser_vertical_code
    beq .collision

    lda #0
    sta laser_collisiong_flag_z
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta laser_collisiong_flag_z
    sta func_output_low_z
    rts

; Checks if the laser at a given coord would collide with a wall (wall == anything that would stop laser in its tracks)
; Input:
;    laser_head_x_z: X coordinate
;    laser_head_y_z: Y coordinate
; Output:
;    func_output_low_z: 0 if no collision, 1 if collision
    subroutine
f_check_laser_collision_with_walls:
    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda (screen_mem_addr_coord_z),y
    cmp #wall_code
    beq .collision
    cmp #game_wall_top_code
    beq .collision
    cmp #game_wall_right_code
    beq .collision
    cmp #game_wall_bottom_code
    beq .collision
    cmp #game_wall_left_code
    beq .collision
    cmp #cursor_code
    beq .collision
    cmp #laser_shooter_t_code
    beq .collision
    cmp #laser_shooter_b_code
    beq .collision
    cmp #laser_vertical_code
    beq .collision
    cmp #laser_horizontal_code
    beq .collision

    lda #0
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta func_output_low_z
    rts

; Checks if the laser at a given coord would collide with a receptor
; Input:
;    laser_head_x_z: X coordinate
;    laser_head_y_z: Y coordinate
; Output:
;    func_output_low_z: 0 if no collision, 1 if collision, 2 if collision == win!
    subroutine
f_check_laser_collision_with_receptors:
    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr       ; Convert x, y to screen memory address
    lda (screen_mem_addr_coord_z),y           ; Load the character at this screen memory location

    ldx #1
    ; Check if it's a top receptor
    cmp #laser_receptor_t_code
    beq .check_hit_receptor

    ldx #3
    ; Check if it's a bottom receptor
    cmp #laser_receptor_b_code
    beq .check_hit_receptor

    ; No collision
    lda #0
    sta func_output_low_z
    rts

.check_hit_receptor:
    cpx laser_direction_z                   ; Top receptors must be hit from below (laser direction 1 = up). compare A with the value at the addr tmp_collision_var_z
    beq .hit_receptor
    lda #1                                    ; Collision wasn't from the correct direction, so its just a wall collision
    sta func_output_low_z
    rts

.hit_receptor:
    lda #2                                    ; Collision that counts as a win!
    sta func_output_low_z
    rts                                       ; Exit

; Check if the laser hit a reflector
; Input:
;    laser_head_x_z: X coordinate
;    laser_head_y_z: Y coordinate
; Output:
;    func_output_low_z: 0 if no collision, 1 if collision with reflector 1, 2 if collision with reflector 2
    subroutine
f_check_laser_collision_with_reflectors:
    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda (screen_mem_addr_coord_z),y
    ldx #1
    cmp #reflector_1_code
    beq .collision
    ldx #2
    cmp #reflector_2_code
    beq .collision

    ; also check if the covered char is in the way, and if so, if it is currently a reflector, record that as a collision too!
    lda covered_char_x_z
    cmp laser_head_x_z
    bne .no_collision
    lda covered_char_y_z
    cmp laser_head_y_z
    bne .no_collision

    ; laser head is on the loc of the covered char, check if its a reflector
    lda covered_char_code_z
    ldx #1
    cmp #reflector_1_code
    beq .collision
    ldx #2
    cmp #reflector_2_code
    beq .collision

.no_collision:
    lda #0
    sta func_output_low_z
    rts

.collision:
    stx func_output_low_z
    rts

; Checks if the laser collided with a portal
; Input:
;    laser_head_x_z: X coordinate
;    laser_head_y_z: Y coordinate
; Output:
;    func_output_low_z: 0 if no collision, 1 if collision
    subroutine
f_check_laser_collision_with_portals:
    lda laser_head_x_z
    sta tmp_x_z
    lda laser_head_y_z
    sta tmp_y_z
    jsr f_convert_xy_to_screen_mem_addr
    lda (screen_mem_addr_coord_z),y
    cmp #portal_code
    beq .collision

    lda #0
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta func_output_low_z
    rts

    
    



; Converts an (x, y) coordinate to the corresponding screen memory address.
; Input:
;    tmp_x_z: X coordinate
;    tmp_y_z: Y coordinate
; Output: 
;    screen_mem_addr_coord_z (low byte, high byte).
    subroutine
f_convert_xy_to_screen_mem_addr:
	; ; set the screen_mem_addr_coord_z to 0,0, and then build it up from there
	; lda #<GAME_AREA_START
	; sta screen_mem_addr_coord_z
	; lda #>GAME_AREA_START
	; sta screen_mem_addr_coord_z+1

	lda #<SCREEN_MEM_1
	sta screen_mem_addr_coord_z
	lda #>SCREEN_MEM_1
	sta screen_mem_addr_coord_z+1

	; add the columns to the output
	lda tmp_x_z
	clc
	adc screen_mem_addr_coord_z
	sta screen_mem_addr_coord_z
	lda #0
	adc screen_mem_addr_coord_z+1
	sta screen_mem_addr_coord_z+1

	; add the rows to the output
	lda tmp_y_z
	; multiply by 22 becauyse each row has 22 colunms in it
	; load x with how many times we want to repeatedly add 22 to acc
	sta func_arg_1_z
	jsr f_multiply_by_22

    ; Add the low byte of the result to the screen memory address
    lda func_output_low_z    ; Load the low byte of the multiplication result
    clc                      ; Clear carry for addition
    adc screen_mem_addr_coord_z
    sta screen_mem_addr_coord_z

    ; Add the high byte of the result to the high byte of the screen memory address
    lda func_output_high_z   ; Load the high byte of the multiplication result
    adc screen_mem_addr_coord_z+1
    sta screen_mem_addr_coord_z+1

	rts

; ; Converts a screen memory address to an (x, y) coordinate.
; ; Input:
; ;    screen_mem_addr_coord_z: low_byte
; ;    screen_mem_addr_coord_z+1: high_byte
; ; Output:
; ;    tmp_x_z: X coordinate
; ;    tmp_y_z: Y coordinate
;     subroutine
; f_convert_screen_mem_addr_to_xy:
;     ; subtract the base address of the screen mem from the screen_mem_addr_coord_z
;     lda screen_mem_addr_coord_z
;     sec
;     sbc #<SCREEN_MEM_1
;     sta screen_mem_addr_coord_z
;     lda screen_mem_addr_coord_z+1
;     sbc #>SCREEN_MEM_1
;     sta screen_mem_addr_coord_z+1

;     ; divide the result by 22 to get the row
;     ; load x with 22
;     lda #22
;     sta func_arg_1_z
;     jsr f_divide_by_22
;     sta tmp_y_z

;     ; the remainder is the column
;     lda func_output_low_z
;     sta tmp_x_z

;     rts



; perform repeated addition for necessary multiplications
; Input:
;    func_arg_1_z: number of times to add
; Output:
;    func_output_low_z: low byte of the result
;    func_output_high_z: high byte of the result
	subroutine
f_multiply_by_22:
    lda #0                   ; Clear A for the result
    sta func_output_low_z    ; Initialize low byte to 0
    sta func_output_high_z   ; Initialize high byte to 0

    ldx func_arg_1_z         ; Load the multiplier into X
    lda #0                   ; Clear A to use for addition
	jmp .mul_loop_test

.mul_loop:
    clc                      ; Clear carry for addition
    adc #22                  ; Add 22 (multiplicand) to A
    bcc .no_carry            ; If no carry, skip overflow handling
    inc func_output_high_z   ; Increment high byte on carry
.no_carry:
    dex                      ; Decrement X (loop counter)
.mul_loop_test:
	cpx #0                   ; Check if X > 0
    bne .mul_loop            ; Repeat if X > 0
    sta func_output_low_z    ; Store final low byte result
    rts

f_divide_by_22:
    lda #0                   ; Clear A for the result
    sta func_output_low_z    ; Initialize low byte to 0
    sta func_output_high_z   ; Initialize high byte to 0

    ldx #0                   ; Initialize X to 0
    lda #0                   ; Clear A to use for subtraction
    jmp .div_loop_test

.div_loop:
    clc                      ; Clear carry for subtraction
    sbc #22                  ; Subtract 22 (divisor) from A
    bcs .no_borrow           ; If no borrow, skip underflow handling
    inc func_output_high_z   ; Increment high byte on borrow
.no_borrow:
    inx                      ; Increment X (loop counter)
.div_loop_test:
    bcc .div_loop            ; Repeat if A >= 22
    sta func_output_low_z    ; Store final low byte result
    rts