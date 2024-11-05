f_draw_titlescreen:
_set_data_addrs:
    lda #<encoded_title_screen_data_start
    sta DATA_ADDR_LOW
    lda #>encoded_title_screen_data_start
    sta DATA_ADDR_HIGH
_set_load_addrs:
    lda encoded_title_screen_data_start
    sta LOAD_ADDR_LOW
    lda encoded_title_screen_data_start + 1
    sta LOAD_ADDR_HIGH

    ; lda #$00
    ; sta LOAD_ADDR_LOW
    ; lda #$1e
    ; sta LOAD_ADDR_HIGH

    jsr f_rle_decoder
    rts