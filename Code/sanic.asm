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
	col			;variable to program race colour (for serial transmissions)
	count		
	mes1		;received message command character 1	
	mes2		;received message command character 2
	mes3		;received message command character 3
	mes4
	charCount	;character count for receive
	reg
	size		;startup message size variable
	loop
	delay1		; delay loop counters, these are reused
	delay2
	delay3
	Touch1		; for touch start sensor
	Touch2
	diff

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~NAVIGATE VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	LLwhiteValue      ; Hardcoded voltage values for each color for Left Left sensor
	LLgreenValue
	LLblueValue
	LLredValue
	LLblackValue	 ;.20

	LwhiteValue      ; Hardcoded voltage values for each color for Left sensor
	LgreenValue
	LblueValue
	LredValue
	LblackValue	 ;.39

	MwhiteValue      ; Hardcoded voltage values for each color for Middle sensor
	MgreenValue
	MblueValue
	MredValue
	MblackValue	 ;.44

	RwhiteValue      ; Hardcoded voltage values for each color for Right sensor
	RgreenValue
	RblueValue
	RredValue
	RblackValue	 ;.49

	RRwhiteValue      ; Hardcoded voltage values for each color for Right Right sensor
	RRgreenValue
	RRblueValue
	RRredValue
	RRblackValue	 ;.54	0X36

	LLsensorVal     ; Voltage value received from sensors
	LsensorVal
	MsensorVal
	RsensorVal
	RRsensorVal	 ;.59	0x3B

	LLcolorSensed     	; One-hot encoded colour of each sensor
	LcolorSensed      	; white  = bit 0      green = bit 1
	McolorSensed      	; blue   = bit 2      red   = bit 3
	RcolorSensed      	; black  = bit 4
	RRcolorSensed	  	;.64

	raceColor	  	; One-hot encoded colour of that the marv will race
	raceLinePosition  	; position of the race line -  LL-L-M-R-RR

	pythonCounter1		;variables for calibration with python, these can't be reused 
	pythonCounter2		;.73 0x49
	
	temp	    ; temp variable for sensor output averaging	4A
	aveloop	    ; loop counter for sensor averaging	4B
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~NAVIGATE VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 	ENDC

whiteBit    equ .0
greenBit    equ .1
blueBit     equ .2
redBit		equ .3
blackBit    equ .4

llBit   equ .0
lBit    equ .1
mBit    equ .2
rBit    equ .3
rrBit   equ .4
;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
;<editor-fold defaultstate="collapsed" desc="Reset and Interrupt Vectors">
    org	    0h
    GOTO    setup  

    org	    8h  
    CALL    InterruptHandler
    return

    RETURN
    
    ;<editor-fold defaultstate="collapsed" desc="Interrupt Handler">
InterruptHandler:
    BTFSC   PIR1,RCIF
    GOTO    touchISR
    BTFSC   PIR1,TMR2IF		;PWM timer interrupts	
    CALL    PWMISRL,FAST		
    BTFSC   PIR5,TMR4IF		
    CALL    PWMISRR,FAST
    RETURN
    ;</editor-fold>
;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    
;<editor-fold defaultstate="collapsed" desc="Setup">
setup
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
    ;BSF	    INTCON,INT0IE
    BCF	    PIE1,RC1IE		; Set RCIE Interrupt Enable
    BCF	    PIE1,TX1IE
    BCF	    PIR1,RCIF
    bsf     INTCON,GIE  ; Enable global interrupts
    BSF	    IOCB,IOCB7
  
    
    ;setup port for transmission
    CLRF    FSR0
    MOVLW   b'00100100'	;enable TXEN and BRGH
    MOVWF   TXSTA1
    MOVLW   b'10010000'	    ;enable serial port and continuous receive 
    MOVWF   RCSTA1
    MOVLW   D'25'
    MOVWF   SPBRG1
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
    MOVLW   A'B'
    MOVWF   col
    
    ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~NAVIGATION SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVLW   .128
    MOVWF   LLwhiteValue
    MOVLW   .128
    MOVWF   LwhiteValue
    MOVLW   .138
    MOVWF   MwhiteValue
    MOVLW   .133
    MOVWF   RwhiteValue
    MOVLW   .125
    MOVWF   RRwhiteValue    ;move hardcoded voltage values into their registers

    MOVLW   .148
    MOVWF   LLgreenValue
    MOVLW   .138
    MOVWF   LgreenValue
    MOVLW   .156
    MOVWF   MgreenValue
    MOVLW   .148
    MOVWF   RgreenValue
    MOVLW   .143
    MOVWF   RRgreenValue    ;move hardcoded voltage values into their registers

    MOVLW   .189
    MOVWF   LLblueValue
    MOVLW   .184
    MOVWF   LblueValue
    MOVLW   .209
    MOVWF   MblueValue
    MOVLW   .204
    MOVWF   RblueValue
    MOVLW   .199
    MOVWF   RRblueValue    ;move hardcoded voltage values into their registers

    MOVLW   .230
    MOVWF   LLredValue
    MOVLW   .230
    MOVWF   LredValue
    MOVLW   .230
    MOVWF   MredValue
    MOVLW   .235
    MOVWF   RredValue
    MOVLW   .230
    MOVWF   RRredValue    ;move hardcoded voltage values into their registers

    MOVLW   .255
    MOVWF   LLblackValue
    MOVWF   LblackValue
    MOVWF   MblackValue
    MOVWF   RblackValue
    MOVWF   RRblackValue    ;move hardcoded voltage values into their registers

    MOVLW   .140             ;set hardcoded values for sensor outputs (for testing)
    MOVWF   LLsensorVal
    MOVLW   .40
    MOVWF   LsensorVal
    MOVLW   .250
    MOVWF   MsensorVal
    MOVLW   .40
    MOVWF   RsensorVal
    MOVLW   .90
    MOVWF   RRsensorVal
    
    CLRF	raceColor
    BSF   	raceColor,blueBit
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~NAVIGATION SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GOTO    RCE
	
