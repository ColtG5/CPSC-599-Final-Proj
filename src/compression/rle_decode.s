; Used just for the compressed titlescreen right now, this decodes standard RLE encoded data
; TODO: use x reg as well as per A2 feedback to make code smaller

    subroutine
f_rle_decoder:
    ; reset zero page addresses we use
    lda #0
    sta current_byte_from_data_z
    sta count_z
    sta value_z

    lda #2                  ; init y to 2 (skip header of 001e)
    ldy #2
    ; lda #0
    ; ldy #0
    sta current_byte_from_data_z
.decode_loop:
    ; load the count from the encoded data
    ldy current_byte_from_data_z

    lda (data_addr_low_z),y   ; load the count
    sta count_z               ; store the count
    iny                     ; inc offset to go get value byte

    ; load the value from the encoded data
    lda (data_addr_low_z),y   ; load the value
    sta value_z               ; store the value
    iny                     ; inc offset to go get next count byte later on

    sty current_byte_from_data_z

    ; store the value to screen mem!!!
.store_loop:
    lda count_z               ; load the count
    beq .rle_end             ; count of 0 means we done entirely, exit condition here ! !

    lda value_z               ; load the value

    ; ldx load_addr_low_z       ; load low byte of the destination address
    ; ldy load_addr_high_z      ; load high byte of the destination address

    ldy #0
    sta (load_addr_low_z),y   ; freaky store
    inc load_addr_low_z       ; increment the low byte of the address
    bne .no_high_inc         ; if it doesn't overflow, skip the high byte increment
    inc load_addr_high_z      ; increment the high byte of the address if low byte overflowed

.no_high_inc:
    dec count_z               ; dec count
    beq .decode_loop         ; if count is 0, done w this value, go do another
    bne .store_loop          ; if count is not 0, store another value

.rle_end:
    rts