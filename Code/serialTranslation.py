import serial 
import matplotlib.pyplot as plt 
import matplotlib.animation as animation
from matplotlib import style
import numpy as np
import csv

ser = serial.Serial()
data = [[], [], [], [], []]
pos = 0

def dumpData(d, fname):
    global data

    d = np.array(data, dtype = float)
    d = d.transpose()
    dataFile = open(fname, 'wb')
    with dataFile:
        writer = csv.writer(dataFile)
        writer.writerows(d)

def setupSerial(baud):
    ser.baudrate = baud
    ser.bytesize = 8
    ser.port = 'COM10' 
    ser.parity = 'N'
    ser.stopbits = 1
    ser.timeout = None
    ser.open()


def animate(i):
    global data
    global pos
    points = 0
    while ser.is_open and points < 30:
        line = ser.readline()
        for a in range(0, 5):
            try:
                voltage = 5 * ord(line[a]) / 255.0
                data[a].append(voltage)
            except:
                data[a].append(0) #append prev voltage if too few bits
        points += 1

    if len(data[0]) % 2000 == 0:
        #data[0] = data[0][1000:]
        #data[1] = data[1][1000:]
        #data[2] = data[2][1000:]
        #data[3] = data[3][1000:]
        #data[4] = data[4][1000:]
        pos += 1

    ax1.clear()
    ax1.plot(data[0][2000 * pos:])
    ax1.plot(data[1][2000 * pos:])
    ax1.plot(data[2][2000 * pos:])
    ax1.plot(data[3][2000 * pos:])
    ax1.plot(data[4][2000 * pos:])


    return 
style.use('fast')
fig = plt.figure()

ax1 = fig.add_subplot(1,1,1)
setupSerial(19600)
plt.ylabel("Voltage")
ani = animation.FuncAnimation(fig, animate, interval = 310)
plt.show()
dumpData(data, 'dataDump.csv')
ser.close()

