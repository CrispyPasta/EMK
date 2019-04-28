; TODO INSERT INCLUDE CODE HERE
    list p=PIC18F45K22
    #include "p18f45K22.inc"
;*******************************************************************************
;
; TODO Step #2 - Configuration Word Setup
;
 ;--- Configuration bits ---
    CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
    CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bit (WDT is controlled by SWDTEN bit of the WDTCON register)
    CONFIG  LVP	= ON
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
    
    ;<editor-fold defaultstate="collapsed" desc="CBLOCK">
    CBLOCK 0x00
    col			;variable to program race colour
    count		
    mes1		;received message command character 1	
    mes2		;received message command character 2
    mes3		;received message command character 3
    cnt			;character count for receive
    reg
    size		;startup message size variable
    
    loop
    newsize	    ; used to store new message size
    redValue	    ; These will store the values read by the cal subroutine come prac 2
    blueValue
    greenValue
    whiteValue
    blackValue
    stateBits	    ; One-hot encoding indicating the current state
		    ; 7 = MSG, 6 = RCE, 5 = PRC, 4 = CAL
    portAbackup	    ; this stores whatever was in PORTA before the debugging interrupt so it can be restored
    delay1
    delay2
    delay3
    TX_BYTE
    RX_BYTE
    WRITE_ACKNOWLEDGE_POLL_LOOPS
    POLL_COUNTER
    WRITE_CONTROL
    READ_CONTROL
    EEPROM_ADDRESS
    EEPROM_DATA
    readCount
    newdelay
    ENDC
    ;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;<editor-fold defaultstate="collapsed" desc="Reset and Interrupt Vectors">
    org 	0h
    GOTO 	setup   
    org 	8h  
    BTFSC   INTCON,RBIF      ; Test the interrupt flag of PORTB pin 0
    BTG	    PORTA,7
    return
    org		18h
    BTFSC   INTCON,RBIF      ; Test the interrupt flag of PORTB pin 0
    GOTO    DEBUG_SUB       ; Go to the debugging subroutine
    RETURN
    ;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    
    ;<editor-fold defaultstate="collapsed" desc="Setup">
setup
    ;setup
     ;oscillator setup
	BSF		OSCCON,IRCF0
	BCF		OSCCON,IRCF1
	BSF		OSCCON,IRCF2
     ; Initialize Port A	(just flashes an LED in my program)
    MOVLB	0xF		    ; Set BSR for banked SFRs
    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    CLRF	ANSELA		; clear bits for all pins	
    CLRF	LATC
    CLRF	TRISC
    CLRF	ANSELC
    CLRF	PORTC
    ; Initialize Port B	(SSD port)
     ; Initialize Port B (button interrupt for debugging subsystem)
    CLRF    PORTB
    CLRF    LATB
    CLRF    ANSELB
    MOVLW   b'10010001'
    MOVWF   TRISB
    
    
    
    ; Initialize Port D	(SSD port)
    CLRF	PORTD		; Initialize PORTD by clearing output data latches
    CLRF	LATD		; Alternate method to clear output data latches
    CLRF	TRISD		; clear bits for all pins
    CLRF	ANSELD		; clear bits for all pins
    
    ;;;;; Interrupt initialization
    BSF	    INTCON,PEIE		; Enable peripheral interrupts
    BSF	    INTCON,RBIE		;enable PORTB pins interrupt enabled
    BSF	    INTCON,INT0IE
    BCF	    PIE1,RC1IE		; Set RCIE Interrupt Enable
    BCF	    PIE1,TX1IE
    BCF	    PIR1,RCIF
    bsf     INTCON,GIE  ; Enable global interrupts
    BSF	    IOCB,IOCB7
  
    
    ;setup port for transmission
    CLRF    FSR0
    MOVLW 	b'00100100'	;enable TXEN and BRGH
    MOVWF 	TXSTA1
    MOVLW 	b'10010000'	    ;enable serial port and continuous receive 
    MOVWF 	RCSTA1
    MOVLW 	D'25'
    MOVWF 	SPBRG1
    CLRF    SPBRGH1
    BCF	    BAUDCON1,BRG16	; Use 8 bit baud generator
    BSF	    TRISC,TX		; make TX an output pin
    BSF	    TRISC,RX		; make RX an input pin
    CLRF    PORTC
    CLRF    ANSELC
    MOVLW   b'11011000'  	; Setup port C for serial port.
			    ; TRISC<7>=1 and TRISC<6>=1.
    MOVWF   TRISC
    MOVLW   D'5'
    MOVWF   size
    
    ; INITIALISE VARIABLES
	MOVLW 	0xA0
	MOVWF 	WRITE_CONTROL
	MOVLW 	0X00
	MOVWF 	EEPROM_ADDRESS
	CLRF 	EEPROM_DATA
	MOVLW 	0xA1
	MOVWF 	READ_CONTROL
	MOVLW 	D'255'
	MOVWF 	WRITE_ACKNOWLEDGE_POLL_LOOPS
	CLRF 	POLL_COUNTER
	CLRF 	RX_BYTE
	CLRF 	TX_BYTE
