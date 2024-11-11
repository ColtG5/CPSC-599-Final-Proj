; Simple loop to set all of color mem to black
    subroutine
f_set_color_mem_black:
    ldx #0
.color_stuff_1:                      ; these next 15ish lines set all of color mem to black, so we can see the title screen
    lda #0                          ; foreground black
    sta COLOUR_MEM_1,x
    inx
    txa
    bne .color_stuff_1

.color_stuff_2:
    lda #0
    sta COLOUR_MEM_2,x
    inx
    txa
    bne .color_stuff_2

    rts

    subroutine
f_clear_screen:
.clear_screen_mem_1:         ; write a blank character to all of screen mem (used to be blank charcters, but we changed the character code for blank character)
    lda #40                 ; goob_16 character is secretly a blank character (and its character code 40)
    sta SCREEN_MEM_1,x
    inx
    txa
    bne .clear_screen_mem_1

.clear_screen_mem_2:
    lda #40
    sta SCREEN_MEM_2,x
    inx
    txa
    bne .clear_screen_mem_2

    rts