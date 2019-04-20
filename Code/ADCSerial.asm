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
    MOVWF   SPBRG1          ;Move it to the baud rate speed selection register
    CLRF    SPBRGH1         ;This shouldn't matter, but I'm adding it to be sure
;</editor-fold>
    
    GOTO    start
;</editor-fold>

start 
    MOVLW   0xFF
    MOVWF   PORTA
    MOVLW   A'A'
    CALL    writeChar
    MOVLW   A'\n'
    call    writeChar
    GOTO    start
   
writeChar
    BTFSS   PIR1,TX1IF      ;Checking this flag is like checking if the 
    BRA     writeChar       ;Loop until the transmit register is empty
    MOVWF   TXREG1          ;Move it to the sending register
    return 

end