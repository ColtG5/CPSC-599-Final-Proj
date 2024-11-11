; VIC-20 melody: titlescreen_music.s

    subroutine
f_play_melody:
    lda #1
    sta $900E                           ; Set volume to maximum

.play_note_loop:
    jsr .check_for_input
    bne .exit_melody                    ; If input detected, exit immediately

    ; Play each note sequence in blocks to simplify the loop
    jsr .play_note_c4                   ; Play C4
    jsr .check_for_input
    bne .exit_melody

    jsr .play_note_f4                   ; Play F4
    jsr .check_for_input
    bne .exit_melody

    jsr .play_note_c5                   ; Play C5
    jsr .check_for_input
    bne .exit_melody

    jsr .play_note_d4                   ; Play D4
    jsr .check_for_input
    bne .exit_melody

    jsr .play_note_e4                   ; Play E4
    jsr .check_for_input
    bne .exit_melody

    jsr .play_note_e5                   ; Play E5
    jsr .check_for_input
    bne .exit_melody

    jsr .play_note_f4                   ; Repeat F4
    jsr .check_for_input
    bne .exit_melody

    jsr .play_note_c4_long              ; Repeat C4 with a long delay
    jsr .check_for_input
    bne .exit_melody

    jmp .play_note_loop                 ; Loop back to play notes again

.exit_melody:
    rts                                 ; Exit on input detection

.check_for_input:
    jsr GETIN                           ; Poll for input
    cmp #0
    rts                                 ; If input, sets zero flag clear; no input, zero flag set

; Define notes with moderate delays
.play_note_c4:
    lda #$A0
    sta $900A
    jsr .medium_delay
    lda #$00
    sta $900A
    rts

.play_note_f4:
    lda #$90
    sta $900B
    jsr .long_delay
    lda #$00
    sta $900B
    rts

.play_note_c5:
    lda #$B0
    sta $900C
    jsr .medium_delay
    lda #$00
    sta $900C
    rts

.play_note_d4:
    lda #$B0
    sta $900A
    jsr .short_delay
    lda #$00
    sta $900A
    rts

.play_note_e4:
    lda #$C0
    sta $900A
    jsr .medium_delay
    lda #$00
    sta $900A
    rts

.play_note_e5:
    lda #$C0
    sta $900C
    jsr .long_delay
    lda #$00
    sta $900C
    rts

.play_note_c4_long:
    lda #$A0
    sta $900A
    jsr .long_delay
    lda #$00
    sta $900A
    rts

; Delay subroutines
.short_delay:
    ldx #$FF
.short_loop:
    ldy #$FF
.inner_short_loop:
    dey
    bne .inner_short_loop
    dex
    bne .short_loop
    rts

.medium_delay:
    ldx #$FF
.medium_outer:
    ldy #$FF
.inner_medium_loop:
    dey
    bne .inner_medium_loop
    dex
    bne .medium_outer
    rts

.long_delay:
    ldx #$FF
.long_outer:
    ldy #$FF
.inner_long_loop:
    dey
    bne .inner_long_loop
    dex
    bne .long_outer
    rts
