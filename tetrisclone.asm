:BasicUpstart2(start)
.encoding "screencode_upper"

// .label mul_a = $02
// .label mul_b = $03
// .label mul_result = $04
.label playfield_addrs_vec = $02
.label piece_x = $03
.label piece_y = $04
.label ticks = $fc
.label piece_rotation = $fd
.label draw_addr = $fe
.label seconds = $05


.label background_color = $d021
.label border_color = $d020
.label chrout = $ffd2
.label screen_memory = $0400

.label irq_handler_vector = $0314
.label irq_handler_address = $ea31


start:
	// set up the playfield addresses vector
	lda #<playfield_addrs
	sta playfield_addrs_vec
	lda #>playfield_addrs
	sta playfield_addrs_vec+1

	// set background and border to black, clear screen
	lda #0
	sta border_color
	sta background_color
	lda #147
	jsr chrout

	// copy playfield to screen memory
	ldx #250
playfield_loop:
	.for (var i = 0; i < 4; i++) {
		lda playfield + 250*i, X
		sta screen_memory + 250*i - 1, X
	}
	dex
	bne playfield_loop

	lda #0
	sta ticks
	lda #1
	sta piece_y
	sei
	ldx #<irq_wedge
	ldy #>irq_wedge
	stx irq_handler_vector
	sty irq_handler_vector + 1
	cli

main_loop:
	lda seconds
	cmp #10
	bmi notwrap
	lda #0
	sta piece_y
notwrap:
	lda piece_y
	adc #1
	sta piece_y
	// lda border_color
	// adc #1
	// sta border_color

	jsr draw
	jmp main_loop


// 
// expects to find X,Y, rotation in zero page
//
draw:
	ldy piece_y
	lda (playfield_addrs_vec),Y
	sta draw_addr
	iny
	lda (playfield_addrs_vec),Y
	sta draw_addr+1
	lda piece_x
	adc draw_addr+1
	bcc skipcarry
	lda draw_addr
	adc #1
	sta draw_addr
skipcarry:
	ldy #0
	lda #'@'
	sta (draw_addr),Y
	rts


irq_wedge:
	lda ticks
	cmp #60
	bne no_overflow
	lda #0
	sta ticks
	lda seconds
	adc #1
	sta seconds
	lda border_color
	adc #1
	sta border_color
no_overflow:
	clc
	adc #1
	sta ticks
	jmp irq_handler_address

// .label PRA  =  $dc00            // CIA#1 (Port Register A)
// .label DDRA =  $dc02            // CIA#1 (Data Direction Register A)
// .label PRB  =  $dc01            // CIA#1 (Port Register B)
// .label DDRB =  $dc03            // CIA#1 (Data Direction Register B)


// 	sei             // interrupts deactivated

// 	lda #%11111111  // CIA#1 port A = outputs 
// 	sta DDRA             

// 	lda #%00000000  // CIA#1 port B = inputs
// 	sta DDRB             

// 	lda #%11111110  // testing column 0 (COL0) of the matrix
// 	sta PRA

// 	//cli             // interrupts activated


// waitkey_pressed:        
// 	lda PRB
// 	and #%00010000  // masking row 4 (ROW4) 
// 	bne waitkey_pressed     // wait until key "F1" 

// 	lda selected_color
// 	adc #$01
// 	and #%00001111
// 	tay
// 	sta selected_color
// 	sta border_color
// 	sta background_color

//     ldx #'0'
// 	stx screen_memory + [40 * 17] + 30

// 	tya
// 	cmp #%00001010
// 	bmi msd_zero
// 	ldx #'1'
// 	stx screen_memory + [40 * 17] + 30
// 	sec
// 	sbc #%00001010

// msd_zero:
// 	clc
// 	adc #'0'
// 	sta screen_memory + [40 * 17] + 31


// waitkey_released:
// 	lda PRB
// 	and #%00010000
// 	beq waitkey_released

// 	jmp loop

.pc = * "Data"
playfield:
// Playfield dimensions are 10 columns x 20 rows
// Text screen is 40 columns x 24 rows
.text "                                        "
.text "              #          #              "  // playfield actually starts next line down.
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
.text "              #          #              "
.text "       %      #          #              "
.text "       %      #          #              "
.text "      %%      #          #              "
.text "              #          #              "
.text "              ############              "
.text "                                        "
.text "                                        "
.text " " // not sure why i need this last space

playfield_addrs:
.word $045f,$0487,$04af,$04d7,$04ff,$0527,$054f,$0577,$059f,$05c7
.word $05ef,$0617,$063f,$0667,$068f,$06b7,$06df,$0707,$072f,$0757

tetrominoes:
//
// the T
//
// +++
//  +
.byte -1,1,40
//  +
//  ++
//  +
.byte 1,-40,40
//  +
// +++
.byte -1,1,-40
//  +
// ++
//  +
.byte -1,40,-40

//
// the J
//
//   +
//   +
//  ++
.byte -1,-40,-80
// +++
//   +
.byte -1,-2,40
//  ++
//  +
//  +
.byte 1,40,80
// +
// +++
.byte -1,-2,-40

//
// the S
//
//  ++
// ++
.byte -1,-40,-39
// +
// ++
//  +
.byte -1,-41,40
//  ++
// ++
.byte -1,-40,-39
// +
// ++
//  +
.byte -1,-41,40

//
// the I
// 
//  +
//  +
//  +
//  +
.byte 40,-40,-80
// ++++
.byte 1,-1,-2
//  +
//  +
//  +
//  +
.byte 40,-40,-80
// ++++
.byte 1,-1,-2

//
// the O
//
.byte -1,-40,-39
.byte -1,-40,-39
.byte -1,-40,-39
.byte -1,-40,-39

//
// the.. R?
//
// ++
//  ++
.byte 1,-40,-41
//   +
//  ++
//  +
.byte -1,-40,39
// ++
//  ++
.byte 1,-40,-41
//   +
//  ++
//  +
.byte -1,-40,39
