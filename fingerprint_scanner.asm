#include p18f87k22.inc

	    global  byte_reversal
	    
acs0	udata_acs
byte_to_reverse res 1   ; reserve 1 byte for each variable Mul_temp	
reversed_byte	res 1
byte_counter	res 1

finger  code
	
	
byte_reversal				; uses byte in W and reverses it
	movwf	byte_to_reverse	
	movlw	0x00
	movwf	reversed_byte		; initialize reversed_byte register
	movlw	0x08			 
	movwf	byte_counter		; counter to reverse a byte
	movlw	0x00			; make W 0 again
	call	reversing
	movf	reversed_byte, 0, 0		; move reversed byte to W
	return

reversing	
	rrcf	byte_to_reverse, 1, 0	    ; rotates the byte to the left and stores in byte_to_reserve
	addwfc	reversed_byte, 1, 0	    ; add the least significant bit to 0x00 in reversed byte  
	rlncf	reversed_byte, 1, 0
	decfsz	byte_counter, 1, 0
	call	reversing
	return   
;   Preliminary work to get the fingerprint scanner working. Couldn't finish
; This is some byte reversal code for reversing serial messages to fingerprint scanner. RIP! 
end1    
	end
