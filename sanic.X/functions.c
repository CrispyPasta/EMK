#include <pic18f45k22.h>    //remove this when done
#define whiteBit 0 
#define greenBit 1 
#define redBit   2 
#define blueBit  3 
#define blackBit 4 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GLOBAL VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
unsigned char size = 5;
unsigned char col = 'B';
//white, green, red, blue, black
unsigned char LLranges[] = {140, 168, 185, 185, 255};
unsigned char Lranges[] = {130, 178, 180, 188, 255};
unsigned char Mranges[] = {130, 165, 175, 188, 255};
unsigned char Rranges[] = {140, 170, 210, 175, 255};
unsigned char RRranges[] = {140, 185, 195, 195, 255};
unsigned char sensorVals[] = {255, 255, 255, 255, 255};
unsigned char raceColor[] = "00000000";    //initialize as none for now
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GLOBAL VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


void setupSerial(){
    PIE1bits.RC1IE = 0;
    PIE1bits.TX1IE = 0;
    PIR1bits.RCIF = 0;

    FSR0 = 0;
    TXSTA1 = 0b00100100;    //enable TXEN  en BRGH
    RCSTA1 = 0b10010000;    //enable serial port and continuous receive
    
    SPBRG1 = 25;
    SPBRGH1 = 0;
    BAUDCON1bits.BRG16 = 0;
    TRISCbits.RC6 = 1;      //tx is an output pin
    TRISCbits.RC7 = 1;      //rx is an input pin
    
    PORTC = 0;      //clear port
    ANSELC = 0;     //not analog
    return;
}

void trans(unsigned char s){
    while(!PIR1bits.TX1IF);     //wait for previous transmission to finish
    TXREG = s;                  //move character into txreg
    return;
}

//Does setup for ADC, default channel is AN12
void setupADC(){
    ADCON2bits.ADCS = 0b100;        //Fosc/4
    ADCON1 = 0;                     //configure voltage reference 
    ADCON0bits.CHS = 0b01100;       //default channel is AN12
    ADCON2bits.ADFM = 0;            //left justify 
    ADCON2bits.ACQT = 0b101;        //Acquisition delay = 12Tas
    ADCON0bits.ADON = 1;            //turn on the ADC module
    return;
}


//changes the ADC channel.
//Enter only number eg 15 for AN15
//LL = 12
//L  = 10
//M  = 8
//R  = 9
//RR = 13
//CT = 15
void setADCChannel(unsigned char channel){
    ADCON0bits.CHS = channel;       //select channel with this 

    switch (channel){
    case 8:
        TRISBbits.TRISB2 = 1;       //sensors
        ANSELBbits.ANSB2 = 1;      
        break;
    case 9:
        TRISBbits.TRISB3 = 1;       //disable digital output
        ANSELBbits.ANSB3 = 1;       //set pin as analog pin
        break;
    case 10:
        TRISBbits.TRISB1 = 1;
        ANSELBbits.ANSB1 = 1;
        break;
    case 12:
        TRISBbits.TRISB0 = 1;
        ANSELBbits.ANSB0 = 1;
        break;
    case 13:
        TRISBbits.TRISB5 = 1;
        ANSELBbits.ANSB5 = 1;
        break;
    case 15:
        TRISCbits.TRISC3 = 1;       //for touch start
        ANSELCbits.ANSC3 = 1;      
        break;
    
    default:
        TRISBbits.TRISB0 = 1;       //default to RB0 for no good reason
        ANSELBbits.ANSB0 = 1;       //default to RB0 for no good reason
        break;
    }
    return;
}

//Reads the ADC and returns the result
unsigned char readADC(){
    ADCON0bits.GO = 1;

    while (ADCON0bits.GO);  //wait for conversion to finish
    return ADRESH;
}

//This function returns the average sensor value 
unsigned char aveSensor(unsigned char s){
    setADCChannel(s);               //set the channel of the pin 
    unsigned int measurements = 0;

    for (unsigned char a = 0; a < 10; a++){
        measurements += readADC();
    }
    
    unsigned char result = measurements / 10;
    
    return result;
}

