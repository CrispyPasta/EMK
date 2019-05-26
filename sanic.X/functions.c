#include <pic18f45k22.h> //remove this when done
#define whiteBit 0
#define greenBit 1
#define redBit 2
#define blueBit 3
#define blackBit 4

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GLOBAL VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
unsigned char size = 5;
unsigned char col = 'B';
//white, green, red, blue, black
unsigned char LLranges[] = {140, 168, 185, 185, 255};
unsigned char Lranges[] = {130, 178, 180, 188, 255};
unsigned char Mranges[] = {130, 165, 175, 188, 255};
unsigned char Rranges[] = {140, 170, 175, 210, 255};
unsigned char RRranges[] = {140, 185, 195, 195, 255};
unsigned char sensorVals[] = {120, 170, 170, 190, 250};
unsigned char raceColor[] = "00001000"; //initialize as blue for now
unsigned char sensorChannels[] = {12, 10, 8, 9, 13, 15};
unsigned char colorsDetected[] = {0, 0, 0, 0, 0};
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GLOBAL VARIABLES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//###############SETUP FUNCTIONS##################
void setupPWMLeft()
{
    CCP1CON = 0; //clear
    PR2 = 255;
    CCPR1L = 255; //init as 100%

    TRISCbits.RC2 = 0; //enable PWM output

    CCPTMRS0 = 0; //select timer 2, default
    CCP1CON = 0b00001100;
    T2CON = 0b00000000; //1 prescale, 1 postscale, timer off
    TMR2 = 0;            //clear timer
    PIE1bits.TMR1IE = 0; //disable timer interrupts
    T2CONbits.TMR2ON = 1; //turn timer on
    return;
}

void setupPWMRight()
{
    CCP5CON = 0; //clear
    PR4 = 255;
    CCPR5L = 255; //init as 100%

    TRISEbits.RE2 = 0; //enable PWM output

    CCPTMRS1 = 0b00000100; //select timer 4
    CCP5CON = 0b00001100;
    T4CON = 0b00000000; //1 prescale, 1 postscale, timer off
    TMR4 = 0;            //clear timer
    PIE5bits.TMR4IE = 0; //disable timer interrupts
    T4CONbits.TMR4ON = 1; //turn timer on
    return;
}

