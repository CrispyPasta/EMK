import serial 
import matplotlib.pyplot as plt 
import matplotlib.animation as animation
from matplotlib import style
import numpy as np

ser = serial.Serial()

def setupSerial(baud):
    ser.baudrate = baud
    ser.bytesize = 8
    ser.port = 'COM9' 
    ser.parity = 'N'
    ser.stopbits = 1
    ser.timeout = None
    ser.open()

data = [[],[],[],[],[]]
def animate(i):
    global data
    if len(data[0]) > 3000:
        data[0] = data[0][1000:]
    points = 0
    while ser.is_open and points < 50:
        line = ser.readline()
        voltage = 5 * ord(line[0]) / 255.0
        data[0].append(voltage)
	points += 1
    ax1.clear()
    ax1.plot(data[0])
    return 
style.use('fast')
fig = plt.figure()

ax1 = fig.add_subplot(1,1,1)
setupSerial(19600)
plt.ylabel("Voltage")
ani = animation.FuncAnimation(fig, animate, interval = 500)
plt.show()
ser.close()

