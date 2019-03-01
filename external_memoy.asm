#include p18f87k22.inc
    
    global  init_chip_s, write_sequence_init, write_sequence, set_cs_high, read_sequence_init, read_sequence 
    extern  SPI_MasterInit, SPI_MasterInit2, SPI_MasterTransmit2, SPI_MasterTransmit, SPI_MasterReceive
    global  counter, address_count1, address_count2
    
    extern  LCD_delay_ms, LCD_delay_x4us 
    
acs0	udata_acs
counter	    res 1
address_count1	res 1
address_count2	res 1
	
	
memory_interface    code
   
init_chip_s
	movlw	b'11111101'		    ; set RE1 tris to low so its the only output
	movwf	TRISE
	movlw	b'00000010'		    ; set RE1 to high and call a delay
	movwf	PORTE
	movlw	.1
	call	LCD_delay_ms	
	movlw   0x00	    ; set RE1 to low
	movwf	PORTE
	return

set_cs_low
	bcf	TRISE, 1		    ; set RE1 tris to low so its the only output
	bcf	PORTE, 1		    ; set RE1 to high and call a delay
	return

set_cs_high
	bcf	TRISE, 1		    ; set RE1 tris to low so its the only output
	bsf	PORTE, 1			    ; set RE1 to high and call a delay	
	return
	
write_sequence_init
	
	call	init_chip_s
	movlw	b'00000010'		    ; set RE1 to high and call a delay
	movwf	PORTE
	
	call	SPI_MasterInit
	
	call	init_chip_s
	movlw	b'00000110'		; Set write enable latch opcode to initialize writing into the external memory	
	call	SPI_MasterTransmit	; send serial data
	
	call	init_chip_s   
	movlw	b'00000010'		; write sequence starter
	call	SPI_MasterTransmit
	
	
	movlw	0x00				; call	address where to store this is on memory
	call	SPI_MasterTransmit
	movlw	0x00				
	call	SPI_MasterTransmit
	movlw	0x00				
	call	SPI_MasterTransmit
	
	return
	
write_sequence			; assumes a write sequence has been initialized
;	movf	counter, 0, 0		; check with test data to see if it works
;	dcfsnz	counter, 1, 0
;	call	reset_counter
;	movlw	0xAA
	call	SPI_MasterTransmit	; serial it and send it to external memory
;	call	set_cs_high		; terminate the write sequence
	return	
	
read_sequence_init
	call	init_chip_s
	movlw	b'00000010'		    ; set RE1 to high and call a delay
	movwf	PORTE
			
	call	SPI_MasterInit
	
	call	init_chip_s
	movlw	b'00000011'		; Set write enable latch opcode to initialize writing into the external memory	
	call	SPI_MasterTransmit	; send serial data i.e. the READ opcode in serial form
	
	movlw	0x00				;call	address where to store this is on memory
	call	SPI_MasterTransmit
	movlw	0x00				
	call	SPI_MasterTransmit
	movlw	0x00				
	call	SPI_MasterTransmit
	
	return	

read_sequence		    ; assumes the read and read sequence is initialized
	call	SPI_MasterReceive	    ; stores read byte in W
;	call	set_cs_high		; terminate read if single reads preferred
	return
	
	
reset_counter
	movlw	0xFF
	movwf	counter, 0
	return
    
    
    
    end



