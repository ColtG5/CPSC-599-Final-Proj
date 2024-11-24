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

; Check collision between cursor and anything in the level
    subroutine
f_check_collision:
    
    
    rts


; Converts an (x, y) coordinate to the corresponding screen memory address.
; Input: X = x-coordinate, Y = y-coordinate (relative to the game area)
; Output: Screen memory address is stored in screen_mem_addr_coord_z (low byte, high byte).
    subroutine
f_convert_xy_to_screen_mem_addr:
    lda #0
    sta x_y_to_screen_mem_output
    sta x_y_to_screen_mem_output+1

    ; ; Calculate row offset
    ; tya                         ; Load Y (row) into A
    ; clc                         ; Clear carry for addition
    ; adc #3                      ; Offset by 3 to account for top rows
    ; sta TMP_Y                   ; Store adjusted Y temporarily

    ; ; Calculate column offset
    ; txa                         ; Load X (column) into A
    ; ; clc                         ; Clear carry for addition
    ; ; adc #1                      ; Offset by 1 to account for leftmost column
    ; sta TMP_X                   ; Store adjusted X temporarily

    ; Calculate screen memory address
    lda #<SCREEN_MEM_1
    sta x_y_to_screen_mem_output+1
    lda #>SCREEN_MEM_2
    sta x_y_to_screen_mem_output

    ; Calculate row offset
    lda TMP_Y
    clc
    adc x_y_to_screen_mem_output+1
    sta x_y_to_screen_mem_output+1

    ; Calculate column offset
    lda TMP_X
    clc
    adc x_y_to_screen_mem_output
    sta x_y_to_screen_mem_output

    rts


