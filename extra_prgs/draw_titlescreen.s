CUSTOM_CHAR_MEM = $1C00
    
    processor 6502
    org $1001, 0

    include "./setup/stub.s"

    ; use outputted code from level_editor.py to draw the title screen

loop:
    jmp loop

    org CUSTOM_CHAR_MEM
    include "local_character_table.s"