; Simple routine that draws the title screen from its compressed binary!
    subroutine
f_draw_titlescreen:
; set addrs of where the data is located
.set_data_addrs:
    lda #<encoded_title_screen_data_start
    sta DATA_ADDR_LOW
    lda #>encoded_title_screen_data_start
    sta DATA_ADDR_HIGH
    
; set addrs of where the data will be loaded to (screen mem in our case)
.set_load_addrs:
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