list p=PIC18F45K22
#include "p18f45K22.inc"
    
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
    newsize
    redValue    ; These will store the values read by the cal subroutine come prac 2
    blueValue
    greenValue
    whiteValue
    blackValue
    TX_BYTE
    RX_BYTE
    WRITE_ACKNOWLEDGE_POLL_LOOPS
    POLL_COUNTER
    WRITE_CONTROL
    READ_CONTROL
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
    
    ;Flashes an LED in my program     
     
    MOVLB	0xF		; Set BSR for banked SFRs
    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    CLRF	ANSELA		; clear bits for all pins	

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
    BCF	    BAUDCON1,BRG16	; Use 8 bit baud generator
    BSF	    TRISC,TX		; make TX an output pin
    BSF	    TRISC,RX		; make RX an input pin
    CLRF    PORTC
    CLRF    ANSELC
    MOVLW   b'11011000'		; Setup port C for serial port.
					; TRISC<7>=1 and TRISC<6>=1.
    MOVWF   TRISC
    MOVLW   D'5'
    MOVWF   size
	
    ;</editor-fold>
    
    GOTO    start
;</editor-fold>

start 
    MOVLW   0xFF
    MOVWF   PORTA
    GOTO    start
   

;<editor-fold defaultstate="collapsed" desc="Serial Communications Block">
    Transmit:	
    MOVFF	INDF1,WREG
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
    
Race:	
    MOVLW	b'10100100'
	MOVWF	PORTD
	MOVLW	A'M'
	call trans
;</editor-fold>
end