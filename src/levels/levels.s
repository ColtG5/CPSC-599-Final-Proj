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

    subroutine
f_draw_char_to_screen_mem:
    ; get the screen mem addr for the char, and draw it 
    jsr f_convert_xy_to_screen_mem_addr

    lda tmp_char_code_z
    ldy #0
    sta (screen_mem_addr_coord_z),y     ; Draw the character to screen mem

    rts














; ; function that draws the top level label indicator
;     subroutine
; f_draw_top_level:
;     ; need to write "LEVEL: " and the level number

;     ; below code just writes "LEVEL: " to the top right area (magic number hell)
;     lda #15                                     ; Character code for "L"
;     sta $1e23

;     lda #07                                     ; Character code for "E"
;     sta $1e24

;     lda #55                                     ; Character code for "V"
;     sta $1e25

;     lda #07                                     ; Character code for "E"
;     sta $1e26

;     lda #15                                     ; Character code for "L"
;     sta $1e27

;     lda #$28                                    ; Character code for space/nothing
;     sta $1e28

;     lda #21                                     ; Character code for "0"
;     sta $1e29

;     ; now, read value from what_level_tracker_z, and write it to screen
;     ; TODO: rethink assembly approach and/or learn DASM better to get a better approach to this rather 
;     ; than terribly hardcoding it...
;     lda what_level_tracker_z                      ; simple int storing what level we are on
;     cmp #1
;     bne .check_level_2
;     lda #56                                     ; Character code for "1"
;     sta DYNAMIC_LEVEL_NUM
;     jmp .found

; .check_level_2:
;     cmp #2
;     bne .check_level_3
;     lda #20                                     ; Character code for "2"
;     sta DYNAMIC_LEVEL_NUM

; .check_level_3:
;     cmp #3
;     bne .check_level_4
;     lda #57                                     ; Character code for "3"
;     sta DYNAMIC_LEVEL_NUM

; .check_level_4:


; .found:
;     rts

;     subroutine
; f_draw_game_border:                                    ; draw the game border
;     ; draw the border around the game area
;     ; TODO: right now this is a VERY harcoded manual drawing of the level border. In the future,
;     ; we will look at switching this to compressed RLE code that we decompress on the fly. This hardcoded
;     ; solution was just to get it up and running the quickest for the demo.

;     ; $1e42 is the top left corner of the game area
;     ; $1e57 is the top right corner of the game area
;     ; $1f8c is the bottom left corner of the game area
;     ; $1fa1 is the bottom right corner of the game area

;     lda #51             ; Character code for the top wall
;     ldx #0
; .draw_top_wall:
;     sta $1e43,x         ; Write top wall starting from $1e43
;     inx
;     cpx #20          
;     bne .draw_top_wall

;     lda #53             ; Character code for the bottom wall
;     ldx #0
; .draw_bottom_wall:
;     sta $1f8d,x         ; Write bottom wall starting from $1f8d
;     inx
;     cpx #20
;     bne .draw_bottom_wall

; .draw_left_wall:
;     lda #54                  ; Character code for left wall
;     ldx #0                   ; Row counter
;     lda #<$1e58              ; Low byte of starting address
;     sta load_addr_low_z
;     lda #>$1e58              ; High byte of starting address
;     sta load_addr_high_z

; .draw_left_wall_loop:
;     lda #54
;     ldy #0
;     sta (load_addr_low_z),y   ; Write left wall character to address

;     ; Move to the next row address by adding ROW_LENGTH to LOAD_ADDR
;     lda load_addr_low_z
;     clc
;     adc #ROW_LENGTH
;     sta load_addr_low_z
;     lda load_addr_high_z
;     adc #0                   ; Add carry if needed
;     sta load_addr_high_z

;     inx
;     cpx #NUM_OF_SIDE_WALLS    ; Check if we've reached the desired number of rows
;     bne .draw_left_wall_loop

; .draw_right_wall:
;     lda #52                  ; Character code for right wall
;     ldx #0                   ; Row counter
;     lda #<$1e6d              ; Low byte of starting address
;     sta load_addr_low_z
;     lda #>$1e6d              ; High byte of starting address
;     sta load_addr_high_z

; .draw_right_wall_loop:
;     lda #52
;     ldy #0
;     sta (load_addr_low_z),y   ; Write right wall character to address

;     ; Move to the next row address by adding ROW_LENGTH to LOAD_ADDR
;     lda load_addr_low_z
;     clc
;     adc #ROW_LENGTH
;     sta load_addr_low_z
;     lda load_addr_high_z
;     adc #0
;     sta load_addr_high_z

;     inx
;     cpx #NUM_OF_SIDE_WALLS    ; Check if we've reached the desired number of rows
;     bne .draw_right_wall_loop

;     rts

;     subroutine
; f_draw_level:
;     jsr f_draw_level_template                  ; first, draw the static template that each level has

; .check_level_1:
;     lda what_level_tracker_z
;     cmp #1
;     bne .check_level_2
;     lda #<level_1_data_start_p
;     sta level_data_addr_low_z
;     lda #>level_1_data_start_p
;     sta level_data_addr_high_z
;     jmp .level_data_addr_set

; .check_level_2:
;     lda what_level_tracker_z
;     cmp #2
;     bne .check_level_3
;     lda #<level_2_data_start_p
;     sta level_data_addr_low_z
;     lda #>level_2_data_start_p
;     sta level_data_addr_high_z

; .check_level_3:
;     lda what_level_tracker_z
;     cmp #3
;     bne .check_level_4
;     lda #<level_3_data_start_p
;     sta level_data_addr_low_z
;     lda #>level_3_data_start_p
;     sta level_data_addr_high_z

; .check_level_4:

; .level_data_addr_set:
;     ; read in the level data binary and draw it to the screen

;     ldy #0                          
;     ldx #0
; .read_char:
;     lda (level_data_addr_low_z),y
;     cmp #$
;     beq .level_data_end

;     sta curr_char_code_z
;     iny

;     lda (level_data_addr_low_z),y
;     sta load_addr_low_z
;     iny
;     lda (level_data_addr_low_z),y
;     sta load_addr_high_z
;     iny

; .store_char:
;     lda curr_char_code_z
;     sta (load_addr_low_z,x)

;     jmp .read_char    

; .level_data_end:
;     rts