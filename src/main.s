    processor 6502

CUSTOM_CHAR_MEM = $1c00             ; custom char table start
SCREEN_MEM = $1e00                  ; screen mem start!
CHARSET_POINTER = $9005             ; custom char table vic chip mem address place
CHROUT = $ffd2

DATA_ADDR_LOW = $00
DATA_ADDR_HIGH = $01

    org $1001, 0

    include "./src/extras/stub.s"

    ; clear screen
    lda #147
    jsr CHROUT

    lda #255
    sta CHARSET_POINTER


loop:
    jmp loop