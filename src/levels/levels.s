f_draw_level:
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