//Hierdie function clear ports A - E, clear ook
//hulle TRIS and ANSEL registers
void clearPorts()
{
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
void setupOSC()
{
    OSCCONbits.IRCF = 0b101;
    return;
}

void setupSerial()
{
    PIE1bits.RC1IE = 0;
    PIE1bits.TX1IE = 0;
    PIR1bits.RCIF = 0;

    FSR0 = 0;
    TXSTA1 = 0b00100100; //enable TXEN  en BRGH
    RCSTA1 = 0b10010000; //enable serial port and continuous receive

    SPBRG1 = 25;
    SPBRGH1 = 0;
    BAUDCON1bits.BRG16 = 0;
    TRISCbits.RC6 = 1; //tx is an output pin
    TRISCbits.RC7 = 1; //rx is an input pin

    PORTC = 0;  //clear port
    ANSELC = 0; //not analog
    return;
}

//Does setup for ADC, default channel is AN12
//However, AN12's pin will not be set up
void setupADC()
{
    ADCON2bits.ADCS = 0b100;  //Fosc/4
    ADCON1 = 0;               //configure voltage reference
    ADCON0bits.CHS = 0b01100; //default channel is AN12
    ADCON2bits.ADFM = 0;      //left justify
    ADCON2bits.ACQT = 0b101;  //Acquisition delay = 12Tas
    ADCON0bits.ADON = 1;      //turn on the ADC module
    return;
}
//###############SETUP FUNCTIONS##################




//###############STATE FUNCTIONS##################
//Determines the voltage ranges for color on each sensor
//order is white, green, red, blue, black
void calibrate()
{
    unsigned char *rangeArray[] = {LLranges, Lranges, Mranges, Rranges, RRranges};
    for (unsigned char a = 0; a < 5; a++)
    {
        for (unsigned char b = 0; b < 5; b++)
        {
            rangeArray[a][b] = 0;   //reset all voltage ranges 
        }
    }

    PORTA = 0;
    unsigned char sensors[5] = {12, 8, 9, 10, 13};
    unsigned char temp = 0;

    PORTD = 0b11000001;
    oneSecDelay();
    oneSecDelay();
    for (unsigned char samples = 0; samples < 250; samples++)
    {
        temp = aveSensor(12);
        if (temp >= LLranges[whiteBit])
        {
            LLranges[whiteBit] = temp;
        }
        temp = aveSensor(10);
        if (temp >= Lranges[whiteBit])
        {
            Lranges[whiteBit] = temp;
        }
        temp = aveSensor(8);
        if (temp >= Mranges[whiteBit])
        {
            Mranges[whiteBit] = temp;
        }
        temp = aveSensor(9);
        if (temp >= Rranges[whiteBit])
        {
            Rranges[whiteBit] = temp;
        }
        temp = aveSensor(13);
        if (temp >= RRranges[whiteBit])
        {
            RRranges[whiteBit] = temp;
        }
    }
    PORTAbits.RA0 = 1; //turn on the white LED
    PORTD = 0b10000010;

    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    for (unsigned char samples = 0; samples < 250; samples++)
    {
        temp = aveSensor(12);
        if (temp >= LLranges[greenBit])
        {
            LLranges[greenBit] = temp;
        }
        temp = aveSensor(10);
        if (temp >= Lranges[greenBit])
        {
            Lranges[greenBit] = temp;
        }
        temp = aveSensor(8);
        if (temp >= Mranges[greenBit])
        {
            Mranges[greenBit] = temp;
        }
        temp = aveSensor(9);
        if (temp >= Rranges[greenBit])
        {
            Rranges[greenBit] = temp;
        }
        temp = aveSensor(13);
        if (temp >= RRranges[greenBit])
        {
            RRranges[greenBit] = temp;
        }
    }
    PORTAbits.RA1 = 1; //turn on the green LED
    PORTD = 0b10001000;

    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    for (unsigned char samples = 0; samples < 250; samples++)
    {
        temp = aveSensor(12);
        if (temp >= LLranges[redBit])
        {
            LLranges[redBit] = temp;
        }
        temp = aveSensor(10);
        if (temp >= Lranges[redBit])
        {
            Lranges[redBit] = temp;
        }
        temp = aveSensor(8);
        if (temp >= Mranges[redBit])
        {
            Mranges[redBit] = temp;
        }
        temp = aveSensor(9);
        if (temp >= Rranges[redBit])
        {
            Rranges[redBit] = temp;
        }
        temp = aveSensor(13);
        if (temp >= RRranges[redBit])
        {
            RRranges[redBit] = temp;
        }
    }
    PORTAbits.RA2 = 1; //turn on the red LED
    PORTD = 0b10000000;

    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    for (unsigned char samples = 0; samples < 250; samples++)
    {
        temp = aveSensor(12);
        if (temp >= LLranges[blueBit])
        {
            LLranges[blueBit] = temp;
        }
        temp = aveSensor(10);
        if (temp >= Lranges[blueBit])
        {
            Lranges[blueBit] = temp;
        }
        temp = aveSensor(8);
        if (temp >= Mranges[blueBit])
        {
            Mranges[blueBit] = temp;
        }
        temp = aveSensor(9);
        if (temp >= Rranges[blueBit])
        {
            Rranges[blueBit] = temp;
        }
        temp = aveSensor(13);
        if (temp >= RRranges[blueBit])
        {
            RRranges[blueBit] = temp;
        }
    }
    PORTAbits.RA3 = 1; //turn on the blue LED
    PORTD = 0b11001000;

    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    oneSecDelay();
    for (unsigned char samples = 0; samples < 250; samples++)
    {
        temp = aveSensor(12);
        if (temp >= LLranges[blackBit])
        {
            LLranges[blackBit] = temp;
        }
        temp = aveSensor(10);
        if (temp >= Lranges[blackBit])
        {
            Lranges[blackBit] = temp;
        }
        temp = aveSensor(8);
        if (temp >= Mranges[blackBit])
        {
            Mranges[blackBit] = temp;
        }
        temp = aveSensor(9);
        if (temp >= Rranges[blackBit])
        {
            Rranges[blackBit] = temp;
        }
        temp = aveSensor(13);
        if (temp >= RRranges[blackBit])
        {
            RRranges[blackBit] = temp;
        }
    }
    PORTAbits.RA4 = 1; //turn on the black LED

    ranges();       //call ranges
    PORTA = 0;      //clear the port when done 
    return;
}

void PRC()
{
    PORTD = 0b11111001; //show on 7seg
    while (1)
    {
        unsigned char message[] = "\nWhat color should sanic race?\n";
        unsigned char message2[] = "\nSet";

        for (unsigned char a = 0; a < 31; a++)
        {
            trans(message[a]);
        }

        while (!PIR1bits.RC1IF);

        switch (RCREG){
        case 'B':
            for (unsigned char a = 0; a < 8; a++)
            {
                raceColor[a] = 0;
            }
            raceColor[blueBit] = 1;
            for (unsigned char a = 0; a < 4; a++)
            {
                trans(message2[a]);
            }
            return;
            break;
        case 'G':
            for (unsigned char a = 0; a < 8; a++)
            {
                raceColor[a] = 0;
            }
            raceColor[greenBit] = 1;
            for (unsigned char a = 0; a < 4; a++)
            {
                trans(message2[a]);
            }
            return;
            break;
        case 'R':
            for (unsigned char a = 0; a < 8; a++)
            {
                raceColor[a] = 0;
            }
            raceColor[redBit] = 1;
            for (unsigned char a = 0; a < 4; a++)
            {
                trans(message2[a]);
            }
            return;
            break;
        case 'n':
            for (unsigned char a = 0; a < 8; a++)
            {
                raceColor[a] = 0;
            }
            raceColor[blackBit] = 1;
            for (unsigned char a = 0; a < 4; a++)
            {
                trans(message2[a]);
            }
            return;
            break;

        default:
            error();
            continue;
            break;
        }

        return;
    } //while not done
}

void pyCal()
{
    setupADC();
    PORTD = 0b00001100;
    unsigned char done = 0;
    while (1)
    {
        msDelay(10); //delay 10ms between transmissions
        for (unsigned char a = 0; a < 5; a++)
        {
            trans(aveSensor(sensorChannels[a]));
        }
        trans('\n');

        if (PIR1bits.RC1IF)
        {
            PIR1bits.RC1IF = 0; //clear the flag
            if (RCREG == 'S' || RCREG == 's')
            {
                return;
            }
        }
    }
}

void navigate(){
    displayRaceColor();         //this should remain constant
    setupPWMLeft();
    setupPWMRight();
    setupADC();             //call just in case 
    while(1){                   //repeat until some stop condition
        readAllSensors();
        classifyColors();
        displayColorDetected(2);
        determineDirection();
        // msDelay(50);            //sit hierdies by vir bietjie latency 


        if (PIR1bits.RC1IF)     //stop condition
        {
            PIR1bits.RC1IF = 0; //clear the flag
            if (RCREG == 'S' || RCREG == 's')
            {
                stopMotors();
                return;
            }
        } else if (testBlack() == 0xAA){
            stopMotors();
            return;
        }  //end if RC1IF
    }//end while
}

void capTouch(){

    unsigned char message[] = "\nSanic waits for a touch\n";

    for (unsigned char a = 0; a < 25; a++)
    {
        trans(message[a]);
    }

    signed int change  = 0;
    unsigned char touch1 = 0;
    unsigned char touch2 = 0;

    while(1){
        touch1 = aveSensor(15);
        msDelay(5);
        touch2 = aveSensor(15);
        // trans(touch1);
        // trans(touch2);

        if (abs(touch2 - touch1) > 50){
            return;
        } else {
            touch1 = touch2 = 0;        //reset the bad bois
        }
    }
    return;
}

void searchMode(){
    timer1setup();
    while(!PIR1bits.TMR1IF){
        PORTAbits.RA5 = 1;
        PORTAbits.RA6 = 1;
        PORTAbits.RA7 = 1;
    }
    return;
}
//###############STATE FUNCTIONS##################




//###############UTILITY FUNCTIONS##################
void straight(){
    PORTAbits.RA5 = 1;  //indicate straight
    PORTAbits.RA6 = 0;  //indicate right
    PORTAbits.RA7 = 0;  //indicate left

    PORTCbits.RC0 = 0;
    PORTCbits.RC1 = 1;

    PORTEbits.RE0 = 0;
    PORTEbits.RE1 = 1;

    CCPR1L = 250;        
    CCPR5L = 250;
}

void left(){
    PORTAbits.RA5 = 0;  //indicate straight
    PORTAbits.RA6 = 0;  //indicate right
    PORTAbits.RA7 = 1;  //indicate left

    PORTCbits.RC0 = 0;
    PORTCbits.RC1 = 1;

    PORTEbits.RE0 = 0;
    PORTEbits.RE1 = 1;

    CCPR1L = 100;      
    CCPR5L = 200;
    return;
}

void hardLeft(){
    PORTAbits.RA5 = 0;  //indicate straight
    PORTAbits.RA6 = 0;  //indicate right
    PORTAbits.RA7 = 1;  //indicate left

    PORTCbits.RC0 = 1;
    PORTCbits.RC1 = 0;

    PORTEbits.RE0 = 0;
    PORTEbits.RE1 = 1;

    CCPR1L = 20;
    CCPR5L = 100;
    return;
}

void right(){
    PORTAbits.RA5 = 0;  //indicate straight
    PORTAbits.RA6 = 1;  //indicate right
    PORTAbits.RA7 = 0;  //indicate left

    PORTCbits.RC0 = 0;
    PORTCbits.RC1 = 1;

    PORTEbits.RE0 = 0;
    PORTEbits.RE1 = 1;

    CCPR1L = 200; 
    CCPR5L = 100;
    return;
}

void hardRight(){
    PORTAbits.RA5 = 0;  //indicate straight
    PORTAbits.RA6 = 1;  //indicate right
    PORTAbits.RA7 = 0;  //indicate left

    PORTCbits.RC0 = 0;
    PORTCbits.RC1 = 1;

    PORTEbits.RE0 = 0;
    PORTEbits.RE1 = 1;

    CCPR1L = 100;
    CCPR5L = 0;
    return;
}

void reverse(){
    PORTCbits.RC0 = 1;
    PORTCbits.RC1 = 0;

    PORTEbits.RE0 = 1;
    PORTEbits.RE1 = 0;

    CCPR1L = 100;
    CCPR5L = 100;
    return;
}

void turn45p(){
    PORTAbits.RA5 = 1;  //indicate search
    PORTAbits.RA6 = 1;
    PORTAbits.RA7 = 1;

    PORTCbits.RC0 = 1;
    PORTCbits.RC1 = 0;

    PORTEbits.RE0 = 0;
    PORTEbits.RE1 = 1;

    CCPR1L = 100;
    CCPR5L = 100;

    msDelay(50);
    return;
}

void turn45n(){
    PORTAbits.RA5 = 1;  //indicate search
    PORTAbits.RA6 = 1;
    PORTAbits.RA7 = 1;

    PORTCbits.RC0 = 0;
    PORTCbits.RC1 = 1;

    PORTEbits.RE0 = 1;
    PORTEbits.RE1 = 0;

    CCPR1L = 100;
    CCPR5L = 100;
    return;
}


void determineDirection(){
    //check of race color detected by enige sensor
    //as nie, kyk na relative voltage levels
    static unsigned char rc = 0;
    if (rc == 0){
        if (raceColor[whiteBit])
        {
            rc = 'W';
        }
        else if (raceColor[greenBit])
        {
            rc = 'G';
        }
        else if (raceColor[redBit])
        {
            rc = 'B';       //call red and blue blue because we can't be sure
        }
        else if (raceColor[blueBit])
        {
            rc = 'B';       //call red and blue blue because we can't be sure
        }
        else if (raceColor[blackBit])
        {
            rc = 'n';
        }   //ek weet hierdie is super dom, maar ek wil nie oorskakel van die goed wat reeds werk nie
    }

    if (colorsDetected[2] == rc){   //middle sensor
        straight();
    }
    else if (colorsDetected[1] == rc){  //left 
        left();
    }
    else if (colorsDetected[3] == rc){  //right 
        right();
    }
    else if (colorsDetected[0] == rc){  //left left
        hardLeft();
    }
    else if (colorsDetected[4] == rc){  //right right 
        hardRight();
    }
    else {          //race color not detected anywhere
        searchMode();
    }
    return;
}

//Returns '0xAA' if all sensors are reading black 
unsigned char testBlack(){
    if ((sensorVals[0] < LLranges[3]) || (sensorVals[0] < LLranges[2])){       //check if higher than blue
        return 0x0;
    }
    if ((sensorVals[1] < Lranges[3]) || (sensorVals[1] < Lranges[2])){
        return 0x0;
    }
    if ((sensorVals[2] < Mranges[3]) || (sensorVals[2] < Mranges[2])){
        return 0x0;
    }
    if ((sensorVals[3] < Rranges[3]) || (sensorVals[3] < Rranges[2])){
        return 0x0;
    }
    if ((sensorVals[4] < RRranges[3]) || (sensorVals[4] < RRranges[2])){
        return 0x0;
    }
    return 0xAA;        //this means there's black everywhere 
}

//fills the colorsDetected array 
//W = white, R = red, G = green, B = blue, n = black
void classifyColors(){
    unsigned char* sensorRanges[] = {LLranges, Lranges, Mranges, Rranges, RRranges};

    for (unsigned char a = 0; a < 5; a++){
        if (sensorVals[a] < sensorRanges[a][1]){    //white
            colorsDetected[a] = 'W';
        }
        else if ((sensorVals[a] < sensorRanges[a][2]) || (sensorVals[a] < sensorRanges[a][3])){       //green
            colorsDetected[a] = 'G';
        }
        else if (sensorVals[a] < sensorRanges[a][4]){       //blue
            colorsDetected[a] = 'B';
        }
        else{
            colorsDetected[a] = 'n';        //black
        }
    }
    return;
}

//lights up an LED indicating the color detected by a sensor
//sensor = 0, 1, 2, 3, 4 = LL, L, M, R, RR
void displayColorDetected(unsigned char sensor){
    switch (colorsDetected[sensor])
    {
    case 'W':
        PORTAbits.RA0 = 1;      //white
        PORTAbits.RA1 = 0;      //green
        PORTAbits.RA2 = 0;      //red
        PORTAbits.RA3 = 0;      //blue
        PORTAbits.RA4 = 0;      //black
        break;
    case 'G':
        PORTAbits.RA0 = 0;      //white
        PORTAbits.RA1 = 1;      //green
        PORTAbits.RA2 = 0;      //red
        PORTAbits.RA3 = 0;      //blue
        PORTAbits.RA4 = 0;      //black
        break;
    case 'R':
        PORTAbits.RA0 = 0;      //white
        PORTAbits.RA1 = 0;      //green
        PORTAbits.RA2 = 1;      //red
        PORTAbits.RA3 = 0;      //blue
        PORTAbits.RA4 = 0;      //black
        break;
    case 'B':
        PORTAbits.RA0 = 0;      //white
        PORTAbits.RA1 = 0;      //green
        PORTAbits.RA2 = 0;      //red
        PORTAbits.RA3 = 1;      //blue
        PORTAbits.RA4 = 0;      //black
        break;
    case 'n':
        PORTAbits.RA0 = 0;      //white
        PORTAbits.RA1 = 0;      //green
        PORTAbits.RA2 = 0;      //red
        PORTAbits.RA3 = 0;      //blue
        PORTAbits.RA4 = 1;      //black
        break;
    
    default:        //something is wrong, no valid code found
        PORTAbits.RA0 = 1; //white
        PORTAbits.RA1 = 1; //green
        PORTAbits.RA2 = 1; //red
        PORTAbits.RA3 = 1; //blue
        PORTAbits.RA4 = 1; //black
        break;
    }
    return;
}

//Sets PWM TRIS bits
//Clears motor control output pins
//Clears PORTA
void stopMotors(){
    PORTCbits.RC0 = 0;      //same output on both pins
    PORTCbits.RC1 = 0;
    TRISCbits.TRISC2 = 1;   //disable output on pin
    PORTEbits.RE0 = 0;      //same output on both pins
    PORTEbits.RE1 = 0;
    TRISEbits.TRISE2 = 1;   //disable output on pin
    PORTA = 0;
    return;
}

//displays the racing color on the 7seg
void displayRaceColor(){
    if (raceColor[whiteBit]){
        PORTD = 0b10111111;     //turn on the middle thingie
    } 
    else if (raceColor[greenBit]){
        PORTD = 0b10000010;
    }
    else if (raceColor[redBit]){
        PORTD = 0b10001000;
    }
    else if (raceColor[blueBit]){
        PORTD = 0b10000000;
    }
    else if (raceColor[blackBit]){
        PORTD = 0b11001000;
    }
    return;
}

//reads sensor values into the sensorVals array
void readAllSensors(){
    for (unsigned a  = 0; a < 5; a++){
        sensorVals[a] = aveSensor(sensorChannels[a]);
    }
    return;
}

void trans(unsigned char s)
{
    while (!PIR1bits.TX1IF)
        ;      //wait for previous transmission to finish
    TXREG = s; //move character into txreg
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
void setADCChannel(unsigned char channel)
{
    ADCON0bits.CHS = channel; //select channel with this

    switch (channel)
    {
    case 8:
        TRISBbits.TRISB2 = 1; //sensors
        ANSELBbits.ANSB2 = 1;
        break;
    case 9:
        TRISBbits.TRISB3 = 1; //disable digital output
        ANSELBbits.ANSB3 = 1; //set pin as analog pin
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
        TRISCbits.TRISC3 = 1; //for touch start
        ANSELCbits.ANSC3 = 1;
        break;

    default:
        TRISBbits.TRISB0 = 1; //default to RB0 for no good reason
        ANSELBbits.ANSB0 = 1; //default to RB0 for no good reason
        break;
    }

    return;
}

//Reads the ADC and returns the result
unsigned char readADC()
{
    ADCON0bits.GO = 1;

    while (ADCON0bits.GO)
        ; //wait for conversion to finish
    return ADRESH;
}

//This function returns the average sensor value
unsigned char aveSensor(unsigned char s)
{
    setADCChannel(s); //set the channel of the pin
    unsigned int measurements = 0;

    for (unsigned char a = 0; a < 4; a++)
    {
        measurements += readADC();
    }

    unsigned char result = measurements / 4;

    return result;
}

void ranges()
{
    unsigned char* rangeArray[] = {LLranges, Lranges, Mranges, Rranges, RRranges};
    LLranges[0] += 10;
    LLranges[1] += 5;
    LLranges[2] += 10;
    LLranges[3] += 0;
    LLranges[4] += 0;

    Lranges[0] += 10;
    Lranges[1] += 10;
    Lranges[2] += 10;
    Lranges[3] += 0;
    Lranges[4] += 0;

    Mranges[0] += 10;
    Mranges[1] += 10;
    Mranges[2] += 0;
    Mranges[3] += 0;
    Mranges[4] += 0;

    Rranges[0] += 10;
    Rranges[1] += 10;
    Rranges[2] += 0;
    Rranges[3] += 0;
    Rranges[4] += 0;

    RRranges[0] += 10;
    RRranges[1] += 10;
    RRranges[2] += 0;
    RRranges[3] += 0;
    RRranges[4] += 0;


    for (unsigned char a = 0; a < 5; a++){
        for (unsigned char b = 0; b < 5; b++){
            trans(rangeArray[a][b]);
        }
        trans('\n');
    }

    return;
}

void error()
{
    unsigned char message[] = "ERROR\n";

    for (unsigned char a = 0; a < 6; a++)
    {
        trans(message[a]);
    }

    RCREG = 0;  //clear RCREG
}
//###############UTILITY FUNCTIONS##################



//################DELAY FUNCTIONS###################
void oneSecDelay()
{
    for (unsigned char a = 0; a < 15; a++)
    {
        msDelay(63);
    }
}

//call to wait for the desired delay up to 65ms
//65 ms is eintlik 64.8ms
void msDelay(unsigned char delayInMs)
{
    TMR6 = 0;   //clear the timer 
    PR6 = 4 * delayInMs;
    T6CON = 0xFF; //16 pre, 16 post, timer on

    while (!PIR5bits.TMR6IF);
    PIR5bits.TMR6IF = 0; //clear the flag
    T6CON = 0;
    return;
}

//Sets up the timer and lets it run. Interrupt flag must 
//be cleared manually. Does not enable interrupts 
void timer6Setup(unsigned char delayInMs)
{
    TMR6 = 0;   //clear the timer 
    PR6 = 3.90625 * delayInMs;
    T6CON = 0xFF; //16 pre, 16 post, timer on
    return;
}

void timer1setup(){
    T1CON = 0b00110010;         //8 prescaler, timer off 
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    PIE1bits.TMR1IE = 1;        //enable timer interrupt
    PIR1bits.TMR1IF = 0;        //clear at the beginning
    TMR1 = 0;                   //clear the timer
    T1CONbits.TMR1ON = 1;       //turn on the timer 
    return;
}

void stopTimer1(){
    PIE1bits.TMR1IE = 0;
}