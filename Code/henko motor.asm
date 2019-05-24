; ASM source line config statements
    LIST    p=pic18F45K22
    #include "p18F45K22.inc"

; PIC18F45K22 Configuration Bit Settings
    
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
  CONFIG  CCP3MX = PORTE0       ; P3A/CCP3 Mux bit (P3A/CCP3 input/output is mulitplexed with RE0)
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

; TODO PLACE VARIABLE DEFINITIONS GO HERE
  CBLOCK    0x00
    FLAG_REG    ; 0x00
    delay1
    delay2
    delay3
  ENDC
;*******************************************************************************
; Reset Vector
;*******************************************************************************

    org     0x0000                    ; processor reset vector
    GOTO    INIT                   ; go to beginning of program
    org     0x0008
    org     0x0018
    GOTO    ISR


MAIN_PROG CODE                      ; let linker place main program

INIT:
    MOVLB   0xF
;   OSCILATOR = 4 MHz
    BSF     OSCCON, IRCF0
    BCF     OSCCON, IRCF1
    BSF     OSCCON, IRCF2
    
   
; Initialize Port A	(just flashes an LED in my program)
    CLRF	PORTA		; Initialize PORTA by clearing output data latches
    CLRF	LATA		; Alternate method to clear output data latches
    CLRF	TRISA		; clear bits for all pins
    CLRF	ANSELA		; clear bits for all pins

;Initialize Port B
    
    CLRF    PORTB 		; Initialize PORTA by clearing output data latches
    CLRF    LATB 		; Alternate method to clear output data latches
    CLRF    ANSELB 		; Configure I/O
    CLRF    TRISB		; All digital outputs
    
;Initialize Port C
    CLRF	LATC
    CLRF	TRISC
    CLRF	ANSELC
    CLRF	PORTC
        
; Initialize Port D	
    CLRF	PORTD		; Initialize PORTD by clearing output data latches
    CLRF	LATD		; Alternate method to clear output data latches
    CLRF	TRISD		; clear bits for all pins
    CLRF	ANSELD		; clear bits for all pins
    
;Initialize Port E

    CLRF    PORTE 		; Initialize PORTA by clearing output data latches
    CLRF    LATE 		; Alternate method to clear output data latches
    CLRF    ANSELE 		; Configure I/O
    CLRF    TRISE		; All digital outputs
    
    
;PWM SETUP FOR RC1
    CALL    PWM_SETUP_CCP2

;PWM SETUP FOR RC2
    CALL    PWM_SETUP_CCP3
    
;USART SETUP
    CALL    UART_SETUP
    
    
    MOVLB   0x00

    GOTO	MAIN
    
MAIN:
    
;SET BITS FOR MOTOR CONTROL
    
    CALL    LEFT_PWM_50
    CALL    LEFT_MOTOR_F
    CALL    delay1s
    
    CALL    LEFT_PWM_75
    CALL    delay1s
    
    CALL    LEFT_PWM_100
    CALL    delay1s
    
    CALL    LEFT_MOTOR_R
    CALL    delay1s
    
    CALL    LEFT_MOTOR_OFF
    CALL    delay1s
    
;    CALL    LEFT_PWM_50
    CALL    RIGHT_PWM_50
    CALL    RIGHT_MOTOR_F
    CALL    delay1s
    
    CALL    RIGHT_PWM_75
    CALL    delay1s
    
    CALL    RIGHT_PWM_100
    CALL    delay1s
    
    CALL    RIGHT_MOTOR_R
    CALL    delay1s
    
    CALL    RIGHT_MOTOR_OFF
    CALL    delay1s
    
    
    GOTO    MAIN  


RIGHT_PWM_50:    
;    MOVLW   0x35
    MOVLB   0xF
; LOAD PR2 = 77
    MOVLW   .100
    MOVWF   PR4
    MOVLB   0x0
    RETURN

LEFT_PWM_50:    
;    MOVLW   0x35
    
; LOAD PR2 = 77
    MOVLW   .100
    MOVWF   PR2
    RETURN

RIGHT_PWM_75:    
;    MOVLW   0x35
    MOVLB   0xF
