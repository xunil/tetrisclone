:BasicUpstart2(main)

.label background_color = $d021
.label border_color = $d020
.label chrout = $ffd2
.label screen_memory = $0400

.encoding "screencode_upper"

main:
	lda #$40
	sta $fb
	lda #$05
	sta $fc
	lda #'A'
	ldy #00
	sta ($fb),Y
	ldy #-1
	sta ($fb),Y
	ldy #1
	sta ($fb),Y	
	ldy #-40
	sta ($fb),Y	
	
loop:
	nop
	jmp loop


piece:
.byte 0,-1,1,40