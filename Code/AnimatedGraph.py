import serial 
import matplotlib.pyplot as plt 
import matplotlib.animation as animation
from matplotlib import style
import numpy as np

style.use('fivethirtyeight')

fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)

ys = []   


def animate(i):
    graph_data = data
    lines = graph_data.split(',')
    for line in lines:
        if len(line) > 1:
            x, y = line.split(',')
            xs.append(x)    
            ys.append(y)

ax1.clear()
ax1.plot(xs, ys)

ani = animation.FuncAnimation(fig, animate, interval = 1000)
plt.show()