;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
;     ;<editor-fold defaultstate="collapsed" desc="Startup">
; startup
; 	LFSR	1,0x08		; set pointer to address of character that must be transmitted
; T1	MOVFF	INDF1,WREG	;transmission loop for startup message
; 	call 	trans			; transmit startup message character
; 	INCF	FSR1L,F
; 	DECFSZ	size
; 	BRA 	T1
; 	MOVLW	A' '		;transmit a space character
; 	call	trans		; trans is the actual transmission function
; 	MOVLW   42h			;set blue as default colour
; 	MOVWF   col
; 	BSF		PORTA,7
; 	GOTO	RCE
; ;</editor-fold>
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;<editor-fold defaultstate="collapsed" desc="RCE">
RCE	
	MOVLW	0x00
	MOVWF	PORTA
	MOVLW	b'10100100'			;hard coded transmission of RCE mode message
	MOVWF	PORTD
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
	MOVF	col,w	
	call    trans				
	MOVLW	A'\n'
	call    trans			;until here
	bcf	PIR1,TXIF
	bcf	PIE1,TXIE
	BSF	PORTA,4
	bcf	PIR1,5
	BCF	PORTA,4
	GOTO	R1
	
R1
	LFSR	0,0x02			;set pointer to where serial command characters are stored
	BCF	INTCON,GIE
	BCF	INTCON,PEIE
	MOVLW	D'3'
	MOVWF	charCount
R2
	BTFSS	PIR1,RC1IF		; check if something is received loop
	BRA	R2
cat
	MOVFF	RCREG, INDF0		; catches the character
	INCF	FSR0L,F
	DCFSNZ	charCount 			; if 3 characters received goto processing function
	GOTO	PRO
	GOTO	R2
	
PRO
	LFSR	0,0x02
	MOVLW	A'N'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro1			;if M is received goto NAV processing branch
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
	MOVLW	A'Q'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	Pro5		;if P is received go to PCL processing branch
	GOTO	err			; if none of the serial commands is received goto error message
	
Pro1
	LFSR	0,0x03		    ;check if  rest of NAV is received
	MOVLW	A'A'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x04
	MOVLW	A'V'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	navigate
	GOTO	err
	
Pro2
	LFSR	0,0x03		    ;check if rest of prc is received
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
	
Pro3
	LFSR	0,0x03		    ;check if rest of rce is received
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
	
Pro4
	LFSR	0,0x03		    ;check if rest of cal is received
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
	
Pro5
	LFSR	0,0x03		    ;check if rest of QCL is received
	MOVLW	A'C'
	XORWF	INDF0,W
	BTFSS	STATUS,Z
	GOTO	err
	LFSR	0,0x04
	MOVLW	A'L'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	pyCal
	GOTO	err
;</editor-fold>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;<editor-fold defaultstate="collapsed" desc="ERROR Message">	
err

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
	
;<editor-fold defaultstate="collapsed" desc="Navigation Functions">	
    
;<editor-fold defaultstate="collapsed" desc="getColor">
getColor:
	CLRF    LLcolorSensed       ; so that we can repeat this without bits being left over
	CLRF    LcolorSensed
	CLRF    McolorSensed
	CLRF    RcolorSensed
	CLRF    RRcolorSensed
	call	AverageLL		;use these cause they have less noise
	call	AverageL
	call	AverageM
	call	AverageR
	call	AverageRR
	call	getColor_LL
	call	getColor_L
	call	getColor_M
	call	getColor_R
	call	getColor_RR
	return            
	
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
getColor_LL:	
	MOVF    LLwhiteValue,w
	CPFSGT  LLsensorVal         ; if LLsensorVal is > LLwhiteValue, it's not white
	BSF     LLcolorSensed,whiteBit     ; if it is white, set that bit
	BTFSS	LLcolorSensed,whiteBit
	Return			    ; return if white sensed
	
	MOVF    LLgreenValue,w
	CPFSGT  LLsensorVal         
	BSF     LLcolorSensed,greenBit     ; if it's smaller than the max for green, it's could be green
    	BTFSS	LLcolorSensed,greenBit
	Return			    ; return if green sensed

	MOVF    LLredValue,w
	CPFSGT  LLsensorVal         
	BSF     LLcolorSensed,redBit     
	BTFSS	LLcolorSensed,redBit
	Return			    ; return if red sensed

	MOVF    LLblueValue,w
	CPFSGT  LLsensorVal         
	BSF     LLcolorSensed,blueBit     
	BTFSS	LLcolorSensed,blueBit
	Return			    ; return if blue sensed


	BSF     LLcolorSensed,blackBit     ; else, it's black
	Return
	
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
getColor_L:
	MOVF    LwhiteValue,w
	CPFSGT  LsensorVal         ; if LLsensorVal is > LLwhiteValue, it's not white
	BSF     LcolorSensed,whiteBit     ; if it is white, set that bit
	BTFSS	LcolorSensed,whiteBit
	Return			    ; return if white sensed
	
	MOVF    LgreenValue,w
	CPFSGT  LsensorVal         
	BSF     LcolorSensed,greenBit     ; if it's smaller than the max for green, it's could be green
    	BTFSS	LcolorSensed,greenBit
	Return			    ; return if green sensed


	MOVF    LredValue,w
	CPFSGT  LsensorVal         
	BSF     LcolorSensed,redBit     
	BTFSS	LcolorSensed,redBit
	Return			    ; return if red sensed
	
	MOVF    LblueValue,w
	CPFSGT  LsensorVal         
	BSF     LcolorSensed,blueBit
	BTFSS	LcolorSensed,blueBit
	Return			    ; return if blue sensed


	BSF     LcolorSensed,blackBit     ; else, it's black
	Return
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Middle Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
getColor_M:
	
	MOVF    MwhiteValue,w
	CPFSGT  MsensorVal         ; if LLsensorVal is > LLwhiteValue, it's not white
	BSF     McolorSensed,whiteBit     ; if it is white, set that bit
	BTFSS	McolorSensed,whiteBit
	Return			    ; return if white sensed
	
	MOVF    MgreenValue,w
	CPFSGT  MsensorVal         
	BSF     McolorSensed,greenBit     ; if it's smaller than the max for green, it's could be green
    	BTFSS	McolorSensed,greenBit
	Return			    ; return if green sensed


	MOVF    MredValue,w
	CPFSGT  MsensorVal         
	BSF     McolorSensed,redBit     
	BTFSS	McolorSensed,redBit
	Return			    ; return if red sensed
	
	
	MOVF    MblueValue,w
	CPFSGT  MsensorVal         
	BSF     McolorSensed,blueBit     
	BTFSS	McolorSensed,blueBit
	Return			    ; return if blue sensed


	BSF     McolorSensed,blackBit     ; else, it's black
	Return
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Middle Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    getColor_R:
	
	MOVF    RwhiteValue,w
	CPFSGT  RsensorVal         ; if LLsensorVal is > LLwhiteValue, it's not white
	BSF     RcolorSensed,whiteBit     ; if it is white, set that bit
	BTFSS	RcolorSensed,whiteBit
	Return			    ; return if white sensed
	
	MOVF    RgreenValue,w
	CPFSGT  RsensorVal         
	BSF     RcolorSensed,greenBit     ; if it's smaller than the max for green, it's could be green
    	BTFSS	RcolorSensed,greenBit
	Return			    ; return if green sensed


	MOVF    RredValue,w
	CPFSGT  RsensorVal         
	BSF     RcolorSensed,redBit     
	BTFSS	RcolorSensed,redBit
	Return			    ; return if red sensed

	MOVF    RblueValue,w
	CPFSGT  RsensorVal         
	BSF     RcolorSensed,blueBit     
	BTFSS	RcolorSensed,blueBit
	Return			    ; return if blue sensed


	
	BSF     RcolorSensed,blackBit     ; else, it's black
	Return
    ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
    ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
