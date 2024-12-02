; adds the char in covered_char_code_z to the inventory
    subroutine
f_add_char_to_inventory:
    lda covered_char_code_z
    sta inventory_item_z

    jsr f_clear_covered_char_in_mem     ; after adding char to inventory, we are no longer covering it!
    rts

; removes the char in inventory_item_z from the inventory (by placing it in the level)
    subroutine
f_place_char_from_inventory:
    ; placed item starts as covered!
    lda inventory_item_z
    sta covered_char_code_z
    lda cursor_x_z
    sta covered_char_x_z
    lda cursor_y_z
    sta covered_char_y_z

    ; clear current inventory char
    lda #empty_character_code
    sta inventory_item_z

    rts

    subroutine
f_clear_inventory:
    lda #empty_character_code
    sta inventory_item_z
    rts

; Draws the character code in the inventory to the top left of the screen, so player knows whats in their inv
    subroutine
f_draw_inventory:
    lda inventory_item_z
    sta tmp_char_code_z
    lda #INV_VIEW_X
    sta tmp_x_z
    lda #INV_VIEW_Y
    sta tmp_y_z
    jsr f_draw_char_to_screen_mem
    rts