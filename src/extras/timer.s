; File: timer.s
; Timer utilities for counting ticks/seconds using the VIC-20 jiffy clock.

; Custom clock variables
custom_clock_low_z     = $fb  ; Low byte of custom clock
custom_clock_high_z    = $fc  ; High byte of custom clock
tmp_timer_target_low_z = $fd  ; Timer target (low byte)
tmp_timer_target_high_z = $fe ; Timer target (high byte)

; Subroutine: f_increment_custom_clock
; Updates the custom clock using the VIC-20 jiffy clock.
    subroutine
f_increment_custom_clock:
    lda TIMER_LOW         ; Read the VIC-20 jiffy clock low byte
    cmp custom_clock_low_z
    bne .update_clock     ; If it doesn't match, update the custom clock

    lda TIMER_HIGH        ; Read the VIC-20 jiffy clock high byte
    cmp custom_clock_high_z
    bne .update_clock     ; If high byte doesn't match, update the custom clock
    rts                   ; No update needed, return

.update_clock:
    lda TIMER_LOW
    sta custom_clock_low_z
    lda TIMER_HIGH
    sta custom_clock_high_z

    ; Increment the custom clock (counts in ticks)
    inc custom_clock_low_z
    bne .done             ; If low byte didn't overflow, we're done
    inc custom_clock_high_z ; Increment high byte on overflow
.done:
    rts

; Subroutine: f_set_timer
; Sets a timer for a specific duration in seconds (based on jiffy clock).
; Input:
;    A: Timer duration (in seconds)
; Output:
;    tmp_timer_target_low_z, tmp_timer_target_high_z
    subroutine
f_set_timer:
    ; Set the target by adding the duration to the current custom clock.
    lda custom_clock_low_z
    clc
    adc #<custom_clock_low_z
    sta tmp_timer_target_low_z

    lda custom_clock_high_z
    adc #>custom_clock_low_z
    sta tmp_timer_target_high_z
    rts

; Subroutine: f_check_timer
; Checks if the timer has expired.
; Output:
;    Z flag: Set if the timer has expired, clear otherwise
    subroutine
f_check_timer:
    lda custom_clock_low_z
    cmp tmp_timer_target_low_z
    bcc .not_expired      ; If current low is below target, timer hasn't expired

    lda custom_clock_high_z
    cmp tmp_timer_target_high_z
    bcc .not_expired      ; If current high is below target, timer hasn't expired

    sec                   ; Timer expired
    rts

.not_expired:
    clc                   ; Timer not expired
    rts