getColor_RR:
    	MOVF    RRwhiteValue,w
	CPFSGT  RRsensorVal         ; if LLsensorVal is > LLwhiteValue, it's not white
	BSF     RRcolorSensed,whiteBit     ; if it is white, set that bit
	BTFSS	RRcolorSensed,whiteBit
	Return			    ; return if white sensed
	
	MOVF    RRgreenValue,w
	CPFSGT  RRsensorVal         
	BSF     RRcolorSensed,greenBit     ; if it's smaller than the max for green, it's could be green
    	BTFSS	RRcolorSensed,greenBit
	Return			    ; return if green sensed

	MOVF    RRredValue,w
	CPFSGT  RRsensorVal         
	BSF     RRcolorSensed,redBit     
	BTFSS	RRcolorSensed,redBit
	Return			    ; return if red sensed

	MOVF    RRblueValue,w
	CPFSGT  RRsensorVal         
	BSF     RRcolorSensed,blueBit     
	BTFSS	RRcolorSensed,blueBit
	Return			    ; return if blue sensed

	

	BSF     RRcolorSensed,blackBit     ; else, it's black
	Return
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;</editor-fold>


;<editor-fold defaultstate="collapsed" desc="Test for black on all sensors">
testBlack:


;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="getRaceLinePosition">
getRaceLinePosition:
	MOVLW   b'11100000'
	MOVWF   raceLinePosition        ;raceLinePosition is vol ones 
	MOVF    raceColor,w             ;move die one-hot encoded race color in die wreg in, vir comparisons 

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Left Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CPFSEQ  LLcolorSensed
	BSF     raceLinePosition,0
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Left Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CPFSEQ  LcolorSensed
	BSF     raceLinePosition,1
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Middle Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CPFSEQ  McolorSensed
	BSF     raceLinePosition,2
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Middle Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CPFSEQ  RcolorSensed
	BSF     raceLinePosition,3
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Right Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CPFSEQ  RRcolorSensed
	BSF     raceLinePosition,4
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Right Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	COMF    raceLinePosition        ;invert die position, dan behoort hy te wys waar die race line opgetel word
	
	return                          ; return from getRaceLinePosition (determine where the line is that we want to race on)
;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="Determine Direction">

determineDirection:
	;forward = middle sensor is die regte kleur
	;forward = race color is nie opgetel nie
	;left = L of LL is getrigger
	;right = R of RR is getrigger
	BTFSC   McolorSensed, greenBit     ; M senses green (these three are for the LED 
	BSF     PORTA,greenBit
	BTFSC   McolorSensed, blueBit     ; M senses blue   ...that indicates the color 
	BSF     PORTA,blueBit
	BTFSC   McolorSensed, redBit     ; M senses red    ...sensed by sensor M)
	BSF     PORTA,0
	
	BTFSC   raceLinePosition, mBit     ; if M senses race colour, go straight
	BSF     PORTA,4
	BTFSC   raceLinePosition, mBit     ; if going straight, return
	return				
	
	BTFSC   raceLinePosition, 0     ; if LL senses race colour, turn left
	BSF     PORTA,3
	BTFSC   raceLinePosition, 1     ; if L senses race colour, turn left
	BSF     PORTA,3
	
	BTFSC   raceLinePosition, 3     ; if R senses race colour, turn right
	BSF     PORTA,5
	BTFSC   raceLinePosition, 4     ; if RR senses race colour, turn right
	BSF     PORTA,5
	
	MOVLW   0x0
	CPFSEQ  raceLinePosition	    ; if none sense the colour, go to search mode
	return 
	CALL	searchModeLights		; flash die LEDs



	BTFSC	raceLinePosition, mBit
	GOTO	Straight				; GOTO (not call), then the motor control thing returns back to nav
	
	BTFSC	raceLinePosition, lBit
	GOTO	Left	

	BTFSC	raceLinePosition, rBit
	GOTO	Right	

	BTFSC	raceLinePosition, llBit
	GOTO	HardLeft	

	BTFSC	raceLinePosition, rrBit
	GOTO	HardRight	

	CALL	testBlack	
	return

;</editor-fold>
	
;<editor-fold defaultstate="collapsed" desc="Search mode">
searchModeLights:
	bcf	PORTA,3
	bsf	PORTA,4		;go straight in search mode
	bcf	PORTA,5
	
	bsf	PORTA,0
	bcf	PORTA,1
	bcf	PORTA,2
	CALL 	threeMilDelay
	
	bcf	PORTA,0
	bsf	PORTA,1
	bcf	PORTA,2
	CALL 	threeMilDelay
	
	bcf	PORTA,0
	bcf	PORTA,1
	bsf	PORTA,2
	CALL 	threeMilDelay
	RETURN 
;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="Left motor control">
LeftMotorControl macro dutyCycle, direction
    MOVLB   0x0f
    CLRF    CCP1CON
    MOVLW   .200
    MOVWF   PR2
    MOVLW   dutyCycle
    MOVWF   CCPR1L
    
    BCF	    TRISC,CCP1      ;C2
    
    CLRF    CCPTMRS0
  
    MOVLW   b'00001100'	     ;PWM mode
    MOVWF   CCP1CON 
    MOVLB   0xF
    MOVLW   b'01111010'	     ;16 prescale, 16 postscale, timer off
    MOVWF   T2CON 
    CLRF    TMR2
    BSF     PIE1, TMR2IE     ; enable interrupts from the timer
    bsf     INTCON,PEIE      ; Enable peripheral interrupts
    bsf     INTCON,GIE       ; Enable global interrupts
    BSF	    T2CON, TMR2ON    ; Turn timer on
    MOVLB   0x0
	; BSF     PORTA,5        ;indicate that the setup was performed
    endm

