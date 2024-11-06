curr_char_code = $05                                    ; overwriting count zero page mem spot that was used in rle decoder
LOAD_ADDR_LOW = $02
LOAD_ADDR_HIGH = $03                                    ; reusing these from rle since same idea here, these represent addr we are loading data into

_f_draw_level_template:                                ; function that draws the template for a level (top score, game border, etc.)
    jsr _f_draw_top_level
    jsr _f_draw_game_border
    rts

_f_draw_top_level:                                      ; draw the level label
    ; need to write "LEVEL: " and the level number
    ; lda #<level_label

    lda #15
    sta $1e23

    lda #07
    sta $1e24

    lda #55
    sta $1e25

    lda #07
    sta $1e26

    lda #15
    sta $1e27

    lda #$28
    sta $1e28

    lda #21
    sta $1e29

    lda #21
    sta $1e2a

    rts

_f_draw_game_border:                                    ; draw the game border
    ; draw the border around the game area
    ; $1e42 is the top left corner of the game area
    ; $1e57 is the top right corner of the game area
    ; $1f8c is the bottom left corner of the game area
    ; $1fa1 is the bottom right corner of the game area

    lda #51             ; Character code for the top wall
draw_top_wall:
    sta $1e43,x        ; Write top wall starting from $1e42
    inx
    cpx #20          
    bne draw_top_wall

    lda #53             ; Character code for the bottom wall
    ldx #0              ; Reset X register for bottom wall
draw_bottom_wall:
    sta $1f8d,x
    inx
    cpx #20
    bne draw_bottom_wall

    lda #54             ; Character code for the left wall
    ldy #0


    lda #54                 
    ldx #0                  
    lda #<$1e58             
    sta LOAD_ADDR_LOW
    lda #>$1e58             
    sta LOAD_ADDR_HIGH
draw_left_wall:
    lda #54                 
    ldy #0                  
    sta (LOAD_ADDR_LOW),y  

    clc
    lda LOAD_ADDR_LOW
    adc #22
    sta LOAD_ADDR_LOW
    bcc no_inc_left_high    
    inc LOAD_ADDR_HIGH
no_inc_left_high:
    inx                     
    cpx #14                 
    bne draw_left_wall

    lda #52                 
    ldx #0                  
    lda #<$1e6d             
    sta LOAD_ADDR_LOW
    lda #>$1e6d             
    sta LOAD_ADDR_HIGH
draw_right_wall:
    lda #52                 
    ldy #0                  
    sta (LOAD_ADDR_LOW),y  

    clc
    lda LOAD_ADDR_LOW
    adc #22
    sta LOAD_ADDR_LOW
    bcc no_inc_right_high   
    inc LOAD_ADDR_HIGH
no_inc_right_high:
    inx                     
    cpx #14                 
    bne draw_right_wall

    rts

f_draw_level:
    jsr _f_draw_level_template                  ; first, draw the static template that each level has

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