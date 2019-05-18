;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Headers
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------
    
;<editor-fold defaultstate="collapsed" desc="Headers">   
    list p=PIC18F45K22
    #include "p18f45K22.inc"
;</editor-fold>

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Configuration Bits
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------        
    
;<editor-fold defaultstate="collapsed" desc="Configuration Bits">  
    
    ;--- Configuration bits ---
    CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
    CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bit (WDT is controlled by SWDTEN bit of the WDTCON register)
    CONFIG  LVP	= ON
    
;</editor-fold>
    
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    CBlock
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------
    
;<editor-fold defaultstate="collapsed" desc="CBlock">      
    CBLOCK 0x00
    col
    count
    mes1
    mes2
    mes3
    cnt
    reg
    size
    eep1
    eep2
    eep3
    eep4
    eep5
    eep6
    eep7
    eep8
    eep9
    eep10
    loop
    newsize
    redValue    ; These will store the values read by the cal subroutine come prac 2
    blueValue
    greenValue
    whiteValue
    blackValue
    delayCounter    ; Used to make a 3s delay for calibration subroutine
    calOffset   ; The offset used to display the right character on the SSD
    calRounds   ; The number of times the calibration subroutine must be run = 5
    stateBits   ; One-hot encoding indicating the current state
                    ; 7 = MSG, 6 = RCE, 5 = PRC, 4 = CAL
    portAbackup ; this stores whatever was in PORTA before the debugging interrupt so it can be restored
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
    ADCHIGH
    ADCLOW
    ENDC
    
    ;</editor-fold>
    
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Reset Vectors
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------

;<editor-fold defaultstate="collapsed" desc="Reset Vectors"> 
    
    
    org 0h
	GOTO setup   
    
	
    org 8h  
	RETURN
    
;</editor-fold>    

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Setup Block
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------	

;<editor-fold defaultstate="collapsed" desc="Setup">	
	
setup:

;-------------------------------------------------
;		Oscillator Setup
;-------------------------------------------------

    ;<editor-fold defaultstate="collapsed" desc="Oscillator Setup"> 

;Set up the oscillator frequency of the PIC to run at 4 MHz
    
    BSF	OSCCON,IRCF0
    BCF	OSCCON,IRCF1
    BSF	OSCCON,IRCF2
	
    ;</editor-fold> 
	     
;-------------------------------------------------
;		Initialize Port A
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="Initialize Port A">
    
    ;Flashes an LED in my program     
     
    MOVLB	0xF		; Set BSR for banked SFRs
    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    CLRF	ANSELA		; clear bits for all pins	

    ;</editor-fold>
    
;-------------------------------------------------
;		Initialize Port C
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="Initialize Port C">
    	
    CLRF	LATC
    CLRF	TRISC
    CLRF	ANSELC
    CLRF	PORTC
    
    ;</editor-fold>
    
;-------------------------------------------------
;		Initialize Port B
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="Initialize Port B">    
    
    ;SSD port
    ;Initialize Port B (button interrupt for debugging subsystem)
    
    CLRF    PORTB
    CLRF    LATB
    MOVLW   0xFF 
    MOVWF   TRISB
    CLRF    ANSELB
    MOVLB   0xF

    ;</editor-fold>
    
;-------------------------------------------------
;		Initialize Port D
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="Initialize Port D">
    
    ; Initialize Port D	(SSD port)
    
    CLRF	PORTD		; Initialize PORTD by clearing output data latches
    CLRF	LATD		; Alternate method to clear output data latches
    CLRF	TRISD		; clear bits for all pins
    CLRF	ANSELD		; clear bits for all pins
    
    ;</editor-fold>
    
