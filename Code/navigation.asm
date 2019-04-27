    list p=PIC18F45K22
    #include "p18f45K22.inc"

     ;--- Configuration bits ---
    CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
    CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bit (WDT is controlled by SWDTEN bit of the WDTCON register)
    CONFIG  LVP	= ON


    ;~~~~~~~~~~~~~~~~~~~~~~~CBLOCK~~~~~~~~~~~~~~~~~~~~~~~
    ;<editor-fold defaultstate="collapsed" desc="CBLOCK">
    CBLOCK  0x00
    LLwhiteValue      ; Hardcoded voltage values for each color for Left Left sensor
    LLgreenValue
    LLblueValue
    LLredValue
    LLblackValue
    
    LwhiteValue      ; Hardcoded voltage values for each color for Left sensor
    LgreenValue
    LblueValue
    LredValue
    LblackValue

    MwhiteValue      ; Hardcoded voltage values for each color for Middle sensor
    MgreenValue
    MblueValue
    MredValue
    MblackValue

    RwhiteValue      ; Hardcoded voltage values for each color for Right sensor
    RgreenValue
    RblueValue
    RredValue
    RblackValue

    RRwhiteValue      ; Hardcoded voltage values for each color for Right Right sensor
    RRgreenValue
    RRblueValue
    RRredValue
    RRblackValue

    LLsensorVal     ; Voltage value received from sensors
    LsensorVal
    MsensorVal
    RsensorVal
    RRsensorVal

    LLcolorSensed     ; One-hot encoded colour of each sensor
    LcolorSensed      ; white  = bit 0      green = bit 1
    McolorSensed      ; blue   = bit 2      red   = bit 3
    RcolorSensed      ; black  = bit 4
    RRcolorSensed

    raceColor        ; One-hot encoded colour of that the marv will race
    raceLinePosition  ; position of the race line -  LL-L-M-R-RR
    
    delay1
    delay2
    ENDC
    ;</editor-fold>
    ;~~~~~~~~~~~~~~~~~~~~~~~CBLOCK~~~~~~~~~~~~~~~~~~~~~~~

    org     0h
    GOTO    init
    ;interrupt vector
    org     8h  
    RETURN
    
    ;<editor-fold defaultstate="collapsed" desc="Initialization (init)">
init:
    BSF	OSCCON,IRCF0
    BCF	OSCCON,IRCF1
    BSF	OSCCON,IRCF2

    MOVLB   0xF
    CLRF    PORTA		; Initialize PORTA by clearing output data latches
    CLRF    LATA		; Alternate method to clear output data latches
    CLRF    TRISA		; clear bits for all pins
    CLRF    ANSELA		; clear bits for all pins	
    MOVLB   0x0
    
    MOVLW   .50
    MOVWF   LLwhiteValue
    MOVWF   LwhiteValue
    MOVWF   MwhiteValue
    MOVWF   RwhiteValue
    MOVWF   RRwhiteValue    ;move hardcoded voltage values into their registers

    MOVLW   .100
    MOVWF   LLgreenValue
    MOVWF   LgreenValue
    MOVWF   MgreenValue
    MOVWF   RgreenValue
    MOVWF   RRgreenValue    ;move hardcoded voltage values into their registers

    MOVLW   .150
    MOVWF   LLredValue
    MOVWF   LredValue
    MOVWF   MredValue
    MOVWF   RredValue
    MOVWF   RRredValue    ;move hardcoded voltage values into their registers

    MOVLW   .200
    MOVWF   LLblueValue
    MOVWF   LblueValue
    MOVWF   MblueValue
    MOVWF   RblueValue
    MOVWF   RRblueValue    ;move hardcoded voltage values into their registers

    MOVLW   .250
    MOVWF   LLblackValue
    MOVWF   LblackValue
    MOVWF   MblackValue
    MOVWF   RblackValue
    MOVWF   RRblackValue    ;move hardcoded voltage values into their registers

    MOVLW   .40             ;set hardcoded values for sensor outputs (for testing)
    MOVWF   LLsensorVal
    MOVLW   .40
    MOVWF   LsensorVal
    MOVLW   .40
    MOVWF   MsensorVal
    MOVLW   .40
    MOVWF   RsensorVal
    MOVLW   .40
    MOVWF   RRsensorVal
    
    MOVLW   b'00000010'
    MOVWF   raceColor
    GOTO    start

    ;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="getColor">
