#include p18f87k22.inc
	global	ac1, ac2, ac3, ac_temp1, ac_temp2, ac_temp3, init_counter24bit, counter24bit
	
acs0	udata_acs
ac1	res 1
ac2	res 1
ac3	res 1
ac_temp1    res	1
ac_temp2   res	1
ac_temp3   res	1


here_is_some	code
	
init_counter24bit
	movlw	0x00
	movwf	ac_temp1, 0
	movwf	ac_temp2, 0
	movwf	ac_temp3, 0
	return

counter24bit	    		; initialize by adding some values to ac1, ac2, ac3 to count up to
				; counter increments by 1 each time it is called
;	call	init_counter24bit
	movlw	0x00
	cpfseq	ac3, 0		; skips decrementing if already zero
	bra	temp
	bra	second_byte_count1

temp		
	decfsz	ac3, 1, 0	; count down from the lowest byte  then move on to the second byte
	return
	bra	second_byte_count1

	
second_byte_count1
	incf	ac_temp1, 1, 0	    ; increment temp register with 1
	bc	second_byte_count2    ; branch if carry i.e counted all up to .256
	return

second_byte_count2
	movlw	0x00
	addwfc	ac_temp1, 0
	clrf	ac_temp1, 0	    ; reset counter fow second byte
	movlw	0x00
	cpfseq	ac2, 0		    ; skips decrementing if already zero	
	bra	temp1
	bra	third_byte_count1
	
temp1		
	decfsz	ac2, 1, 0	    ; decrement second more significant byte
	return
	bra	third_byte_count1
	
third_byte_count1
	incf	ac_temp2, 1, 0
	bc	third_byte_count2
	return

third_byte_count2
	movlw	0x00
	addwfc	ac_temp2, 0
	clrf	ac_temp2, 0	    ; reset lower byte counter 2 fow third byte
	decf	ac1, 1, 0	    ; decrement most significant byte
	return
	
; now add the condition in simple one where writes are called
;   loop writes and just add 
;	call	counter24bit	(add appropriate bytes to ac1, ac2, ac3 address counters)
;	then  branch to read once ac1 is 0.
	
;	cond:	    cpfseq  ac1, 0	    skips if ac1 is 0 i.e. the same as W

;	whole:	    call    counter24bit
;		    cpfseq  ac1, 0
;		    bra	    write
;		    bra	    read
	
;
; append condition to end of write module
; also 
	end


