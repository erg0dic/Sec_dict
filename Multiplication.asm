#include p18f87k22.inc

	global	Mul_temp_A, Mul_temp_C, Mul_temp_B, Mul_temp_D, Mul_temp_E
	global  hex_to_dec
    
	extern  LCD_Write_Hex, LCD_Clear_Screen
    
acs0	udata_acs
Mul_temp_1 res 1   ; reserve 1 byte for each variable Mul_temp	
Mul_temp_2 res 1
Mul_temp_3 res 1
Mul_temp_4 res 1
Mul_temp_5 res 1
Mul_temp_6 res 1
Mul_temp_A res 1
Mul_temp_B res 1
Mul_temp_C res 1
Mul_temp_D res 1
Mul_temp_E res 1
dec_1 res 1
dec_2 res 1
dec_3 res 1
dec_4 res 1
multiplication  code

mul_8x16
				    ; Multiply BA x W 16 bit by 8 bit
				    ; Result is in temp 321
				    ;Have 8 bit number already in W register
				    
	mulwf	Mul_temp_A, 0
		
	movff	PRODL, Mul_temp_1   ;store least significant byte in temp register Mul_temp_1
	
	movff	PRODH, Mul_temp_2 
	
	mulwf	Mul_temp_B, 0  ; assuming that w is unchanged
	
	movf	PRODL, 0
	addwfc	Mul_temp_2, 1, 0    ;add bits and store middle significant byte in temp register Mul_temp_2
	movlw	0x00
	addwfc	PRODH,  0, 0	    ;add 0 and carry bit to most significant byte   
	movwf	Mul_temp_3	    ;store most significant byte in temp register Mul_temp_3
				    ;from W to f reg
				    
	return
		
mul_16x16
				    ; Multiply BA x DC 16 bit by 16 bit 
				    ; Result is temp 3214 
				     
	movf	Mul_temp_C, 0		    ;move least sig byte to W reg for 8x16 mul
	call	mul_8x16	    ;complete multiplication
	movff	Mul_temp_1, Mul_temp_4    ;move straight to final address - doesn't need to be added
	movff	Mul_temp_2, Mul_temp_5
	movff	Mul_temp_3, Mul_temp_6
	
	
	movlw	0x00
	movwf	Mul_temp_1
	movwf	Mul_temp_2
	movwf	Mul_temp_3
	
	movf	Mul_temp_D, 0		    ;move most sig byte into W reg for mul
	call	mul_8x16
	
	movf	Mul_temp_5, 0	    ;move Mul_temp_5 to W reg for addition
	addwfc	Mul_temp_1, 1	    ;add with appropriate num from other mul	
	
	movf	Mul_temp_6, 0	    ;repeat prev
	addwfc	Mul_temp_2, 1
	
	movlw	0x00		    ;move 0 to w reg
	addwfc	Mul_temp_3, 1	    ;add 0 with carry to most sig byte
	
	
	
	return
	
mul_8x24
					    ; Multiply CBA x E 24 bit by 8 bit 
					    ; Result is in temp 4321
	movf	Mul_temp_E, 0		    ; move least sig byte to W reg for 8x16 mul
	call	mul_8x16	    ;complete multiplication

	movf	Mul_temp_E, 0
	
	mulwf	Mul_temp_C, 0		
	 
	movf	PRODL, 0
	addwfc	Mul_temp_3, 1
	
	movff	PRODH, Mul_temp_4
	movlw	0x00
	addwfc	Mul_temp_4, 1
	return
	
hex_to_dec
	; define a 16 x 16 bit input using temp_B and temp_A (BA)
	
	movlw	0x8A
	movwf	Mul_temp_C
	
	movlw	0x41
	movwf	Mul_temp_D		    ; define DC the second 16 bit that is generic for the algorithm
	
	call	mul_16x16		    ; have result in order temp_3214
	
	movff	Mul_temp_3, dec_1   ; get most sig decimal (first output)
;	movf	dec_1, 0
;	call	LCD_Write_Hex
	
	movff	Mul_temp_2, Mul_temp_C	    
	movff	Mul_temp_1, Mul_temp_B
	movff	Mul_temp_4, Mul_temp_A
	
	movlw	0x0A			    ; second step of the algorithm
	movwf	Mul_temp_E
	call	mul_8x24		    ; have result in order temp_4321
	
	movff	Mul_temp_4, dec_2   ; get most sig decimal (second output)
	
	movff	Mul_temp_3, Mul_temp_C	    
	movff	Mul_temp_2, Mul_temp_B
	movff	Mul_temp_1, Mul_temp_A
	
	call	mul_8x24		    ; have result in order temp_4321
	
	movff	Mul_temp_4, dec_3   ; get most sig decimal (third output)
	
	movff	Mul_temp_3, Mul_temp_C	    
	movff	Mul_temp_2, Mul_temp_B
	movff	Mul_temp_1, Mul_temp_A
	
	call	mul_8x24		    ; have result in order temp_4321
	
	movff	Mul_temp_4, dec_4   ; get most sig decimal (fourth output)
	
	swapf	dec_1, 0
	addwf	dec_2, 1
	swapf	dec_3, 0
	addwf	dec_4, 1

	
;	call	LCD_Clear_Screen
	
	return
	end