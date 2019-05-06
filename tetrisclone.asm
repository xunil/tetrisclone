:BasicUpstart2(main)

.label selected_color = $fb
.label background_color = $d021
.label border_color = $d020
.label chrout = $ffd2
.label screen_memory = $0400

main:
	// set background and border to black, clear screen
	lda #0
	sta selected_color
	lda #147
	jsr chrout

	// copy playfield to screen memory
	ldx #250
loopx:
	.for (var i = 0; i < 4; i++) {
		lda playfield + 250*i, X
		sta screen_memory + 250*i - 1, X
	}
	dex
	bne loopx

loop:


.label PRA  =  $dc00            // CIA#1 (Port Register A)
.label DDRA =  $dc02            // CIA#1 (Data Direction Register A)
.label PRB  =  $dc01            // CIA#1 (Port Register B)
.label DDRB =  $dc03            // CIA#1 (Data Direction Register B)


	sei             // interrupts deactivated

	lda #%11111111  // CIA#1 port A = outputs 
	sta DDRA             

	lda #%00000000  // CIA#1 port B = inputs
	sta DDRB             

	lda #%11111110  // testing column 0 (COL0) of the matrix
	sta PRA

waitkey_pressed:        
	lda PRB
	and #%00010000  // masking row 4 (ROW4) 
	bne waitkey_pressed     // wait until key "F1" 

	//cli             // interrupts activated

	lda selected_color
	adc #$01
	and #%00001111
	tay
	sta selected_color
	sta border_color
	sta background_color


// xxx
    ldx #'0'
	stx screen_memory + [40 * 17] + 32

	tya
	cmp #%00001010
	bmi msd_zero
	ldx #'1'
	stx screen_memory + [40 * 17] + 32
	sec
	sbc #%00001010
	//and #%00001111

msd_zero:
	clc
	adc #'0'
	sta screen_memory + [40 * 17] + 33


// xxx

	// tya
	// and #%00000011
	// clc
	// adc #'0'
	// sta screen_memory + [40 * 17] + 33

	// tya
	// and #%00001100
	// lsr
	// lsr
	// clc
	// adc #'0'
	// sta screen_memory + [40 * 17] + 32

waitkey_released:
	lda PRB
	and #%00010000
	beq waitkey_released

	jmp loop

.pc = * "Data"
playfield:
// Playfield dimensions are 10 columns x 20 rows
// Text screen is 40 columns x 24 rows
.encoding "screencode_upper"
.text "                                        "
.text "                                        "
.text "              #          #              "
.text "              #          #              "
.text "    LINES     #          #              "
.text "     135      #          #              "
.text "              #          #              "
.text "              #          #              "
.text "  HI SCORE    #          #    LEVEL     "
.text "  99999999    #          #     12       "
.text "              #          #              "
.text "              #          #              "
.text "    SCORE     #          #              "
.text "  99999999    #          #              "
.text "              #          #              "
.text "              #          #              "
.text "     NEXT     #          #              "
.text "       %      #          #              "
.text "       %      #          #              "
.text "      %%      #          #              "
.text "              #          #              "
.text "              #          #              "
.text "              ############              "
.text "                                        "
.text "                                        "
.text " " // not sure why i need this last space