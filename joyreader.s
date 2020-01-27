;; Joystick bits in $dc00: - - F R L D U -

CR      = 13
LF      = 10
CLEARSCREEN = $e544
CHROUT  = $ffd2
PRA     = $dc00

; wrapper for the print_ subroutine that takes care
; of loading a pointer into target.
print   .macro
        lda #(\1 & $00ff)
        sta target
        lda #(\1 >> 8)
        sta target + 1
        jsr print_
        .endm

; If the named button has been pressed, print the name. Otherwise
; continue to next check.
ckbtn   .macro
        bit \1
        bmi check_\2
        bvc check_\2
        #print s_\1
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
readloop:
        jsr read_joystick

check_up:
        #ckbtn up, down
check_down:
        #ckbtn down, left
check_left:
        #ckbtn left, right
check_right:
        #ckbtn right, fire
check_fire:
        #ckbtn fire, bottom
        jmp say_hello
check_bottom:
        jmp readloop

say_hello:
        jsr CLEARSCREEN
        #print s_hello
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

s_hello:
        .text "hello world"
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
