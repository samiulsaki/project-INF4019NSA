#!/usr/bin/python

import os
import random
import urllib
import subprocess
import re
from collections import Counter

os.system('clear')
import csv
import datetime
import numpy as np
import pylab as pl
import matplotlib.pyplot as plt
import datetime as dt
import matplotlib.dates as mdates
import matplotlib
from datetime import datetime 

data = open("/Users/samiulsaki/Desktop/data.csv","r")
temp = []
lines = data.readlines()
for i in lines:
  temp.append(i.rstrip().split(','))
x = []
x1 = []
y1 = []
y2 = []
y3 = []
y4 = []
y5 = []
n = 30 # mins
for i in temp[-(int(n)*12):]:
  dt = datetime.fromtimestamp(int(i[0]) // 1000000000)
  time = dt.strftime('%Y-%m-%d %H:%M:%S')
  
  x1.append(dt)
  y1.append(i[1])
  y2.append(i[2])
  y3.append(i[3])
  y4.append(i[4])
  y5.append((int(i[5])*100))

#converted_dates = matplotlib.dates.datestr2num(x)
#x1 = (converted_dates)


pl.plot(x1, y1, 'g')
pl.plot(x1, y2, 'b')
pl.plot(x1, y3, 'c')
pl.plot(x1, y4, 'y')
pl.plot(x1, y5, 'rx')
# give plot a title 
pl.title('Time vs Connection Status (Last %s mins)' % n )


# make axis labels
pl.xlabel('Time')
pl.ylabel('Connection Rate')
pl.legend(['Curr. Conn.', 'Max. Conn.', 'Curr. Conn. Rate', 'Curr. Conn. Rate Limit', 'Services'])

# set axis limits
pl.xlim(x1[0], x1[-1])
pl.ylim(0,15000) 
# show the plot on the screen
pl.show()