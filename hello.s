;; Hello world in Commodore 64 Assembler - runs automatically
;; for 64Tass assembler from https://sourceforge.net/projects/tass64/
;; Initial BASIC stub adapted from http://tass64.sourceforge.net/

*       = $0801
        .word (+), 10  ;pointer, line number
        .null $9e, format("%d", start) ;will be sys 2061
+	.word 0          ;basic line end

start:
        ldy #0
loop:   lda message, y
        jsr $ffd2
        iny
        cpy #15
        bne loop
        rts
        
message: .byte 147 
        .text "hello world!"
        .byte 13
        .byte 10
