_f_draw_level_template:                                ; function that draws the template for a level (top score, game border, etc.)
    jsr _f_draw_top_score
    jsr _f_draw_game_border
    rts

_f_draw_top_score:                                      ; draw the score numbers at the top of the screen
    

    rts

_f_draw_game_border:                                    ; draw the game border

    rts





f_draw_level:
    jsr _f_draw_level_template

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





    rts