getColor:
    CLRF    LLcolorSensed       ; so that the 
    CLRF    LcolorSensed
    CLRF    McolorSensed
    CLRF    RcolorSensed
    CLRF    RRcolorSensed
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVF    LLwhiteValue,w
    CPFSGT  LLsensorVal         ; if LLSensorVal is > LLwhiteValue, it's not white
    BSF     LLcolorSensed,0     ; if it is white, set that bit

    MOVF    LLgreenValue,w
    CPFSGT  LLsensorVal         
    BSF     LLcolorSensed,1     ; if it's smaller than the max for green, it's could be green
    MOVF    LLwhiteValue,w    
    CPFSGT  LLsensorVal         ; it it's smaller than white, it's not green
    BCF     LLcolorSensed,1     

    MOVF    LLblueValue,w
    CPFSGT  LLsensorVal         
    BSF     LLcolorSensed,2     
    MOVF    LLgreenValue,w
    CPFSGT  LLsensorVal         
    BCF     LLcolorSensed,2     

    MOVF    LLredValue,w
    CPFSGT  LLsensorVal         
    BSF     LLcolorSensed,3     
    MOVF    LLblueValue,w
    CPFSGT  LLsensorVal         
    BCF     LLcolorSensed,3     

    MOVF    LLblackValue,w
    CPFSGT  LLsensorVal
    BSF     LLcolorSensed,4     ; else, it's black
    MOVF    LLredValue,w
    CPFSGT  LLsensorVal
    BCF     LLcolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVF    LwhiteValue,w
    CPFSGT  LsensorVal         ; if LLSensorVal is > LLwhiteValue, it's not white
    BSF     LcolorSensed,0     ; if it is white, set that bit

    MOVF    LgreenValue,w
    CPFSGT  LsensorVal         
    BSF     LcolorSensed,1     ; if it's smaller than the max for green, it's could be green
    MOVF    LwhiteValue,w    
    CPFSGT  LsensorVal         ; it it's smaller than white, it's not green
    BCF     LcolorSensed,1     

    MOVF    LblueValue,w
    CPFSGT  LsensorVal         
    BSF     LcolorSensed,2     
    MOVF    LgreenValue,w
    CPFSGT  LsensorVal         
    BCF     LcolorSensed,2     

    MOVF    LredValue,w
    CPFSGT  LsensorVal         
    BSF     LcolorSensed,3     
    MOVF    LblueValue,w
    CPFSGT  LsensorVal         
    BCF     LcolorSensed,3     

    MOVF    LblackValue,w
    CPFSGT  LsensorVal
    BSF     LcolorSensed,4     ; else, it's black
    MOVF    LredValue,w
    CPFSGT  LsensorVal
    BCF     LcolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Middle Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVF    MwhiteValue,w
    CPFSGT  MsensorVal         ; if LLSensorVal is > LLwhiteValue, it's not white
    BSF     McolorSensed,0     ; if it is white, set that bit

    MOVF    MgreenValue,w
    CPFSGT  MsensorVal         
    BSF     McolorSensed,1     ; if it's smaller than the max for green, it's could be green
    MOVF    MwhiteValue,w    
    CPFSGT  MsensorVal         ; it it's smaller than white, it's not green
    BCF     McolorSensed,1     

    MOVF    MblueValue,w
    CPFSGT  MsensorVal         
    BSF     McolorSensed,2     
    MOVF    MgreenValue,w
    CPFSGT  MsensorVal         
    BCF     McolorSensed,2     

    MOVF    MredValue,w
    CPFSGT  MsensorVal         
    BSF     McolorSensed,3     
    MOVF    MblueValue,w
    CPFSGT  MsensorVal         
    BCF     McolorSensed,3     

    MOVF    MblackValue,w
    CPFSGT  MsensorVal
    BSF     McolorSensed,4     ; else, it's black
    MOVF    MredValue,w
    CPFSGT  MsensorVal
    BCF     McolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Middle Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVF    RwhiteValue,w
    CPFSGT  RsensorVal         ; if LLSensorVal is > LLwhiteValue, it's not white
    BSF     RcolorSensed,0     ; if it is white, set that bit

    MOVF    RgreenValue,w
    CPFSGT  RsensorVal         
    BSF     RcolorSensed,1     ; if it's smaller than the max for green, it's could be green
    MOVF    RwhiteValue,w    
    CPFSGT  RsensorVal         ; it it's smaller than white, it's not green
    BCF     RcolorSensed,1     

    MOVF    RblueValue,w
    CPFSGT  RsensorVal         
    BSF     RcolorSensed,2     
    MOVF    RgreenValue,w
    CPFSGT  RsensorVal         
    BCF     RcolorSensed,2     

    MOVF    RredValue,w
    CPFSGT  RsensorVal         
    BSF     RcolorSensed,3     
    MOVF    RblueValue,w
    CPFSGT  RsensorVal         
    BCF     RcolorSensed,3     

    MOVF    RblackValue,w
    CPFSGT  RsensorVal
    BSF     RcolorSensed,4     ; else, it's black
    MOVF    RredValue,w
    CPFSGT  RsensorVal
    BCF     RcolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVF    RRwhiteValue,w
    CPFSGT  RRsensorVal         ; if LLSensorVal is > LLwhiteValue, it's not white
    BSF     RRcolorSensed,0     ; if it is white, set that bit

    MOVF    RRgreenValue,w
    CPFSGT  RRsensorVal         
    BSF     RRcolorSensed,1     ; if it's smaller than the max for green, it's could be green
    MOVF    RRwhiteValue,w    
    CPFSGT  RRsensorVal         ; it it's smaller than white, it's not green
    BCF     RRcolorSensed,1     

    MOVF    RRblueValue,w
    CPFSGT  RRsensorVal         
    BSF     RRcolorSensed,2     
    MOVF    RRgreenValue,w
    CPFSGT  RRsensorVal         
    BCF     RRcolorSensed,2     

    MOVF    RRredValue,w
    CPFSGT  RRsensorVal         
    BSF     RRcolorSensed,3     
    MOVF    RRblueValue,w
    CPFSGT  RRsensorVal         
    BCF     RRcolorSensed,3     

    MOVF    RRblackValue,w
    CPFSGT  RRsensorVal
    BSF     RRcolorSensed,4     ; else, it's black
    MOVF    RRredValue,w
    CPFSGT  RRsensorVal
    BCF     RRcolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
    return                             ; Return from getColor (determine color sensed by each sensor)
    ;</editor-fold>

    ;<editor-fold defaultstate="collapsed" desc="getRaceLinePosition">
