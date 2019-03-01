	#include p18f87k22.inc

	global	DAC_write, DAC_setup
	extern	LCD_delay_x4us, read_sequence, SPI_MasterTransmit2
	
acs0	udata_acs
config_register	res 1
temp_reg	res 1 

; 8 bit DAC via interrupts. Fortunately not used as its counterpart high resolution 12 bit dac is used instead
	
int_hi	code	0x0008	; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	incf	LATD		; increment PORTD
	bcf	INTCON,TMR0IF	; clear interrupt flag
	retfie	FAST		; fast return from interrupt

DAC	code
DACs	
	clrf	TRISD		; Set PORTD as all outputs
	clrf	LATD		; Clear PORTD outputs
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	return

; 12 bit DAC c	

DAC_setup	    ; unnecessary but can set up DAC first during read initialization
	bcf	TRISE, 3	    ; set LDAC high
	bsf	PORTE, 3
	
	bcf	TRISE, 2	    ; set RE2 as Chip select CS
	bsf	PORTE, 2	    ; set RE2 high
	movlw	.1
	call	LCD_delay_x4us	
	return

DAC_write
	bcf	TRISE, 3	    ; set LDAC high
	bsf	PORTE, 3
	
	bcf	TRISE, 2	    ; set RE2 as Chip select CS
	bsf	PORTE, 2	    ; set RE2 high
	movlw	.3
	call	LCD_delay_x4us		
	
	bcf	PORTE, 2	    ; set CS low
	
	movlw	b'00010000'	    ; configuration bits in W
	movwf	config_register
	
	call	read_sequence	    ; load right justified adc bits in W
;	movlw	b'00001111'
	addwf	config_register, 1, 0    ; store high (config) and low nibble (data) ADDRESH high value

	call	read_sequence
;	movlw	b'11111111'	
	addwf	temp_reg, 1, 0
	
	movf	config_register, 0, 0
	call	SPI_MasterTransmit2	; send first byte i.e. ADRESH
	
	movf	temp_reg, 0, 0	
	call	SPI_MasterTransmit2	; send second byte i.e. send ADRESL data to DAC

	bcf	TRISE, 2
	bsf	PORTE, 2		; set CS high
	
	bcf	TRISE, 3
	bcf	PORTE, 3		; set LDAC low
	
	bcf	TRISE, 3
	bsf	PORTE, 3		; pulse LDAC back to high
	
	return
    
    end
	