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