PWMISRL:
    BCF	    PIR5,TMR4IE
    BCF	    PIR1,TMR2IF
    CLRF    TMR2
    BSF	    PIR5,TMR4IE
    RETURN
    ;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="Right motor control">
RightMotorControl macro dutyCycle, direction
    CLRF    CCP5CON
    MOVLW   .200
    MOVWF   PR4
    MOVLW   dutyCycle
    MOVWF   CCPR5L
    
    BCF	    TRISE, 2         ;E2
    
    BSF     CCPTMRS1, 2      ;use timer 4

    MOVLW   b'00001100'	     ;PWM mode
    MOVWF   CCP5CON 
    
    MOVLB   0xF
    MOVLW   b'01111010'	      ;16 prescale, 16 postscale, timer off
    MOVWF   T4CON 
    CLRF    TMR4
    BSF     PIE5, TMR4IE      ; enable interrupts from the timer
    bsf     INTCON, PEIE      ; Enable peripheral interrupts
    bsf     INTCON, GIE       ; Enable global interrupts
    BSF	    T4CON, TMR4ON     ; Turn timer on
    MOVLB   0x0
    ; BSF     PORTA,6         ; indicate tea the setup was performed
    endm

PWMISRR:
    BCF	    PIR5,TMR4IF
    MOVLB   0xF
    CLRF    TMR4
    MOVLB   0x0
    RETURN
    ;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="Direction Controls">
HardRight:
	BSF		PORTA, 5	;indicates right 
    RightMotorControl  .20,b'1'
    LeftMotorControl  .100,b'0'
    RETURN		;return to navigation 
	
HardLeft:
	BSF		PORTA, 3	;indicates left
    RightMotorControl  .100,b'0'
    LeftMotorControl  .20,b'1'
    RETURN		;return to navigation 

Right:
	BSF		PORTA, 5	;indicates right
    RightMotorControl  .60,b'1'
    LeftMotorControl  .100,b'0'
    RETURN		;return to navigation 

Left:
	BSF		PORTA, 3	;indicates left
    RightMotorControl  .100,b'0'
    LeftMotorControl  .60,b'1'
    RETURN		;return to navigation 

Stop:
	CLRF	PORTA		;turn off all leddies for stop
    RightMotorControl  .0,b'0'		;turn motors off 
    LeftMotorControl  .0,b'0'
    RETURN		;return to navigation 

Straight:
	BSF		PORTA, 4
    RightMotorControl  .200, b'0'	; g2g  f�st
    LeftMotorControl  .200, b'0'
    RETURN		;return to navigation  
    ;</editor-fold>
    
    
;<editor-fold defaultstate="collapsed" desc="Navigation">
navigate:
    CALL	Straight				;initially go forward 
	
    BTFSC   raceColor,whiteBit		;check white
    MOVLW   b'10101011'
    BTFSC   raceColor,greenBit		;check green
    MOVLW   b'10000010'
    BTFSC   raceColor,greenBit		;check green
    BSF	    PORTA,1
    BTFSC   raceColor,blueBit		;check blue
    MOVLW   b'10000000'
    BTFSC   raceColor,blueBit		;check blue
    BSF	    PORTA,2
    BTFSC   raceColor,redBit		;check red
    MOVLW   b'10001000'
    BTFSC   raceColor,redBit		;check red
    BSF	    PORTA,0
    BTFSC   raceColor,blackBit		;check black
    MOVLW   b'10101011'
    MOVWF   PORTD
    
nav    
    CALL    getColor
    CALL    getRaceLinePosition
    CALL    determineDirection
    ;CALL    hunnitMilDelay
    GOTO    nav
	; navigate doesn't end, it must be interruted 
;</editor-fold>
	
;</editor-fold>	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;<editor-fold defaultstate="collapsed" desc="Program Color (PRC)">
PRC	
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

R3
	BTFSS	PIR1, RCIF	; receive new color to race 
	BRA 	R3
	MOVFF	RCREG, col
	GOTO	REC				; go chech if it is a valid race color 
R4
	LFSR 	0,0x02
	MOVLW	D'3'
	MOVWF	charCount
R5
	BTFSS 	PIR1, RCIF	; check if something is received
	BRA 	R5
	MOVFF	RCREG, INDF0
	INCF	FSR0L,F
	DCFSNZ	charCount 
	GOTO	PROC
	GOTO	R5

REC
	LFSR	0,0x00			; check if a valid race color is received 
	MOVLW	A'B'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	transmitForPy
	MOVLW	A'R'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	transmitForPy
	MOVLW	A'G'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	transmitForPy
	MOVLW	A'n'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	transmitForPy
	MOVLW	A'L'
	XORWF	INDF0,W
	BTFSC	STATUS,Z
	GOTO	transmitForPy				;until here
	GOTO	err				; if it is not valid show error message

transmitForPy
	MOVLW	A'S'
	CALL	trans
	MOVLW	A'e'
	CALL	trans
	MOVLW	A't'
	CALL	trans

	MOVLW	A'\n'
	CALL	trans
	
	MOVLW	A'R'
	CPFSEQ	col
	GOTO	C1
	MOVLW	b'00001000'
	MOVWF	raceColor
	
C1	MOVLW	A'B'
	CPFSEQ	col
	GOTO	C2
	MOVLW	b'00000100'
	MOVWF	raceColor
	
C2	MOVLW	A'G'
	CPFSEQ	col
	GOTO	C3
	MOVLW	b'00000010'
	MOVWF	raceColor
	
C3	MOVLW	A'n'
	CPFSEQ	col
	GOTO	C4
	MOVLW	b'00010000'
	MOVWF	raceColor
	
C4	GOTO	R4
	;L = Maze is not implemented yet
	
	
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

;<editor-fold defaultstate="collapsed" desc="Touch Start (RCE1)">	
RCE1	MOVLW	A's'
	call	trans
	MOVLW	d'9'
	MOVWF	diff
	call	delay1s
