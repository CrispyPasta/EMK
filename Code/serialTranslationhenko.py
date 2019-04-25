import serial 
import matplotlib.pyplot as plt 
import matplotlib.animation as animation
from matplotlib import style
import numpy as np

style.use('fivethirtyeight')

ser = serial.Serial(
    port='COM6', 
    baudrate = 9600, 
    bytesize=serial.EIGHTBITS, 
    parity=serial.PARITY_NONE,
    timeout=2
    )

data = []
a = 0

try:
   ser.isOpen()
   print("Serial port is open")
except:
   print("ERROR")
   exit()
 

if(ser.isOpen()):
    try: 
        while( True) :
            line = ser.read()
            voltage = 5 * line[0] / 255.0
            data.append(voltage)
            print(data)
            # print(voltage)
            # print(ser.read())
            # a =+ 1
            # print(data)
    except:
        print("error")
else:
    print("Cannot open serial port")

# fig = plt.figure()
# ax1 = fig.add_subplot(1,1,1)

# def animate(i):
#     graph_data = open('example.txt','r').read()
#     lines = graph_data.split('\n')
#     xs = []
#     ys = []
#     for line in lines:
#         if len(line) > 1:
#             x, y = line.split(',')
#             xs.append(x)    
#             ys.append(y)

# ax1.plot(xs, ys)

# ani = animation.FuncAnimation(fig, animate, interval = 1000)
# plt.show()