#include <pic18f45k22.h>

// PIC18F45K22 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1H
#pragma config FOSC = INTIO67   // Oscillator Selection bits (Internal oscillator block)
#pragma config PLLCFG = OFF     // 4X PLL Enable (Oscillator used directly)
#pragma config PRICLKEN = ON    // Primary clock enable bit (Primary clock is always enabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
#pragma config IESO = OFF       // Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

// CONFIG2L
#pragma config PWRTEN = OFF     // Power-up Timer Enable bit (Power up timer disabled)
#pragma config BOREN = SBORDIS  // Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
#pragma config BORV = 190       // Brown Out Reset Voltage bits (VBOR set to 1.90 V nominal)

// CONFIG2H
#pragma config WDTEN = OFF      // Watchdog Timer Enable bits (Watch dog timer is always disabled. SWDTEN has no effect.)
#pragma config WDTPS = 32768    // Watchdog Timer Postscale Select bits (1:32768)

// CONFIG3H
#pragma config CCP2MX = PORTC1  // CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
#pragma config PBADEN = ON      // PORTB A/D Enable bit (PORTB<5:0> pins are configured as analog input channels on Reset)
#pragma config CCP3MX = PORTB5  // P3A/CCP3 Mux bit (P3A/CCP3 input/output is multiplexed with RB5)
#pragma config HFOFST = ON      // HFINTOSC Fast Start-up (HFINTOSC output and ready status are not delayed by the oscillator stable status)
#pragma config T3CMX = PORTC0   // Timer3 Clock input mux bit (T3CKI is on RC0)
#pragma config P2BMX = PORTD2   // ECCP2 B output mux bit (P2B is on RD2)
#pragma config MCLRE = EXTMCLR  // MCLR Pin Enable bit (MCLR pin enabled, RE3 input pin disabled)

// CONFIG4L
#pragma config STVREN = ON      // Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
#pragma config LVP = ON         // Single-Supply ICSP Enable bit (Single-Supply ICSP enabled if MCLRE is also 1)
#pragma config XINST = OFF      // Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

// CONFIG5L
#pragma config CP0 = OFF        // Code Protection Block 0 (Block 0 (000800-001FFFh) not code-protected)
#pragma config CP1 = OFF        // Code Protection Block 1 (Block 1 (002000-003FFFh) not code-protected)
#pragma config CP2 = OFF        // Code Protection Block 2 (Block 2 (004000-005FFFh) not code-protected)
#pragma config CP3 = OFF        // Code Protection Block 3 (Block 3 (006000-007FFFh) not code-protected)

// CONFIG5H
#pragma config CPB = OFF        // Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
#pragma config CPD = OFF        // Data EEPROM Code Protection bit (Data EEPROM not code-protected)

// CONFIG6L
#pragma config WRT0 = OFF       // Write Protection Block 0 (Block 0 (000800-001FFFh) not write-protected)
#pragma config WRT1 = OFF       // Write Protection Block 1 (Block 1 (002000-003FFFh) not write-protected)
#pragma config WRT2 = OFF       // Write Protection Block 2 (Block 2 (004000-005FFFh) not write-protected)
#pragma config WRT3 = OFF       // Write Protection Block 3 (Block 3 (006000-007FFFh) not write-protected)

// CONFIG6H
#pragma config WRTC = OFF       // Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
#pragma config WRTB = OFF       // Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
#pragma config WRTD = OFF       // Data EEPROM Write Protection bit (Data EEPROM not write-protected)

// CONFIG7L
#pragma config EBTR0 = OFF      // Table Read Protection Block 0 (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
#pragma config EBTR1 = OFF      // Table Read Protection Block 1 (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
#pragma config EBTR2 = OFF      // Table Read Protection Block 2 (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
#pragma config EBTR3 = OFF      // Table Read Protection Block 3 (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

// CONFIG7H
#pragma config EBTRB = OFF      // Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include "functions.h"
#include "functions.c"

void init(void);
void RCE(void);


void main(void)
{
    // unsigned int x;
    // TRISA = 0;
    // PORTA = 0;
    // ANSELA = 0;
    // unsigned char bits = 0b101;
    // OSCCONbits.IRCF = bits;
    // unsigned char message[] = "Gotta go fast";

    // for (x = 0; x < 13; x++){
    //     delay();
    //     // PORTAbits.RA7 = !PORTAbits.RA7;
    //     PORTA = message[x];
    // }

    // while(1);       //hang here forever
    init();
    RCE();
    while(1);
    // setupADC();
    // while(1){
    //     PORTA = aveSensor(12);
    //     trans(PORTA);
    //     trans('\n');
    // }

}

void init(){
    raceColor[blueBit] = 1;     //set default color 
    setupOSC();
    clearPorts();
    setupSerial();
    setupADC();
}

void RCE(){
    while(1){
        PORTD = 0b10100100; //show in 7seg
        
        unsigned char message[] = "\nSanic races ";

        for (unsigned char a = 0; a < 13; a++)
        {
            trans(message[a]);
        }

        if (raceColor[blueBit] == 1){
            trans('B');
        }
        else if (raceColor[redBit] == 1){
            trans('R');  
        }
        else if (raceColor[greenBit] == 1){
            trans('G');
        }
        else {
            trans('n');
        }
        trans('\n');
        

        INTCONbits.GIE = 0;     //disable global interrupts
        INTCONbits.PEIE = 0;    //disable peripheral interrupts 
        unsigned char nCharsReceived = 0;        //init to 0
        unsigned char commandReceived[3];

        while(nCharsReceived < 3){
            if (PIR1bits.RC1IF){
                commandReceived[nCharsReceived] = RCREG;        //save received character
                nCharsReceived++;       //inc num chars received
            }
        }


        switch (commandReceived[0])
        {
        case 'R':
            capTouch(); 
            break;
        case 'P':
            PRC();
            break;
        case 'N':
            navigate();
            break;
        case 'Q':
            pyCal(); 
            break;
        case 'C':
            calibrate();  
            break;
        
        default:
            error();
            break;
        }
        
        for (unsigned char a = 0; a < 3; a++){
            commandReceived[a] = 0;
        }
        nCharsReceived = 0;
    }
    return;
}

