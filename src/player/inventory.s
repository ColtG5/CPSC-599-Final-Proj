; adds the char in covered_char_code_z to the inventory
    subroutine
f_add_char_to_inventory:
    lda covered_char_code_z
    sta inventory_item_z

    ; if we added a portal, set its now old portal coords to ff
    cmp #portal_code
    bne .done
    lda portal_1_x_z
    cmp cursor_x_z
    bne .clear_portal_2
    lda portal_1_y_z
    cmp cursor_y_z
    bne .clear_portal_2

    lda #0xff
    sta portal_1_x_z
    sta portal_1_y_z
    jmp .done

.clear_portal_2:
    ; lda portal_2_x_z
    ; cmp cursor_x_z
    ; bne .done
    ; lda portal_2_y_z
    ; cmp cursor_y_z
    ; bne .done

    lda #0xff
    sta portal_2_x_z
    sta portal_2_y_z
    jmp .done



.done:
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

    ; if we are placing a portal, put these new coords into whatevcer portal coords are currently ff
    lda inventory_item_z
    cmp #portal_code
    bne .done
    lda portal_1_x_z
    cmp #0xff
    beq .put_in_portal_1
    lda portal_2_x_z
    cmp #0xff
    beq .put_in_portal_2
    jmp .done

.put_in_portal_1:
    lda cursor_x_z
    sta portal_1_x_z
    lda cursor_y_z
    sta portal_1_y_z
    jmp .done

.put_in_portal_2:
    lda cursor_x_z
    sta portal_2_x_z
    lda cursor_y_z
    sta portal_2_y_z
    jmp .done


.done:
    ; clear current inventory char
    jsr f_clear_inventory

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