;-------------------------------------------------
;		Enable Periphiral Interrupts
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="Enable Periphiral Interrupts">
    
    BSF	    INTCON,PEIE		; Enable peripheral interrupts
    BSF	    INTCON,GIE		; Enable global interrupts
    BSF	    INTCON,INT0IE
    ;BSF	    INTCON,INT0IF
    BSF	    PIE1,RC1IE		; Set RCIE Interrupt Enable
    ;BSF	    PIE2,RC2IE		; Set RCIE Interrupt Enable
    BSF	    PIE1,TX1IE
    ;BSF	    IPR1,RC1IP
    BCF	    PIR1,RCIF
    ;BSF	    PIR1,TXIF
    ;bsf     INTCON,PEIE ; Enable peripheral interrupts
    ;bsf     INTCON,GIE  ; Enable global interrupts
    ;setup port for transmission
    
    ;</editor-fold>

;-------------------------------------------------
;		Serial Communication
;-------------------------------------------------

    ;<editor-fold defaultstate="collapsed" desc="Serial Communication">
    
	CLRF    FSR0
	MOVLW   b'00100100'		;enable TXEN and BRGH
	MOVWF   TXSTA1
	MOVLW   b'10010000'		;enable serial port and continuous receive 
	MOVWF   RCSTA1
	MOVLW   D'25'
	MOVWF   SPBRG1
	CLRF    SPBRGH1
	BCF	BAUDCON1,BRG16		; Use 8 bit baud generator
	BSF	TRISC,TX		; make TX an output pin
	BSF	TRISC,RX		; make RX an input pin
	CLRF    PORTC
	CLRF    ANSELC
	MOVLW   b'11011000'		; Setup port C for serial port.
					; TRISC<7>=1 and TRISC<6>=1.
	MOVWF   TRISC
	MOVLW   D'5'
	MOVWF   size
	
    ;</editor-fold>

;-------------------------------------------------
;		Initialize Variables
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="Initialize Variables">

	MOVLW	0xA0
	MOVWF	WRITE_CONTROL
	MOVLW	0X00
	MOVWF	EEPROM_ADDRESS
	CLRF	EEPROM_DATA
	MOVLW	0xA1
	MOVWF	READ_CONTROL
	MOVLW	D'255'
	MOVWF	WRITE_ACKNOWLEDGE_POLL_LOOPS
	CLRF	POLL_COUNTER
	CLRF	RX_BYTE
	CLRF	TX_BYTE
	call	I2C_INIT
	
	    GOTO    startup
	    
    ;</editor-fold>
    
;</editor-fold>

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Main
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------    
   
;<editor-fold defaultstate="collapsed" desc="Main">  
    
startup:	
	
;	CALL	ADC_READ
	CALL	Read_AN0
	
	RCALL	READ
	
	LFSR	1,0x08	
;</editor-fold>
	
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    ADC Block
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------    
   
;<editor-fold defaultstate="collapsed" desc="ADC Block">  
    
;-------------------------------------------------
;		    ADC Read
;-------------------------------------------------
	
;<editor-fold defaultstate="collapsed" desc="ADC Read"> 	

;The ADC_Read function will, when it is called, read a value from the selected analog channel
;then it will store that value in a vaiable. The variable will then be sent to the TXREG.
;The TXREG should then send this value to the serial terminal of the computer connected to it.
;The aim of this function is to read the voltage levels from the sensors and output them sequentially on a serial terminal.

;ADC_Read:
		
    ;<editor-fold defaultstate="collapsed" desc="Read_AN0"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    
Read_AN0:

    CALL	ADC_SETUP_AN0		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go0
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go0    
    
    CLRF	TXREG			    ;Clear TXREG before reading values to it
    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it
    
;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF    	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>
     
    ;<editor-fold defaultstate="collapsed" desc="Read_AN1"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    
Read_AN1:

    CALL	ADC_SETUP_AN1		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go1
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go1 
    
    CLRF	TXREG			    ;Clear TXREG before reading values to it
    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it

;Read ADC Result and store the results in variables
    MOVF 	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF 	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>
     
    ;<editor-fold defaultstate="collapsed" desc="Read_AN2"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    
