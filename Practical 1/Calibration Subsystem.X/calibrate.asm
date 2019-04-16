
; PIC18F45K22 Configuration Bit Settings

; Assembly source line config statements
    title 	"Calibration Subsystem"  
    LIST   	P=PIC18F45K22 ; processor type
    #include "p18f45k22.inc"
    
    
; CONFIG1H
  CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block)
  CONFIG  PLLCFG = OFF          ; 4X PLL Enable (Oscillator used directly)
  CONFIG  PRICLKEN = ON         ; Primary clock enable bit (Primary clock is always enabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRTEN = OFF          ; Power-up Timer Enable bit (Power up timer disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 190            ; Brown Out Reset Voltage bits (VBOR set to 1.90 V nominal)

; CONFIG2H
  CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bits (Watch dog timer is always disabled. SWDTEN has no effect.)
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC1       ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<5:0> pins are configured as analog input channels on Reset)
  CONFIG  CCP3MX = PORTB5       ; P3A/CCP3 Mux bit (P3A/CCP3 input/output is multiplexed with RB5)
  CONFIG  HFOFST = ON           ; HFINTOSC Fast Start-up (HFINTOSC output and ready status are not delayed by the oscillator stable status)
  CONFIG  T3CMX = PORTC0        ; Timer3 Clock input mux bit (T3CKI is on RC0)
  CONFIG  P2BMX = PORTD2        ; ECCP2 B output mux bit (P2B is on RD2)
  CONFIG  MCLRE = EXTMCLR       ; MCLR Pin Enable bit (MCLR pin enabled, RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled if MCLRE is also 1)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection Block 0 (Block 0 (000800-001FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection Block 1 (Block 1 (002000-003FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection Block 2 (Block 2 (004000-005FFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection Block 3 (Block 3 (006000-007FFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection Block 0 (Block 0 (000800-001FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection Block 1 (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection Block 2 (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection Block 3 (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection Block 0 (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection Block 1 (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection Block 2 (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection Block 3 (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)
;
    cblock	0x00
    ;~~~~~~~~~~~~~~~~~~~ CALIBRATION SUBROUTINE VARIABLES ~~~~~~~~~~~~~~~~~~~ 
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
    endc
    
    
    org	0h
    GOTO INIT       ; Perform setup of all the stuff

    org 0x08
    BTFSC   PIR1,TMR2IF     ; Test the interrupt flag of timer 2
    GOTO    CALIBRATE_SUB   ; Got to cal subroutine
    BTFSC   INTCON,INT0IF      ; Test the interrupt flag of PORTB pin 0
    GOTO    DEBUG_SUB       ; Go to the debugging subroutine
start
    GOTO    CALIBRATE
    GOTO    $



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INITIALIZATION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
INIT
    ; Set oscillator frequency to 500kHz - 010
    bsf OSCCON,IRCF0
    bcf OSCCON,IRCF1
    bsf OSCCON,IRCF2

    ; Initialize Port A	(just flashes an LED in my program)
    MOVLB	0xF		    ; Set BSR for banked SFRs
    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    CLRF	ANSELA		; clear bits for all pins	

    ; Initialize Port B (button interrupt for debugging subsystem)
    CLRF    PORTB
    CLRF    LATB
    MOVLW   b'00000001' 
    MOVWF   TRISB
    CLRF    ANSELB

    ; Initialize Port D	(SSD port)
    CLRF	PORTD		; Initialize PORTD by clearing output data latches
    CLRF	LATD		; Alternate method to clear output data latches
    CLRF	TRISD		; clear bits for all pins
    CLRF	ANSELD		; clear bits for all pins
    MOVLB	0x0		 
    MOVLW   0xFF    
    MOVWF   PORTD

    bsf     INTCON,PEIE ; Enable peripheral interrupts
    bsf     INTCON,GIE  ; Enable global interrupts

    bsf     INTCON,INT0IE   ; Enable external interrupt on B0 pin
    bcf     INTCON,INT0IF   ; Clear flag just in case

    GOTO    start           ; Init finished, go to start
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INITIALIZATION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 


CALIBRATE

    ; Initialize Timer 2 registers and so on
    bsf	    PIE1,TMR2IE     ; Enable Timer2 interrups
    MOVLW   b'01111111'     ; Set the prescaler to 16x and the postscaler to 16x
    MOVWF   T2CON           ; Move to the Timer2 control register
    MOVLW   d'245'          ; Using 245 rollovers to get to 3s
    MOVWF   PR2             ; Move that value to the period register

    MOVLW   b'00010000'     ; indicates calibrate sub
    MOVWF   stateBits       ; Store this incase debugging is called
    ; Initialize calibration subroutine variables
    MOVLW   d'48'
    MOVWF   delayCounter    ; After 12 interrups, 3s have passed
    MOVLW   0x0
    MOVWF   calOffset       ; Initialize the offset to zero, so it doesn't skip the first character
    MOVLW   0x7             
    MOVWF   calRounds       ; We want to repeat the calibration routine five times, plus two for other shite
    GOTO    $               ; Wait here until the first interrupt

CALIBRATE_SUB
    bcf     PIR1,TMR2IF     ; clear niterrupt flag
    CLRF    TMR2	        ; Clear timer 2 of any counts accumulated (this is as close as we can get I guess)
    DECFSZ  delayCounter    ; Decrement and skip if zero, store the answer in delayCounter
    RETFIE 

    CALL    LEDS
    MOVLW   d'48'
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
    MOVLW   b'01000000'
    MOVWF   stateBits
    RETFIE		            ; Return to main program


LEDS 
    MOVLW   0x00
    CPFSEQ  calOffset       ; if the offset is zero, it is the first colour being calibrated
    bsf     PORTA,7         ; make the MSB of porta 1
    RLNCF   PORTA           ; rotate that in so they display on the LEDs
    RETFIE

SSDTABLE
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


DEBUG_SUB
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

debugMessage
    MOVF    calOffset,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugRace
    MOVF    calOffset,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugProgram
    MOVF    calOffset,w
    MOVWF   PORTA
    call    delay1s
    RETURN

debugCalibrate
    MOVF    calOffset,w  
    MOVWF   PORTA
    call    delay1s
    RETURN 

delay1s
    MOVLW   0x05
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

    end
