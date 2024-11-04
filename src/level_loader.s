    processor 6502

CUSTOM_CHAR_MEM = $1c00             ; Custom char table start
SCREEN_MEM = $1e00                  ; Screen memory start
CHARSET_POINTER = $9005             ; VIC chip memory address for custom charset
CHROUT = $ffd2                      ; VIC character output subroutine

SCREEN_WIDTH = 22                   ; VIC-20 screen width
ITEM_CODE = $00                     ; Zero page storage for item code
ROW_POS = $01                       ; Zero page storage for row position
COL_POS = $02                       ; Zero page storage for column position

    org $1001, 0

    include "./src/extras/stub.s"

    jsr start

    ; Include the binary level data
level_data:
    .incbin "./levels/level1.bin"

start:
    lda #$93                  ; Clear screen command (PETSCII code)
    jsr CHROUT

    ldx #0                    ; Start with X = 0 (beginning of level_data)

load_loop:
    lda level_data,x         ; Load item code from the level data
    sta ITEM_CODE             ; Store the item code in ITEM_CODE
    inx                       ; Move to the next byte

    lda level_data,x         ; Load row position
    sta ROW_POS               ; Store row position
    inx                       ; Move to the next byte

    lda level_data,x         ; Load column position
    sta COL_POS               ; Store column position
    inx                       ; Move to the next byte

    ; Display the character based on item code
    lda ITEM_CODE
    cmp #1                    ; Check if it's a wall
    beq draw_wall
    cmp #2                    ; Check if it's a mirror
    beq draw_mirror
    cmp #3                    ; Check if it's a laser
    beq draw_laser
    jmp draw_empty            ; Otherwise, treat it as empty

    ; Loop back if more data to process
    cpx #(25 * 3)             ; Check if we've reached the end (25 items * 3 bytes = 75)
    bne load_loop

end_display:
    jmp loop                  ; Infinite loop for testing purposes

draw_wall:
    lda #'W                  ; ASCII code for 'W' (wall)
    jmp place_char

draw_mirror:
    lda #'M                  ; ASCII code for 'M' (mirror)
    jmp place_char

draw_laser:
    lda #'L                  ; ASCII code for 'L' (laser)
    jmp place_char

draw_empty:
    lda #'                   ; ASCII code for space (empty)
    jmp place_char

; Subroutine to place character at the specified screen position
place_char:
    ; Calculate the correct screen memory address based on row and column
    lda ROW_POS               ; Load the row position
    clc                       ; Clear carry for addition
    adc #SCREEN_WIDTH         ; Multiply row by SCREEN_WIDTH (row * 22)
    sta ROW_POS               ; Store back in ROW_POS temporarily

    lda SCREEN_MEM            ; Load base screen memory address
    clc                       ; Clear carry for addition
    adc ROW_POS               ; Add row offset
    tay                       ; Store result in Y for final screen address

    lda COL_POS               ; Load column position
    sta SCREEN_MEM,y         ; Store character at calculated screen memory location
    jsr CHROUT                ; Print character to screen
    rts                       ; Return to load_loop for next item

loop:
    jmp loop                  ; Infinite loop to keep the program running
