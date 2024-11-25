; Input Handling Subroutine
    subroutine
.f_handle_input:
    lda current_byte_from_data_z
    cmp #KEY_W                                ; W key for up
    beq f_move_up
    cmp #KEY_A                                ; A key for left
    beq f_move_left
    cmp #KEY_S                                ; S key for down
    beq f_move_down
    cmp #KEY_D                                ; D key for right
    beq f_move_right
    cmp #KEY_E                                ; E key to pick/place portal
    beq f_toggle_portal
    rts


; ; Movement Functions
; f_move_up:
;     jsr f_erase_cursor                        ; Erase cursor at previous position
;     dec cursor_y_z
;     jsr f_draw_cursor
;     rts

; f_move_left:
;     jsr f_erase_cursor                        ; Erase cursor at previous position
;     dec cursor_x_z
;     jsr f_draw_cursor
;     rts

; f_move_down:
;     jsr f_erase_cursor                        ; Erase cursor at previous position
;     inc cursor_y_z
;     jsr f_draw_cursor
;     rts

; f_move_right:
;     jsr f_erase_cursor                        ; Erase cursor at previous position
;     inc cursor_x_z
;     jsr f_draw_cursor
;     rts