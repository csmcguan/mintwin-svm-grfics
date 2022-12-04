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
    true = pd.read_csv("./util/monitor-true.csv")
    pred = pd.read_csv("./util/monitor-pred.csv")
    plt.cla()
    plt.plot(true["time"], true["actual"], label="Actual")
    plt.plot(pred["time"], pred["prediction"], label="Prediction")
    plt.xlabel("Time")
    plt.ylabel("State")
    plt.title("Prediction Accuracy")
    plt.gcf().autofmt_xdate()
    plt.tight_layout()
    plt.legend()
    plt.ylim([-0.25, 1.25])
    plt.yticks([0, 1])

ani = FuncAnimation(plt.gcf(), animate, 5000)

plt.tight_layout()
plt.show()
