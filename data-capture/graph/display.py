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
    data = pd.read_csv("monitor.csv")
    plt.cla()
    plt.plot(data["time"], data["f1_ps"], label="F1 Pos")
    plt.plot(data["time"], data["f1_flw"], label="F1 Flow")
    plt.plot(data["time"], data["f2_ps"], label="F2 Pos")
    plt.plot(data["time"], data["f2_flw"], label="F2 Flow")
    plt.plot(data["time"], data["purge_ps"], label="Purge Pos")
    plt.plot(data["time"], data["purge_flw"], label="Purge Flow")
    plt.plot(data["time"], data["prod_ps"], label="Product Pos")
    plt.plot(data["time"], data["prod_flw"], label="Product Flow")
    plt.plot(data["time"], data["press"], label="Pressure")
    plt.plot(data["time"], data["lvl"], label="Level")
    plt.plot(data["time"], data["a_purge"], label="A in Purge")
    plt.plot(data["time"], data["b_purge"], label="B in Purge")
    plt.plot(data["time"], data["c_purge"], label="C in Purge")
    plt.xlabel("Time")
    plt.ylabel("Values")
    plt.title("Data")
    plt.gcf().autofmt_xdate()
    plt.tight_layout()
    plt.legend()

ani = FuncAnimation(plt.gcf(), animate, 5000)

plt.tight_layout()
plt.show()
