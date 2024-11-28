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
    cmp #wall_top_code
    beq .collision
    cmp #wall_right_code
    beq .collision
    cmp #wall_bottom_code
    beq .collision
    cmp #wall_left_code
    beq .collision
    cmp #laser_shooter_code
    beq .collision
    cmp #laser_receptor_code
    beq .collision

    lda #0
    sta collision_flag_z
    sta func_output_low_z

    rts
.collision:
    lda #1
    sta collision_flag_z
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
    sta collision_flag_z
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta collision_flag_z
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
    sta collision_flag_z
    sta func_output_low_z
    rts

.collision:
    lda #1
    sta collision_flag_z
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
;    func_output_1_z: result of the multiplication
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
