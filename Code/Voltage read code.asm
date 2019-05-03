;*******************************************************************************
;                                                                              *
;    Microchip licenses this software to you solely for use with Microchip     *
;    products. The software is owned by Microchip and/or its licensors, and is *
;    protected under applicable copyright laws.  All rights reserved.          *
;                                                                              *
;    This software and any accompanying information is for suggestion only.    *
;    It shall not be deemed to modify Microchip?s standard warranty for its    *
;    products.  It is your responsibility to ensure that this software meets   *
;    your requirements.                                                        *
;                                                                              *
;    SOFTWARE IS PROVIDED "AS IS".  MICROCHIP AND ITS LICENSORS EXPRESSLY      *
;    DISCLAIM ANY WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING  *
;    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS    *
;    FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL          *
;    MICROCHIP OR ITS LICENSORS BE LIABLE FOR ANY INCIDENTAL, SPECIAL,         *
;    INDIRECT OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, HARM TO     *
;    YOUR EQUIPMENT, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR    *
;    SERVICES, ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY   *
;    DEFENSE THEREOF), ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER      *
;    SIMILAR COSTS.                                                            *
;                                                                              *
;    To the fullest extend allowed by law, Microchip and its licensors         *
;    liability shall not exceed the amount of fee, if any, that you have paid  *
;    directly to Microchip to use this software.                               *
;                                                                              *
;    MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF    *
;    THESE TERMS.                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Filename:                                                                 *
;    Date:                                                                     *
;    File Version:                                                             *
;    Author:                                                                   *
;    Company:                                                                  *
;    Description:                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Notes: In the MPLAB X Help, refer to the MPASM Assembler documentation    *
;    for information on assembly instructions.                                 *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Known Issues: This template is designed for relocatable code.  As such,   *
;    build errors such as "Directive only allowed when generating an object    *
;    file" will result when the 'Build in Absolute Mode' checkbox is selected  *
;    in the project properties.  Designing code in absolute mode is            *
;    antiquated - use relocatable mode.                                        *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Revision History:                                                         *
;                                                                              *
;*******************************************************************************