void setupPWMLeft(unsigned char dutyCycle, unsigned char direction){
    return;
}

void setupPWMRight(unsigned char dutyCycle, unsigned char direction){
    return;
}

void setupTimer2(unsigned char PR2Value){
    return;
}

//
//Hierdie function clear ports A - E, clear ook
//hulle TRIS and ANSEL registers
void clearPorts(){
    PORTA = 0;
    LATA = 0;
    TRISA = 0;
    ANSELA = 0;

    PORTB = 0;
    LATB = 0;
    TRISB = 0;
    ANSELB = 0;

    PORTC = 0;
    LATC = 0;
    TRISC = 0;
    ANSELC = 0;

    PORTD = 0;
    LATD = 0;
    TRISD = 0;
    ANSELD = 0;

    PORTE = 0;
    LATE = 0;
    TRISE = 0;
    ANSELE = 0;
    raceColor[blueBit] = 1; //blue is the default
    return;
}

//Stel die oscillator frequency, 4MHz
void setupOSC(){
    OSCCONbits.IRCF = 0b101;
    return;
}

//Determines the voltage ranges for color on each sensor
void calibrate(){
    PORTA = 0;
    unsigned char sensors[5] = {12, 8, 9, 10, 13};
    PORTD = 0b10000000;
    
    LLranges[blueBit] = aveSensor(12);
    Lranges[blueBit] = aveSensor(8);
    Mranges[blueBit] = aveSensor(9);
    Rranges[blueBit] = aveSensor(10);
    RRranges[blueBit] = aveSensor(13);
    PORTAbits.RA3 = 1;          //turn on the blue LED
    twoSecondDelay();
    
    LLranges[redBit] = aveSensor(12);
    Lranges[redBit] = aveSensor(8);
    Mranges[redBit] = aveSensor(9);
    Rranges[redBit] = aveSensor(10);
    RRranges[redBit] = aveSensor(13);
    PORTAbits.RA2 = 1;          //turn on the red LED
    twoSecondDelay();
    
    LLranges[greenBit] = aveSensor(12);
    Lranges[greenBit] = aveSensor(8);
    Mranges[greenBit] = aveSensor(9);
    Rranges[greenBit] = aveSensor(10);
    RRranges[greenBit] = aveSensor(13);
    PORTAbits.RA0 = 1;          //turn on the green LED
    twoSecondDelay();
    
    LLranges[whiteBit] = aveSensor(12);
    Lranges[whiteBit] = aveSensor(8);
    Mranges[whiteBit] = aveSensor(9);
    Rranges[whiteBit] = aveSensor(10);
    RRranges[whiteBit] = aveSensor(13);
    PORTAbits.RA4 = 1;          //turn on the white LED
    twoSecondDelay();
    
    LLranges[blackBit] = aveSensor(12);
    Lranges[blackBit] = aveSensor(8);
    Mranges[blackBit] = aveSensor(9);
    Rranges[blackBit] = aveSensor(10);
    RRranges[blackBit] = aveSensor(13);
    PORTAbits.RA4 = 1;          //turn on the black LED
    twoSecondDelay();
    
    return;
}

void ranges(){
    for (unsigned char a = 0; a < 4; a++){
        LLranges[a] = (LLranges[a] + LLranges[a+1]) / 2;
        Lranges[a] = (LLranges[a] + LLranges[a+1]) / 2;
        Mranges[a] = (LLranges[a] + LLranges[a+1]) / 2;
        Rranges[a] = (LLranges[a] + LLranges[a+1]) / 2;
        RRranges[a] = (LLranges[a] + LLranges[a+1]) / 2;
    }
    return;
}

//I actually have no idea how long this will take 
void twoSecondDelay(){
    for (unsigned char a = 0; a < 255; a++){
        for (unsigned char b = 0; b < 255; b++);
    }
}