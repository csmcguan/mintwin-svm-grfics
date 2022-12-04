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
    data = pd.read_csv("log.csv")
    plt.cla()
    plt.plot(data["time"], data["prod_ps"], label="Product Pos")
    plt.plot(data["time"], data["prod_flw"], label="Product Flow")
    plt.xlabel("Time")
    plt.ylabel("Values")
    plt.title("Data")
    plt.gcf().autofmt_xdate()
    plt.tight_layout()
    plt.legend()

ani = FuncAnimation(plt.gcf(), animate, 5000)

plt.tight_layout()
plt.show()