Read_AN2:

    CALL	ADC_SETUP_AN2		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go2
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go2     
    
    CLRF	TXREG			    ;Clear TXREG before reading values to it
    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it

;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable    
    
    MOVF	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>
     
    ;<editor-fold defaultstate="collapsed" desc="Read_AN3"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    
Read_AN3:

    CALL	ADC_SETUP_AN3		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go3
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go3 
    
    CLRF	TXREG			    ;Clear TXREG before reading values to it
    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it

;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable    
    
    MOVF	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>
     
    ;<editor-fold defaultstate="collapsed" desc="Read_AN4"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    
Read_AN4:

    CALL	ADC_SETUP_AN4		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go4
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go4 
    
    CLRF	TXREG			    ;Clear TXREG before reading values to it
    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it

;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable    
    
    MOVF	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg
    MOVWF	TXREG			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>
     
	RETURN
	
;</editor-fold>	
	
	
;</editor-fold>
	
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Serial Communications Block
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------

;<editor-fold defaultstate="collapsed" desc="Serial Communications Block"> 	
	
T1:	MOVFF	INDF1,WREG
	call	trans
	INCF	FSR1L,F
	DECFSZ	size
	BRA	T1
	
	MOVLW	A' '
	call	trans
	MOVLW   42h			;set blue as default colour
	MOVWF   col
	BSF	PORTA,7
	GOTO	RCE
    
RCE:	MOVLW	b'10100100'
	MOVWF	PORTD
	MOVLW	A'M'
	call trans
	MOVLW	A'A'
	call trans
	MOVLW	A'R'
	call trans
	MOVLW	A'V'
	call trans
	MOVLW	A' '
	call trans
	MOVLW	A'r'
	call trans
	MOVLW	A'a'
	call trans
	MOVLW	A'c'
	call trans
	MOVLW	A'e'
	call trans
	MOVLW	A's'
	call trans
	MOVLW	A' '
	call trans
	MOVF	col,0	
	call trans
	BSF	PORTA,4
	call	delay1s
	BCF	PORTA,4
	GOTO	R1
	
R1:	LFSR	0,0x02
	MOVLW	D'3'
	MOVWF	cnt
R2:	BTFSS	PIR1,RC1IF	; check if something is received
	BRA	R2

cat:	MOVFF	RCREG, INDF0
	INCF	FSR0L,F
	DCFSNZ	cnt 
	GOTO	PRO
	GOTO	R2
	
PRO:	BSF	PORTA,5
	call	delay1s
	BCF	PORTA,5
	LFSR	0,0x02
	MOVLW	A'M'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro1
	MOVLW	A'P'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro2
	MOVLW	A'R'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro3
	MOVLW	A'C'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro4
	GOTO	err
	
Pro1:	LFSR	0,0x03		    ;check if msg 
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
	
Pro2:	LFSR	0,0x03		    ;check if prc
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
	
Pro3:	LFSR	0,0x03		    ;check if rce
	MOVLW	A'C'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x04
	MOVLW	A'E'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	RCE1
	GOTO	err
	
Pro4:	LFSR	0,0x03		    ;check if cal
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
	
err:	BSF	PORTA,5
	call	delay1s
	BCF	PORTA,5
	MOVLW	A'E'		    ;display error
	call trans
	MOVLW	A'R'
	call trans
	MOVLW	A'R'
	call trans
	MOVLW	A'O'
	call trans
	MOVLW	A'R'
	call trans
	GOTO R1
	
MSG:	MOVLW	b'11000000'
	MOVWF	PORTD
	MOVLW	D'0'
	MOVF	newsize,0
	LFSR	0,0x08
	MOVLW	D'10'
	MOVWF	cnt

clear:	CLRF	INDF0
	DCFSNZ	cnt
	GOTO	R6
	GOTO	clear

R6:	LFSR	0,0x08

