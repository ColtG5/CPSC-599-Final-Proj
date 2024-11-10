; VIC-20 melody: titlescreen_music.s


f_play_melody:
    lda #1
    sta $900E                           ; Set volume to maximum

_play_note_loop:
    jsr _check_for_input
    bne _exit_melody                    ; If input detected, exit immediately

    ; Play each note sequence in blocks to simplify the loop
    jsr _play_note_c4                   ; Play C4
    jsr _check_for_input
    bne _exit_melody

    jsr _play_note_f4                   ; Play F4
    jsr _check_for_input
    bne _exit_melody

    jsr _play_note_c5                   ; Play C5
    jsr _check_for_input
    bne _exit_melody

    jsr _play_note_d4                   ; Play D4
    jsr _check_for_input
    bne _exit_melody

    jsr _play_note_e4                   ; Play E4
    jsr _check_for_input
    bne _exit_melody

    jsr _play_note_e5                   ; Play E5
    jsr _check_for_input
    bne _exit_melody

    jsr _play_note_f4                   ; Repeat F4
    jsr _check_for_input
    bne _exit_melody

    jsr _play_note_c4_long              ; Repeat C4 with a long delay
    jsr _check_for_input
    bne _exit_melody

    jmp _play_note_loop                 ; Loop back to play notes again

_exit_melody:
    rts                                 ; Exit on input detection

_check_for_input:
    jsr GETIN                           ; Poll for input
    cmp #0
    rts                                 ; If input, sets zero flag clear; no input, zero flag set

; Define notes with moderate delays
_play_note_c4:
    lda #$A0
    sta $900A
    jsr _medium_delay
    lda #$00
    sta $900A
    rts

_play_note_f4:
    lda #$90
    sta $900B
    jsr _long_delay
    lda #$00
    sta $900B
    rts

_play_note_c5:
    lda #$B0
    sta $900C
    jsr _medium_delay
    lda #$00
    sta $900C
    rts

_play_note_d4:
    lda #$B0
    sta $900A
    jsr _short_delay
    lda #$00
    sta $900A
    rts

_play_note_e4:
    lda #$C0
    sta $900A
    jsr _medium_delay
    lda #$00
    sta $900A
    rts

_play_note_e5:
    lda #$C0
    sta $900C
    jsr _long_delay
    lda #$00
    sta $900C
    rts

_play_note_c4_long:
    lda #$A0
    sta $900A
    jsr _long_delay
    lda #$00
    sta $900A
    rts

; Delay subroutines
_short_delay:
    ldx #$FF
_short_loop:
    ldy #$FF
_inner_short_loop:
    dey
    bne _inner_short_loop
    dex
    bne _short_loop
    rts

_medium_delay:
    ldx #$FF
_medium_outer:
    ldy #$FF
_inner_medium_loop:
    dey
    bne _inner_medium_loop
    dex
    bne _medium_outer
    rts

_long_delay:
    ldx #$FF
_long_outer:
    ldy #$FF
_inner_long_loop:
    dey
    bne _inner_long_loop
    dex
    bne _long_outer
    rts
