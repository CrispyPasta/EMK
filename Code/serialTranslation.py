import serial 

data = ['X']
ser = serial.Serial()
ser.baudrate = 19200
ser.bytesize = 8
ser.port = 'COM9' 
ser.parity = 'N'
ser.stopbits = 1
ser.timeout = None
ser.open()
dataPoints = 0
while ser.is_open:
    line = ser.readline()
    print(line[0])
    data.append(line[0])
    dataPoints += 1

ser.close()
print(data)

