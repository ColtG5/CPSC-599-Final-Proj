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

    rts

; Colours a character at a position
; Inputs:
;   - screen_mem_addr_coord_z: The screen memory address of the character to colour (just call f_convert_xy_to_screen_mem_addr before this)
;   - func_arg_1_z: The colour to set the character to
; 
    subroutine
f_colour_a_character:
    lda screen_mem_addr_coord_z           ; Load the low byte of the screen address
    clc
    adc #<COLOUR_MEM_1 - <SCREEN_MEM_1    ; Calculate the offset for color memory
    sta tmp_addr_lo_z
    lda screen_mem_addr_coord_z+1         ; Load the high byte of the screen address
    adc #>COLOUR_MEM_1 - >SCREEN_MEM_1
    sta tmp_addr_hi_z

    lda func_arg_1_z                      ; Load the colour to set
    ldy #0
    sta (tmp_addr_lo_z),y                 ; Set the color in the color memory
    rts

; used when trying to place a portal, checks if cursor is neighbouring a wall
; Output:
;    func_output_low_z: 0 if not close to wall, 1 if close to wall
    subroutine
f_close_to_wall:
    jsr f_put_cursor_into_temp
    dec tmp_y_z                         ; check above cursor
    jsr f_get_char_from_screen_mem
    cmp #wall_code
    beq .close_to_wall

    jsr f_put_cursor_into_temp
    inc tmp_x_z                         ; check right of cursor
    jsr f_get_char_from_screen_mem
    cmp #wall_code
    beq .close_to_wall

    jsr f_put_cursor_into_temp
    inc tmp_y_z                         ; check below cursor
    jsr f_get_char_from_screen_mem
    cmp #wall_code
    beq .close_to_wall

    jsr f_put_cursor_into_temp
    dec tmp_x_z                         ; check left of cursor
    jsr f_get_char_from_screen_mem
    cmp #wall_code
    beq .close_to_wall

    lda #0
    sta func_output_low_z
    rts

.close_to_wall:
    lda #1
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
    jsr f_put_cursor_into_temp
    jsr f_get_char_from_screen_mem
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
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta func_output_low_z
    rts

; Check collision between cursor and objects the player can pick-up and grab
    subroutine
f_check_cursor_collision_with_level_objects:
    jsr f_put_cursor_into_temp
    jsr f_get_char_from_screen_mem
    cmp #reflector_1_code
    beq .collision
    ; cmp #reflector_1_hit_tr_code
    ; beq .collision
    ; cmp #reflector_1_hit_bl_code
    ; beq .collision
    cmp #reflector_2_code
    beq .collision
    ; cmp #reflector_2_hit_tl_code
    ; beq .collision
    ; cmp #reflector_2_hit_br_code
    ; beq .collision
    cmp #portal_code
    beq .collision

    lda #0
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta func_output_low_z
    rts

; Check collision between cursor and laser beams
    subroutine
f_check_cursor_collision_with_lasers:
    jsr f_put_cursor_into_temp
    jsr f_get_char_from_screen_mem
    cmp #laser_horizontal_code
    beq .collision
    cmp #laser_vertical_code
    beq .collision

    lda #0
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta func_output_low_z
    rts

; ; Checks if the laser didnt collide with anything
; ; Input:
; ;    laser_head_x_z: X coordinate
; ;    laser_head_y_z: Y coordinate
; ; Output:
; ;    func_output_low_z: 0 if no collision, 1 if collision
;     subroutine
; f_check_laser_collision_with_nothing_important:
;     lda laser_head_x_z
;     sta tmp_x_z
;     lda laser_head_y_z
;     sta tmp_y_z
;     jsr f_convert_xy_to_screen_mem_addr
;     ldy #0
;     lda (screen_mem_addr_coord_z),y
;     cmp #empty_character_code
;     beq .no_collision
;     cmp #laser_horizontal_code
;     beq .no_collision
;     cmp #laser_vertical_code
;     beq .no_collision
;     ; cmp #cursor_code
;     ; beq .no_collision

;     lda #1                          ; we probably collided with something
;     sta func_output_low_z
;     rts

; .no_collision:
;     lda #0                          ; we collided with nothing!!!
;     sta func_output_low_z
;     rts


; Checks if the laser at a given coord would collide with a wall (wall == anything that would stop laser in its tracks)
; Input:
;    laser_head_x_z: X coordinate
;    laser_head_y_z: Y coordinate
; Output:
;    func_output_low_z: 0 if no collision, 1 if collision
    subroutine
f_check_laser_collision_with_walls:
    jsr f_put_laser_into_temp
    jsr f_get_char_from_screen_mem
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
    ; cmp #cursor_code
    ; beq .collision
    cmp #laser_shooter_t_code
    beq .collision
    cmp #laser_shooter_b_code
    beq .collision
    ; cmp #laser_vertical_code
    ; beq .collision
    ; cmp #laser_horizontal_code
    ; beq .collision

    sty func_output_low_z
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
;    func_output_high_z: 1 if top receptor, 3 if bottom receptor
    subroutine
f_check_laser_collision_with_receptors:
    jsr f_put_laser_into_temp
    jsr f_get_char_from_screen_mem

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
    stx func_output_high_z                    ; record what type of receptor was hit (to easily get correct sprite for updating receptor later)
    rts

; Check if the laser hit a reflector
; Input:
;    laser_head_x_z: X coordinate
;    laser_head_y_z: Y coordinate
; Output:
;    func_output_low_z: 0 if no collision, 1 if collision with reflector 1, 2 if collision with reflector 2
    subroutine
f_check_laser_collision_with_reflectors:
    jsr f_put_laser_into_temp
    jsr f_get_char_from_screen_mem
    ldx #1
    cmp #reflector_1_code
    beq .collision
    ldx #2
    cmp #reflector_1_hit_tr_code
    beq .collision
    cmp #reflector_1_hit_bl_code
    beq .collision
    ldx #3
    cmp #reflector_2_code
    beq .collision
    ldx #4
    cmp #reflector_2_hit_tl_code
    beq .collision
    cmp #reflector_2_hit_br_code
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
    ldx #3
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
    jsr f_put_laser_into_temp
    jsr f_get_char_from_screen_mem
    cmp #portal_code
    beq .collision

    ; also check if the covered char is in the way, and if so, if it is currently a portal, record that as a collision too!
    lda covered_char_x_z
    cmp laser_head_x_z
    bne .no_collision
    lda covered_char_y_z
    cmp laser_head_y_z
    bne .no_collision

    ; laser head is on the loc of the covered char, check if its a portal
    lda covered_char_code_z
    cmp #portal_code
    beq .collision

.no_collision:
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