R7:	BTFSS	PIR1, RCIF	; check if something is received
	BRA	R7
	MOVFF	RCREG, INDF0
	MOVLW	A'$'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	STORE
	INCF	FSR0L,F
	INCF	newsize,F
	MOVLW	D'10'
	CPFSEQ	newsize
	GOTO	R7 
	GOTO	STORE
	


	
	
PRC:	MOVLW	b'11111001'
	MOVWF	PORTD
	MOVLW	A'W'
	call trans
	MOVLW	A'h'
	call trans
	MOVLW	A'a'
	call trans
	MOVLW	A't'
	call trans
	MOVLW	A' '
	call trans
	MOVLW	A's'
	call trans
	MOVLW	A'h'
	call trans
	MOVLW	A'a'
	call trans
	MOVLW	A'l'
	call trans
	MOVLW	A'l'
	call trans
	MOVLW	A' '
	call trans
	MOVLW	A'M'
	call trans
	MOVLW	A'A'
	call trans
	MOVLW	A'R'
	call trans
	MOVLW	A'V'
	call trans
	MOVLW	A' '
	call trans
	MOVLW	A'r'
	call trans
	MOVLW	A'a'
	call trans
	MOVLW	A'c'
	call trans
	MOVLW	A'e'
	call trans
	MOVLW	A'?'
	call trans

R3:	BTFSS PIR1, RCIF	; check if something is received
	BRA R3
	MOVFF	RCREG, col
	GOTO	REC
R4:	LFSR 0,0x02
	MOVLW	D'3'
	MOVWF	cnt
R5:	BTFSS PIR1, RCIF	; check if something is received
	BRA R5
	MOVFF	RCREG, INDF0
	INCF	FSR0L,F
	DCFSNZ	cnt 
	GOTO	PROC
	GOTO	R5

REC:	LFSR	0,0x00
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
	GOTO	R4
	GOTO	err
	
PROC:	LFSR	0,0x02
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
RCE1:
	
trans:
S1:	BTFSS PIR1, TX1IF
	BRA S1
	MOVWF TXREG
	return
	
;</editor-fold>

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Calibration Block
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------	

;<editor-fold defaultstate="collapsed" desc="Calibration Block"> 	
	
CAL:
CALIBRATE:
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
    ; Initialize Timer 2 registers and so on
    bsf	    PIE1,TMR2IE     ; Enable Timer2 interrups
    MOVLW   b'01111111'     ; Set the prescaler to 16x and the postscaler to 16x
    MOVWF   T2CON           ; Move to the Timer2 control register
    MOVLW   d'245'          ; Using 245 rollovers to get to 3s
    MOVWF   PR2             ; Move that value to the period register

    MOVLW   b'00010000'     ; indicates calibrate sub
    MOVWF   stateBits       ; Store this incase debugging is called
    ; Initialize calibration subroutine variables
    MOVLW   d'12'
    MOVWF   delayCounter    ; After 12 interrups, 3s have passed
    MOVLW   0x0
    MOVWF   calOffset       ; Initialize the offset to zero, so it doesn't skip the first character
    MOVLW   0x7             
    MOVWF   calRounds       ; We want to repeat the calibration routine five times, plus two for other shite
    GOTO    $               ; Wait here until the first interrupt