poll_c	
	call	Read_AN14
	MOVFF	Touch1,Touch2
	MOVWF	Touch1
	
	call	Read_AN14
	
	MOVFF	Touch1,Touch2
	MOVWF	Touch1
	
	
	call	Read_AN14
	MOVFF	Touch1,Touch2
	MOVWF	Touch1
	
	
	SUBFWB	Touch2
	CPFSGT	diff
	goto	stop
	MOVLW   A'\n'
	goto	poll_c

stop	MOVLW	A'D'
	call	trans
	BSF	    INTCON,GIEL		; Enable peripheral interrupts
	bsf     INTCON,GIEH  ; Enable global interrupts
	BSF	    PIE1,RC1IE		; Set RCIE Interrupt Enable
	GOTO	navigate

;</editor-fold>	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;<editor-fold defaultstate="collapsed" desc="touchISR">
touchISR	
    CLRF    RCREG
    BCF	    PIR1,RCIF
    BCF	    PIE1,RC1IE
    GOTO    RCE
;</editor-fold>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;<editor-fold defaultstate="collapsed" desc="Transmit Character Via Serial">
trans						;general transmission function
S1
	BTFSS 	PIR1, TX1IF
	BRA 	S1
	MOVWF 	TXREG
	return	
;</editor-fold>
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;<editor-fold defaultstate="collapsed" desc="CALIBRATE">	
CAL							;calibrate the sensors here
CALIBRATE					; order is blue, red, green, white, black
    CLRF    PORTA
    MOVLW   b'10000000'
    MOVWF   PORTD
	CALL	Read_AN12
	MOVWF	LLblueValue		;~~~~~BLUE~~~~~
	CALL	Read_AN10
	MOVWF	LblueValue
	CALL	Read_AN8
	MOVWF	MblueValue
	CALL	Read_AN9
	MOVWF	RblueValue
	CALL	Read_AN13
	MOVWF	RRblueValue		;~~~~~BLUE~~~~~
    call    delay1s

    BSF	    PORTA,0
    MOVLW   b'10001000'
    MOVWF   PORTD
	CALL	Read_AN12
	MOVWF	LLredValue		;~~~~~RED~~~~~
	CALL	Read_AN10
	MOVWF	LredValue
	CALL	Read_AN8
	MOVWF	MredValue
	CALL	Read_AN9
	MOVWF	RredValue
	CALL	Read_AN13
	MOVWF	RRredValue		;~~~~~RED~~~~~
    call    delay1s
    BSF	    PORTA,1
    MOVLW   b'10000010'
    MOVWF   PORTD
	CALL	Read_AN12
	MOVWF	LLgreenValue		;~~~~~GREEN~~~~~
	CALL	Read_AN10
	MOVWF	LgreenValue
	CALL	Read_AN8
	MOVWF	MgreenValue
	CALL	Read_AN9
	MOVWF	RgreenValue
	CALL	Read_AN13
	MOVWF	RRgreenValue		;~~~~~GREEN~~~~~
    call    delay1s
    BSF	    PORTA,2
    MOVLW   b'11000001'
    MOVWF   PORTD
	CALL	Read_AN12
	MOVWF	LLwhiteValue	;~~~~~WHITE~~~~~
	CALL	Read_AN10
	MOVWF	LwhiteValue
	CALL	Read_AN8
	MOVWF	MwhiteValue
	CALL	Read_AN9
	MOVWF	RwhiteValue
	CALL	Read_AN13
	MOVWF	RRwhiteValue	;~~~~~WHITE~~~~~
    call    delay1s
    BSF	    PORTA,3
    MOVLW   b'11001000'
    MOVWF   PORTD
	CALL	Read_AN12
	MOVWF	LLblackValue	;~~~~~BLACK~~~~~
	CALL	Read_AN10
	MOVWF	LblackValue
	CALL	Read_AN8
	MOVWF	MblackValue
	CALL	Read_AN9
	MOVWF	RblackValue
	CALL	Read_AN13
	MOVWF	RRblackValue	;~~~~~BLACK~~~~~
    call    delay1s
    BSF	    PORTA,4
    call    delay1s
    CLRF    PORTA
    call    Ranges		; Use Range function for colour detection values
    GOTO    RCE				
;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;<editor-fold defaultstate="collapsed" desc="Calibrate with python + ADC stuff">
    ;<editor-fold defaultstate="collapsed" desc="Setup RC2 (For touch sensor)">
ADC_SETUP_AN14:

	;Configure Port RA0:
    BSF    TRISC,2	;Disable pin output driver (See TRIS register) 	    
    BSF    ANSELC,2     ;Configure pin as analog       
					
	
	;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

	;Configure voltage reference
    CLRF    ADCON1
	
	;Select ADC input channel
    BCF	    ADCON0, CHS4	    ;Select AN12 - 01100
    BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
    BSF	    ADCON0, CHS2
    BSF	    ADCON0, CHS1
    BCF	    ADCON0, CHS0

	;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

	;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

	;Turn on ADC module
    BSF	    ADCON0, ADON
	
    RETURN
;</editor-fold>		
	
    ;<editor-fold defaultstate="collapsed" desc="Setup RB0">
