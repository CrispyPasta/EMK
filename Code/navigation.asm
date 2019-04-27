    list p=PIC18F45K22
    #include "p18f45K22.inc"

     ;--- Configuration bits ---
    CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
    CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bit (WDT is controlled by SWDTEN bit of the WDTCON register)
    CONFIG  LVP	= ON

    ;~~~~~~~~~~~~~~~~~~~~~~~CBLOCK~~~~~~~~~~~~~~~~~~~~~~~
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
    ;~~~~~~~~~~~~~~~~~~~~~~~CBLOCK~~~~~~~~~~~~~~~~~~~~~~~

    org     0h
    GOTO    init
    ;interrupt vector
    org     8h  
    RETURN
    
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
    MOVLW   .90
    MOVWF   MsensorVal
    MOVLW   .40
    MOVWF   RsensorVal
    MOVLW   .40
    MOVWF   RRsensorVal
    GOTO    start

getColor:
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVLW   LLwhiteValue
    CPFSGT  LLsensorVal         ; if LLSensorVal is > LLwhiteValue, it's not white
    BSF     LLcolorSensed,0     ; if it is white, set that bit

    MOVLW   LLgreenValue
    CPFSGT  LLsensorVal         
    BSF     LLcolorSensed,1     

    MOVLW   LLblueValue
    CPFSGT  LLsensorVal         
    BSF     LLcolorSensed,2     

    MOVLW   LLredValue
    CPFSGT  LLsensorVal         
    BSF     LLcolorSensed,3     

    BSF     LLcolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVLW   LwhiteValue
    CPFSGT  LsensorVal         ; if LLSensorVal is > whiteValue, it's not white
    BSF     LcolorSensed,0     ; if it is white, set that bit

    MOVLW   LgreenValue
    CPFSGT  LsensorVal         
    BSF     LcolorSensed,1     

    MOVLW   LblueValue
    CPFSGT  LsensorVal         
    BSF     LcolorSensed,2     

    MOVLW   LredValue
    CPFSGT  LsensorVal         
    BSF     LcolorSensed,3     

    BSF     LcolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Left Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Middle Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVLW   MwhiteValue
    CPFSGT  MsensorVal         ; if LLSensorVal is > whiteValue, it's not white
    BSF     McolorSensed,0     ; if it is white, set that bit

    MOVLW   MgreenValue
    CPFSGT  MsensorVal         
    BSF     McolorSensed,1     

    MOVLW   MblueValue
    CPFSGT  MsensorVal         
    BSF     McolorSensed,2     

    MOVLW   MredValue
    CPFSGT  MsensorVal         
    BSF     McolorSensed,3     

    BSF     McolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Middle Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVLW   RwhiteValue
    CPFSGT  RsensorVal         ; if LLSensorVal is > whiteValue, it's not white
    BSF     RcolorSensed,0     ; if it is white, set that bit

    MOVLW   RgreenValue
    CPFSGT  RsensorVal         
    BSF     RcolorSensed,1     

    MOVLW   RblueValue
    CPFSGT  RsensorVal         
    BSF     RcolorSensed,2     

    MOVLW   RredValue
    CPFSGT  RsensorVal         
    BSF     RcolorSensed,3     

    BSF     RcolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOVLW   RRwhiteValue
    CPFSGT  RRsensorVal         ; if LLSensorVal is > whiteValue, it's not white
    BSF     RRcolorSensed,0     ; if it is white, set that bit

    MOVLW   RRgreenValue
    CPFSGT  RRsensorVal         
    BSF     RRcolorSensed,1     

    MOVLW   RRblueValue
    CPFSGT  RRsensorVal         
    BSF     RRcolorSensed,2     

    MOVLW   RRredValue
    CPFSGT  RRsensorVal         
    BSF     RRcolorSensed,3     

    BSF     RRcolorSensed,4     ; else, it's black
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Determine Right Right Sensor Value~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
    return                             ; Return from getColor (determine color sensed by each sensor)

getRaceLinePosition:
    MOVLW   0xFF
    MOVWF   raceLinePosition        ;raceLinePosition is vol ones 
    MOVLW   raceColor               ;move die one-hot encoded race color in die wreg in, vir comparisons 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Left Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  LLcolorSensed
    BCF     raceLinePosition,0
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  LcolorSensed
    BCF     raceLinePosition,1
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Middle Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  McolorSensed
    BCF     raceLinePosition,2
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Middle Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  RcolorSensed
    BCF     raceLinePosition,3
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Right Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  RRcolorSensed
    BCF     raceLinePosition,4
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Right Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    COMF    raceLinePosition        ;invert die position, dan behoort hy te wys waar die race line opgetel word
    
    return                          ; return from getRaceLinePosition (determine where the line is that we want to race on)

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

navigate:
    CALL    getColor
    CALL    getRaceLinePosition
    CALL    determineDirection
    CALL    hunnitMilDelay
    GOTO    navigate
; navigate doesn't end, it must be interruted 

hunnitMilDelay:
    return 
start:
    GOTO    navigate

    end
    

