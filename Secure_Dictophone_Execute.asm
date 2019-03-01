#include p18f87k22.inc
;	
	extern	write_sequence_init, write_sequence, read_sequence_init, read_sequence
	extern  LCD_Setup, LCD_Clear_Screen, LCD_delay_ms, LCD_Second_Line, LCD_Send_Byte_D, LCD_Write_Hex
	extern	ac1, ac2, ac3, init_counter24bit, counter24bit
	extern  ADC_Setup, ADC_Read
	extern	LCD_delay_x4us
	extern	DAC_write, SPI_MasterInit, SPI_MasterInit2
	extern  key_r, keypad_button_press

acs0	udata_acs	    ; reserve single bytes for certain registers
delay_count	res 1
pin_1	res 1
pin_2	res 1
pin_3	res 1
pin_4	res 1
	
	code
	org 0x0
	goto	start
	org 0x100		    ; Main code starts here at address 0x100
	
start	
	call	LCD_Setup
	movlw	0x00
	movwf	pin_1		    ; clear registers that store pin presses
	movwf	pin_2
	movwf	pin_3
	movwf	pin_4		    
;	goto	write_start	    ; overwrite pin authorization if necessary !!
	bra	authentication		; four digit pin is recorded

authentication				; record first number pressed on keypad in a temporary pin number reg
	call	keypad_button_press	; call records keypad press
	movff	key_r, pin_1
	
;	movlw	key_r
;	call	LCD_Write_Hex		; Here we check whether the right key is pressed on the keypad
;	goto	$			; debugging step has been left as a comment as a similar method is used to 
					; verify various following subroutines
	bra	authentication2
	
authentication2				; record second key pressed
	call	keypad_button_press
	movff	key_r, pin_2
	bra	authentication3	

authentication3
	
	call	keypad_button_press
	movff	key_r, pin_3	
	bra	authentication4
	
authentication4
	
	call	keypad_button_press	
	movff	key_r, pin_4	
	bra	verification		; now verify the 4 recored buttons

	
verification		; pin is 4789!, compare and check and display if its incorrect
		
	movlw	0x84				; 4 on the keypad
	cpfseq	pin_1, 0			; zero stands for access here
	bra	incorrect_pin			; skips if pin_1 button that was pressed is 4 and so on... 

	movlw	0x82	
	cpfseq	pin_2, 0
	bra	incorrect_pin	

	movlw	0x42	
	cpfseq	pin_3, 0
	bra	incorrect_pin	

	movlw	0x22	
	cpfseq	pin_4, 0
	bra	incorrect_pin	
	bra	record_or_play			; allow functionality to be accessed once all 4 digits are verified

	
record_or_play

	movlw	0x00
	movwf	key_r
	call	LCD_Clear_Screen
	movlw	0x4F
	call	LCD_Send_Byte_D			; Display 0 (Ascii: 0x4F) for correct pin confirmation
		
	
	call	keypad_button_press
	movlw	0x81		    ; keypad code for A that signifies record
	cpfseq	key_r, 0	
	bra	play
	goto	write_init	    
	
play
	movlw	0x50
	call	LCD_Send_Byte_D		; Display symbol for play
	movlw	0x21
	cpfseq	key_r, 0		; Check if key B is pressed on the keypad. Otherwise Check if key C is pressed
	bra	lock
	bra	read_init
	
	
lock
	movlw	0x11
	cpfseq	key_r, 0		; Lock the dictophone if key C is pressed otherwise go back to start of the menu
	bra	record_or_play
	goto	start
	
	
	
incorrect_pin				; Display X if incorrect key is pressed and go back to start and ask for pin again.
	call	LCD_Clear_Screen
	movlw	0x58	
	call	LCD_Send_Byte_D
	movlw	0xFF
	call	LCD_delay_ms
	bra	authentication

	
write_init
	
	movlw 	0x03		; count to half of available addresses on FRAM as two bytes are stored after each ADC conversion
	movwf	ac1
	movlw	0xFF		; load up the 24 bit counter to count up to 0x03FFFF i.e. half of all of the available 0x07FFFF addresses.
	movwf	ac2
	movlw	0xFF
	movwf	ac3		; ac stands for address counter and the smallest ac1 is most significant

	call	init_counter24bit	    ; initialize counter by clearing the temporary ac registers (found in counter24bit.asm)
	
	call	ADC_Setup  ; initialize ADC
	
	call	write_sequence_init	; initialize FRAM by sending it appropriate opcodes found in external_memory.asm
	movlw	0x52
	call	LCD_Send_Byte_D		; display R on LCD if all of above has been executed
	bra	write			; goto write routine to actually start writing mic recorded ADC bytes to FRAM sequentially, 
	
write
        nop
	nop				; 62.5 ns delays to tune the sampling rate
	call	ADC_Read		; convert RA0 analogue microphone signals to digital and store them as 12 bits 
					; right justified in ADRESH:ADRESL (high and low byte registers)
	movf	ADRESH,	W		
	call	write_sequence		; write high byte to FRAM	

;	call	LCD_Write_Hex		; can check on LCD if the numbers look right or whether Mic needs calibration. 
					; Another useful debugging step.
	movf	ADRESL, W
	call	write_sequence		; write low byte to FRAM
	nop
	nop
	nop
	
;	movlw	.44
;	call	LCD_delay_x4us		; add longer X times 4 microsecond delays to vary sampling rate
	
	call	counter24bit		; count up 2 writes to keep track of used up addresses on FRAM
	
	movlw	0x00			; if statement to stop writing once all FRAM addresses are written to
	cpfseq	ac3, 0			
	bra	write			; skip if ac3 is 0
	cpfseq	ac2, 0
	bra	write			; skip if ac2 is 0
	cpfseq	ac1, 0	
	bra	write
	bra	record_or_play		; end if ac1, ac2, ac3 are 0
;	goto	$
	
read_init
	movlw	0x00
	movwf	TRISH, ACCESS		; initialize port H to display read bytes on port H as a debugging step
	
	call	read_sequence_init	; initialize FRAM for reading by sending appropriate opcodes found in external_memory.asm
	
	movlw 	0x03
	movwf	ac1
	movlw	0xFF		    
	movwf	ac2
	movlw	0xFF
	movwf	ac3

	call	init_counter24bit	    ; load up 24 bit counter again
	
	movlw	0x50
	call	LCD_Send_Byte_D		    ; display P for playing if above is executed
	call	SPI_MasterInit2		    ; initialize second SPI module to write to 12 bit DAC serially along with reading from FRAM
	bra	read
	
read	;call	read_sequence
	;movwf	PORTH
;	movlw	0xAA
	;call	LCD_Write_Hex		    ; debugging read sequence in external_memory.asm by displaying on LCD
	
;	call	DAC_write		    ; have used Multiplication to display decimal adc voltages on LCD during debugging
	
	
;	movlw	.1
;	call	LCD_delay_x4us
;	bra	read2
	
	call	counter24bit
	
	movlw	0x00		; conditional to check if the 24 bit counter is 0 to stop reading memory
	cpfseq	ac3, 0	
	bra	read
	cpfseq	ac2, 0
	bra	read
	cpfseq	ac1, 0	
	bra	read	
	bra	record_or_play		    ; go back to menu after playing back
	
end1    
	end	