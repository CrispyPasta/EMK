import serial 
import matplotlib.pyplot as plt 
import matplotlib.animation as animation
from matplotlib import style
import numpy as np

style.use('fivethirtyeight')

fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)

data = [101,2,
2,3,
3,6,
4,9,
5,4,
6,7,
7,7,
8,4,
9,3,
10,1,
11,6,
12,8,
13,3,
14,9,
15,10,
16,12,
17,7,
18,3,
19,5,
20,12,
21,11,
22,15,
23,17,
24,10,
25,20,
26,25,
27,50,
28,19]

xs = []
ys = []   


def animate(i):
    graph_data = data[0]
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