getRaceLinePosition:
    MOVLW   b'11100000'
    MOVWF   raceLinePosition        ;raceLinePosition is vol ones 
    MOVF    raceColor,w               ;move die one-hot encoded race color in die wreg in, vir comparisons 

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
    BTFSC   raceLinePosition, 0     ; if LL senses race colour, turn left
    BSF     PORTA,7
    BTFSC   raceLinePosition, 1     ; if L senses race colour, turn left
    BSF     PORTA,7

    BTFSC   raceLinePosition, 2     ; if M senses race colour, go straight
    BSF     PORTA,6

    BTFSC   raceLinePosition, 3     ; if R senses race colour, turn right
    BSF     PORTA,5
    BTFSC   raceLinePosition, 4     ; if RR senses race colour, turn right
    BSF     PORTA,5

    return 

    ;</editor-fold>

navigate:
    CALL    getColor
    CALL    getRaceLinePosition
    CALL    determineDirection
    CALL    hunnitMilDelay
    GOTO    navigate
; navigate doesn't end, it must be interruted 

    ;<editor-fold defaultstate="collapsed" desc="100 ms Delay loop">
hunnitMilDelay
	movlw	.130	
	movwf	delay2		
Go_on1			
	movlw	0xFF
	movwf	delay1
Go_on2
	decfsz	delay1,f	
	goto	Go_on2		        ; The Inner loop takes 3 instructions per loop * 256 loops = 768 instructions
	decfsz	delay2,f	    ; The outer loop takes an additional (3 instructions per loop + 2 instructions to reload Delay 1) * 256 loops
	goto	Go_on1		        ; (768+5) * 130 = 100490 instructions / 1M instructions per second = 100.50 ms.

	RETURN

    ;</editor-fold>

start:
    GOTO    navigate

    end
    

