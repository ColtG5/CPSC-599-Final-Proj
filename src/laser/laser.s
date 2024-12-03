
; If the laser collides with the wall, it should stop drawing more lasers afterwards, by setting laser head to none
    subroutine
f_handle_laser_collision_with_wall:


    rts

; If the laser collides wiht a receptor, check if it hit the receptor from the right side. if so, set that this receptor was hit! otherwise, its like a wall
    subroutine
f_handle_laser_collision_with_receptor:


    rts

; If the laser collides with a reflector, update reflector sprite, calculate the new direction of the laser, and update laser head to new location
    subroutine
f_handle_laser_collision_with_reflector:


    rts

; If the laser collides with a portal, update portal sprite, and update the laser head to the new location of the portal
    subroutine
f_handle_laser_collision_with_portal:


    rts