;	call	I2C_INIT
	GOTO    RCE
	
	;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
    ;<editor-fold defaultstate="collapsed" desc="Startup">
startup
	LFSR	1,0x08		; set pointer to address of character that must be transmitted
T1	MOVFF	INDF1,WREG	;transmission loop for startup message
	call 	trans			; transmit startup message character
	INCF	FSR1L,F
	DECFSZ	size
	BRA 	T1
	MOVLW	A' '		;transmit a space character
	call	trans		; trans is the actual transmission function
	MOVLW   42h			;set blue as default colour
	MOVWF   col
	BSF		PORTA,7
	GOTO	RCE
;</editor-fold>
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
    ;<editor-fold defaultstate="collapsed" desc="RCE">
RCE	MOVLW	b'10100100'			;hard coded transmission of RCE mode message
	MOVWF	PORTD
	MOVLW	A'\n'
	call     trans
	MOVLW	A'M'
	call    trans
	MOVLW	A'A'
	call    trans
	MOVLW	A'R'
	call    trans
	MOVLW	A'V'
	call    trans
	MOVLW	A' '
	call    trans
	MOVLW	A'r'
	call    trans
	MOVLW	A'a'
	call    trans
	MOVLW	A'c'
	call    trans
	MOVLW	A'e'
	call    trans
	MOVLW	A's'
	call    trans
	MOVLW	A' '
	call    trans
	MOVF	col,0	
	call    trans				
	MOVLW	A'\n'
	call    trans			;until here
	bcf	PIR1,TXIF
	bcf	PIE1,TXIE
	BSF	PORTA,4
	bcf	PIR1,5
	BCF	PORTA,4
	GOTO	R1
	
R1	LFSR 0,0x02			;set pointer to where serial command characters are stored
	BCF	INTCON,GIE
	BCF	INTCON,PEIE
	MOVLW	D'3'
	MOVWF	cnt
R2	BTFSS PIR1,RC1IF	; check if something is received loop
	BRA R2
cat	MOVFF	RCREG, INDF0	;catches the character
	INCF	FSR0L,F
	DCFSNZ	cnt 			; if 3 characters received goto processing function
	GOTO	PRO
	GOTO	R2
	
PRO	LFSR	0,0x02
	; MOVLW	A'M'
	; XORWF	INDF0,W
	; BTFSC	STATUS,Z
	; GOTO	Pro1			;if M is received goto MSG processing branch
	MOVLW	A'P'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro2			;if P is received goto PRC processing branch
	MOVLW	A'R'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro3		;if R is received goto RCE processing branch
	MOVLW	A'C'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro4		;if C is received goto CAL processing branch
	GOTO	err			; if none of the serial commands is received goto error message
	
Pro1	LFSR	0,0x03		    ;check if  rest of msg is received
	MOVLW	A'S'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x04
	MOVLW	A'G'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	MSG
	GOTO	err
	
Pro2	LFSR	0,0x03		    ;check if rest of prc is received
	MOVLW	A'R'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x04
	MOVLW	A'C'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	PRC
	GOTO	err
	
Pro3	LFSR	0,0x03		    ;check if rest of rce is received
	MOVLW	A'C'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x04
	MOVLW	A'E'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	RCE
	GOTO	err
	
Pro4	LFSR	0,0x03		    ;check if rest of cal is received
	MOVLW	A'A'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x04
	MOVLW	A'L'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	CAL
	GOTO	err
;</editor-fold

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;<editor-fold defaultstate="collapsed" desc="ERROR Message">	
err	
	MOVLW	A'\n'
	call    trans
	MOVLW	A'E'		    ;display error message if wrong serial command entered
	call    trans
	MOVLW	A'R'
	call    trans
	MOVLW	A'R'
	call    trans
	MOVLW	A'O'
	call    trans
	MOVLW	A'R'
	call    trans
	MOVLW	A'\n'
	call    trans
	GOTO R1
;</editor-fold>	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;<editor-fold defaultstate="collapsed" desc="Startup Message">	
MSG	MOVLW	b'11000000'		;program startup message 
	MOVWF	PORTD
	MOVLW	D'0'
	MOVF	newsize,0
	LFSR	0,0x08
	MOVLW	D'10'
	MOVWF	cnt
clear	
	CLRF	INDF0
	DCFSNZ	cnt
	GOTO	R6
	GOTO	clear
R6	LFSR	0,0x08
R7	BTFSS	PIR1, RCIF	;receive new startup message 
	BRA	R7
	MOVFF	RCREG, INDF0
	MOVLW	A'$'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
;	GOTO	STORE
	INCF	FSR0L,F
	INCF	newsize,F
	MOVLW	D'10'
	CPFSEQ	newsize
	GOTO	R7 
