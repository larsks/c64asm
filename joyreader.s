;; Joystick bits in $dc00: - - F R L D U -

CR      = 13
LF      = 10

println .macro
        lda #(\1 & $00ff)
        sta target
        lda #(\1 >> 8)
        sta target + 1
        jsr print
        .endm

*       = $00fb
target  .addr ?

*       = $0801
        .word (+), 10  ;pointer, line number
        .null $9e, format("%d", start) ;will be sys 2061
+       .word 0          ;basic line end

up      .byte 0
down    .byte 0
left    .byte 0
right   .byte 0
fire    .byte 0

start:
        jsr read_joystick
check_up:
        bit up
        bmi check_down
        bvc check_down
        #println s_up
check_down:
        bit down
        bmi check_left
        bvc check_left
        #println s_down
check_left:
        bit left
        bmi check_right
        bvc check_right
        #println s_left
check_right:
        bit right
        bmi check_fire
        bvc check_fire
        #println s_right
check_fire:
        bit fire
        bmi bottom
        bvc bottom
        jmp say_hello
bottom:
        jmp start

say_hello:
        jsr $e544
        lda #(s_hello & $00ff)
        sta target
        lda #(s_hello >> 8)
        sta target + 1
        jsr print
        rts

; from https://codebase64.org/doku.php?id=base:joystick_input_handling
read_joystick:
        lda $dc00
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

print:
        ldy #0
loop:   
        lda (target), y
        cmp #0
        beq eol
        jsr $ffd2
        iny
        bne loop
eol:
        lda #CR
        jsr $ffd2
        lda #LF
        jsr $ffd2
        rts

;
; String constants
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
