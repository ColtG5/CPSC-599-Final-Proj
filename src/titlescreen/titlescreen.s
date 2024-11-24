; Simple routine that draws the title screen from its compressed binary!
    subroutine
f_draw_titlescreen:
; set addrs of where the data is located
.set_data_addrs:
    lda #<encoded_title_screen_data_start
    sta data_addr_low_z
    lda #>encoded_title_screen_data_start
    sta data_addr_high_z
    
; set addrs of where the data will be loaded to (screen mem in our case)
.set_load_addrs:
    lda encoded_title_screen_data_start
    sta load_addr_low_z
    lda encoded_title_screen_data_start + 1
    sta load_addr_high_z

    ; lda #$00
    ; sta load_addr_low_z
    ; lda #$1e
    ; sta load_addr_high_z

    jsr f_rle_decoder
    rts