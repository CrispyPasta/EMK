#ifndef FUNCTIONS_H
#define FUNCTIONS_H

//###############SETUP FUNCTIONS##################
void setupPWMLeft();
void setupPWMRight();
void clearPorts(void);
void setupOSC();
void setupSerial();
void setupADC();
//###############SETUP FUNCTIONS##################

//###############STATE FUNCTIONS##################
void calibrate(void);
void PRC(void);
void pyCal(void);
void navigate();
void capTouch();
void searchMode();
//###############STATE FUNCTIONS##################

//##############UTILITY FUNCTIONS#################
void straight();
void left();
void hardLeft();
void right();
void hardRight();
void reverse();
void turn45p(); //turn 45 degrees positive (anticlockwise)
void turn45n(); //turn 45 degrees negative (clockwise)
void determineDirection();
unsigned char testBlack();
void classifyColors();
void displayColorDetected(unsigned char sensor);
void stopMotors();
void displayRaceColor();
void readAllSensors();
void trans(unsigned char s);
void setADCChannel(unsigned char channel);
unsigned char readADC();
unsigned char aveSensor(unsigned char s);
void ranges();
void error();
//##############UTILITY FUNCTIONS#################

//###############DELAY FUNCTIONS##################
void oneSecDelay(void);
void msDelay(unsigned char delayInMs);
void timer6Setup(unsigned char delayInMs);
void timer1setup();
//###############DELAY FUNCTIONS##################

#endif