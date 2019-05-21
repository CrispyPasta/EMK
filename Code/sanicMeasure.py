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
# backupData = []

# def dumpData(d, fname):
#     global data

#     d = np.array(data, dtype = float)
#     d = d.transpose()
#     dataFile = open(fname, 'wb')
#     with dataFile:
#         writer = csv.writer(dataFile)
#         writer.writerows(d)

def setupSerial(baud):
    ser.baudrate = baud
    ser.bytesize = 8
    ser.port = 'COM15' 
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
sensors = [2]
def animate(i):
    global calibrationComplete
    global data
    global pos
    global fig
    sensors
    points = 0
    while ser.is_open and points < 50:
        line = ser.readline()
        # backupData.append(line)
        line = str(line)
        for a in range(0,5):
            #for b in range(0, 8):
            #    line = ser.readline()
            #    voltages += 5 * ord(line[a]) / 255.0

            try:
                voltage = 5 * ord(line[a]) / 255.0
                data[a].append(voltage)
            except:
                try:
                    data[a].append(data[a][len(data[a]) - 1])
                except:
                    data[a].append(0)  # append prev voltage if too few bits
        points += 1

    if len(data[0]) % 50 == 0 and len(data[0]) >= 2000:
        data = [data[0][50:],data[1][50:],data[2][50:],data[3][50:],data[4][50:]]
        # pos += 1

    ax1.clear()
    labels = ['RR', 'R', 'M', 'L', 'LL']
    for a in sensors:
        ax1.plot(data[a], label= labels[a])
        ax1.legend()
    # ax1.plot(data[0][2000 * pos:])
    # ax1.plot(data[1][2000 * pos:])
    # ax1.plot(data[2][2000 * pos:]) 
    # ax1.plot(data[3][2000 * pos:])
    # ax1.plot(data[4][2000 * pos:])

    return 

style.use('fast')
fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)
setupSerial(9600)

ani = animation.FuncAnimation(fig, animate, interval=510)
plt.show()
ser.close()     #close die com port connection