ADC_SETUP_AN12:

	;Configure Port RA0:
	BSF    TRISB,   TRISB0  ;Disable pin output driver (See TRIS register) 	    
	BSF    ANSELB,  ANSB0   ;Configure pin as analog       
					
	
	;Configure the ADC module: 
	BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
	BCF	    ADCON2, ADCS1	   	
	BSF	    ADCON2, ADCS2	    			    				    	    

	;Configure voltage reference
	CLRF	    ADCON1
	
	;Select ADC input channel
	BCF	    ADCON0, CHS4	    ;Select AN12 - 01100
	BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
	BSF	    ADCON0, CHS2
	BCF	    ADCON0, CHS1
	BCF	    ADCON0, CHS0

	;Select result format
	BCF	    ADCON2, ADFM	    ;Left Justify

	;Select acquisition delay
	BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
	BCF	    ADCON2, ACQT1
	BSF	    ADCON2, ACQT2

	;Turn on ADC module
	BSF	    ADCON0, ADON
	
	RETURN
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="Setup RB1">
ADC_SETUP_AN10:

	;Configure Port RA0:
	BSF    TRISB,   TRISB1  ;Disable pin output driver (See TRIS register) 	    
	BSF    ANSELB,  ANSB1   ;Configure pin as analog      
					
	
	;Configure the ADC module: 
	BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
	BCF	    ADCON2, ADCS1	   	
	BSF	    ADCON2, ADCS2	    			    				    	    

	;Configure voltage reference
	CLRF	    ADCON1
	
	;Select ADC input channel
	BCF	    ADCON0, CHS4	    ;Select AN12 - 01100
	BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
	BCF	    ADCON0, CHS2
	BSF	    ADCON0, CHS1
	BCF	    ADCON0, CHS0

	;Select result format
	BCF	    ADCON2, ADFM	    ;Left Justify

	;Select acquisition delay
	BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
	BCF	    ADCON2, ACQT1
	BSF	    ADCON2, ACQT2

	;Turn on ADC module
	BSF	    ADCON0, ADON
	
	RETURN
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="Setup RB2">
ADC_SETUP_AN8:

	;Configure Port RA0:
	BSF    TRISB,   TRISB2  ;Disable pin output driver (See TRIS register) 	    
	BSF    ANSELB,  ANSB2   ;Configure pin as analog     
					
	
	;Configure the ADC module: 
	BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
	BCF	    ADCON2, ADCS1	   	
	BSF	    ADCON2, ADCS2	    			    				    	    

	;Configure voltage reference
	CLRF	    ADCON1
	
	;Select ADC input channel
	BCF	    ADCON0, CHS4	    ;Select AN12 - 01100
	BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
	BCF	    ADCON0, CHS2
	BCF	    ADCON0, CHS1
	BCF	    ADCON0, CHS0

	;Select result format
	BCF	    ADCON2, ADFM	    ;Left Justify

	;Select acquisition delay
	BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
	BCF	    ADCON2, ACQT1
	BSF	    ADCON2, ACQT2

	;Turn on ADC module
	BSF	    ADCON0, ADON
	
	RETURN
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="Setup RB3">
ADC_SETUP_AN9:

	;Configure Port RA0:
	BSF    TRISB,   TRISB3  ;Disable pin output driver (See TRIS register) 	    
	BSF    ANSELB,  ANSB3   ;Configure pin as analog     
					
	
	;Configure the ADC module: 
	BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
	BCF	    ADCON2, ADCS1	   	
	BSF	    ADCON2, ADCS2	    			    				    	    

	;Configure voltage reference
	CLRF	    ADCON1
	
	;Select ADC input channel
	BCF	    ADCON0, CHS4	    ;Select AN12 - 01100
	BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
	BCF	    ADCON0, CHS2
	BCF	    ADCON0, CHS1
	BSF	    ADCON0, CHS0

	;Select result format
	BCF	    ADCON2, ADFM	    ;Left Justify

	;Select acquisition delay
	BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
	BCF	    ADCON2, ACQT1
	BSF	    ADCON2, ACQT2

	;Turn on ADC module
	BSF	    ADCON0, ADON
	
	RETURN
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="Setup RB5">
ADC_SETUP_AN13:

	;Configure Port RA0:
	BSF    TRISB,   TRISB5  ;Disable pin output driver (See TRIS register) 	    
	BSF    ANSELB,  ANSB5   ;Configure pin as analog     
					
	
	;Configure the ADC module: 
	BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
	BCF	    ADCON2, ADCS1	   	
	BSF	    ADCON2, ADCS2	    			    				    	    

	;Configure voltage reference
	CLRF	    ADCON1
	
	;Select ADC input channel
	BCF	    ADCON0, CHS4	    ;Select AN12 - 01100
	BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
	BSF	    ADCON0, CHS2
	BCF	    ADCON0, CHS1
	BSF	    ADCON0, CHS0

	;Select result format
	BCF	    ADCON2, ADFM	    ;Left Justify

	;Select acquisition delay
	BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
	BCF	    ADCON2, ACQT1
	BSF	    ADCON2, ACQT2

	;Turn on ADC module
	BSF	    ADCON0, ADON
	
	RETURN
;</editor-fold>


    ;<editor-fold defaultstate="collapsed" desc="READ RC2 (for touch sensor)">
Read_AN14:
    BTFSS   TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA	    Read_AN14

    CALL    ADC_SETUP_AN14	;do setup

    BSF	    ADCON0, GO	    ;start a conversion

Poll_Go0
    BTFSC   ADCON0, GO	    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA	    Poll_Go0

    MOVF    ADRESH,W	    ;copy result of conversion into WREG
    ;MOVWF   Touch	    ;copy this into LLsensorVal
    RETURN		    ;WREG still contains the results of the conversion at this point
;</editor-fold>

	
    ;<editor-fold defaultstate="collapsed" desc="READ AN12">
Read_AN12:
;	BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
;	BRA	Read_AN12
	
	CALL	ADC_SETUP_AN12	;do setup

	BSF	ADCON0, GO	;start a conversion

Poll_Go1
	BTFSC	ADCON0, GO	;Polling the GO/DONE bit - Checked if hardware cleared go				    
	BRA	Poll_Go1

	MOVF	ADRESH,W 	;copy result of conversion into WREG
	MOVWF	LLsensorVal
	RETURN	;WREG still contains the results of the conversion at this point
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="READ RB1">
Read_AN10:
;	BTFSS	TXSTA1, TRMT	;Check if TMRT is set, to ensure that shift register is empty (p263)
;	BRA	Read_AN10
	
	CALL	ADC_SETUP_AN10	;do setup

	BSF	ADCON0, GO	;start a conversion

Poll_Go2
	BTFSC	ADCON0, GO	;Polling the GO/DONE bit - Checked if hardware cleared go				    
	BRA	Poll_Go2

	MOVF	ADRESH,W 	;copy result of conversion into WREG
	MOVWF	LsensorVal
	RETURN	;WREG still contains the results of the conversion at this point
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="READ RB2">
Read_AN8:
;	BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
;	BRA	Read_AN8
	
	CALL	ADC_SETUP_AN8	;do setup

	BSF	ADCON0, GO	;start a conversion

Poll_Go3
	BTFSC	ADCON0, GO	;Polling the GO/DONE bit - Checked if hardware cleared go				    
	BRA	Poll_Go3

	MOVF	ADRESH,W 	;copy result of conversion into WREG
	MOVWF	MsensorVal
	RETURN	;WREG still contains the results of the conversion at this point
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="READ RB3">
Read_AN9:
;	BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
;	BRA	Read_AN9
	
	CALL	ADC_SETUP_AN9	;do setup

	BSF	ADCON0, GO	;start a conversion