;	GOTO	STORE		;go store the new startup message
;</editor-fold>	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;<editor-fold defaultstate="collapsed" desc="Program Color PRC">
PRC	
	MOVLW	A'\n'
	call    trans
	MOVLW	A'W'
	call    trans
	MOVLW	A'h'
	call    trans
	MOVLW	A'a'
	call    trans
	MOVLW	A't'
	call    trans
	MOVLW	A' '
	call    trans
	MOVLW	A's'
	call    trans
	MOVLW	A'h'
	call    trans
	MOVLW	A'a'
	call    trans
	MOVLW	A'l'
	call    trans
	MOVLW	A'l'
	call    trans
	MOVLW	A' '
	call    trans
	MOVLW	A'M'
	call    trans
	MOVLW	A'A'
	call    trans
	MOVLW	A'R'
	call    trans
	MOVLW	A'V'
	call    trans
	MOVLW	A' '
	call    trans
	MOVLW	A'r'
	call    trans
	MOVLW	A'a'
	call    trans
	MOVLW	A'c'
	call    trans
	MOVLW	A'e'
	call    trans
	MOVLW	A'?'
	call    trans		
	MOVLW	A'\n'
	call    trans		;until here

R3	BTFSS	PIR1, RCIF	; receive new color to race 
	BRA 	R3
	MOVFF	RCREG, col
	GOTO	REC				; go chech if it is a valid race color 
R4	LFSR 	0,0x02
	MOVLW	D'3'
	MOVWF	cnt
R5	BTFSS 	PIR1, RCIF	; check if something is received
	BRA 	R5
	MOVFF	RCREG, INDF0
	INCF	FSR0L,F
	DCFSNZ	cnt 
	GOTO	PROC
	GOTO	R5

REC	LFSR	0,0x00			; check if a valid race color is received 
	MOVLW	A'B'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	R4
	MOVLW	A'R'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	R4
	MOVLW	A'G'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	R4
	MOVLW	A'n'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	R4
	MOVLW	A'L'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	R4				;until here
	GOTO	err				; if it is not valid show error message
	
PROC	
	LFSR	0,0x02			;check if RCE is received only valid serial command if in PRC
	MOVLW	A'R'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x03
	MOVLW	A'C'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x04
	MOVLW	A'E'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	GOTO	RCE
;</editor-fold>
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


trans						;general transmission function
S1	BTFSS 	PIR1, TX1IF
	BRA 	S1
	MOVWF 	TXREG
	return	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;<editor-fold defaultstate="Calibration Subroutine">	
CAL							;calibrate the sensors here
CALIBRATE
    CLRF    PORTA
    MOVLW   b'10000000'
    MOVWF   PORTD
    call    delay1s
    BSF	    PORTA,0
    MOVLW   b'10001000'
    MOVWF   PORTD
    call    delay1s
    BSF	    PORTA,1
    MOVLW   b'10000010'
    MOVWF   PORTD
    call    delay1s
    BSF	    PORTA,2
    MOVLW   b'11000001'
    MOVWF   PORTD
    call    delay1s
    BSF	    PORTA,3
    MOVLW   b'11001000'
    MOVWF   PORTD
    call    delay1s
    BSF	    PORTA,4
    call    delay1s
    CLRF    PORTA
    GOTO    RCE				
;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;<editor-fold defaultstate="collapsed" desc="Debugging subroutine">
DEBUG_SUB
    bcf     INTCON,INT0IF      ; clear the interrupt flag
    bcf	    INTCON,RBIF
    MOVF    PORTA,w	    	; copy porta to w
    MOVWF   portAbackup     ; copy from w to the backup register 
    BTFSC   stateBits,7     ; check if it's in message mode
    CALL    debugMessage
    BTFSC   stateBits,6     ; check if it's in race mode
    CALL    debugRace
    BTFSC   stateBits,5     ; check if it's in programming mode
    CALL    debugProgram
    BTFSC   stateBits,4     ; check if it's in calibration mode
    CALL    debugCalibrate
    MOVF    portAbackup,w
    MOVWF   PORTA           ; restore port A contents
    bcf	    INTCON,RBIF
    RETFIE

debugMessage
    MOVF    0x08,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugRace
    MOVF    col,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugProgram
    MOVF    col,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugCalibrate
    ;MOVF    calOffset,w  
    MOVWF   PORTA
    call    delay1s
    RETURN 
   
;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;<editor-fold defaultstate="collapsed" desc="One second delay">
delay1s
    MOVLW   0x0F
    MOVWF   delay3
Go_off0
	movlw	0xFF
	movwf	delay2
Go_off1				
	movlw	0xFF	
	movwf	delay1
Go_off2
	decfsz	delay1,f
	goto	Go_off2
	decfsz	delay2,f
	goto	Go_off1
	decfsz	delay3,f
	goto	Go_off0
	RETURN
;</editor-fold>
   	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    end