CALIBRATE_SUB:
    bcf     PIR1,TMR2IF     ; clear niterrupt flag
    CLRF    TMR2	        ; Clear timer 2 of any counts accumulated (this is as close as we can get I guess)
    DECFSZ  delayCounter    ; Decrement and skip if zero, store the answer in delayCounter
    RETFIE 

    ;CALL    LEDS
    MOVLW   d'12'
    MOVWF   delayCounter    ; Reset deulayCounter so that it can continue looping at the same rate

    MOVF    calOffset,w	    ; move the offset into wreg
    CALL    SSDTABLE	    ; call the lookup table
    MOVWF   PORTD           ; move the bits to port B to display them on the SSD

    MOVLW   d'2'	        ; move 2 into wreg
    ADDWF   calOffset	    ; add 2 to the offset - We want to post increment, because the first offset should b 0
    DCFSNZ  calRounds       ; calRounds represents how many rounds of this routine we have left
    bcf	    PIE1,TMR2IE     ; Disable Timer2 interrups. We're done with this subroutine now
    MOVLW   0xFF
    BTFSS   PIE1,TMR2IE	    ; If the timer 2 interrupt enable is ON, then skip the next line
    MOVWF   PORTD           ; Turn off all the lights on the SSD
    MOVLW   0x00
    BTFSS   PIE1,TMR2IE	    ; If the timer 2 interrupt enable is ON, then skip the next line
    MOVWF   PORTA           ; Turn off all the LEDs
    CLRF    TMR2	        ; Clear timer 2 of any counts accumulated during the ISR
    GOTO    RCE		            ; Return to main program

;</editor-fold>    

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    SSD Block
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------
    
;<editor-fold defaultstate="collapsed" desc="SSD Block"> 
    
SSDTABLE:
    ADDWF   PCL             ; Add offset to the program counter
    RETLW   b'00010001'     ; Character "R" = 0
    RETLW   b'00000001'     ; Character "B" = 2
    RETLW   b'01000001'     ; Character "G" = 4
    RETLW   b'00010011'     ; Character "|^|"" (blac calibration) = 6
    RETLW   b'10000011'     ; Character "|_|" (white) = 8
    RETLW   b'11111111'     ; Dummy variable for the calibration subroutine = 10
    RETLW   b'11010101'     ; Character "n" (black track racing) = 12
    RETLW   b'11100011'     ; Character "L" (maze racing) = 14
    RETLW   b'00000011'     ; Character "0" (maze racing) = 16
    RETLW   b'10011111'     ; Character "1" (maze racing) = 18
    RETLW   b'00100101'     ; Character "2" (maze racing) = 20

;</editor-fold>
    
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Debugging Block
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------    

;<editor-fold defaultstate="collapsed" desc="Debugging Block">      
    
DEBUG_SUB:
    bcf     INTCON,INT0IF      ; clear the interrupt flag
    MOVF    PORTA,w	    ; copy porta to w
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
    RETFIE

debugMessage:
    MOVF    calOffset,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugRace:
    MOVF    col,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugProgram:
    MOVF    col,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugCalibrate:
    MOVF    calOffset,w  
    MOVWF   PORTA
    call    delay1s
    RETURN 

delay1s:
    MOVLW   0x0F
    MOVWF   delay3
Go_off0:
	movlw	0xFF
	movwf	delay2
Go_off1:				
	movlw	0xFF	
	movwf	delay1
Go_off2:
	decfsz	delay1,f
	goto	Go_off2
	decfsz	delay2,f
	goto	Go_off1
	decfsz	delay3,f
	goto	Go_off0
	RETURN

;</editor-fold>	
	
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    EEPROM Block
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------

;<editor-fold defaultstate="collapsed" desc="EEPROM Block">	

;-------------------------------------------------
;		EEPROM Read
;-------------------------------------------------

    ;<editor-fold defaultstate="collapsed" desc="EEPROM Read">
	
READ:	MOVLW	0XFF
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   readCount
	;MOVF	RX_BYTE,0
	;MOVWF	size
	
	MOVLW	0X00
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep1
	
	DCFSNZ  readCount, 1
	RETURN
	
	MOVLW	0X01
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep2
	
	DCFSNZ  readCount, 1
	RETURN
	
	MOVLW	0X02
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep3
	
	DCFSNZ  readCount, 1
	RETURN
	
	MOVLW	0X03
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep4
	
	DCFSNZ  readCount, 1
	RETURN
	
	MOVLW	0X04
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep5
	
	DCFSNZ  readCount, 1
	RETURN
	
	
	MOVLW	0X05
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep6
	
	DCFSNZ  readCount, 1
	RETURN
	
	MOVLW	0X06
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep7
	
	DCFSNZ  readCount, 1
	RETURN
	
	MOVLW	0X07
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep8
	
	DCFSNZ  readCount, 1
	RETURN
	
	MOVLW	0X08
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep9
	
	DCFSNZ  readCount, 1
	RETURN
	
	MOVLW	0X09
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_READ
	MOVF	RX_BYTE,0
	MOVWF   eep10
	
	
	RETURN
	
