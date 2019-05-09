    list p=PIC18F45K22
    #include "p18f45K22.inc"

    ;--- Configuration bits ---
    CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
    CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bit (WDT is controlled by SWDTEN bit of the WDTCON register)
    CONFIG  LVP	= ON              ; Low voltage programming
    ;--- Configuration bits ---

    ORG     0x00
    GOTO    setup

    ORG     0x08
    BTFSC   PIR1,TMR2IF
    CALL    PWMISRL,FAST
    BTFSC   PIR5,TMR4IF
    CALL    PWMISRR,FAST
    RETFIE


setup
    BSF	    OSCCON,IRCF0
    BCF	    OSCCON,IRCF1
    BSF	    OSCCON,IRCF2   

    MOVLB   0xF		    ; Set BSR for banked SFRs
    CLRF    PORTA		; Initialize PORTA by clearing output data latches
    CLRF    LATA		; Alternate method to clear output data latches
    CLRF    TRISA		; clear bits for all pins
    CLRF    ANSELA		; clear bits for all pins	
    MOVLW   0x0

    CALL    PWM
    GOTO    start

    
start
    GOTO    start
    
    
;<editor-fold defaultstate="collapsed" desc="PWM Setup Left">
LeftMotorControl macro dutyCycle, direction
    MOVLB   0x0f
    CLRF    CCP1CON
    MOVLW   .200
    MOVWF   PR2
    MOVLW   dutyCycle
    MOVWF   CCPR1L
    
    BCF	    TRISC,CCP1      ;C2
    
    CLRF    CCPTMRS0
  
    MOVLW   b'00001100'	    ;PWM mode
    MOVWF   CCP1CON 
    MOVLB   0xF
    MOVLW   b'01111010'	    ;16 prescale, 16 postscale, timer off
    MOVWF   T2CON 
    CLRF    TMR2
    BSF     PIE1, TMR2IE     ; enable interrupts from the timer
    bsf     INTCON,PEIE      ; Enable peripheral interrupts
    bsf     INTCON,GIE       ; Enable global interrupts
    BSF	    T2CON, TMR2ON    ; Turn timer on
    MOVLB   0x0
	; BSF     PORTA,5        ;indicate that the setup was performed
    endm
    ;</editor-fold>
    
;<editor-fold defaultstate="collapsed" desc="PWM Setup Right">
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
    ;</editor-fold>
    
PWMISRL:
    BCF	    PIR5,TMR4IE
    BCF	    PIR1,TMR2IF
    CLRF    TMR2
    BSF	    PIR5,TMR4IE
    RETURN
    
PWMISRR:
    BCF	    PIR5,TMR4IF
    MOVLB   0xF
    CLRF    TMR4
    MOVLB   0x0
    RETURN
    
PWM:

    RightMotorControl .150,b'0'
    LeftMotorControl .200,b'0'    
    RETURN 
    end