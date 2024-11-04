f_set_color_mem_black:
    ldx #0
_color_stuff_1:                      ; these next 15ish lines set all of color mem to black, so we can see the title screen
    lda #0                          ; foreground black
    sta $9600,x
    inx
    txa
    cmp #00
    bne _color_stuff_1

_color_stuff_2:
    lda #0
    sta $9700,x
    inx
    txa
    cmp #00
    bne _color_stuff_2

    rts

f_clear_screen:

    rts