;</editor-fold>

;-------------------------------------------------
;		EEPROM Store
;-------------------------------------------------	

    ;<editor-fold defaultstate="collapsed" desc="EEPROM Store">
	
STORE:	
	MOVF	newsize,0
	MOVWF	EEPROM_DATA
	MOVLW	0XFF
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep1,0
	MOVWF	EEPROM_DATA
	MOVLW	0X00
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep2,0
	MOVWF	EEPROM_DATA
	MOVLW	0X01
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep3,0
	MOVWF	EEPROM_DATA
	MOVLW	0X02
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep4,0
	MOVWF	EEPROM_DATA
	MOVLW	0X03
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep5,0
	MOVWF	EEPROM_DATA
	MOVLW	0X04
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	
	MOVF	eep6,0
	MOVWF	EEPROM_DATA
	MOVLW	0X05
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep7,0
	MOVWF	EEPROM_DATA
	MOVLW	0X06
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep8,0
	MOVWF	EEPROM_DATA
	MOVLW	0X07
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep9,0
	MOVWF	EEPROM_DATA
	MOVLW	0X08
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	
	MOVF	eep10,0
	MOVWF	EEPROM_DATA
	MOVLW	0X09
	MOVWF	EEPROM_ADDRESS	
	RCALL	I2C_WRITE
	BSF	PORTA,6
	
	GOTO	R4
	
;</editor-fold>
	
;</editor-fold>	
	
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    I2C Block
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------

;<editor-fold defaultstate="collapsed" desc="I2C Block">	

;-------------------------------------------------
;		I2C Initialization
;-------------------------------------------------		

;<editor-fold defaultstate="collapsed" desc="I2C Initialization">
	
I2C_INIT:     
    MOVLW   0x09			    
    MOVWF   SSP1ADD			   
    CLRF    SSP1STAT			    
    BSF	    SSP1STAT, SMP		   
    MOVLW   0x28			    
    MOVWF   SSPCON1			    
    CLRF    SSPCON2			    
    BCF	    PIR1, SSPIF			    
    BCF	    PIR2, BCLIF
    RETURN
 
;</editor-fold>    
    
;-------------------------------------------------
;		I2C Start
;-------------------------------------------------
    
;<editor-fold defaultstate="collapsed" desc="I2C Start">
    
I2C_START:
    BCF	    PIR1, SSP1IF
    BSF	    SSP1CON2, SEN     
wait_i2c_start:    
    BTFSC   SSP1CON2, SEN
    BRA	    wait_i2c_start
    RETURN
;</editor-fold> 
    
;-------------------------------------------------
;		I2C Restart
;-------------------------------------------------
    
;<editor-fold defaultstate="collapsed" desc="I2C Restart">    
    
I2C_RESTART:
    BCF	    PIR1, SSP1IF
    BSF	    SSP1CON2, RSEN    
wait_i2c_restart:
    BTFSS   PIR1, SSP1IF
    BRA	    wait_i2c_restart
    RETURN

;</editor-fold>     

;-------------------------------------------------
;		I2C Stop
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="I2C Stop">    
    
I2C_STOP:
    BCF	    PIR1, SSP1IF
    BSF	    SSP1CON2, PEN
wait_i2c_stop:
    BTFSS   PIR1, SSP1IF
    BRA	    wait_i2c_stop
    RETURN

;</editor-fold>
    
;-------------------------------------------------
;		I2C Send
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="I2C Send">    
    