Poll_Go4
	BTFSC	ADCON0, GO	;Polling the GO/DONE bit - Checked if hardware cleared go				    
	BRA	Poll_Go4

	MOVF	ADRESH,W 	;copy result of conversion into WREG
	MOVWF	RsensorVal
	RETURN	;WREG still contains the results of the conversion at this point
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="READ RB5">
Read_AN13:
;	BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
;	BRA	Read_AN13
	
	CALL	ADC_SETUP_AN13	;do setup

	BSF	ADCON0, GO	;start a conversion

Poll_Go5
	BTFSC	ADCON0, GO	;Polling the GO/DONE bit - Checked if hardware cleared go				    
	BRA	Poll_Go5

	MOVF	ADRESH,W 	;copy result of conversion into WREG
	MOVWF	RRsensorVal
	RETURN	;WREG still contains the results of the conversion at this point
;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="AverageLL - LL ">
AverageLL:
	MOVLW	0x08
	MOVWF	aveloop
	CLRF	temp
	
rep1
	CALL	Read_AN12
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	BCF	WREG,7		;incase rotation causes a mistake
	BCF	WREG,6		;incase rotation causes a mistake
	BCF	WREG,5		;incase rotation causes a mistake
	ADDWF	temp
	DECFSZ	aveloop
	GOTO	rep1
	MOVF	temp,w		;move to w
	BCF	WREG,0		;clear to reduce noise 
	BCF	WREG,1
	BCF	WREG,2
	
	MOVWF	LLsensorVal
	RETURN
    ;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="AverageL - L">
AverageL:
	MOVLW	0x08
	MOVWF	aveloop
	CLRF	temp
	
rep2
	CALL	Read_AN10
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	BCF	WREG,7		;incase rotation causes a mistake
	BCF	WREG,6		;incase rotation causes a mistake
	BCF	WREG,5		;incase rotation causes a mistake
	ADDWF	temp
	DECFSZ	aveloop
	GOTO	rep2
	MOVF	temp,w		;move to w
	BCF	WREG,0		;clear to reduce noise 
	BCF	WREG,1
	BCF	WREG,2
	
	MOVWF	LsensorVal
	RETURN
    ;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="AverageM - M">
AverageM:
	MOVLW	0x08
	MOVWF	aveloop
	CLRF	temp
	
rep3
	CALL	Read_AN8
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	BCF	WREG,7		;incase rotation causes a mistake
	BCF	WREG,6		;incase rotation causes a mistake
	BCF	WREG,5		;incase rotation causes a mistake
	ADDWF	temp
	DECFSZ	aveloop
	GOTO	rep3
	MOVF	temp,w		;move to w
	BCF	WREG,0		;clear to reduce noise 
	BCF	WREG,1
	BCF	WREG,2
	
	MOVWF	MsensorVal
	RETURN
    ;</editor-fold>
	
    ;<editor-fold defaultstate="collapsed" desc="AverageR - R">
AverageR:
	MOVLW	0x08
	MOVWF	aveloop
	CLRF	temp
	
rep4
	CALL	Read_AN9
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	BCF	WREG,7		;incase rotation causes a mistake
	BCF	WREG,6		;incase rotation causes a mistake
	BCF	WREG,5		;incase rotation causes a mistake
	ADDWF	temp
	DECFSZ	aveloop
	GOTO	rep4
	MOVF	temp,w		;move to w
	BCF	WREG,0		;clear to reduce noise 
	BCF	WREG,1
	BCF	WREG,2
	
	MOVWF	RsensorVal
	RETURN
    ;</editor-fold>
	
    ;<editor-fold defaultstate="collapsed" desc="AverageRR - RR">
AverageRR:
	MOVLW	0x08
	MOVWF	aveloop
	CLRF	temp
	
rep5
	CALL	Read_AN13
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	RRNCF	WREG,w		;divide by 2
	BCF	WREG,7		;incase rotation causes a mistake
	BCF	WREG,6		;incase rotation causes a mistake
	BCF	WREG,5		;incase rotation causes a mistake
	ADDWF	temp
	DECFSZ	aveloop
	GOTO	rep5
	MOVF	temp,w		;move to w
	BCF	WREG,0		;clear to reduce noise 
	BCF	WREG,1
	BCF	WREG,2
	
	MOVWF	RRsensorVal
	RETURN
    ;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="Python Stop Word Transmission">
stopWord:
    MOVLW	.92
    CALL	trans
    MOVLW	.79
    CALL	trans
    MOVLW	.119
    CALL	trans
    MOVLW	.79
    CALL	trans
    MOVLW	.47
    CALL	trans
    MOVLW	'\n'				;Send an enter
    CALL	trans
	RETURN
    ;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="Transmit Calibrated Values">
sendCals:
	MOVLW	.25		; there are 25 calibrated values 
	MOVWF	delay3	
	;we're gonna start from address .16, 0x10 and send one character 25 times in a row.
	LFSR	0, 0x010	;clear FSR0H and load FRS0L with 0x10

not_done
	MOVF	POSTINC0, W 	;move contents of FSR to W, then incremement 
	call	trans
	DECFSZ	delay3
	GOTO	not_done

	MOVLW	A'\n'
	call	trans
	CLRF	WREG 
	RETURN
    ;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="1m Python Calibration">
pyCal:
    CALL    sendCals
    movlw   b'00001100'
    MOVWF   PORTD
    movlw   .250		;24 * 250 * 0.01s = 60s
    movwf   pythonCounter2		
pythonLoop1
    movlw   .250
    movwf   pythonCounter1
pythonLoop2

    CALL    AverageLL
    CALL    trans

    CALL    AverageL
    MOVF    LsensorVal,w
    CALL    trans

    CALL    AverageM
    MOVF    MsensorVal,w
    CALL    trans

    CALL    AverageR
    MOVF    RsensorVal,w
    CALL    trans

    CALL    AverageRR
    MOVF    RRsensorVal,w
    CALL    trans

    MOVLW   '\n'				;Send an enter
    CALL    trans

    CALL    tenmsDelay
 
    decfsz  pythonCounter1,f
    goto    pythonLoop2
    decfsz  pythonCounter2,f   
    goto    pythonLoop1
    
    CALL    stopWord

    GOTO    RCE
;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="Range Calculation">
    Ranges:
    
