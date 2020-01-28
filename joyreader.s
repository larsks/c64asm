;; Joystick bits in $dc00: - - F R L D U -

CR      = 13
LF      = 10
CLEARSCREEN = $e544
CHROUT  = $ffd2
PRA     = $dc00

; print <address>
;
; wrapper for the print_ subroutine that takes care
; of loading a pointer into target.
print   .macro
        lda #(\1 & $00ff)
                        ; A pointer is 16 bits but our registers are
        sta target      ; only 8 bits, so we need to separately load
        lda #(\1 >> 8)  ; and store the low byte of the pointer followed
        sta target + 1  ; by the high byte of the pointer.
        jsr print_
        .endm

; ckbtn <button> <label_if_not_pressed>
;
; If button is not pressed, branch to <label_if_not_pressed>. Otherwise,
; continuing executing.
ckbtn   .macro
        bit \1          ; The `bit` instruction puts bit 7 of the argument
        bmi \2          ; into the N and flag and bit 6 into the V flag.
        bvc \2          ; We then branch to the next check if N is set
                        ; or V is clear: in other words, the only time
                        ; we skip these branches is when the button history
                        ; has the pattern `01...`. Recall that a button is
                        ; 1 when released and 0 when pressed, so the pattern
                        ; `01` shows a transition from released (1) to
                        ; pressed (0).
        .endm

*       = $00fb
target  .addr ?         ; This is where we store the address for
                        ; a string to be printed by print_.


; program header from http://tass64.sourceforge.net/
;
; This creats a one-line BASIC program which contains the
; necessary SYS instruction to run the main application
; (so the operator can just type "RUN").
*       = $0801
        .word (+), 10   ;pointer, line number
        .null $9e, format("%d", start) ;will be sys 2061
+       .word 0         ;basic line end

up      .byte 0
down    .byte 0
left    .byte 0
right   .byte 0
fire    .byte 0

start:
        lda #$ff
        sta up
        sta down
        sta right
        sta left
        sta fire

        jsr CLEARSCREEN
        print s_welcome

readloop:
        jsr read_joystick

check_up:
        #ckbtn up, check_down
        #print s_up
check_down:
        #ckbtn down, check_left
        #print s_down
check_left:
        #ckbtn left, check_right
        #print s_left
check_right:
        #ckbtn right, check_fire
        #print s_right
check_fire:
        #ckbtn fire, bottom
        jmp exit
bottom:
        jmp readloop

exit:
        #print s_goodbye
        rts

; from https://codebase64.org/doku.php?id=base:joystick_input_handling
read_joystick:
        lda PRA
        lsr A
        ror up
        lsr A
        ror down
        lsr A
        ror left
        lsr A
        ror right
        lsr A
        ror fire
        rts

print_:
        ldy #0
_loop:
        lda (target), y
        beq eol         ; stop looping when we reach end-of-string
                        ; marker
        jsr CHROUT
        iny
        bne _loop
eol:                    ; print cr/lf
        lda #CR
        jsr CHROUT
        lda #LF
        jsr CHROUT
        rts

;
; Strings
;

s_welcome:
        .text "========================================", CR, LF
        .text "press joystick buttons (fire to exit)", CR, LF
        .text "========================================"
        .byte 0
s_goodbye:
        .text "========================================", CR, LF
        .text "fire button detected", CR, LF
        .byte 0
s_left:
        .text "left"
        .byte 0
s_right:
        .text "right"
        .byte 0
s_up:
        .text "up"
        .byte 0
s_down:
        .text "down"
        .byte 0
s_fire:
        .text "fire"
        .byte 0