; LOAD PR2 = 77
    MOVLW   .65
    MOVWF   PR4
    MOVLB   0x0
    RETURN

LEFT_PWM_75:    
;    MOVLW   0x35
    
; LOAD PR2 = 77
    MOVLW   .65
    MOVWF   PR2
    RETURN

RIGHT_PWM_100:    
;    MOVLW   0x35
    MOVLB   0xF
; LOAD PR2 = 77
    MOVLW   .5
    MOVWF   PR4
    MOVLB   0x0
    RETURN

LEFT_PWM_100:    
;    MOVLW   0x35
    
; LOAD PR2 = 77
    MOVLW   .5
    MOVWF   PR2
    RETURN
    
LEFT_MOTOR_F:
    
    BSF     PORTC,  RC4
    BCF     PORTC,  RC5
    
    RETURN

LEFT_MOTOR_R:
    
    BCF     PORTC,  RC4
    BSF     PORTC,  RC5
    
    RETURN

LEFT_MOTOR_OFF:
    
    BSF     PORTC,  RC4
    BSF     PORTC,  RC5
    
    RETURN

RIGHT_MOTOR_F:
    
    BCF     PORTD,  RD3
    BSF     PORTD,  RD2
    
    RETURN

RIGHT_MOTOR_R:
    
    BSF     PORTD,  RD3
    BCF     PORTD,  RD2
    
    RETURN

RIGHT_MOTOR_OFF:
    
    BSF     PORTD,  RD3
    BSF     PORTD,  RD2
    
    RETURN


  
ISR:

    RETFIE
    
SEND_BYTE:
    
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		SEND_BYTE
    
    MOVWF	TXREG1
    RETURN
    
    
PWM_SETUP_CCP2:; ON CCP2 = RC1
    BSF     TRISC,  RC1
    BCF     ANSELC, RC1
; USE TIMER2 = 00
    BCF     CCPTMRS0,C2TSEL0
    BCF     CCPTMRS0,C2TSEL1
; LOAD PR2 = 77
;    MOVLW   .10
    MOVLW   .77
    MOVWF   PR2
; SET CCP2CON TO PWM MODE = 11XX
    BSF     CCP2CON, CCP2M2
    BSF     CCP2CON, CCP2M3

; LOAD DCB BITS = 11
;    MOVLW   0x35
    MOVLW   .53
;    MOVLW   .200
    MOVWF   CCPR2L
    BSF     CCP2CON, DC2B0
    BSF     CCP2CON, DC2B1
; SET UP TIMER, BY CLEAR FLAG, THEN FREE RUN
    BCF     PIR2, TMR2IF
    BCF     T2CON, T2CKPS0
    BCF     T2CON, T2CKPS1
    BSF     T2CON, TMR2ON
; WAIT FOR OVERFLOW
    BTFSC   PIR2, TMR2IF
    BRA     $-2
    BCF     TRISC,  RC1
    
    RETURN

    
;USE TMR4 FOR CCP1
    
PWM_SETUP_CCP3:; ON CCP3 = RE0
    BSF     TRISE,  RE0
    BCF     ANSELE, RE0
; USE TIMER4 = 01
    BSF     CCPTMRS0,C3TSEL0
    BCF     CCPTMRS0,C3TSEL1
; LOAD PR4 = 77
    MOVLW   .77
    MOVWF   PR4
; SET CCP2CON TO PWM MODE = 11XX
    BSF     CCP3CON, CCP3M2
    BSF     CCP3CON, CCP3M3

; LOAD DCB BITS = 11
;    MOVLW   0x35
    MOVLW   .53
    MOVWF   CCPR3L
    BSF     CCP3CON, DC3B0
    BSF     CCP3CON, DC3B1
; SET UP TIMER, BY CLEAR FLAG, THEN FREE RUN
    BCF     PIR5, TMR4IF
    BCF     T4CON, T4CKPS0
    BCF     T4CON, T4CKPS1
    BSF     T4CON, TMR4ON
; WAIT FOR OVERFLOW
    BTFSC   PIR5, TMR4IF
    BRA     $-2
    BCF     TRISE,  RE0
    
    RETURN
    