;*******************************************************************************
; Processor Inclusion
;
; TODO Step #1 Open the task list under Window > Tasks.  Include your
; device .inc file - e.g. #include <device_name>.inc.  Available
; include files are in C:\Program Files\Microchip\MPLABX\mpasmx
; assuming the default installation path for MPLAB X.  You may manually find
; the appropriate include file for your device here and include it, or
; simply copy the include generated by the configuration bits
; generator (see Step #2).
;
;*******************************************************************************

; TODO INSERT INCLUDE CODE HERE
    
    title	"Voltage read attempt"
    list	p=PIC18F45K22
    #include	"p18f45k22.inc"

;*******************************************************************************
;
; TODO Step #2 - Configuration Word Setup
;
; The 'CONFIG' directive is used to embed the configuration word within the
; .asm file. MPLAB X requires users to embed their configuration words
; into source code.  See the device datasheet for additional information
; on configuration word settings.  Device configuration bits descriptions
; are in C:\Program Files\Microchip\MPLABX\mpasmx\P<device_name>.inc
; (may change depending on your MPLAB X installation directory).
;
; MPLAB X has a feature which generates configuration bits source code.  Go to
; Window > PIC Memory Views > Configuration Bits.  Configure each field as
; needed and select 'Generate Source Code to Output'.  The resulting code which
; appears in the 'Output Window' > 'Config Bits Source' tab may be copied
; below.
;
;*******************************************************************************

; TODO INSERT CONFIG HERE

; <editor-fold defaultstate="collapsed" desc="Configuration Bits">
    
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

  ; </editor-fold>

;*******************************************************************************
;
; TODO Step #3 - Variable Definitions
;
; Refer to datasheet for available data memory (RAM) organization assuming
; relocatible code organization (which is an option in project
; properties > mpasm (Global Options)).  Absolute mode generally should
; be used sparingly.
;
; Example of using GPR Uninitialized Data
;
;   GPR_VAR        UDATA
;   MYVAR1         RES        1      ; User variable linker places
;   MYVAR2         RES        1      ; User variable linker places
;   MYVAR3         RES        1      ; User variable linker places
;
;   ; Example of using Access Uninitialized Data Section (when available)
;   ; The variables for the context saving in the device datasheet may need
;   ; memory reserved here.
;   INT_VAR        UDATA_ACS
;   W_TEMP         RES        1      ; w register for context saving (ACCESS)
;   STATUS_TEMP    RES        1      ; status used for context saving
;   BSR_TEMP       RES        1      ; bank select used for ISR context saving
;
;*******************************************************************************

; TODO PLACE VARIABLE DEFINITIONS GO HERE
  
    CBLOCK	0X00
	    ADCHIGH
	    ADCLOW
	    delayCounter1        ; I want to make a 10ms delay
	    delayCounter2
        sensor1
        sensor2
        sensor3
        sensor4
        sensor5
        temp
        loopvar
    ENDC

;*******************************************************************************
; Reset Vector
;*******************************************************************************

    org		0h			    ; processor reset vector
    GOTO	START			    ; go to beginning of program

;*******************************************************************************
; TODO Step #4 - Interrupt Service Routines
;
; There are a few different ways to structure interrupt routines in the 8
; bit device families.  On PIC18's the high priority and low priority
; interrupts are located at 0x0008 and 0x0018, respectively.  On PIC16's and
; lower the interrupt is at 0x0004.  Between device families there is subtle
; variation in the both the hardware supporting the ISR (for restoring
; interrupt context) as well as the software used to restore the context
; (without corrupting the STATUS bits).
;
; General formats are shown below in relocatible format.
;
;------------------------------PIC16's and below--------------------------------
;
; ISR       CODE    0x0004           ; interrupt vector location
;
;     <Search the device datasheet for 'context' and copy interrupt
;     context saving code here.  Older devices need context saving code,
;     but newer devices like the 16F#### don't need context saving code.>
;
;     RETFIE
;
;----------------------------------PIC18's--------------------------------------
;
; ISRHV     CODE    0x0008
;     GOTO    HIGH_ISR
; ISRLV     CODE    0x0018
;     GOTO    LOW_ISR
;
; ISRH      CODE                     ; let linker place high ISR routine
; HIGH_ISR
;     <Insert High Priority ISR Here - no SW context saving>
;     RETFIE  FAST
;
; ISRL      CODE                     ; let linker place low ISR routine
; LOW_ISR
;       <Search the device datasheet for 'context' and copy interrupt
;       context saving code here>
;     RETFIE
;
;*******************************************************************************

; TODO INSERT ISR HERE

;Interrupt Code  
    org		08h

    org		18h
    
    GOTO	ISR 
    
;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

START

;-------------------------------------------------
;		    INITIALIZATION
;-------------------------------------------------  

    ;<editor-fold defaultstate="collapsed" desc="Initialization">
    
    
    MOVLB   0X0F		    ;Tell PIC to work in bank where SFRs are
				    ;Because new PIC is fussy 

;Initialize Port E

    CLRF    PORTE 		; Initialize PORTA by clearing output data latches
    CLRF    LATE 		; Alternate method to clear output data latches
    CLRF    ANSELE 		; Configure I/O
    CLRF    TRISE		; All digital outputs
    
;Initialize Port B
    
    CLRF    PORTB 		; Initialize PORTA by clearing output data latches
    CLRF    LATB 		; Alternate method to clear output data latches
    CLRF    ANSELB 		; Configure I/O
    CLRF    TRISB		; All digital outputs
		    
				    
;Initialize clock speed    
    
    BSF	    OSCCON, IRCF0
    BCF	    OSCCON, IRCF1
    BSF	    OSCCON, IRCF2
    
;Initialize UART
   
    
    CALL    UART_SETUP
    
    
    MOVLB   0X00		    ;Go back to GPR after setup
				    ;Because new PIC is fussy code
    
    ; </editor-fold>
    
;-------------------------------------------------
;		    MAIN
;-------------------------------------------------  

    ;<editor-fold defaultstate="collapsed" desc="MAIN">
 
    ;<editor-fold defaultstate="collapsed" desc="Send Column Headers">

Headers:
    
    MOVLW   A'Q'
    CALL    SEND_BYTE
    
    MOVLW   A';'
    CALL    SEND_BYTE

    MOVLW   A'L'
    CALL    SEND_BYTE
    
    MOVLW   A';'
    CALL    SEND_BYTE
       
    MOVLW   A'M'
    CALL    SEND_BYTE
    
    MOVLW   A';'
    CALL    SEND_BYTE
       
    MOVLW   A'R'
    CALL    SEND_BYTE
    
    MOVLW   A';'
    CALL    SEND_BYTE
       
    MOVLW   A'P'
    CALL    SEND_BYTE
    
    MOVLW   A';'
    CALL    SEND_BYTE

    MOVLW   .13				;Send an enter
    CALL    SEND_BYTE
    
    GOTO    MAIN
    ; </editor-fold>     
    
    
MAIN:

    MOVLW   0x4 		
    MOVWF   PORTE

;    ;<editor-fold defaultstate="collapsed" desc="Read AN0 for testing">
;    
;;Send AN0 reading then send an enter to the serial port
;    
;    CALL    Read_AN0			;For Testing just read AN0
;    CALL    SEND_BYTE
;    
;;    MOVLW   '\n'				;Send an enter
;;    CALL    SEND_BYTE
;    
;    ; </editor-fold>
;    
;Send 5 sensor values to the serial port seperated by a semicolon, then send an enter for a newline
    
        ;<editor-fold defaultstate="collapsed" desc="Send 5 Sensor values">
    MOVLW   0x02
    MOVWF   loopvar
    MOVLW   0x0 
    MOVWF   temp
ave1:
    CALL    Read_AN12   ;reading is now in wreg
    RRNCF   WREG,w        ;divide wreg by 2
    BCF     WREG,7        ;clear first bit cause it rotates
    ADDWF   temp,f      ;add the two together
    decfsz  loopvar
    GOTO    ave1
    MOVF    temp,w
    BCF     WREG,0
    BCF     WREG,1
    CALL    SEND_BYTE
    
;    MOVLW   A';'
;    CALL    SEND_BYTE
    MOVLW   0x02
    MOVWF   loopvar
    MOVLW   0x0 
    MOVWF   temp
ave2:
    CALL    Read_AN10
    RRNCF   WREG,w        ;divide wreg by 2
    BCF     WREG,7        ;clear first bit cause it rotates
    ADDWF   temp,f      ;add the two together
    decfsz  loopvar
    GOTO    ave2
    MOVF    temp,w
    BCF     WREG,0
    BCF     WREG,1
    CALL    SEND_BYTE
    
;    MOVLW   A';'
;    CALL    SEND_BYTE
    MOVLW   0x02
    MOVWF   loopvar
    MOVLW   0x0 
    MOVWF   temp
ave3:
    CALL    Read_AN8
    RRNCF   WREG,w        ;divide wreg by 2
    BCF     WREG,7        ;clear first bit cause it rotates
    ADDWF   temp,f      ;add the two together
    decfsz  loopvar
    GOTO    ave3
    MOVF    temp,w
    BCF     WREG,0
    BCF     WREG,1
    CALL    SEND_BYTE
    
;    MOVLW   A';'
;    CALL    SEND_BYTE
    MOVLW   0x02
    MOVWF   loopvar
    MOVLW   0x0 
    MOVWF   temp
ave4:
    CALL    Read_AN9
    RRNCF   WREG,w        ;divide wreg by 2
    BCF     WREG,7        ;clear first bit cause it rotates
    ADDWF   temp,f      ;add the two together
    decfsz  loopvar
    GOTO    ave4
    MOVF    temp,w
    BCF     WREG,0
    BCF     WREG,1
    CALL    SEND_BYTE
    
;    MOVLW   A';'
;    CALL    SEND_BYTE
    MOVLW   0x02
    MOVWF   loopvar
    MOVLW   0x0 
    MOVWF   temp
ave5:
    CALL    Read_AN13
    RRNCF   WREG,w        ;divide wreg by 2
    BCF     WREG,7        ;clear first bit cause it rotates
    ADDWF   temp,f      ;add the two together
    decfsz  loopvar
    GOTO    ave5
    MOVF    temp,w
    BCF     WREG,0
    BCF     WREG,1
    CALL    SEND_BYTE
    
;    MOVLW   A';'
;    CALL    SEND_BYTE
    
    MOVLW   '\n'				;Send an enter
    CALL    SEND_BYTE
   
    ; </editor-fold>  
        
;    MOVLW   A'H'
;    CALL    SEND_BYTE
;    MOVLW   A'L'
;    CALL    SEND_BYTE
;    MOVLW   A'L'
;    CALL    SEND_BYTE
;    MOVLW   A'O'
;    CALL    SEND_BYTE
;    MOVLW   A'O'
;    CALL    SEND_BYTE
;    GOTO    $
    CALL    tenmsDelay
    
    GOTO MAIN
    
    ; </editor-fold> 
      
;-------------------------------------------------
;		    ADC Block
;-------------------------------------------------    
   
    ;<editor-fold defaultstate="collapsed" desc="ADC Block">  
    
;-------------------------------------------------
;		    ADC Read
;-------------------------------------------------
	
;<editor-fold defaultstate="collapsed" desc="ADC Read"> 	

;The ADC_Read function will, when it is called, read a value from the selectrd analog channel
;then it will store that value in a vaiable. The variable will then be sent to the TXREG.
;The TXREG should then send this value to the serial terminal of the computer connected to it.
;The aim of this function is to read the voltage levels from the sensors and output them sequentially on a serial terminal.

;ADC_Read:
		
    ;<editor-fold defaultstate="collapsed" desc="Read_AN0"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    


Read_AN0:

;poll to see if the TMRT is empty
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		Read_AN0
    
    CALL	ADC_SETUP_AN0		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

    ;add delay- if problems
				    
;Start conversion by setting the GO/DONE bit.

    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go0
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go0    
    
    ;RATHER USE POLL OF TMRT TO SEE IF ITS EMPTY
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		SEND_BYTE

    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it
    
;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF    	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    
    
;    CALL	SEND_BYTE		    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
;    MOVLW   A';'
;					    
;    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg

    
;    CALL	SEND_BYTE			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>				;RA0
		
    ;<editor-fold defaultstate="collapsed" desc="Read_AN12"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    


Read_AN12:

;poll to see if the TMRT is empty
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		Read_AN12
    
    CALL	ADC_SETUP_AN12		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

    ;add delay- if problems
				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go1
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go0    
    
    ;RATHER USE POLL OF TMRT TO SEE IF ITS EMPTY
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		SEND_BYTE

    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it
    
;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF    	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    
    
;    CALL	SEND_BYTE		    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
;    MOVLW   A';'
;					    
;    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg

    
;    CALL	SEND_BYTE			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>				;RB0
		
    ;<editor-fold defaultstate="collapsed" desc="Read_AN10"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    


Read_AN10:

;poll to see if the TMRT is empty
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		Read_AN10
    
    CALL	ADC_SETUP_AN10		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

    ;add delay- if problems
				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go2
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go1    
    
    ;RATHER USE POLL OF TMRT TO SEE IF ITS EMPTY
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		SEND_BYTE

    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it
    
;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF    	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    
    
;    CALL	SEND_BYTE		    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
;    MOVLW   A';'
;					    
;    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg

    
;    CALL	SEND_BYTE			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>				;RB1
		
    ;<editor-fold defaultstate="collapsed" desc="Read_AN8"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    


Read_AN8:

;poll to see if the TMRT is empty
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		Read_AN8
    
    CALL	ADC_SETUP_AN8		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

    ;add delay- if problems
				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go3
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go2    
    
    ;RATHER USE POLL OF TMRT TO SEE IF ITS EMPTY
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		SEND_BYTE

    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it
    
;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF    	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    
    
;    CALL	SEND_BYTE		    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
;    MOVLW   A';'
;					    
;    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg

    
;    CALL	SEND_BYTE			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>				;RB2
		
    ;<editor-fold defaultstate="collapsed" desc="Read_AN9"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    


Read_AN9:

;poll to see if the TMRT is empty
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		Read_AN9
    
    CALL	ADC_SETUP_AN9		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

    ;add delay- if problems
				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go4
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go3    
    
    ;RATHER USE POLL OF TMRT TO SEE IF ITS EMPTY
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		SEND_BYTE

    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it
    
;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF    	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    
    
;    CALL	SEND_BYTE		    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
;    MOVLW   A';'
;					    
;    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg

    
;    CALL	SEND_BYTE			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>				;RB3
		
    ;<editor-fold defaultstate="collapsed" desc="Read_AN13"> 	

;To read a value from multiple pins, one has to call the ADC setup function to select the desired channel to read from    


Read_AN13:

;poll to see if the TMRT is empty
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		Read_AN13
    
    CALL	ADC_SETUP_AN13		    ;Call ADC setup for reading analog input on pin AN0

;Wait the required acquisition time(2). - we dont want this now (0 seconds) 

    ;add delay- if problems
				    
;Start conversion by setting the GO/DONE bit.
    BSF		ADCON0, GO
				    
;Wait for ADC conversion to complete by one of the following: 
Poll_Go5
    BTFSC	ADCON0, GO		    ;Polling the GO/DONE bit - Checked if hardware cleared go				    
    BRA		Poll_Go5    
    
    ;RATHER USE POLL OF TMRT TO SEE IF ITS EMPTY
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		SEND_BYTE

    CLRF	ADCHIGH			    ;Clear ADCHIGH before reading values to it
    CLRF	ADCLOW			    ;Clear ADCLOW before reading values to it
    
;Read ADC Result and store the results in variables
    MOVF	ADRESH, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCHIGH			    ;The Wreg is moved to ADCHIGH so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF	ADRESL, 0		    ;The result stored in ADRESH is moved to Wreg
    MOVWF	ADCLOW			    ;The Wreg is moved to ADCLOW so the 
					    ;value of the analog pin is stored in a variable
    
    MOVF    	ADCHIGH, 0		    ;The result stored in the ADCHIGH variable is moved to Wreg
    
    
;    CALL	SEND_BYTE		    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    
;    MOVLW   A';'
;					    
;    MOVF	ADCLOW, 0		    ;The result stored in the ADCLOW variable is moved to Wreg

    
;    CALL	SEND_BYTE			    ;The Wreg is moved to TXREG so the 
					    ;value of the analog pin can be sent to the serial output
    RETURN
    
    ;</editor-fold>				;RB5
     
 
     
	RETURN
	
;</editor-fold>	
	
	
;</editor-fold>
	    
;-------------------------------------------------
;		Send Byte
;-------------------------------------------------

    ;<editor-fold defaultstate="collapsed" desc="Send Byte">
    
SEND_BYTE:
    
    BTFSS	TXSTA1, TRMT		    ;Check if TMRT is set, to ensure that shift register is empty (p263)
    BRA		SEND_BYTE
    
    MOVWF	TXREG1
    RETURN
    
    ;</editor-fold>
    
;-------------------------------------------------
;		UART Setup
;-------------------------------------------------
    
    ;<editor-fold defaultstate="collapsed" desc="UART Setup">
    
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
    
;9. Load 8-bit data into the TXREGx register. This will start the transmission.    


;</editor-fold> 
    
;-------------------------------------------------
;		ADC Setup
;-------------------------------------------------

    ;<editor-fold defaultstate="collapsed" desc="ADC Setup">
    
;Set up the ADC in such a way that there is a delay between channel select to allow capacitor discharge
    
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN0">
    
ADC_SETUP_AN0:

;Configure Port RA0:
    BSF    TRISA,   TRISA0  ;Disable pin output driver (See TRIS register) 	    
    BSF    ANSELA,  ANSA0   ;Configure pin as analog     
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
   CLRF	    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
;    BCF    TRIGSEL		    ;Do this bit by bit
;    BCF    PVCFG0		    ;so that you can be shure
;    BCF    PVCFG1		    ;that you cleared all of the 
;    BCF    NVCFG0		    ;bits in the register
;    BCF    NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS0	    ;Select AN0 - 00000
    BCF	    ADCON0, CHS1	    ;We must stull decide which chanel we are using for the practical
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS3
    BCF	    ADCON0, CHS4

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN12">
    
ADC_SETUP_AN12:

;Configure Port RB0:
    BSF    TRISB,   TRISB0  ;Disable pin output driver (See TRIS register) 	    
    BSF    ANSELB,  ANSB0   ;Configure pin as analog     
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
   CLRF	    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
;    BCF    TRIGSEL		    ;Do this bit by bit
;    BCF    PVCFG0		    ;so that you can be shure
;    BCF    PVCFG1		    ;that you cleared all of the 
;    BCF    NVCFG0		    ;bits in the register
;    BCF    NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS4	    ;Select AN12 - 01100
    BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
    BSF	    ADCON0, CHS2
    BCF	    ADCON0, CHS1
    BCF	    ADCON0, CHS0

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN10">
    
ADC_SETUP_AN10:

;Configure Port RB1:
    BSF    TRISB,   TRISB1  ;Disable pin output driver (See TRIS register) 	    
    BSF    ANSELB,  ANSB1   ;Configure pin as analog       
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
   CLRF	    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
;    BCF    TRIGSEL		    ;Do this bit by bit
;    BCF    PVCFG0		    ;so that you can be shure
;    BCF    PVCFG1		    ;that you cleared all of the 
;    BCF    NVCFG0		    ;bits in the register
;    BCF    NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS4	    ;Select AN10 - 01010
    BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
    BCF	    ADCON0, CHS2
    BSF	    ADCON0, CHS1
    BCF	    ADCON0, CHS0

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN8">
    
ADC_SETUP_AN8:

;Configure Port RB2:
    BSF    TRISB,   TRISB2  ;Disable pin output driver (See TRIS register) 	    
    BSF    ANSELB,  ANSB2   ;Configure pin as analog         
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
   CLRF	    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
;    BCF    TRIGSEL		    ;Do this bit by bit
;    BCF    PVCFG0		    ;so that you can be shure
;    BCF    PVCFG1		    ;that you cleared all of the 
;    BCF    NVCFG0		    ;bits in the register
;    BCF    NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS4	    ;Select AN8 - 01000
    BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS1
    BCF	    ADCON0, CHS0

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup A9">
    
ADC_SETUP_AN9:

;Configure Port RB3:
    BSF    TRISB,   TRISB3  ;Disable pin output driver (See TRIS register) 	    
    BSF    ANSELB,  ANSB3   ;Configure pin as analog         
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
   CLRF	    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
;    BCF    TRIGSEL		    ;Do this bit by bit
;    BCF    PVCFG0		    ;so that you can be shure
;    BCF    PVCFG1		    ;that you cleared all of the 
;    BCF    NVCFG0		    ;bits in the register
;    BCF    NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS4	    ;Select AN9 - 01001
    BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS1
    BSF	    ADCON0, CHS0

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
    
    ;<editor-fold defaultstate="collapsed" desc="ADC Setup AN13">
    
ADC_SETUP_AN13:

    
;Configure Port RB5:
    BSF    TRISB,   TRISB5  ;Disable pin output driver (See TRIS register) 	    
    BSF    ANSELB,  ANSB5   ;Configure pin as analog         
				    
    
;Configure the ADC module: 
    BCF	    ADCON2, ADCS0	    ;Select ADC conversion clock - Fosc/4
    BCF	    ADCON2, ADCS1	   	
    BSF	    ADCON2, ADCS2	    			    				    	    

;Configure voltage reference
    
   CLRF	    ADCON1		    ;Clear the adcon1 register - in a test do this bit by bit
				    ;Below it is done bit by bit
;    BCF    TRIGSEL		    ;Do this bit by bit
;    BCF    PVCFG0		    ;so that you can be shure
;    BCF    PVCFG1		    ;that you cleared all of the 
;    BCF    NVCFG0		    ;bits in the register
;    BCF    NVCFG1
    
    
;Select ADC input channel
    BCF	    ADCON0, CHS4	    ;Select AN11 - 01101
    BSF	    ADCON0, CHS3	    ;We must stull decide which chanel we are using for the practical
    BSF	    ADCON0, CHS2
    BCF	    ADCON0, CHS1
    BSF	    ADCON0, CHS0

;Select result format
    BCF	    ADCON2, ADFM	    ;Left Justify

;Select acquisition delay
    BSF	    ADCON2, ACQT0	    ;Set to 12 Tad
    BCF	    ADCON2, ACQT1
    BSF	    ADCON2, ACQT2

;Turn on ADC module
    BSF	    ADCON0, ADON
    
	RETURN

;link to read multiple ADC channels
;https://www.edaboard.com/showthread.php?265549-How-to-use-multiple-ADC-channels-for-pic18f452-controller

    ;</editor-fold>
    
    ;</editor-fold>

;-------------------------------------------------
;		ISR
;-------------------------------------------------

    ;<editor-fold defaultstate="collapsed" desc="ISR">
    
ISR:
    
    BCF	    PIR1,   RC1IF		    ;Make sure we have cleared the flag
    
    MOVLW   A'*'
    CALL    SEND_BYTE
    
    MOVF    RCREG1,  0
    
    CALL    SEND_BYTE
    
    RETFIE
    
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


fifusDelay:		
    movlw	0x0F
    movwf	delayCounter1
Go_on
    decfsz	delayCounter1,f	
    goto	Go_on	        ; (768+5) * 13 = 10049 instructions / 1M instructions per second = 10.05 ms.

    RETURN
    
    END