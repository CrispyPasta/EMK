    list p=PIC18F45K22
    #include "p18f45K22.inc"

    ;--- Configuration bits ---
    CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
    CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bit (WDT is controlled by SWDTEN bit of the WDTCON register)
    CONFIG  LVP	= ON              ; Low voltage programming
    ;--- Configuration bits ---
    
    CBLOCK 0x00

    ENDC


    ORG     0x00
    GOTO    setup

    ORG     0x08
    BCF	    PIR1,TMR2IF
    RETURN


setup
    BSF		OSCCON,IRCF0
    BCF		OSCCON,IRCF1
    BSF		OSCCON,IRCF2   

    MOVLB	0xF		    ; Set BSR for banked SFRs
    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    BSF     TRISA,0     ; Disable digital output driver
    CLRF	ANSELA		; clear bits for all pins	
    BSF     ANSELA,0    ; Disable digital input buffer
    MOVLW   0x0

    GOTO    start

start
    BSF     PORTA,7
    GOTO    PWM 

;<editor-fold defaultstate="collapsed" desc="PWM Setup">
PWMSetup:
    CLRF    CCP1CON
    MOVLW   .199
    MOVWF   PR2
    MOVLW   .49
    MOVWF   CCPR1L
    BCF	    TRISC,CCP1
    MOVLW   b'01111010'	    ;16 prescale, 16 postscale, timer off
    MOVWF   T2CON   
    MOVLW   b'00011100'	    ;.25, PWM mode
    MOVWF   CCP1CON 
    CLRF    TMR2
    BSF	    T2CON, TMR2ON
	
    RETURN
    ;</editor-fold>


PWM:
;    CLRF    CCP1CON
;    MOVLW   .249
;    MOVWF   PR2
;    MOVLW   .124
;    MOVWF   CCPR1L
;    BCF     TRISC, CCP1
;    MOVLW   0x7A    ;16 prescale, 16 postscale, timer off
;    MOVWF   T2CON
;    MOVLW   b'00101100'   
;    MOVWF   CCP1CON
;    CLRF    TMR2
;    BSF     T2CON, TMR2ON
    CALL    PWMSetup
again
    BCF     PIR1, TMR2IF
over
    BTFSS   PIR1, TMR2IF 
    BRA     over
    GOTO    again 

    end