UART_SETUP:
    
;1.Initialize the SPBRGHx:SPBRGx register pair and the BRGH and BRG16 bits 
;to achieve the desired baud rate (see Section 16.4 ?EUSART Baud Rate Generator (BRG)?).
    
    MOVLW   .25			    ;Move the variable in to baud rate generator registers
    MOVWF   SPBRG1
    CLRF    SPBRGH1

    BSF	    BAUDCON1,	BRG16	    ;Set to 001
    BCF	    TXSTA1,	SYNC
    BCF	    TXSTA1,	BRGH
    
;2. Set the RXx/DTx and TXx/CKx TRIS controls to ?1?.

    CLRF    TRISC
    BSF	    TRISC, TRISC6	    ;Set the RC6 pin to transmit 
    CLRF    ANSELC
    
;3. Enable the asynchronous serial port by clearing the SYNC bit and setting the SPEN bit.

    BSF	    RCSTA1, SPEN
    
;4. If 9-bit transmission is desired, set the TX9 control bit. 
;A set ninth data bit will indicate that the eight Least Significant data bits are an address when the receiver is set for address detection.

    ;Not using it now so just leave it
    
;5. Set the CKTXP control bit if inverted transmit data polarity is desired.

    BCF	    BAUDCON1, CKTXP	    ;Just leav it low, because not using inverted polarity
    
;6. Enable the transmission by setting the TXEN control bit. This will cause the TXxIF interrupt bit to be set.

    BSF	    TXSTA1, TXEN
    
;7. If interrupts are desired, set the TXxIE interrupt enable bit. 
;An interrupt will occur immediately provided that the GIE/GIEH and PEIE/GIEL bits of the INTCON register are also set.

    ;we are polling at this stageg, so we don't need to use this rigt now
    
;8. If 9-bit transmission is selected, the ninth bit should be loaded into the TX9D data bit.

    ;Not using
    
;**********NOW DOING RECEPTION SETUP
    
;1. Initialize the SPBRGHx:SPBRGx register pair and the BRGH and BRG16 bits to achieve the desired baud rate (see Section 16.4 ?EUSART Baud Rate Generator (BRG)?).

;2. Set the RXx/DTx and TXx/CKx TRIS controls to ?1?.

    BSF	    TRISC, TRISC7	    ;Set the RC7 pin to receive 
    
;3. Enable the serial port by setting the SPEN bit and the RXx/DTx pin TRIS bit. The SYNC bit must be clear for asynchronous operation.

;4. If interrupts are desired, set the RCxIE interrupt enable bit and set the GIE/GIEH and PEIE/GIEL bits of the INTCON register.

;5. If 9-bit reception is desired, set the RX9 bit. 

;6. Set the DTRXP if inverted receive polarity is desired.

;7. Enable reception by setting the CREN bit. 
    
    BSF	    RCSTA1, CREN
    
;8. The RCxIF interrupt flag bit will be set when a character is transferred from the RSR to the receive buffer. 
;   An interrupt will be generated if the RCxIE interrupt enable bit was also set.

    BCF    PIR1, RC1IF		    ;interrupt results* - SO WE DONT GET FALSE FLAGS
    BSF    PIE1, RC1IE		    ;Interrupt enables  
    
;Enable global interrupts
    
    BSF    INTCON, GIEH
    BSF    INTCON, GIEL
    
;9. Read the RCSTAx register to get the error flags and, if 9-bit data reception is enabled, the ninth data bit.

;10. Get the received eight Least Significant data bits from the receive buffer by reading the RCREGx register.

;11. If an overrun occurred, clear the OERR flag by clearing the CREN receiver enable bit.
    
    RETURN
    
    
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
    
threeMilDelay: ;(actually now 333ms)
;    BSF	    INTCON,GIEL		; Enable peripheral interrupts
;    bsf     INTCON,GIEH		; Enable global interrupts
;    BSF	    PIE1,RC1IE		; Set RCIE Interrupt Enable
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
    
delay1s:

    MOVLW	0x0F
    MOVWF	delay3
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

    END