I2C_TRANSMIT:
    BCF	    PIR1, SSP1IF
    MOVF    TX_BYTE, 0
    MOVWF   SSP1BUF
wait_i2c_trans:
    BTFSS   PIR1, SSP1IF
    BRA	    wait_i2c_trans
    RETURN

;</editor-fold> 
    
;-------------------------------------------------
;		I2C Receive
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="I2C Receive">    
    
I2C_RECEIVE:
    BCF	    PIR1, SSP1IF
    BSF	    SSP1CON2, RCEN
wait_i2c_receive1:
    BTFSS   PIR1, SSP1IF
    BRA wait_i2c_receive1
    MOVF    SSP1BUF, 0
    MOVWF   RX_BYTE
    BCF	    PIR1, SSP1IF
    BSF	    SSP1CON2, ACKEN
wait_i2c_receive2:
    BTFSS   PIR1, SSP1IF
    BRA	    wait_i2c_receive2
    RETURN
;</editor-fold> 
    
;-------------------------------------------------
;		I2C Write
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="I2C Write">    
    
I2C_WRITE:
        
    RCALL   I2C_START
    
    MOVF    WRITE_CONTROL,0
    MOVWF   TX_BYTE
    RCALL   I2C_TRANSMIT
    
    MOVF    EEPROM_ADDRESS, 0
    MOVWF   TX_BYTE
    RCALL   I2C_TRANSMIT
     
    MOVF    EEPROM_DATA, 0
    MOVWF   TX_BYTE
    RCALL   I2C_TRANSMIT
    RCALL   I2C_STOP
    RCALL   I2C_ACK
        
    RETURN

;</editor-fold>   
    
;-------------------------------------------------
;		I2C Random Read
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="I2C Random Read">    
    
I2C_READ:
     
    RCALL   I2C_START
    
    MOVF   WRITE_CONTROL,0
    MOVWF   TX_BYTE
    RCALL   I2C_TRANSMIT
    
    MOVF    EEPROM_ADDRESS,0
    MOVWF   TX_BYTE
    RCALL   I2C_TRANSMIT
    RCALL   I2C_RESTART    
    
    MOVF   READ_CONTROL,0
    MOVWF   TX_BYTE
    RCALL   I2C_TRANSMIT
    
    BSF	    SSPCON2, ACKDT
    RCALL   I2C_RECEIVE
    
    RCALL   I2C_STOP
    
    RETURN
    
;</editor-fold>
    
;-------------------------------------------------
;		I2C Acknowledge
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="I2C Acknowledge">    
    
I2C_ACK:
    MOVF   WRITE_ACKNOWLEDGE_POLL_LOOPS, 0
    MOVWF   POLL_COUNTER
poll_loop:
    RCALL   I2C_RESTART
    
    MOVF   WRITE_CONTROL, 0
    MOVWF   TX_BYTE
    RCALL   I2C_TRANSMIT
    
    BTFSS   SSP1CON2, ACKSTAT
    BRA	    poll_end
    DECFSZ  POLL_COUNTER, 1
    BRA	    poll_loop
    
poll_end:
    RCALL   I2C_STOP
    RETURN 

;</editor-fold>     
 
;</editor-fold>
    
;-------------------------------------------------
;		ADC Setup
;-------------------------------------------------

;<editor-fold defaultstate="collapsed" desc="ADC Setup">
    
;Set up the ADC in such a way that there is a delay between channel select to allow capacitor discharge
    
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN0">
    
ADC_SETUP_AN0:

;Configure Port:
;    BSF	    TRISA, RA0	    ;Disable pin output driver (See TRIS register) 	    
;    BSF	    ANSELA,AN0	    ;Configure pin as analog     
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
;   CLRF    ADCON1		            ;Clear the adcon1 register - in a test do this bit by bit
				                    ;Below it is done bit by bit
    BCF	    ADCON1,TRIGSEL		    ;Do this bit by bit
    BCF	    ADCON1,PVCFG0		    ;so that you can be shure
    BCF	    ADCON1,PVCFG1		    ;that you cleared all of the 
    BCF	    ADCON1,NVCFG0		    ;bits in the register
    BCF	    ADCON1,NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS0	    ;Select AN0
    BCF	    ADCON0, CHS1	    ;We must stull decide which chanel we are using for the practical
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS3
    BCF	    ADCON0, CHS4

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN1">
    
ADC_SETUP_AN1:

;Configure Port:
;    BSF	    TRISA, RA0	    ;Disable pin output driver (See TRIS register) 	    
;    BSF	    ANSELA,AN0	    ;Configure pin as analog     
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
;   CLRF    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
    BCF	    ADCON1,TRIGSEL		    ;Do this bit by bit
    BCF	    ADCON1,PVCFG0		    ;so that you can be shure
    BCF	    ADCON1,PVCFG1		    ;that you cleared all of the 
    BCF	    ADCON1,NVCFG0		    ;bits in the register
    BCF	    ADCON1,NVCFG1
    
    
;Select ADC input channel
    BSF	    ADCON0, CHS0	    ;Select AN1
    BCF	    ADCON0, CHS1	    ;We must stull decide which chanel we are using for the practical
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS3
    BCF	    ADCON0, CHS4

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
 
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN2">
    
ADC_SETUP_AN2:

;Configure Port:
;    BSF	    TRISA, RA0	    ;Disable pin output driver (See TRIS register) 	    
;    BSF	    ANSELA,AN0	    ;Configure pin as analog     
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
;   CLRF    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
    BCF	    ADCON1,TRIGSEL		    ;Do this bit by bit
    BCF	    ADCON1,PVCFG0		    ;so that you can be shure
    BCF	    ADCON1,PVCFG1		    ;that you cleared all of the 
    BCF	    ADCON1,NVCFG0		    ;bits in the register
    BCF	    ADCON1,NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS0	    ;Select AN2
    BSF	    ADCON0, CHS1	    ;We must stull decide which chanel we are using for the practical
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS3
    BCF	    ADCON0, CHS4

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN3">
    
ADC_SETUP_AN3:

;Configure Port:
;    BSF	    TRISA, RA0	    ;Disable pin output driver (See TRIS register) 	    
;    BSF	    ANSELA,AN0	    ;Configure pin as analog     
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
;   CLRF    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
    BCF	    ADCON1,TRIGSEL		    ;Do this bit by bit
    BCF	    ADCON1,PVCFG0		    ;so that you can be shure
    BCF	    ADCON1,PVCFG1		    ;that you cleared all of the 
    BCF	    ADCON1,NVCFG0		    ;bits in the register
    BCF	    ADCON1,NVCFG1
    
    
;Select ADC input channel
    BSF	    ADCON0, CHS0	    ;Select AN3
    BSF	    ADCON0, CHS1	    ;We must stull decide which chanel we are using for the practical
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS3
    BCF	    ADCON0, CHS4

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
 
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN3">
    
ADC_SETUP_AN4:

;Configure Port:
;    BSF	    TRISA, RA0	    ;Disable pin output driver (See TRIS register) 	    
;    BSF	    ANSELA,AN0	    ;Configure pin as analog     
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
;   CLRF    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
    BCF	    ADCON1,TRIGSEL		    ;Do this bit by bit
    BCF	    ADCON1,PVCFG0		    ;so that you can be shure
    BCF	    ADCON1,PVCFG1		    ;that you cleared all of the 
    BCF	    ADCON1,NVCFG0		    ;bits in the register
    BCF	    ADCON1,NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS0	    ;Select AN4
    BCF	    ADCON0, CHS1	    ;We must stull decide which chanel we are using for the practical
    BSF	    ADCON0, CHS2
    BCF	    ADCON0, CHS3
    BCF	    ADCON0, CHS4

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
    
    ;</editor-fold>
     

    end