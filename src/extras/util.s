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
clear_screen_mem_1:         ; write a blank character to all of screen mem (used to be blank charcters, but we changed the character code for blank character)
    lda #40                 ; goob_16 character is secretly a blank character (and its character code 40)
    sta $1e00,x
    inx
    txa
    cmp #00
    bne clear_screen_mem_1

clear_screen_mem_2:
    lda #40
    sta $1f00,x
    inx
    txa
    cmp #00
    bne clear_screen_mem_2

    rts