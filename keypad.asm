	#include p18f87k22.inc

	global  keypad_setup, record_row, keypad_setup2, record_column, sumHandJ, keypad_LCD, key_r, key_c, keypad_LCD_secure, keypad_button_press
    
	extern  LCD_delay_ms, LCD_Send_Byte_D, LCD_Clear_Screen
    
acs0	udata_acs
key_r	res 1
key_c	res 1
	

keypad  code
  
  
keypad_setup
	banksel	PADCFG1
        bsf	PADCFG1, REPU, BANKED		; set pull ups for PORTE
	movlb	0x00			    
	setf	TRISE
	clrf	LATE			; set 0s to LATE register
	movlw	0x0F			; set ports 4-7 to outputs (0s) and 0-3 as inputs (1s)
	movwf	TRISE, ACCESS
	movlw	0x90		    ; no. of ms delay
	call	LCD_delay_ms
	movlw	0x00
	movwf	key_r
	return
	
keypad_setup2
	
	movlw	0xF0			; set ports 4-7 to outputs (0s) and 0-3 as inputs (1s)
	movwf	TRISE, ACCESS
	movlw	0x10		    ; no. of ms delay
	call	LCD_delay_ms
	return
	
record_row
	movlw	0x00
	movwf	TRISD, ACCESS	
	movff	PORTE, PORTD
	movlw	0x10		    ; no. of ms delay
	call	LCD_delay_ms
	
	movlw	0x0F
	cpfseq	PORTD		    ; compare value and skip if equal
	bra	check
	bra	record_row
check	
	movlw	0x05		    ; no. of ms delay
	call	LCD_delay_ms
	movlw	0x0F
	cpfseq	PORTD		    ; compare value and skip if equal
	bra	conditional
	bra	record_row
	
conditional	
	movlw	0x10		    ; 16  in W
	subfwb	PORTD, 1, ACCESS    ; records the pressed bit
	movlw	0x00
	movwf	key_r, ACCESS	
	movff	PORTD, key_r	    ; record in D		
	return
		
record_column
	
	movlw	0x00
	movwf	TRISD, ACCESS	
	movff	PORTE, PORTD
	movlw	0x10		    ; no. of ms delay
	call	LCD_delay_ms
	
	movlw	0xF0
	cpfseq	PORTD		    ; compare value and skip if equal
	bra	check2
	bra	record_column
check2	
	movlw	0x05		    ; no. of ms delay
	call	LCD_delay_ms
	movlw	0xF0
	cpfseq	PORTD		    ; compare value and skip if equal
	bra	conditional2
	bra	record_column
	
conditional2	
	movlw	0xF1		    ; 16  in W
	subfwb	PORTD, 1, ACCESS    ; records the pressed bit
	movlw	0x00
	movwf	key_c, ACCESS
	movff	PORTD, key_c
	return

	
sumHandJ	    ; sum rows and columns, initially done on ports H and J hence the name
	movlw	0x00
	addwf	0x00,1, ACCESS
	movf	key_c, 0, ACCESS
	addwf	key_r, 1, ACCESS
	return
	
keypad_LCD		    ; display correct numbers on LCD in terms of decoded Asciis of the keys pressed on keypad
	call	LCD_Clear_Screen
	
	movlw	0x88
	cpfseq	key_r
	bra	br1
	movlw	0x31
	bra	print
	
br1	movlw	0x48
	cpfseq	key_r
	bra	br2
	movlw	0x32
	bra	print
	
br2	movlw	0x28
	cpfseq	key_r
	bra	br3
	movlw	0x33
	bra	print
	
br3	movlw	0x18
	cpfseq	key_r
	bra	br4
	movlw	0x46
	bra	print
	
br4	movlw	0x84
	cpfseq	key_r
	bra	br5
	movlw	0x34
	bra	print
	
br5	movlw	0x44
	cpfseq	key_r
	bra	br6
	movlw	0x35
	bra	print
		
br6	movlw	0x24
	cpfseq	key_r
	bra	br7
	movlw	0x36
	bra	print

br7	movlw	0x14
	cpfseq	key_r
	bra	br8
	movlw	0x45
	bra	print
	
br8	movlw	0x82
	cpfseq	key_r
	bra	br9
	movlw	0x37
	bra	print
	
br9	movlw	0x42
	cpfseq	key_r
	bra	br10
	movlw	0x38
	bra	print
	
br10	movlw	0x22
	cpfseq	key_r
	bra	br11
	movlw	0x39
	bra	print

br11	movlw	0x12
	cpfseq	key_r
	bra	br12
	movlw	0x44
	bra	print
	
br12	movlw	0x81
	cpfseq	key_r
	bra	br13
	movlw	0x41
	bra	print
	
br13	movlw	0x41
	cpfseq	key_r
	bra	br14
	movlw	0x30
	bra	print
	
br14	movlw	0x21
	cpfseq	key_r
	bra	br15
	movlw	0x42
	bra	print

br15	movlw	0x11
	cpfseq	key_r
	nop
	movlw	0x43
	bra	print

print	
	call	LCD_Send_Byte_D
	return
 
	
keypad_LCD_secure		; display * instead of actual digits pressed on LCD when entering pin code!	    
	movlw	0x2A
	call	LCD_Send_Byte_D
	return
	
	

keypad_button_press		; a routine that records the correct key pressed on keypad and stores it in key_r register
	call	keypad_setup
	call	record_row
	call	keypad_setup2
	call	record_column
	call	sumHandJ
	movlw	0x0FF		    ; no. of ms delay
	call	LCD_delay_ms
	call	keypad_LCD_secure
	return
    
	end


