; Constants for anything used in the program

; -------------- Memory Locations --------------
CUSTOM_CHAR_MEM      = $1C00                  ; Custom character table start
SCREEN_MEM_1         = $1E00                  ; Screen memory start
SCREEN_MEM_2         = $1F00                  ; Additional screen memory
COLOUR_MEM_1         = $9600                  ; Color memory start
COLOUR_MEM_2         = $9700                  ; Additional color memory
CHARSET_POINTER      = $9005                  ; Custom char table VIC chip address
GETIN                = $FFE4                  ; Get input routine
PLOT                 = $FFF0                  ; Plot character at X, Y coordinates
CHROUT               = $FFD2                  ; Output character
DYNAMIC_LEVEL_NUM    = $1e2a

; -------------- Other Constants ---------------
KEY_W                = 87                     ; W key for moving up
KEY_A                = 65                     ; A key for moving left
KEY_S                = 83                     ; S key for moving down
KEY_D                = 68                     ; D key for moving right
KEY_E                = 69                     ; E key to toggle portal
KEY_SPACE            = $20                    ; Spacebar
; CURSOR_CHAR          = 50                     ; Character code for cursor
; PORTAL_CHAR          = 87                     ; Character code for portal
MAX_LEVEL            = 3                      ; Maximum level count
GAME_AREA_ROW_LENGTH = 19                     ; Number of characters in a row in the dynamic level area (first 3 rows of the screen are taken up by level_template)
GAME_AREA_COL_LENGTH = 23                     ; Number of characters in a column in the dynamic level area
; NUM_OF_SIDE_WALLS    = 14                     ; Vertical count of the side walls