;   Half all readings
	
    	RRNCF	LLwhiteValue,f	;divide by 2
	BCF	LLwhiteValue,7
	RRNCF	LLgreenValue,f	;divide by 2
	BCF	LLgreenValue,7
	RRNCF	LLredValue,f	;divide by 2
	BCF	LLredValue,7
	RRNCF	LLblueValue,f	;divide by 2
	BCF	LLblueValue,7
	RRNCF	LLblackValue,f	;divide by 2
	BCF	LLblackValue,7
	
		
    	RRNCF	LwhiteValue,f	;divide by 2
	BCF	LwhiteValue,7
	RRNCF	LgreenValue,f	;divide by 2
	BCF	LgreenValue,7
	RRNCF	LredValue,f	;divide by 2
	BCF	LredValue,7
	RRNCF	LblueValue,f	;divide by 2
	BCF	LblueValue,7
	RRNCF	LblackValue,f	;divide by 2
	BCF	LblackValue,7
	
		
    	RRNCF	MwhiteValue,f	;divide by 2
	BCF	MwhiteValue,7
	RRNCF	MgreenValue,f	;divide by 2
	BCF	MgreenValue,7
	RRNCF	MredValue,f	;divide by 2
	BCF	MredValue,7
	RRNCF	MblueValue,f	;divide by 2
	BCF	MblueValue,7
	RRNCF	MblackValue,f	;divide by 2
	BCF	MblackValue,7
    
		
    	RRNCF	RwhiteValue,f	;divide by 2
	BCF	RwhiteValue,7
	RRNCF	RgreenValue,f	;divide by 2
	BCF	RgreenValue,7
	RRNCF	RredValue,f	;divide by 2
	BCF	RredValue,7
	RRNCF	RblueValue,f	;divide by 2
	BCF	RblueValue,7
	RRNCF	RblackValue,f	;divide by 2
	BCF	RblackValue,7
	
		
    	RRNCF	RRwhiteValue,f	;divide by 2
	BCF	RRwhiteValue,7
	RRNCF	RRgreenValue,f	;divide by 2
	BCF	RRgreenValue,7
	RRNCF	RRredValue,f	;divide by 2
	BCF	RRredValue,7
	RRNCF	RRblueValue,f	;divide by 2
	BCF	RRblueValue,7
	RRNCF	RRblackValue,f	;divide by 2
	BCF	RRblackValue,7
;	AVG white and green
   
	MOVF	LLgreenValue,w
	ADDWF	LLwhiteValue,f	

	
	MOVF	LgreenValue,w
	ADDWF	LwhiteValue,f	


	MOVF	MgreenValue,w
	ADDWF	MwhiteValue,f	

	MOVF	RgreenValue,w
	ADDWF	RwhiteValue,f	

	MOVF	RRgreenValue,w
	ADDWF	RRwhiteValue,f	

	
;	AVG green and red
	MOVF	LLredValue,w
	ADDWF	LLgreenValue,f	
	
	MOVF	LredValue,w
	ADDWF	LgreenValue,f	
	
	MOVF	MredValue,w
	ADDWF	MgreenValue,f	
	
	MOVF	RredValue,w
	ADDWF	RgreenValue,f	
	
	MOVF	RRredValue,w
	ADDWF	RRgreenValue,f	

	
;	AVG red and blue
	MOVF	LLblueValue,w
	ADDWF	LLredValue,f	

	
	MOVF	LblueValue,w
	ADDWF	LredValue,f	

	MOVF	MblueValue,w
	ADDWF	MredValue,f	

	
	MOVF	RblueValue,w
	ADDWF	RredValue,f	

	
	MOVF	RRblueValue,w
	ADDWF	RRredValue,f	

	
	
;	AVG blue and black
	MOVF	LLblackValue,w
	ADDWF	LLblueValue,f	

	
	MOVF	LblackValue,w
	ADDWF	LblueValue,f	

	
	MOVF	MblackValue,w
	ADDWF	MblueValue,f	

	
	MOVF	RblackValue,w
	ADDWF	RblueValue,f	

	
	MOVF	RRblackValue,w
	ADDWF	RRblueValue,f	

	
	RETURN
    ;</editor-fold>

;</editor-fold>
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
;<editor-fold defaultstate="collapsed" desc="Delay Loops">
    
    ;<editor-fold defaultstate="collapsed" desc="10ms Delay">
tenmsDelay:
    movlw	.13		
    movwf	delay2		
Go_on1_10			
    movlw	0xFF
    movwf	delay1
Go_on2_10
    decfsz	delay1,f	
    goto	Go_on2_10		        ; The Inner loop takes 3 instructions per loop * 256 loops = 768 instructions
    decfsz	delay2,f	    ; The outer loop takes an additional (3 instructions per loop + 2 instructions to reload Delay 1) * 256 loops
    goto	Go_on1_10		        ; (768+5) * 13 = 10049 instructions / 1M instructions per second = 10.05 ms.

    RETURN
;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="100 ms Delay loop">
hunnitMilDelay: ;(actually now 100ms)
    movlw	.130	
    movwf	delay2		
Go_on1_100			
    movlw	0xFF
    movwf	delay1
Go_on2_100
    decfsz	delay1,f	
    goto	Go_on2_100		        ; The Inner loop takes 3 instructions per loop * 256 loops = 768 instructions
    decfsz	delay2,f	    ; The outer loop takes an additional (3 instructions per loop + 2 instructions to reload Delay 1) * 256 loops
    goto	Go_on1_100		        ; (768+5) * 130 = 100490 instructions / 1M instructions per second = 100.50 ms.

    RETURN

;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="333 ms Delay loop">
threeMilDelay: ;(actually now 333ms)
    movlw   .3
    movwf   delay3
Go_on0_333
    movlw	.144	
    movwf	delay2		
Go_on1_333			
    movlw	0xFF
    movwf	delay1
Go_on2_333
    decfsz	delay1,f	
    goto	Go_on2_333		        ; The Inner loop takes 3 instructions per loop * 256 loops = 768 instructions
    decfsz	delay2,f	    ; The outer loop takes an additional (3 instructions per loop + 2 instructions to reload Delay 1) * 256 loops
    goto	Go_on1_333		        ; (768+5) * 130 = 100490 instructions / 1M instructions per second = 100.50 ms.
    decfsz  delay3,f
    goto    Go_on0_333

    RETURN

;</editor-fold>
      
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
    
;</editor-fold>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    end