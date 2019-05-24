#ifndef FUNCTIONS_H
#define FUNCTIONS_H

void setupSerial();
void trans(unsigned char s);
void setupADC();
void setADCChannel(unsigned char channel);
unsigned char readADC();
unsigned char aveSensor(unsigned char s);
void setupPWMLeft(unsigned char dutyCycle, unsigned char direction);
void setupPWMRight(unsigned char dutyCycle, unsigned char direction);
void setupTimer2(unsigned char PR2Value);
void clearPorts(void);
void setupOSC();
void calibrate();
void ranges();
void twoSecondDelay();
void error(void);
void PRC();

#endif