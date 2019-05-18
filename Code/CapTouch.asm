    list p=PIC18F45K22
    #include "p18f45K22.inc"
    title = "Capacitive Touch"
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
    count
    ADCValue
    delayCounter1        ; I want to make a 10ms delay
    delayCounter2
    capTouch_reading     ; voltage from cap touch sensing
    capTouch_not_touched ; voltage reading for untouched sensor
    capTouch_touched     ; voltage reading for untouched sensor
    ENDC
    
    ;</editor-fold>
    
    
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;			    Reset Vectors
;-------------------------------------------------------------------------------	
;-------------------------------------------------------------------------------

;<editor-fold defaultstate="collapsed" desc="Reset Vectors"> 
    
    
    org 0h  ;system boot begins here
    GOTO setup   
    
	
    org 8h  ;interrupt vector
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
     
    MOVLB	0xF		; Set BSR for banked SFRs
    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    BSF     TRISA,1     ; Disable digital output driver on pin 1 (sensor pin)
    CLRF	ANSELA		; clear bits for all pins	
    BSF     ANSELA,1    ; Disable digital input buffer (sensor pin)
    MOVLW   0x0

    ;</editor-fold>
    
;-------------------------------------------------
;		Serial Transmit
;-------------------------------------------------

    ;<editor-fold defaultstate="collapsed" desc="Serial Transmit">
    ;setup transmission
    BCF     TXSTA1,TX9      ;Use eight bits per transmission
    BSF     TXSTA1,TXEN     ;Enable transmissions
    BCF     TXSTA1,SYNC     ;Use asynchronous transmission
    BSF     TXSTA1,SENDB    ;Send break character bit at end of current transmission
    BSF     TXSTA1,BRGH     ;Flag for high baud rate 
    BCF     TXSTA1,TRMT     ;Flag the transmit register as full 
    BSF     RCSTA1,SPEN     ;Config Tx and Rx pins as serial pins

    ;Setup port C
    MOVLB   0xF
    CLRF    ANSELC          ;We don't want any analogue operations going on
    CLRF    PORTC           ;Clear the port so it's empty to begin with 
    BSF     TRISC,7         ;Setting both these pins as 1 and also setting the SPEN
    BSF     TRISC,6         ;bit lets the PIC set one as input and the other as output

    ;Setup baud rate generator
    BCF     BAUDCON1,BRG16  ;Don't use the 16 bit baud rate generator
    MOVLW   d'12'           ;Select 19200 baud. For speed like sanic
    ;MOVLW   d'25'           ;Select 2400 baud. For speed like sanic
    MOVWF   SPBRG1          ;Move it to the baud rate speed selection register
    CLRF    SPBRGH1         ;This shouldn't matter, but I'm adding it to be sure
;</editor-fold>
	
;-------------------------------------------------
;		Initialize ADC
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="Initialize ADC">
    
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	;Conversion will take 11us
    BSF	    ADCON2, ADCS2       ;Sampling and discharging are a different matter

    ;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

    ;Select Voltage References
    BCF     ADCON1,PVCFG0       ;Select internal input Vdd
    BCF     ADCON1,PVCFG1
    BCF     ADCON1,NVCFG0       ;Select internal input Vss
    BCF     ADCON1,NVCFG1

    ;Select the PORTA,1 pin (Channel Selection)
    MOVLW   b'00001'
    MOVWF   ADCON0

    BCF     ADCON2,ADFM         ;Left justified-MSB bits are in ADRESH
    BSF     ADCON0,ADON         ;Turn on the ADC
    ;</editor-fold>



    BSF	    PORTA,7	        ;Just so I can see it's on
    GOTO    start
;</editor-fold>

tenmsDelay:
	movlw	.13		
	movwf	delayCounter2		
Go_on1			
	movlw	0xFF
	movwf	delayCounter1
Go_on2
	decfsz	delayCounter1,f	
	goto	Go_on2		        ; The Inner loop takes 3 instructions per loop * 256 loops = 768 instructions
	decfsz	delayCounter2,f	    ; The outer loop takes an additional (3 instructions per loop + 2 instructions to reload Delay 1) * 256 loops
	goto	Go_on1		        ; (768+5) * 13 = 10049 instructions / 1M instructions per second = 10.05 ms.

	RETURN

transmitChar:
trans1
    BTFSS   PIR1,TX1IF          ;Finish transmitting if there's still something
    BRA     trans1		;left to be sent
trans2
    MOVWF   TXREG1              ;Move new char to the sending register
    BTFSS   PIR1,TX1IF          
    BRA     trans2		;Loop until the transmit register is empty
    return 

readPin0:
    BSF     ADCON0,GO       ;Start a conversion

adcPoll:
    BTFSC   ADCON0,GO       ;When bit is 0 again, conversion is finished
    BRA     adcPoll         ;Loop until done, approx 36us
    MOVF    ADRESH,W        ;Copy result to WREG
    return 

capTouch_delay:
    MOVLW   0xFF
loop:
    decfsz  WREG,w
    GOTO    loop
    return

capTouch_setup:
    ;<editor-fold defaultstate="collapsed" desc="Initialize ADC">
    MOVLB   0x0F

    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    CLRF	ANSELA		; clear bits for all pins	
    MOVLB   0x00
            
    CALL    capTouch_delay  ; Delay for draining circuit

    MOVLW   b'00000011'
    MOVWF   CTMUICON            ; Set the current source as 55uA with no trim


    BCF     CTMUCONH,EDGSEQEN  ; Disable edge sequence 
    

    MOVLB   0x0
    ;</editor-fold>
    RETURN 

capTouch:
    CALL    capTouch_setup
    BSF     CTMUCONH,CTMUEN     ; Enable die module
    BCF     CTMUCONL,EDG1STAT   ; These two get XORed to enable the current
    BCF     CTMUCONL,EDG2STAT   ; disable for now
    BSF     CTMUICON,IDISSEN    ; Make sure the current source is initially grounded
            
    CALL    capTouch_delay      ; wait for discharge to finish
    BSF     CTMUICON,IDISSEN    ; Make sure the current source is initially grounded
    BCF     CTMUICON,IDISSEN    ; Stop grounding the current
    BSF     CTMUCONL,EDG1STAT   ; XOR now positive, start charging the circuit
    CALL    capTouch_delay      ; wait for charging
    BCF     CTMUCONL,EDG1STAT   ; stop charging circuit

    MOVLW   0x0F
    BSF     TRISA,1
    BSF     ANSELA,1
    MOVLW   0x0

    BSF     ADCON0,GO           ; Start a conversion

capTouch_poll:
    BTFSC   ADCON0,GO           ; When bit is 0 again, conversion is finished
    BRA     capTouch_poll       ; Loop until done, approx 36us
    MOVF    ADRESH,W            ; Copy result to WREG

    CALL    transmitChar
    RETURN 

start:
    ; CALL    readPin0
    ; CALL    transmitChar
    
    ; CALL    readPin0
    ; CALL    transmitChar
    
    ; CALL    readPin0
    ; CALL    transmitChar
    
    ; CALL    readPin0
    ; CALL    transmitChar
    
    ; CALL    readPin0
    ; CALL    transmitChar

    ; MOVLW   A'\n'
    ; CALL    transmitChar
    CALL    capTouch
    CALL    tenmsDelay
    GOTO    start

    end