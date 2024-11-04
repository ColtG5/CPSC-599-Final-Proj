    processor 6502

SCREEN_MEM_START = $1E00       ; VIC-20 screen memory start
CHROUT = $ffd2                      ; VIC character output subroutine

SCREEN_WIDTH = 22                   ; VIC-20 screen width

ITEM_CODE = $00                 ; Zero page storage for item code
ADDR_LOW = $01                  ; Zero page storage for low byte of screen address
ADDR_HIGH = $02                 ; Zero page storage for high byte of screen address

    org $1001, 0

    include "./src/extras/stub.s"

    jsr start

    ; Include the binary level data directly in the code
level_data:
    .incbin "./levels/level1.bin"

start:
    lda #$93                        ; Clear screen command (PETSCII code)
    jsr CHROUT

    ldx #0                          ; Start reading from the beginning of level_data

load_loop:
    lda level_data,x               ; Load item code from the binary data
    sta ITEM_CODE                   ; Store it in ITEM_CODE
    inx                             ; Move to the next byte

    lda level_data,x               ; Load low byte of screen address
    sta ADDR_LOW                    ; Store it in ADDR_LOW
    inx                             ; Move to the next byte

    lda level_data,x               ; Load high byte of screen address
    sta ADDR_HIGH                   ; Store it in ADDR_HIGH
    inx                             ; Move to the next entry (next 3 bytes)

    ; Set up screen address in screen memory
    lda ADDR_LOW                    ; Load low byte of screen address
    ldy ADDR_HIGH                   ; Load high byte of screen address
    sta $fb                         ; Store in zero-page for indirect addressing
    sty $fc

    ; Display character based on item code
    lda ITEM_CODE
    cmp #1                          ; Check if item code is 1 (wall)
    beq display_wall
    cmp #2                          ; Check if item code is 2 (mirror)
    beq display_mirror
    cmp #3                          ; Check if item code is 3 (laser)
    beq display_laser
    cmp #4                          ; Check if item code is 4 (portal)
    beq display_portal
    jmp display_empty               ; Default to empty if unrecognized

display_wall:
    lda #'W                        ; ASCII code for 'W' (wall)
    jmp write_char

display_mirror:
    lda #'M                        ; ASCII code for 'M' (mirror)
    jmp write_char

display_laser:
    lda #'L                        ; ASCII code for 'L' (laser)
    jmp write_char

display_portal:
    lda #'P                        ; ASCII code for 'P' (portal)
    jmp write_char

display_empty:
    lda #'                         ; ASCII code for space (empty)
    jmp write_char

write_char:
    sta ($fb),y                    ; Write character to calculated screen memory address
    jsr CHROUT                      ; Output character to screen
    cpx #(25 * 3)                   ; Check if all entries have been processed (assuming 25 items)
    bne load_loop                   ; Continue loop if not done

end_display:
    jmp end_display                 ; Infinite loop to keep the program running
