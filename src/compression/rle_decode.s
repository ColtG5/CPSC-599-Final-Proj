DATA_ADDR_LOW = $00
DATA_ADDR_HIGH = $01
LOAD_ADDR_LOW = $02
LOAD_ADDR_HIGH = $03
current_byte_from_data = $04
count = $05
value = $06

f_rle_decoder:
    lda #2                  ; init y to 2 (skip header of 001e)
    ldy #2
    sta current_byte_from_data
    ldx #0                  ; init x to 0
_decode_loop:
    ; load the count from the encoded data
    ldy current_byte_from_data

    lda (DATA_ADDR_LOW),y   ; load the count
    sta count               ; store the count
    iny                     ; inc offset to go get value byte

    ; load the value from the encoded data
    lda (DATA_ADDR_LOW),y   ; load the value
    sta value               ; store the value
    iny                     ; inc offset to go get next count byte later on

    sty current_byte_from_data

    ; store the value to screen mem!!!
_store_loop:
    lda count               ; load the count
    beq _rle_end             ; count of 0 means we done entirely, exit condition here ! !

    lda value               ; load the value

    ; ldx LOAD_ADDR_LOW       ; load low byte of the destination address
    ; ldy LOAD_ADDR_HIGH      ; load high byte of the destination address

    ldy #0
    sta (LOAD_ADDR_LOW),y   ; freaky store
    inc LOAD_ADDR_LOW       ; increment the low byte of the address
    bne _no_high_inc         ; if it doesn't overflow, skip the high byte increment
    inc LOAD_ADDR_HIGH      ; increment the high byte of the address if low byte overflowed

_no_high_inc:
    dec count               ; dec count
    beq _decode_loop         ; if count is 0, done w this value, go do another
    jmp _store_loop          ; if count is not 0, store another value

_rle_end:
    rts