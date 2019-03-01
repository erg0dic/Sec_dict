#include p18f87k22.inc
     
    global  SPI_MasterInit, SPI_MasterInit2, SPI_MasterTransmit2, SPI_MasterTransmit, SPI_MasterReceive
    
    extern  LCD_delay_ms, LCD_delay_x4us 
    

here_is_some    code
 
    
SPI_MasterInit ; Set Clock edge to negative
	bcf	SSP1STAT, CKE	    ; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw	(1<<SSPEN)|(1<<CKP)|(0x02)
	movwf	SSP1CON1		    ; SDO2 output; SCK2 output
	bcf	TRISC, SDO1		    ; PORTC5
	bcf	TRISC, SCK1		    ; PORTC3
	bsf	TRISC, SDI1		    ; PORTC4	
	return
	
SPI_MasterTransmit ; Start transmission of data (held in W)
	movwf	SSP1BUF
Wait_Transmit ; Wait for transmission to complete
	btfss	PIR1, SSP1IF
	bra	Wait_Transmit
	bcf	PIR1, SSP1IF ; clear interrupt flag
	return	
	
	
SPI_MasterReceive
	movlw	0x00
	movwf	SSP1BUF		; customary to write to W to receive data transmission!!!
	
Wait_read ; Wait for transmission to complete and store result in W
;	btfss	SSP1STAT, BF	;Has data been received (transmit complete)?
;	bra	Wait_read
;	movf	SSP1BUF, 0	; alternative method
	
	btfss	PIR1, SSP1IF
	bra	Wait_read  
	bcf	PIR1, SSP1IF ; clear interrupt flag
	movf	SSP1BUF, W	; receive data transmission in W
	return		

    
SPI_MasterInit2 ; Set Clock edge to positive
	bsf	SSP2STAT, CKE	    ; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw	(1<<SSPEN)|(0x02)	; transfer on rising edge
	movwf	SSP2CON1		    ; SDO2 output; SCK2 output
	bcf	TRISD, SDO2		    ; PORTD4
	bcf	TRISD, SCK2		    ; PORTD6	
	return
	
SPI_MasterTransmit2 ; Start transmission of data (held in W)
	movwf	SSP2BUF
Wait_Transmit2 ; Wait for transmission to complete
	btfss	PIR2, SSP2IF
	bra	Wait_Transmit2
	bcf	PIR2, SSP2IF ; clear interrupt flag
	return    

   
    end


