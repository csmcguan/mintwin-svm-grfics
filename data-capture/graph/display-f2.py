import random
from itertools import count
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

plt.style.use("fivethirtyeight")

x_values = []
y_values = []

index = count()

def animate(i):
    plt.cla()
    data = pd.read_csv("log.csv")
    plt.plot(data["time"], data["f2_ps"], label="F2 Pos")
    plt.plot(data["time"], data["f2_flw"], label="F2 Flow")
    plt.ylim(ymin=-1)
    plt.xlabel("Time")
    plt.ylabel("Values")
    plt.title("Data")
    plt.gcf().autofmt_xdate()
    plt.tight_layout()
    plt.legend()

ani = FuncAnimation(plt.gcf(), animate, 5000)

plt.tight_layout()
plt.show()
