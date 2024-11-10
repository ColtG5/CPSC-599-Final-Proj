DYNAMIC_LEVEL_NUM_SCREEN_MEM_ADDR = $1e2a
NUM_OF_COLUMNS = #22
NUM_OF_SIDE_WALLS = #14

curr_char_code = $05                                    ; overwriting count zero page mem spot that was used in rle decoder
LOAD_ADDR_LOW = $02
LOAD_ADDR_HIGH = $03                                    ; reusing these from rle since same idea here, these represent addr we are loading data into


; function that draws the template for a level (top score, game border, etc.)
_f_draw_level_template:
    jsr _f_draw_top_level
    jsr _f_draw_game_border
    rts

; function that draws the top level label indicator
_f_draw_top_level:
    ; need to write "LEVEL: " and the level number

    ; below code just writes "LEVEL: " to the top right area (magic number hell)
    lda #15                                     ; Character code for "L"
    sta $1e23

    lda #07                                     ; Character code for "E"
    sta $1e24

    lda #55                                     ; Character code for "V"
    sta $1e25

    lda #07                                     ; Character code for "E"
    sta $1e26

    lda #15                                     ; Character code for "L"
    sta $1e27

    lda #$28                                    ; Character code for space/nothing
    sta $1e28

    lda #21                                     ; Character code for "0"
    sta $1e29

    ; now, read value from what_level_tracker, and write it to screen
    ; TODO: rethink assembly approach and/or learn DASM better to get a better approach to this rather 
    ; than terribly hardcoding it...
    lda what_level_tracker                      ; simple int storing what level we are on
    cmp #1
    bne _check_level_2_label
    lda #56                                     ; Character code for "1"
    sta DYNAMIC_LEVEL_NUM_SCREEN_MEM_ADDR
    jmp _found_label

_check_level_2_label:
    cmp #2
    bne _check_level_3_label
    lda #20                                     ; Character code for "2"
    sta DYNAMIC_LEVEL_NUM_SCREEN_MEM_ADDR

_check_level_3_label:
    cmp #3
    bne _check_level_4_label
    lda #57                                     ; Character code for "3"
    sta DYNAMIC_LEVEL_NUM_SCREEN_MEM_ADDR

_check_level_4_label:


_found_label:
    rts

_f_draw_game_border:                                    ; draw the game border
    ; draw the border around the game area
    ; TODO: right now this is a VERY harcoded manual drawing of the level border. In the future,
    ; we will look at switching this to compressed RLE code that we decompress on the fly. This hardcoded
    ; solution was just to get it up and running the quickest for the demo.

    ; $1e42 is the top left corner of the game area
    ; $1e57 is the top right corner of the game area
    ; $1f8c is the bottom left corner of the game area
    ; $1fa1 is the bottom right corner of the game area

    lda #51             ; Character code for the top wall
_draw_top_wall:
    sta $1e43,x         ; Write top wall starting from $1e43
    inx
    cpx #20          
    bne _draw_top_wall

    lda #53             ; Character code for the bottom wall
    ldx #0              ; Reset X register for bottom wall
_draw_bottom_wall:
    sta $1f8d,x         ; Write bottom wall starting from $1f8d
    inx
    cpx #20
    bne _draw_bottom_wall

    lda #54             ; Character code for the left wall
    ldx #0
    lda #<$1e58         ; store the 16-bit address of the start of the left wall
    sta LOAD_ADDR_LOW
    lda #>$1e58
    sta LOAD_ADDR_HIGH
_draw_left_wall:
    lda #54                 
    ldy #0
    sta (LOAD_ADDR_LOW),y  

    clc
    lda LOAD_ADDR_LOW       ; increment the address to the next row (22 columns, so add by 22)
    adc NUM_OF_COLUMNS
    sta LOAD_ADDR_LOW
    bcc no_inc_left_high    ; carry means we need to increment the high byte of the address!
    inc LOAD_ADDR_HIGH
no_inc_left_high:
    inx                     
    cpx NUM_OF_SIDE_WALLS   ; 14 rows of the left wall
    bne _draw_left_wall


    ; Drawing right wall is exact same logic as left wall (all this code can definitely be reduced. Just did this solution very hastily)
    lda #52                 
    ldx #0                  
    lda #<$1e6d             
    sta LOAD_ADDR_LOW
    lda #>$1e6d             
    sta LOAD_ADDR_HIGH
_draw_right_wall:
    lda #52                 
    ldy #0                  
    sta (LOAD_ADDR_LOW),y  

    clc
    lda LOAD_ADDR_LOW
    adc NUM_OF_COLUMNS
    sta LOAD_ADDR_LOW
    bcc _no_inc_right_high   
    inc LOAD_ADDR_HIGH
_no_inc_right_high:
    inx                     
    cpx NUM_OF_SIDE_WALLS                 
    bne _draw_right_wall

    rts

;
f_draw_level:
    jsr _f_draw_level_template                  ; first, draw the static template that each level has

_check_level_1:
    lda what_level_tracker
    cmp #1
    bne _check_level_2
    lda #<level_1_data_start
    sta level_data_addr_low
    lda #>level_1_data_start
    sta level_data_addr_high
    jmp _level_data_addr_set

_check_level_2:
    lda what_level_tracker
    cmp #2
    bne _check_level_3
    lda #<level_2_data_start
    sta level_data_addr_low
    lda #>level_2_data_start
    sta level_data_addr_high

_check_level_3:
    lda what_level_tracker
    cmp #3
    bne _check_level_4
    lda #<level_3_data_start
    sta level_data_addr_low
    lda #>level_3_data_start
    sta level_data_addr_high

_check_level_4:

_level_data_addr_set:
    ; read in the level data binary and draw it to the screen

    ldy #0                          
    ldx #0
_read_char:
    lda (level_data_addr_low),y
    cmp #$
    beq _level_data_end

    sta curr_char_code
    iny

    lda (level_data_addr_low),y
    sta LOAD_ADDR_LOW
    iny
    lda (level_data_addr_low),y
    sta LOAD_ADDR_HIGH
    iny

_store_char:
    lda curr_char_code
    sta (LOAD_ADDR_LOW,x)

    jmp _read_char    

_level_data_end:
    rts