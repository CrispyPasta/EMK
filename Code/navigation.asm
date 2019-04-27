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
    ENDC
    ;~~~~~~~~~~~~~~~~~~~~~~~CBLOCK~~~~~~~~~~~~~~~~~~~~~~~

init:
    BSF	OSCCON,IRCF0
	BCF	OSCCON,IRCF1
	BSF	OSCCON,IRCF2

    MOVLB   0xF
    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    CLRF	ANSELA		; clear bits for all pins	
    MOVLB   0x0

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
    BCF     raceLinePosition
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  LcolorSensed
    BCF     raceLinePosition
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Left Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Middle Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  McolorSensed
    BCF     raceLinePosition
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Middle Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  RcolorSensed
    BCF     raceLinePosition
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Right Sens~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CPFSEQ  RRcolorSensed
    BCF     raceLinePosition
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Right Right Sen~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    COMF    raceLinePosition        ;invert die position, dan behoort hy te wys waar die race line opgetel word
    ; compare elke sensor se colour met die race color
    ; if eq, set that sensor's bit in the line position vector
    return                  ; return from getRaceLinePosition (determine where the line is that we want to race on)

determineDirection:
    

