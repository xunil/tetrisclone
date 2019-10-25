	lda #$02     ; set up zero page to point to screen ram
	sta $fc
	lda #$00
	sta $fb

	lda #$01     ; set up color
	sta $fd      ; store in zero page
	ldy #$00
	ldx #32      ; set up loop counter
loop:
	lda $fd      ; load the color into the accumulator
	sta ($fb),y  ; store color in screen ram, indirected through zero page
	dex          ; decrement loop counter
	bne skipy    ; if non-zero, keep looping
	ldx #32      ; restore the loop counter
	adc #$01     ; increment accumulator to switch to the next color
	sta $fd      ; store the color back to the color "register"
skipy:
	lda $fb      ; load the low byte of the screen ram address
	adc #$01     ; add 1 to it
	sta $fb      ; store it back
	bcc skip     ; if the carry flag is clear, adding to the low byte did not wrap
	lda $fc      ; if it was set, load the high byte of screen ram
	adc #$01     ; add 1 to it
	sta $fc      ; store it back
skip:
	jmp loop     ; continue the loop