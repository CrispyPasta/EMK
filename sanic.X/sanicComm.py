import serial 
import matplotlib.pyplot as plt 
import matplotlib.animation as animation
import matplotlib.legend as lgnd 
from matplotlib import style
import numpy as np
import csv

calibrationComplete = False
ser = serial.Serial()
data = [[], [], [], [], []]
pos = 0

def setupSerial(baud):
    ser.baudrate = baud
    ser.bytesize = 8
    ser.port = 'COM10' 
    ser.parity = 'N'
    ser.stopbits = 1
    ser.timeout = None
    ser.open()
    print("COM Port Now Open:")
    print("Baudrate: " + str(baud))
    print("Bits per transmission: 8")
    print("Stop bits: 1")
    print("Parity: None\n")
    

#\OwO/
sensors = [0,1,2,3,4]
ranges  = []
#LL L M R RR
calValues = [[], [], [], [], []]
def animate(i):
    global calibrationComplete
    global data
    global pos
    global fig
    sensors
    points = 0
    while ser.is_open and points < 25:
        line = ser.readline()
        line = str(line)
        if (line == '\OwO/\n'):     #stop string for the python plotting
            calibrationComplete = True
            print("end sequence")
            plt.close()
            return
        elif (len(line) ==26):     #this should be the calibration values
            # print(" \tLL\tL\tM\tR\tRR")
            # colors = ["W", "G", "B", "R", "K"]
            for a in range(0, 5):
                # print colors[a] + "\t",
                for b in range(0, 5):
                    # print str(ord(line[a + 5 * b])) + "\t",
                    calValues[b].append(ord(line[a + 5 * b]))
                # print("\n")
            
            # print(calValues)

                #now just store all this shit in an array and plot it 
            continue

        for a in range(0,5):
            try:
                voltage = ord(line[a])
                data[a].append(voltage)
            except:
                try:
                    data[a].append(data[a][len(data[a]) - 1])
                except:
                    data[a].append(0)  # append prev voltage if too few bits
                    
        points += 1

    if len(data[0]) % 25 == 0 and len(data[0]) >= 1000:
        data = [data[0][25:], data[1][25:], data[2]
                [25:], data[3][25:], data[4][25:]]

    ax1.clear()
    labels = ['RR', 'R', 'M', 'L', 'LL']
    cols = ['c', 'g', 'b', 'r', 'k']
    calVals = np.array(calValues, dtype=np.float)

    for a in sensors:
        ax1.plot(data[a], label= labels[a])
        for b in (ranges):
            ax1.hlines(y = calVals[b], xmin = 0, xmax = 2000, color = cols, linestyle = '--' , alpha = 0.1)
        ax1.legend()
    # ax1.plot(data[0][2000 * pos:])
    # ax1.plot(data[1][2000 * pos:])
    # ax1.plot(data[2][2000 * pos:]) 
    # ax1.plot(data[3][2000 * pos:])
    # ax1.plot(data[4][2000 * pos:])

    return 

def pythonCalibration():
    global calibrationComplete
    if calibrationComplete == False:
        ani = animation.FuncAnimation(fig, animate, interval = 250)
        if calibrationComplete == True:
            plt.close()
            return
        plt.show()
    else:
        plt.close()
        return


style.use('fast')
fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)
setupSerial(9600)

command = ""        #command is die command wat ons vir die marv stuur
while command != "exit":
    marv = ser.readline()       #marv is die string wat ons by hom terug kry
    print ((marv)),
    print (">>>"),
    command = (str(raw_input()))
    # command = str(input())
    ser.write(command.encode())
    if (command == "QCL"):
        pythonCalibration() #call die plot
        calibrationComplete = False

ser.close()     #close die com port connection
#dumpData(data, 'dataDump.csv')
#dumpData(backupData, 'backupdata.csv')

